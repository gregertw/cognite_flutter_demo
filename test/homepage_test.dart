import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/index.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'initwidget.dart';

void main() async {
  AppStateModel loginState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  loginState = AppStateModel(prefs);
  // Make a mock client we can use to make mocked http responses
  loginState.mocks.enableMock('heartbeat', CDFMockApiClient());
  loginState.verifyCDF();

  test('logged in state', () {
    expect(loginState.authenticated, true);
  });

  testWidgets('logged-in homepage widget', (WidgetTester tester) async {
    await initWidget(tester, loginState, HomePage());
    await tester.pump();
    expect(find.byKey(Key("HomePage_Scaffold")), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('open drawer', (WidgetTester tester) async {
    await initWidget(tester, loginState, HomePage());
    await tester.pump();
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
