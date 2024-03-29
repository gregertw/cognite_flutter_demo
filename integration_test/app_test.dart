import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cognite_flutter_demo/firebase_options.dart';

// The application under test.
import 'package:cognite_flutter_demo/app.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  group('demo', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys.
    final clusterButtonFinder = find.byKey(const Key('ClusterDropDownButton'));
    final loginButtonFinder = find.byKey(const Key('LoginPage_LoginButton'));
    final projectFinder = find.byKey(const Key('ProjectDropDownMenu'));
    final openDrawerMenuButton = find.byTooltip("Open navigation menu");
    final exitButtonFinder = find.byKey(const Key('DrawerMenuTile_LogOut'));

    testWidgets('app test', (tester) async {
      var app = await getApp(mock: true);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(clusterButtonFinder);
      await tester.tap(
          loginButtonFinder); // TODO: Integration tests fail here: disabled in codemagic
      await tester.pumpAndSettle();
      await tester.tap(projectFinder);
      await tester.pumpAndSettle();
      await tester.tap(openDrawerMenuButton);
      await tester.pumpAndSettle();
      expect(exitButtonFinder, findsOneWidget);
      await tester.tap(exitButtonFinder);
      await tester.pumpAndSettle();
      expect(clusterButtonFinder, findsOneWidget);
    });
  });
}
