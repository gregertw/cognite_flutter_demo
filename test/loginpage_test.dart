import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  testWidgets('LoginPage', (WidgetTester tester) async {
    await initWidget(tester, state);

    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(1));
  });
}
