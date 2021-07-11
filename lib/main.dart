import 'dart:async';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/config/index.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';

void main() async {
  // A breaking change in the platform messaging, as of Flutter 1.12.13+hotfix.5,
  // we need to explicitly initialise bindings to get access to the BinaryMessenger
  // This is needed by Crashlytics.
  // https://groups.google.com/forum/#!msg/flutter-announce/sHAL2fBtJ1Y/mGjrKH3dEwAJ
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  if (!kIsWeb) {
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  FirebaseAnalytics analytics = FirebaseAnalytics();

  // Get an instance so that globals are initialised
  var prefs = await SharedPreferences.getInstance();
  // Let's initialise the app state with the stored preferences
  var appState = AppStateModel(prefs, analytics);
  // Load values from prefs and check token state
  appState.verifyCDF();

  // as documented in appstate.dart, we here set the defaultLokale
  // from appState to apply loaded locale from sharedpreferences on
  // startup.
  Intl.defaultLocale = appState.locale;

  // Use dart zone to define Crashlytics as error handler for errors
  // that occur outside runApp
  runZonedGuarded<Future<Null>>(() async {
    runApp(
      OverlaySupport(
        child: MaterialApp(
          debugShowCheckedModeBanner:
              false, // set to true to see the debug banner
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
          home: ChangeNotifierProvider.value(
            value: appState,
            child: HomePage(),
          ),
          theme: appTheme,
          routes: <String, WidgetBuilder>{
            "/HomePage": (BuildContext context) => ChangeNotifierProvider.value(
                  value: appState,
                  child: HomePage(),
                ),
            "/ConfigPage": (BuildContext context) =>
                ChangeNotifierProvider.value(
                  value: appState,
                  child: ConfigPage(),
                ),
          },
        ),
      ),
    );
  }, FirebaseCrashlytics.instance.recordError);
}
