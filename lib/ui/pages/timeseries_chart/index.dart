import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';
import 'package:cognite_flutter_demo/models/chartstate.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:intl/intl.dart';
import 'package:cognite_flutter_demo/ui/pages/timeseries_chart/reload.dart';
import 'package:cognite_flutter_demo/ui/pages/timeseries_chart/checkboxes.dart';

class TimeSeriesChart extends StatelessWidget {
  const TimeSeriesChart({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    var chart = Provider.of<ChartFeatureModel>(context);
    var zoomPan = ZoomPanBehavior(enableDoubleTapZooming: true);
    // Initialise the range and controller
    chart.initRange(
        (hbm.rangeStart + (hbm.rangeEnd - hbm.rangeStart) / 3).round(),
        (hbm.rangeEnd - (hbm.rangeEnd - hbm.rangeStart) / 3).round(),
        startSpan: hbm.rangeStart,
        endSpan: hbm.rangeEnd);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ReloadMarker(),
              SfCartesianChart(
                key: const Key('HomePage_TimeSeriesChart'),
                // Initialize category axis
                primaryXAxis: DateTimeAxis(
                    isVisible: true,
                    rangeController: chart.rangeController,
                    dateFormat: DateFormat(chart.dateAxisFormat)),
                primaryYAxis: NumericAxis(
                    isVisible: true, anchorRangeToVisiblePoints: true),
                zoomPanBehavior: zoomPan,
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    toggleSeriesVisibility: true,
                    overflowMode: LegendItemOverflowMode.wrap),
                tooltipBehavior: TooltipBehavior(
                    enable: chart.showToolTip,
                    shared: true,
                    opacity: 0.4,
                    format: 'point.y',
                    tooltipPosition: TooltipPosition.pointer),
                onZoomEnd: (ZoomPanArgs args) {
                  // Double-click zoom
                  if (args.axis is DateTimeAxis &&
                      args.currentZoomFactor < args.previousZoomFactor!) {
                    // We don't want to zoom in more than 11s
                    if ((chart.endRange! - chart.startRange!).round() > 11000) {
                      chart.setNewRange(zoom: 0.4);
                      chart.applyRangeController();
                      zoomPan.reset();
                      hbm.setFilter(
                          start: chart.startRange,
                          end: chart.endRange,
                          resolution: chart.resolution);
                      // Only load raw datapoints when we have a short range
                      if (((chart.endRange! - chart.startRange!) / 1000)
                              .round() <
                          3600) {
                        hbm.loadTimeSeries(raw: true);
                      } else {
                        hbm.loadTimeSeries();
                      }
                    }
                  }
                },
                series: <CartesianSeries<DatapointModel, DateTime>>[
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: true,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartRawValues,
                      width: 2,
                      markerSettings: const MarkerSettings(
                          height: 3, width: 3, isVisible: true),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesDataPoints,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.value),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: true,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartAverage,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.average),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartMaximum,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.max),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartMinimum,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.min),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name:
                          AppLocalizations.of(context)!.chartContinuousVariance,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) =>
                          ts.continuousVariance),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartDiscreteVariance,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) =>
                          ts.discreteVariance),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartCount,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.count),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartInterpolation,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.interpolation),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name:
                          AppLocalizations.of(context)!.chartStepInterpolation,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) =>
                          ts.stepInterpolation),
                  LineSeries<DatapointModel, DateTime>(
                      isVisible: false,
                      isVisibleInLegend: true,
                      name: AppLocalizations.of(context)!.chartTotalVariance,
                      width: 2,
                      markerSettings: MarkerSettings(
                          height: 3, width: 3, isVisible: chart.showMarker),
                      dataSource: Provider.of<HeartBeatModel>(context)
                          .timeSeriesAggregates,
                      xValueMapper: (DatapointModel ts, _) => ts.datetime,
                      yValueMapper: (DatapointModel ts, _) => ts.totalVariance),
                ],
              ),
              SizedBox(
                height: 80,
                width: null,
                child: SfRangeSelector(
                  dateFormat: DateFormat.MMMd(),
                  dateIntervalType: DateIntervalType.days,
                  interval: 1,
                  min: DateTime.fromMillisecondsSinceEpoch(hbm.rangeStart),
                  max: DateTime.fromMillisecondsSinceEpoch(hbm.rangeEnd),
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  showDividers: true,
                  activeColor: const Color.fromARGB(255, 5, 90, 194),
                  inactiveColor: const Color.fromARGB(100, 5, 90, 194),
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
                    key: const Key('HomePage_TimeSeriesChart_RangeSelector'),
                    margin: const EdgeInsets.all(0),
                    primaryXAxis: DateTimeAxis(
                        isVisible: false,
                        minimum:
                            DateTime.fromMillisecondsSinceEpoch(hbm.rangeStart),
                        maximum:
                            DateTime.fromMillisecondsSinceEpoch(hbm.rangeEnd)),
                    primaryYAxis: NumericAxis(isVisible: false),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries<DatapointModel, DateTime>>[
                      LineSeries<DatapointModel, DateTime>(
                          dataSource: Provider.of<HeartBeatModel>(context)
                              .timeSeriesFullRangeAggregates,
                          xValueMapper: (DatapointModel ts, _) => ts.datetime,
                          yValueMapper: (DatapointModel ts, _) => ts.average),
                    ],
                  ),
                ),
              ),
              const CheckBoxButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
