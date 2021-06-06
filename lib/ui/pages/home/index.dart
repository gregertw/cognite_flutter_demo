import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';
import 'package:cognite_flutter_demo/models/chartstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'package:cognite_flutter_demo/ui/pages/config/index.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/ui/pages/timeseries_chart/index.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    if (!appState.cdfLoggedIn!) {
      return Scaffold(
        body: ConfigPage(),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => HeartBeatModel(
                appState.apiClient,
                appState.cdfTimeSeriesId,
                appState.cdfNrOfDays,
                appState.resolutionFactor)),
        ChangeNotifierProvider(
            create: (_) => ChartFeatureModel(
                Provider.of<AppStateModel>(context, listen: false)
                    .resolutionFactor))
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
