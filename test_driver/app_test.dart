import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('cognite_flutter_demo', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys.
    final openDrawerMenuButton = find.byTooltip("Open navigation menu");
    final exitButtonFinder = find.byValueKey('DrawerMenuTile_LogOut');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      // Clear any earlier mocks
      driver.requestData('clearMocks');
      // Clear any actual logged in sessions
      driver.requestData('clearSession');
    });
    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('check flutter driver health', () async {
      final health = await driver.checkHealth();
      expect(health.status, HealthStatus.ok);
    });

    test('logs in', () async {
      driver.requestData('mockHeartrate');
      //await driver.tap(loginButtonFinder);
    });

    test('open drawer menu', () async {
      await driver.tap(openDrawerMenuButton);
      await driver.waitFor(exitButtonFinder);
    });
    test('log out', () async {
      await driver.tap(exitButtonFinder);
    });
  }); // group('cognite_flutter_demo')
}
