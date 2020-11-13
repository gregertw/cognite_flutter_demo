import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:first_app/models/heartbeatstate.dart';
import 'package:first_app/models/appstate.dart';
import 'package:cognite_dart_sdk/cognite_dart_sdk.dart';
import 'package:first_app/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:first_app/ui/pages/home/drawer.dart';

class ChartFeatureModel with ChangeNotifier {
  // Chart functions
  bool showMarker;
  bool showToolTip;
  String _dateAxisFormat;
  int startRange = 0;
  int endRange = 0;
  int resolution;
  get startRangeDate => DateTime.fromMillisecondsSinceEpoch(startRange);
  get endRangeDate => DateTime.fromMillisecondsSinceEpoch(endRange);
  get dateAxisFormat => _dateAxisFormat;

  RangeController _rangeController;

  RangeController get rangeController => _rangeController;

  ChartFeatureModel() {
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

  void initRange(int start, int end) {
    if (startRange == 0 || endRange == 0) {
      setNewRange(start: start, end: end);
    }
  }

  void setNewRange({int start, int end, double zoom: 0.0}) {
    if (zoom != 0.0) {
      var range = (endRange - startRange) / 2;
      startRange = startRange + (range * zoom).round();
      endRange = endRange - (range * zoom).round();
    } else {
      startRange = start;
      endRange = end;
    }
    if (rangeController == null) {
      _rangeController =
          RangeController(start: startRangeDate, end: endRangeDate);
    }
    resolution = ((endRange - startRange) / 230000).round();
    setDateAxisFormat();
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

class CheckBoxButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chart = Provider.of<ChartFeatureModel>(context);
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              child: InkWell(
                key: Key('HomePage_CheckBoxInkwell'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: hbm.loading,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 15, maxHeight: 15),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text('Tooltip'),
                        Checkbox(
                          value: chart.showToolTip,
                          activeColor:
                              Theme.of(context).toggleButtonsTheme.focusColor,
                          hoverColor:
                              Theme.of(context).toggleButtonsTheme.hoverColor,
                          checkColor: Theme.of(context)
                              .toggleButtonsTheme
                              .selectedColor,
                          onChanged: (newVal) {
                            chart.toggleToolTip();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Markers'),
                        Checkbox(
                          value: chart.showMarker,
                          activeColor:
                              Theme.of(context).toggleButtonsTheme.focusColor,
                          hoverColor:
                              Theme.of(context).toggleButtonsTheme.hoverColor,
                          checkColor: Theme.of(context)
                              .toggleButtonsTheme
                              .selectedColor,
                          onChanged: (newVal) {
                            chart.toggleMarker();
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text('Zoom In'),
                          IconButton(
                            icon: Icon(Icons.add,
                                color: Theme.of(context).accentColor),
                            onPressed: () {
                              chart.setNewRange(zoom: 0.4);
                              chart.applyRangeController();
                              hbm.setFilter(
                                  start: chart.startRange,
                                  end: chart.endRange,
                                  resolution: chart.resolution);
                              hbm.loadTimeSeries();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text('Zoom Out'),
                          IconButton(
                            icon: Icon(Icons.remove,
                                color: Theme.of(context).accentColor),
                            onPressed: () {
                              hbm.zoomOut();
                              chart.setNewRange(zoom: -0.4);
                              chart.applyRangeController();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Text('Reset'),
                          IconButton(
                            icon: Icon(Icons.refresh,
                                color: Theme.of(context).accentColor),
                            onPressed: () {
                              while (hbm.zoomOut()) {}
                              chart.setNewRange(
                                  start: (hbm.rangeStart +
                                          (hbm.rangeEnd - hbm.rangeStart) / 3)
                                      .round(),
                                  end: (hbm.rangeEnd -
                                          (hbm.rangeEnd - hbm.rangeStart) / 3)
                                      .round());
                              chart.applyRangeController();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSeriesHome extends StatelessWidget {
  const TimeSeriesHome({
    Key key,
    @required this.apiClient,
    @required this.appState,
  }) : super(key: key);

  final Object apiClient;
  final AppStateModel appState;

  @override
  Widget build(BuildContext context) {
    return new MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => HeartBeatModel(
                apiClient, appState.cdfTimeSeriesId, appState.cdfNrOfDays)),
        ChangeNotifierProvider(create: (_) => ChartFeatureModel())
      ],
      child: Scaffold(
        key: Key("HomePage_Scaffold"),
        appBar: AppBar(
          title: Text(S.of(context).appTitle),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: TimeSeriesChart(),
        drawer: HomePageDrawer(),
      ),
    );
  }
}

class TimeSeriesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    var chart = Provider.of<ChartFeatureModel>(context);
    // Initialise the range and controller
    chart.initRange(
        (hbm.rangeStart + (hbm.rangeEnd - hbm.rangeStart) / 3).round(),
        (hbm.rangeEnd - (hbm.rangeEnd - hbm.rangeStart) / 3).round());
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CheckBoxButtons(),
            SfCartesianChart(
              key: Key('HomePage_TimeSeriesChart'),
              // Initialize category axis
              primaryXAxis: DateTimeAxis(
                  isVisible: true,
                  rangeController: chart.rangeController,
                  dateFormat: DateFormat(chart.dateAxisFormat)),
              primaryYAxis: NumericAxis(
                  isVisible: true, anchorRangeToVisiblePoints: true),
              legend: Legend(isVisible: true, position: LegendPosition.top),
              tooltipBehavior: TooltipBehavior(
                  enable: chart.showToolTip,
                  shared: true,
                  opacity: 0.4,
                  format: 'point.y',
                  tooltipPosition: TooltipPosition.pointer),
              series: <CartesianSeries<DatapointModel, DateTime>>[
                LineSeries<DatapointModel, DateTime>(
                    name: "Maximum (on/off)",
                    width: 2,
                    markerSettings: MarkerSettings(
                        height: 3, width: 3, isVisible: chart.showMarker),
                    dataSource: Provider.of<HeartBeatModel>(context)
                        .timeSeriesDataPoints,
                    xValueMapper: (DatapointModel ts, _) => ts.datetime,
                    yValueMapper: (DatapointModel ts, _) => ts.max),
                LineSeries<DatapointModel, DateTime>(
                    name: "Minimum (on/off)",
                    width: 2,
                    markerSettings: MarkerSettings(
                        height: 3, width: 3, isVisible: chart.showMarker),
                    dataSource: Provider.of<HeartBeatModel>(context)
                        .timeSeriesDataPoints,
                    xValueMapper: (DatapointModel ts, _) => ts.datetime,
                    yValueMapper: (DatapointModel ts, _) => ts.min),
              ],
            ),
            Container(
              height: 120,
              child: Center(
                child: SfRangeSelector(
                  dateFormat: DateFormat.MMMd(),
                  dateIntervalType: DateIntervalType.days,
                  interval: 1,
                  min: DateTime.fromMillisecondsSinceEpoch(hbm.rangeStart),
                  max: DateTime.fromMillisecondsSinceEpoch(hbm.rangeEnd),
                  showTicks: true,
                  showLabels: true,
                  activeColor: Color.fromARGB(255, 5, 90, 194),
                  inactiveColor: Color.fromARGB(100, 5, 90, 194),
                  dragMode: SliderDragMode.both,
                  enableDeferredUpdate: true,
                  deferredUpdateDelay: 500,
                  controller: chart.rangeController,
                  onChanged: (SfRangeValues values) {
                    chart.setNewDateRange(values.start, values.end);
                    hbm.setFilter(
                        start: chart.startRange,
                        end: chart.endRange,
                        resolution: chart.resolution);
                    hbm.loadTimeSeries();
                  },
                  child: SfCartesianChart(
                    key: Key('HomePage_TimeSeriesChart_RangeSelector'),
                    margin: const EdgeInsets.all(0),
                    primaryXAxis: DateTimeAxis(isVisible: false),
                    primaryYAxis: NumericAxis(isVisible: false),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries<DatapointModel, DateTime>>[
                      LineSeries<DatapointModel, DateTime>(
                          dataSource: Provider.of<HeartBeatModel>(context)
                              .timeSeriesFullRangeDataPoints,
                          xValueMapper: (DatapointModel ts, _) => ts.datetime,
                          yValueMapper: (DatapointModel ts, _) => ts.max),
                      LineSeries<DatapointModel, DateTime>(
                          dataSource: Provider.of<HeartBeatModel>(context)
                              .timeSeriesFullRangeDataPoints,
                          xValueMapper: (DatapointModel ts, _) => ts.datetime,
                          yValueMapper: (DatapointModel ts, _) => ts.min),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
