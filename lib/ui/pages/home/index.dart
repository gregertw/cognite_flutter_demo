import 'package:cognite_flutter_demo/ui/pages/config/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';
import 'package:cognite_flutter_demo/models/chartstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'package:cognite_flutter_demo/ui/pages/login/index.dart';
import 'package:cognite_flutter_demo/ui/pages/timeseries_chart/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    if (!appState.authenticated ||
        !appState.cdfLoggedIn ||
        appState.cdfProject.isEmpty) {
      return const Scaffold(
        body: LoginPage(),
      );
    }
    var hbm = HeartBeatModel(appState.apiClient, appState.cdfTimeSeriesId,
        appState.cdfNrOfDays, appState.resolutionFactor);
    Widget body;
    if (appState.cdfTimeSeriesId.isEmpty || hbm.failed) {
      body = ConfigPage();
    } else {
      body = const TimeSeriesChart();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: hbm),
        ChangeNotifierProvider(
            create: (_) => ChartFeatureModel(
                Provider.of<AppStateModel>(context).resolutionFactor))
      ],
      child: Scaffold(
        key: const Key("HomePage_Scaffold"),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: body,
        drawer: const HomePageDrawer(),
      ),
    );
  }
}
