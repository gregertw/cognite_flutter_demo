import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/ui/pages/home/drawer.dart';
import 'initwidget.dart';

void main() async {
  AppStateModel loginState;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  loginState = AppStateModel(prefs);

  testWidgets('is drawer ready', (WidgetTester tester) async {
    await initWidget(tester, loginState, HomePageDrawer());
    await tester.pump();

    expect(loginState.authenticated, true);
    // We should have opened the drawer
    expect(find.byType(HomePageDrawer), findsOneWidget);
    expect(find.byKey(Key("DrawerMenu_Header")), findsOneWidget);
    expect(find.byKey(Key("DrawerMenuTile_Config")), findsOneWidget);
    expect(find.byKey(Key("DrawerMenuTile_About")), findsOneWidget);
    expect(find.byKey(Key("DrawerMenuTile_LogOut")), findsOneWidget);
    expect(find.byKey(Key("DrawerMenuTile_Localisation")), findsOneWidget);
  });

  testWidgets('log out from drawer', (WidgetTester tester) async {
    await initWidget(tester, loginState, HomePageDrawer());
    await tester.pump();

    final buttonFinder = find.descendant(
        of: find.byType(HomePageDrawer),
        matching: find.byKey(Key("DrawerMenuTile_LogOut")));
    await tester.tap(buttonFinder);
    await tester.pump();
    // Authenticated state should be false
    expect(loginState.authenticated, false);
  });
}
