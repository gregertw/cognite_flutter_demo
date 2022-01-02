import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:cognite_flutter_demo/ui/pages/login/index.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cognite_flutter_demo/ui/theme/style.dart';

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
        child: const LoginPage(),
      ),
    ),
  );
}

void main() async {
  AppStateModel state;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();
  // We have one logged in state and one logged out, to be used with various tests
  state = AppStateModel(prefs: prefs, mock: true);

  testWidgets('get_through_full_login', (WidgetTester tester) async {
    await initWidget(tester, state);

    await tester.pump();
    final buttonFinder = find.descendant(
        of: find.byType(ClusterPage),
        matching: find.byKey(const Key('ClusterDropDownButton')));
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    final dropdownItem = find.text('greenfield').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    final loginButton = find.descendant(
        of: find.byType(AuthPage),
        matching: find.byKey(const Key('LoginPage_LoginButton')));
    // Need CDF apiclient mock data for status
    (state.apiClient as CDFMockApiClient).setMock(body: """{
        "subject": "user@cognite.com",
        "projects": [
          {
            "projectUrlName": "publicdata",
            "groups": [62353240994493, 7356024348897575]
          }
        ]
      }""");
    await tester.tap(loginButton);
    await tester.pump(const Duration(seconds: 1));
    expect(state.authenticated, true);
    expect(state.cdfLoggedIn, true);
    expect(state.cdfProject, '');
    final projectFinder = find.descendant(
        of: find.byType(ProjectPage),
        matching: find.byKey(const Key('ProjectDropDownMenu')));
    await tester.tap(projectFinder);
    await tester.pumpAndSettle();
    final dropdownItemProject = find.text('publicdata').last;
    await tester.tap(dropdownItemProject);
    await tester.pumpAndSettle();
    expect(state.cdfLoggedIn, true);
    expect(state.cdfProject, 'publicdata');
  });
}
