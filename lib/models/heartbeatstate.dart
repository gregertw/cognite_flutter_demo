import 'package:flutter/material.dart';
import 'package:cognite_dart_sdk/cognite_dart_sdk.dart';

class HeartBeatModel with ChangeNotifier {
  CDFApiClient apiClient;
  String tsId;
  DatapointsModel _dataPoints = DatapointsModel();
  DatapointsFilterModel _filter = DatapointsFilterModel();
  int _activeLayer = 0;

  HeartBeatModel(this.apiClient, this.tsId) {
    _filter.externalId = tsId;
    setFilter();
    loadTimeSeries();
  }

  set timeSeries(String id) {
    tsId = id;
    _filter.externalId = tsId;
  }

  int get rangeStart => _filter.start;
  int get rangeEnd => _filter.end;
  int get resolution => _filter.resolution;
  int get activeLayer => _activeLayer;

  // Defaults include min, max, average, and count for the last 10 days
  // with 1 hour granularity and a limit of 240 resulting datapoints
  void setFilter(
      {int start,
      int end,
      int resolution,
      List<String> aggregates,
      bool includeOutsidePoints: false}) {
    if (end == null) {
      _filter.end = DateTime.now().millisecondsSinceEpoch;
    } else {
      _filter.end = end;
    }
    if (start == null) {
      // 10 days
      _filter.start = _filter.end - (1000 * 60 * 60 * 24 * 10);
    } else {
      _filter.start = start;
    }
    if (_filter.start >= _filter.end) {
      _filter.end = _filter.start + 1;
    }
    if (aggregates == null) {
      _filter.aggregates = ['min', 'max', 'average', 'count'];
    } else {
      _filter.aggregates = aggregates;
    }
    if (resolution == null) {
      _filter.resolution = ((_filter.end - _filter.start) / 480000).round();
    } else {
      _filter.resolution = resolution;
    }
  }

  List<DatapointModel> get timeSeriesDataPoints {
    if (_dataPoints != null) {
      return _dataPoints.layer(layer: _activeLayer);
    }
    return [];
  }

  void zoomOut() {
    if (_activeLayer > 1) {
      _dataPoints.popLayer();
      _activeLayer -= 1;
      notifyListeners();
    }
  }

  void loadTimeSeries() {
    print(_filter.toString());
    this.apiClient.getDatapoints(_filter).then((res) {
      if (res != null && res.datapoints.isNotEmpty) {
        print("New datapoints: ${res.datapointsLength}");
        this._dataPoints.addDatapoints(res);
        _activeLayer += 1;
        notifyListeners();
      }
    });
  }
}
