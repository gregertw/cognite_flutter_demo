import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:first_app/models/heartbeatstate.dart';
import 'package:first_app/models/appstate.dart';
import 'package:cognite_dart_sdk/cognite_dart_sdk.dart';
import 'package:first_app/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:first_app/ui/pages/home/drawer.dart';

// Fully zoomed out is 1.0
double _zoomFactor = 1.0;
// X-position of y-axis
double _zoomPosition = 0.0;

ZoomPanBehavior _zoomPan = ZoomPanBehavior(
    zoomMode: ZoomMode.x,
    maximumZoomLevel: 0.1,
    enableDoubleTapZooming: true,
    enableMouseWheelZooming: true,
    enablePanning: true,
    enablePinching: true,
    selectionRectBorderColor: Colors.red,
    selectionRectBorderWidth: 1,
    selectionRectColor: Colors.grey);

void loadOnZoomIn(HeartBeatModel hbm) {
  var range = hbm.rangeEnd - hbm.rangeStart;
  var newStart = hbm.rangeStart + (range * _zoomPosition).round();
  var newEnd = newStart + (range * _zoomFactor).round();
  var newResolution = ((newEnd - newStart) * _zoomFactor / 230000).round();
  print("Range: $range, start: $newStart, end: $newEnd");
  hbm.setFilter(start: newStart, end: newEnd, resolution: newResolution);
  hbm.loadTimeSeries();
}

class ChartFeatureModel with ChangeNotifier {
  // Chart functions
  bool showMarker;
  bool showToolTip;
  String dateAxisFormat;
  bool dateFormatDetailed;

  toggleMarker() {
    showMarker = !showMarker;
    notifyListeners();
  }

  toggleToolTip() {
    showToolTip = !showToolTip;
    notifyListeners();
  }

  setDateAxisFormat(String s) {
    dateAxisFormat = s;
    notifyListeners();
  }

  toggleDateAxisFormat() {
    if (dateFormatDetailed) {
      dateFormatDetailed = false;
      dateAxisFormat = 'MMM dd HH:mm';
    } else {
      dateFormatDetailed = true;
      dateAxisFormat = 'HH:mm:ss';
    }
    notifyListeners();
  }

  ChartFeatureModel() {
    showMarker = false;
    showToolTip = true;
    dateFormatDetailed = false;
    dateAxisFormat = 'MMM dd HH:mm';
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
        floatingActionButton: ZoomButtons(),
        body: TimeSeriesChart(),
        drawer: HomePageDrawer(),
      ),
    );
  }
}

class CheckBoxButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chart = Provider.of<ChartFeatureModel>(context);
    var hbm = Provider.of<HeartBeatModel>(context);
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
                    Row(
                      children: <Widget>[
                        Text('Time details'),
                        Checkbox(
                          value: chart.dateFormatDetailed,
                          activeColor:
                              Theme.of(context).toggleButtonsTheme.focusColor,
                          hoverColor:
                              Theme.of(context).toggleButtonsTheme.hoverColor,
                          checkColor: Theme.of(context)
                              .toggleButtonsTheme
                              .selectedColor,
                          onChanged: (newVal) {
                            chart.toggleDateAxisFormat();
                          },
                        ),
                      ],
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

class ZoomButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              child: InkWell(
                key: Key('HomePage_ButtonsInkWell'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 15, 0, 0),
                      child: Tooltip(
                        message: 'Zoom In',
                        child: IconButton(
                          icon: Icon(Icons.add,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomFactor -= 0.05;
                            if (_zoomFactor >= 0.05) {
                              loadOnZoomIn(hbm);
                              _zoomPan.zoomIn();
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Zoom Out',
                        child: IconButton(
                          icon: Icon(Icons.remove,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomFactor += 0.05;
                            hbm.zoomOut();
                            _zoomPan.zoomOut();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Pan Up',
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_up,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomPan.panToDirection('top');
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Pan Down',
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomPan.panToDirection('bottom');
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Pan Left',
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_left,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomPan.panToDirection('left');
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Pan Right',
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_right,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            _zoomPan.panToDirection('right');
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Tooltip(
                        message: 'Reset',
                        child: IconButton(
                          icon: Icon(Icons.refresh,
                              color: Theme.of(context).accentColor),
                          onPressed: () {
                            while (hbm.zoomOut()) {}
                            _zoomPan.reset();
                          },
                        ),
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

class TimeSeriesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    var chart = Provider.of<ChartFeatureModel>(context);
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
              primaryXAxis:
                  DateTimeAxis(dateFormat: DateFormat(chart.dateAxisFormat)),
              primaryYAxis: NumericAxis(anchorRangeToVisiblePoints: true),
              onZoomEnd: (ZoomPanArgs args) {
                if (args.axis is DateTimeAxis) {
                  _zoomFactor = args.currentZoomFactor;
                  _zoomPosition = args.currentZoomPosition;
                  if (_zoomFactor > args.previousZoomFactor) {
                    hbm.zoomOut();
                  } else if (_zoomFactor < args.previousZoomFactor) {
                    loadOnZoomIn(hbm);
                  }
                }
              },
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              tooltipBehavior: TooltipBehavior(
                  enable: chart.showToolTip,
                  shared: true,
                  opacity: 0.4,
                  format: 'point.y',
                  tooltipPosition: TooltipPosition.pointer),
              zoomPanBehavior: _zoomPan,
              series: <CartesianSeries>[
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
          ],
        ),
      ),
    );
  }
}
