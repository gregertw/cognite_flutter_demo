import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';

class ChartFeatureModel with ChangeNotifier {
  // Chart functions
  bool showMarker;
  bool showToolTip;
  String _dateAxisFormat;
  int startRange = 0;
  int endRange = 0;
  int _startSpan = 0;
  int _endSpan = 0;
  int resolution;
  int resolutionFactor;
  get startRangeDate => DateTime.fromMillisecondsSinceEpoch(startRange);
  get endRangeDate => DateTime.fromMillisecondsSinceEpoch(endRange);
  get dateAxisFormat => _dateAxisFormat;

  RangeController _rangeController;

  RangeController get rangeController => _rangeController;
  get startSpan => _startSpan;
  get endSpan => _endSpan;

  ChartFeatureModel(this.resolutionFactor) {
    showMarker = false;
    showToolTip = true;
    _dateAxisFormat = 'MMM dd HH:mm';
  }

// Will update the rangecontroller to the current start and stop
  void applyRangeController() {
    _rangeController.start = startRangeDate;
    _rangeController.end = endRangeDate;
    notifyListeners();
  }

  // Set to empty string to reset to dynamic setting
  void setDateAxisFormat({String format}) {
    if (format != null) {
      _dateAxisFormat = format;
      return;
    }
    if (_dateAxisFormat != 'HH:mm:ss' && _dateAxisFormat != 'MMM dd HH:mm') {
      // Don't set dynamically as it has been explicitly set
      return;
    }
    if ((endRange - startRange) <= (1000 * 60 * 60 * 24)) {
      _dateAxisFormat = 'HH:mm:ss';
    } else {
      _dateAxisFormat = 'MMM dd HH:mm';
    }
  }

  void initRange(int start, int end, {int startSpan, int endSpan}) {
    if (startRange == 0 || endRange == 0) {
      setNewRange(start: start, end: end);
      _startSpan = startSpan;
      _endSpan = endSpan;
    }
  }

  void setNewRange({int start, int end, double zoom: 0.0, double pan: 0.0}) {
    if (zoom != 0.0) {
      var range = (endRange - startRange) / 2;
      startRange = startRange + (range * zoom).round();
      endRange = endRange - (range * zoom).round();
    } else if (pan != 0.0) {
      var range = (endRange - startRange) / 2;
      startRange = startRange + (range * pan).round();
      endRange = endRange + (range * pan).round();
      // Don't go outside range controller min and max range
      if (startRange < _startSpan) {
        startRange = _startSpan;
      } else if (endRange > _endSpan) {
        endRange = _endSpan;
      }
    } else {
      startRange = start;
      endRange = end;
    }
    resolution = ((endRange - startRange) / resolutionFactor).round();
    setDateAxisFormat();
    if (_rangeController == null) {
      _rangeController =
          RangeController(start: startRangeDate, end: endRangeDate);
      return;
    }
    notifyListeners();
  }

  // Helper to set a range with DateTime values instead of millisecondsSinceEpoch
  void setNewDateRange(DateTime start, DateTime end) {
    DateTime startDate = start;
    DateTime endDate = end;
    setNewRange(
        start: startDate.millisecondsSinceEpoch,
        end: endDate.millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    rangeController.dispose();
    super.dispose();
  }

  toggleMarker() {
    showMarker = !showMarker;
    notifyListeners();
  }

  toggleToolTip() {
    showToolTip = !showToolTip;
    notifyListeners();
  }
}
