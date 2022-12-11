import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';

// Helper function to encapsulate code needed to instantiate the HomePage() widget
dynamic initWidget(WidgetTester tester, AppStateModel state) {
  return tester.pumpWidget(
    MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme,
      home: ChangeNotifierProvider.value(
        value: state,
        child: const HomePageDrawer(),
      ),
    ),
  );
}

void main() async {
  AppStateModel loginState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  loginState = AppStateModel(prefs: prefs, mock: true);

  testWidgets('is drawer ready', (WidgetTester tester) async {
    await initWidget(tester, loginState);
    await tester.pump(const Duration(seconds: 1));
    // Need timeseries mock data
    var mock = File('${Directory.current.path}/test/response-1.json')
        .readAsStringSync();
    (loginState.apiClient as CDFMockApiClient).setMock(body: mock);
    await tester.pump(const Duration(seconds: 1));
    // We should have opened the drawer
    expect(find.byType(HomePageDrawer), findsOneWidget);
    expect(find.byKey(const Key("DrawerMenu_Header")), findsOneWidget);
    expect(find.byKey(const Key("DrawerMenuTile_Config")), findsOneWidget);
    expect(
        find.byKey(const Key("DrawerMenuTile_Localisation")), findsOneWidget);
    expect(find.byKey(const Key("DrawerMenuTile_About")), findsOneWidget);
  });

  testWidgets('log out from drawer', (WidgetTester tester) async {
    await initWidget(tester, loginState);
    await tester.pump();

    final buttonFinder = find.descendant(
        of: find.byType(HomePageDrawer),
        matching: find.byKey(const Key("DrawerMenuTile_LogOut")));
    await tester.tap(buttonFinder);
    await tester.pump();
    // Authenticated state should be false
    expect(loginState.authenticated, false);
  });
}
