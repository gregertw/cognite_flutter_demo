import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:cognite_cdf_demo/models/heartbeatstate.dart';
import 'package:cognite_cdf_demo/models/appstate.dart';
import 'package:cognite_cdf_demo/models/chartstate.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:cognite_cdf_demo/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:cognite_cdf_demo/ui/pages/home/drawer.dart';

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

class ReloadMarker extends StatelessWidget {
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
                key: Key('HomePage_ReloadInkwell'),
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
                    Row(
                      children: <Widget>[
                        Text(S.of(context).chartTooltip),
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
                        Text(S.of(context).chartMarkers),
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
                          IconButton(
                            tooltip: S.of(context).chartZoomIn,
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
                          IconButton(
                            tooltip: S.of(context).chartZoomOut,
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
                          IconButton(
                            tooltip: S.of(context).chartZoomOut,
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
            ReloadMarker(),
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
                    name: S.of(context).chartMaximum,
                    width: 2,
                    markerSettings: MarkerSettings(
                        height: 3, width: 3, isVisible: chart.showMarker),
                    dataSource: Provider.of<HeartBeatModel>(context)
                        .timeSeriesDataPoints,
                    xValueMapper: (DatapointModel ts, _) => ts.datetime,
                    yValueMapper: (DatapointModel ts, _) => ts.max),
                LineSeries<DatapointModel, DateTime>(
                    name: S.of(context).chartMinimum,
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
                  showTooltip: true,
                  showDivisors: true,
                  activeColor: Color.fromARGB(255, 5, 90, 194),
                  inactiveColor: Color.fromARGB(100, 5, 90, 194),
                  enableIntervalSelection: true,
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
            CheckBoxButtons(),
          ],
        ),
      ),
    );
  }
}
