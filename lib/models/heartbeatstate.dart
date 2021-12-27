import 'package:flutter/material.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:cognite_flutter_demo/globals.dart';

/// Keeps timeseries data state
class HeartBeatModel with ChangeNotifier {
  CDFApiClient apiClient;
  String tsId;
  int startDays;
  int resolutionFactor;
  final DatapointsModel _dataPoints = DatapointsModel();
  final DatapointsModel _rawDataPoints = DatapointsModel();
  final DatapointsFilterModel _filter = DatapointsFilterModel();
  int _activeLayer = 0;
  int _activeRawLayer = 0;
  int _rangeStart = 0;
  int _rangeEnd = 0;
  bool? _loading;

  get rangeStart => _rangeStart;
  get rangeEnd => _rangeEnd;
  get loading => _loading ?? false;

  HeartBeatModel(
      this.apiClient, this.tsId, this.startDays, this.resolutionFactor) {
    _loading = false;
    _filter.externalId = tsId;
    setFilter(nrOfDays: startDays);
    loadTimeSeries();
  }

  set timeSeries(String id) {
    tsId = id;
    _filter.externalId = tsId;
  }

  int get filterStart => _filter.start;
  int get filterEnd => _filter.end;
  int get resolution => _filter.resolution;
  int get activeLayer => _activeLayer;

  /// Defaults include all aggregations for the last nrOfDays days.
  ///[
  ///      "average",
  ///      "max",
  ///      "min",
  ///      "count",
  ///      "sum",
  ///      "interpolation",
  ///      "stepInterpolation",
  ///      "totalVariation",
  ///      "continuousVariance",
  ///      "discreteVariance"
  ///    ]
  ///
  /// NOTE! includeOutsidePoints is not supported for aggregates!
  void setFilter(
      {int? start,
      int? end,
      int? resolution,
      int? nrOfDays,
      List<String>? aggregates,
      bool includeOutsidePoints = false}) {
    _filter.includeOutsidePoints = includeOutsidePoints;
    if (end == null) {
      _filter.end = DateTime.now().millisecondsSinceEpoch;
    } else {
      _filter.end = end;
    }
    if (start == null) {
      if (nrOfDays == null || nrOfDays < 1) {
        nrOfDays = 10;
      }
      // nrOfDays days
      _filter.start = _filter.end - (1000 * 60 * 60 * 24 * nrOfDays);
    } else {
      _filter.start = start;
    }
    if (_filter.start >= _filter.end) {
      _filter.end = _filter.start + 1000;
    }
    if (aggregates == null) {
      _filter.aggregates = [
        "average",
        "max",
        "min",
        "count",
        "sum",
        "interpolation",
        "stepInterpolation",
        "totalVariation",
        "continuousVariance",
        "discreteVariance"
      ];
    } else {
      _filter.aggregates = aggregates;
    }
    if (_filter.aggregates.isNotEmpty) {
      _filter.includeOutsidePoints = false;
    }
    if (resolution == null) {
      _filter.resolution =
          ((_filter.end - _filter.start) / resolutionFactor).round();
    } else {
      _filter.resolution = resolution;
    }
    // Set the initial range before layering
    if (_rangeStart == 0) {
      _rangeStart = _filter.start;
    }
    if (_rangeEnd == 0) {
      _rangeEnd = _filter.end;
    }
  }

  /// Returns the last active layer of aggregates
  List<DatapointModel> get timeSeriesAggregates {
    if (_dataPoints.datapointsLength != 0) {
      return _dataPoints.layer(layer: _activeLayer);
    }
    return [];
  }

  /// Returns the first full range layer of aggregates.
  List<DatapointModel> get timeSeriesFullRangeAggregates {
    if (_dataPoints.datapointsLength != 0) {
      return _dataPoints.layer(layer: 1);
    }
    return [];
  }

  /// Returns the last layer of datapoints, note that only value is set!!!
  List<DatapointModel> get timeSeriesDataPoints {
    if (_rawDataPoints.datapointsLength != 0) {
      return _rawDataPoints.layer(layer: _activeRawLayer);
    }
    return [];
  }

  /// Returns the first full range layer of raw datapoints.
  List<DatapointModel> get timeSeriesFullRangeDataPoints {
    if (_rawDataPoints.datapointsLength != 0) {
      return _rawDataPoints.layer(layer: 1);
    }
    return [];
  }

  /// Deletes the last active layer
  bool zoomOut() {
    if (_activeLayer > 1) {
      _dataPoints.popLayer();
      _activeLayer -= 1;
      if (_activeRawLayer > 0) {
        _rawDataPoints.popLayer();
        _activeRawLayer -= 1;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Given the last [setFilter], load aggregates and raw datapoints.
  void loadTimeSeries({bool raw = false}) async {
    log.d(_filter.toString());
    if (_loading!) {
      log.d("Already loading new timeseries, skipping...");
      return;
    }
    _loading = true;
    try {
      var aggregates = await TimeSeriesAPI(apiClient).getDatapoints(_filter);
      if (aggregates.datapointsLength != 0 &&
          aggregates.datapoints.isNotEmpty) {
        log.d("New datapoints: ${aggregates.datapointsLength}");
        _dataPoints.addDatapoints(aggregates);
        _activeLayer += 1;
      }
      if (raw) {
        // Limit number of raw datapoints to 10 per second
        _filter.limit = ((_filter.end - _filter.start) / 100).round();
        log.d(_filter.toString());
        var rawDPs =
            await TimeSeriesAPI(apiClient).getDatapoints(_filter, raw: true);
        if (rawDPs.datapointsLength != 0 && rawDPs.datapoints.isNotEmpty) {
          log.d("New raw datapoints: ${rawDPs.datapointsLength}");
          _rawDataPoints.addDatapoints(rawDPs);
          _activeRawLayer += 1;
        }
      }
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
    }
  }
}
