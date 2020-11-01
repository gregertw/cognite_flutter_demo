import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:first_app/models/heartbeatstate.dart';
import 'package:cognite_dart_sdk/cognite_dart_sdk.dart';
import 'package:intl/intl.dart';

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

class ZoomButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              child: InkWell(
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
                            _zoomPan.zoomIn();
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
    return SfCartesianChart(
      // Initialize category axis
      primaryXAxis: DateTimeAxis(dateFormat: DateFormat('MMM dd HH:mm')),
      primaryYAxis: NumericAxis(anchorRangeToVisiblePoints: true),
      onZoomEnd: (ZoomPanArgs args) {
        if (args.axis is DateTimeAxis) {
          var hbm = Provider.of<HeartBeatModel>(context, listen: false);
          var rangeStart = hbm.rangeStart;
          var rangeEnd = hbm.rangeEnd;
          var range = rangeEnd - rangeStart;
          if (args.currentZoomFactor > args.previousZoomFactor) {
            hbm.zoomOut();
          } else if (args.currentZoomFactor < args.previousZoomFactor) {
            var newStart =
                rangeStart + (range * args.currentZoomPosition).round();
            var newEnd = newStart + (range * args.currentZoomFactor).round();
            var newResolution =
                ((newEnd - newStart) * args.currentZoomFactor / 230000).round();
            print("Range: $range, start: $newStart, end: $newEnd");
            hbm.setFilter(
                start: newStart, end: newEnd, resolution: newResolution);
            hbm.loadTimeSeries();
          }
        }
      },
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      trackballBehavior: TrackballBehavior(
          // Enables the trackball
          enable: true,
          tooltipSettings: InteractiveTooltip(
              enable: true, color: Colors.red, format: 'point.x - point.y')),
      zoomPanBehavior: _zoomPan,
      series: <CartesianSeries>[
        LineSeries<DatapointModel, DateTime>(
            name: "Maximum",
            dataSource:
                Provider.of<HeartBeatModel>(context).timeSeriesDataPoints,
            xValueMapper: (DatapointModel ts, _) => ts.datetime,
            yValueMapper: (DatapointModel ts, _) => ts.max,
            animationDuration: 1000),
        LineSeries<DatapointModel, DateTime>(
            name: "Minimum",
            dataSource:
                Provider.of<HeartBeatModel>(context).timeSeriesDataPoints,
            xValueMapper: (DatapointModel ts, _) => ts.datetime,
            yValueMapper: (DatapointModel ts, _) => ts.min,
            animationDuration: 1000)
      ],
    );
  }
}
