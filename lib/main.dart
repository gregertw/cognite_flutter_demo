import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_cdf_demo/generated/l10n.dart';
import 'package:cognite_cdf_demo/models/appstate.dart';
import 'package:cognite_cdf_demo/ui/pages/home/index.dart';
import 'package:cognite_cdf_demo/ui/pages/login/index.dart';
import 'package:cognite_cdf_demo/ui/pages/config/index.dart';
import 'package:cognite_cdf_demo/ui/theme/style.dart';
// Import mock packages for the web version
import 'package:cognite_cdf_demo/mock/mock_appauth.dart';
import 'package:cognite_cdf_demo/globals.dart';

void main() async {
  // A breaking change in the platform messaging, as of Flutter 1.12.13+hotfix.5,
  // we need to explicitly initialise bindings to get access to the BinaryMessenger
  // This is needed by Crashlytics.
  // https://groups.google.com/forum/#!msg/flutter-announce/sHAL2fBtJ1Y/mGjrKH3dEwAJ
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  // Get an instance so that globals are initialised
  var prefs = await SharedPreferences.getInstance();
  // Let's initialise the app state with the stored preferences
  var appState = new AppStateModel(prefs, analytics);

  // Appauth does not support web yet, use the mock
  if (kIsWeb) {
    log.i('Running in web mode...');
    appState.mocks.enableMock('authClient', MockFlutterAppAuth());
  }

  // Use dart zone to define Crashlytics as error handler for errors
  // that occur outside runApp
  runZonedGuarded<Future<Null>>(() async {
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false, // set to true to see the debug banner
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      onGenerateTitle: (context) => S.of(context).appTitle,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: new ChangeNotifierProvider.value(
        value: appState,
        child: new HomePage(),
      ),
      theme: appTheme,
      routes: <String, WidgetBuilder>{
        "/HomePage": (BuildContext context) => new ChangeNotifierProvider.value(
              value: appState,
              child: new HomePage(),
            ),
        "/LoginPage": (BuildContext context) =>
            new ChangeNotifierProvider.value(
              value: appState,
              child: new LoginPage(),
            ),
        "/ConfigPage": (BuildContext context) =>
            new ChangeNotifierProvider.value(
              value: appState,
              child: new ConfigPage(),
            ),
      },
    ));
  }, FirebaseCrashlytics.instance.recordError);
}
