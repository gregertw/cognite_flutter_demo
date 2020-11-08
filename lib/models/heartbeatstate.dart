import 'package:flutter/material.dart';
import 'package:cognite_dart_sdk/cognite_dart_sdk.dart';

class HeartBeatModel with ChangeNotifier {
  CDFApiClient apiClient;
  String tsId;
  int startDays;
  DatapointsModel _dataPoints = DatapointsModel();
  DatapointsFilterModel _filter = DatapointsFilterModel();
  int _activeLayer = 0;
  int _rangeStart = 0;
  int _rangeEnd = 0;
  bool _loading;

  get rangeStart => _rangeStart;
  get rangeEnd => _rangeEnd;
  get loading => _loading;

  HeartBeatModel(this.apiClient, this.tsId, this.startDays) {
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

  // Defaults include min, max, average, and count for the last nrOfDays days
  void setFilter(
      {int start,
      int end,
      int resolution,
      int nrOfDays,
      List<String> aggregates,
      bool includeOutsidePoints: false}) {
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
    if (resolution == null) {
      _filter.resolution = ((_filter.end - _filter.start) / 480000).round();
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

  List<DatapointModel> get timeSeriesDataPoints {
    if (_dataPoints != null) {
      return _dataPoints.layer(layer: _activeLayer);
    }
    return [];
  }

  bool zoomOut() {
    if (_activeLayer > 1) {
      _dataPoints.popLayer();
      _activeLayer -= 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  void loadTimeSeries() {
    print(_filter.toString());
    if (_loading) {
      print("Already loading new timeseries, skipping...");
      return;
    }
    _loading = true;
    this.apiClient.getDatapoints(_filter).then((res) {
      if (res != null && res.datapoints.isNotEmpty) {
        print("New datapoints: ${res.datapointsLength}");
        this._dataPoints.addDatapoints(res);
        _activeLayer += 1;
        _loading = false;
        notifyListeners();
      }
    });
    notifyListeners();
  }
}
