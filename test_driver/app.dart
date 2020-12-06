import 'package:flutter_driver/driver_extension.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/config/index.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';
import 'package:cognite_flutter_demo/globals.dart';

void main() async {
  AppStateModel appState;

  // ignore: missing_return
  Future<String> dataHandler(String msg) async {
    log.d("Got driver message: $msg");
    switch (msg) {
      // case "mockLogin":
      //   {
      //     appState.mocks.enableMock('authClient', MockFlutterAppAuth());
      //   }
      //   break;
      case "clearMocks":
        {
          appState.mocks.clearMocks();
        }
        break;
      case "clearSession":
        {
          appState.logOut();
        }
        break;
      default:
        throw ("Not a valid driver message!!");
        break;
    }
  }

  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  // Get an instance so that globals are initialised
  var prefs = await SharedPreferences.getInstance();
  // We don't want any state we cannot control when testing
  prefs.clear();
  // Let's initialise the app state with the stored preferences
  appState = new AppStateModel(prefs);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // set to true to see the debug banner
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
        "/ConfigPage": (BuildContext context) => ChangeNotifierProvider.value(
              value: appState,
              child: ConfigPage(),
            ),
      },
    ),
  );
}
