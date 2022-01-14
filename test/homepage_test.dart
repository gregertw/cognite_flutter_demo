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
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'package:cognite_flutter_demo/ui/pages/login/index.dart';

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
        child: const HomePage(),
      ),
    ),
  );
}

void main() async {
  AppStateModel loginState, logoutState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  // We have one logged in state and one logged out, to be used with various tests
  loginState = AppStateModel(prefs: prefs, mock: true);
  logoutState = AppStateModel(prefs: prefs, mock: true);
  // Need CDF apiclient mock data for status
  (loginState.apiClient as CDFMockApiClient).setMock(body: """{
        "subject": "user@cognite.com",
        "projects": [
          {
            "projectUrlName": "publicdata",
            "groups": [62353240994493, 7356024348897575]
          }
        ]
      }""");
  loginState.cdfCluster = 'greenfield';
  loginState.cdfProject = 'publicdata';

  test('logged in state', () async {
    await loginState.authorize();
    expect(loginState.authenticated, true,
        reason: 'expect that we have logged in');
    expect(loginState.cdfLoggedIn, true,
        reason: 'and that the CDF project is initialised');
  });

  testWidgets('logged-out homepage widget', (WidgetTester tester) async {
    // We need to mock a fake error to make sure that HomePage() loading happens
    (logoutState.apiClient as CDFMockApiClient).setMock(statusCode: 400);
    await initWidget(tester, logoutState);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('logged-in homepage widget', (WidgetTester tester) async {
    await initWidget(tester, loginState);
    await tester.pump(const Duration(seconds: 1));

    // Need timeseries mock data
    var mock = File(Directory.current.path + '/test/response-1.json')
        .readAsStringSync();
    (loginState.apiClient as CDFMockApiClient).setMock(body: mock);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byKey(const Key("HomePage_Scaffold")), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('open drawer', (WidgetTester tester) async {
    var mock = File(Directory.current.path + '/test/response-1.json')
        .readAsStringSync();
    (loginState.apiClient as CDFMockApiClient).setMock(body: mock);
    await initWidget(tester, loginState);
    await tester.pump(const Duration(seconds: 1));
    // Find the menu button
    final finder = find.descendant(
        of: find.byKey(const Key("HomePage_Scaffold")),
        matching: find.byTooltip("Open navigation menu"));
    // and tap it to open
    await tester.tap(finder);
    await tester.pump();

    // We should have opened the drawer
    expect(find.byType(HomePageDrawer), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(HomePageDrawer),
            matching: find.byType(UserAccountsDrawerHeader)),
        findsOneWidget);
    // Number of menu items
    expect(
        find.descendant(
            of: find.byType(HomePageDrawer), matching: find.byType(ListTile)),
        findsNWidgets(4));
  });
}
