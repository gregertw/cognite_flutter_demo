import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cognite_cdf_demo/models/appstate.dart';
import 'package:cognite_cdf_demo/ui/pages/login/index.dart';
import 'package:cognite_cdf_demo/ui/pages/config/index.dart';
import 'package:cognite_cdf_demo/ui/pages/timeseries_chart/index.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    if (!appState.authenticated) {
      return Scaffold(
        body: LoginPage(),
      );
    }

    if (!appState.cdfLoggedIn) {
      return Scaffold(
        body: ConfigPage(),
      );
    }

    // as documented in appstate.dart, we here set the defaultLokale
    // from appState to apply loaded locale from sharedpreferences on
    // startup.
    Intl.defaultLocale = appState.locale;

    var apiClient = appState.mocks.getMock('heartbeat') ??
        CDFApiClient(
            project: appState.cdfProject,
            apikey: appState.cdfApiKey,
            baseUrl: appState.cdfURL);

    return TimeSeriesHome(apiClient: apiClient, appState: appState);
  }
}
