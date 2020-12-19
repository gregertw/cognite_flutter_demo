import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'initwidget.dart';

void main() async {
  AppStateModel appState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  // Make a mock client we can use to make mocked http responses
  var client = CDFMockApiClient();
  setUpAll(() async {
    appState = AppStateModel(prefs);
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
    await initWidget(tester, appState, HomePage());
    await tester.pumpAndSettle();
    expect(appState.cdfLoggedIn, true);
    expect(find.byKey(Key("HomePage_Scaffold")), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('open drawer', (WidgetTester tester) async {
    await initWidget(tester, appState, HomePage());
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
