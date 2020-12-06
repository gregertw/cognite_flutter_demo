import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:cognite_flutter_demo/ui/pages/config/index.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';

// Helper function to encapsulate code needed to instantiate the HomePage() widget
dynamic initWidget(WidgetTester tester, AppStateModel state, Widget child) {
  return tester.pumpWidget(
    OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, // set to true to see the debug banner
        onGenerateTitle: (context) => S.of(context).appTitle,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: ChangeNotifierProvider.value(
          value: state,
          child: child,
        ),
        theme: appTheme,
        routes: <String, WidgetBuilder>{
          "/HomePage": (BuildContext context) => ChangeNotifierProvider.value(
                value: state,
                child: HomePage(),
              ),
          "/ConfigPage": (BuildContext context) => ChangeNotifierProvider.value(
                value: state,
                child: ConfigPage(),
              ),
        },
      ),
    ),
  );
}
