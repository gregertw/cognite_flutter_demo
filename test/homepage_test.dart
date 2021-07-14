import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';

dynamic initWidget(WidgetTester tester, AppStateModel state) {
  return tester.pumpWidget(
    new MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: appTheme,
      home: new ChangeNotifierProvider.value(
        value: state,
        child: new HomePage(),
      ),
    ),
  );
}

void main() async {
  AppStateModel appState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  appState = AppStateModel(prefs);
  // Make a mock client we can use to make mocked http responses
  var client = CDFMockApiClient();
  setUpAll(() async {
    appState.mocks.enableMock('heartbeat', client);
    client.setMock(body: """{
    "data": {
        "user": "user@cognite.com",
        "loggedIn": true,
        "project": "publicdata",
        "projectId": 5977964818434649,
        "apiKeyId": 934347347677
    }
}""");
    await appState.verifyCDF();
  });

  test('logged in state', () {
    expect(appState.cdfLoggedIn, true);
  });

  testWidgets('logged-in homepage widget', (WidgetTester tester) async {
    await initWidget(tester, appState);
    await tester.pumpAndSettle();
    expect(appState.cdfLoggedIn, true);
    expect(find.byKey(Key("HomePage_Scaffold")), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('open drawer', (WidgetTester tester) async {
    await initWidget(tester, appState);
    await tester.pumpAndSettle();
    // Find the menu button
    final finder = find.descendant(
        of: find.byKey(Key("HomePage_Scaffold")),
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
