import 'package:test/test.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';

// This test can be extended as we get more appstate

void main() async {
  late AppStateModel state;
  // We need mock initial values for SharedPreferences
  SharedPreferences.setMockInitialValues({});
  var prefs = await SharedPreferences.getInstance();

  setUp(() async {
    // We need mock initial values for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    state = AppStateModel(prefs: prefs, mock: true);
  });
  test('not logged in', () async {
    expect(state.authenticated, false);
  });
  test('log in - log out', () async {
    (state.apiClient as CDFMockApiClient).setMock(body: """{
        "subject": "user@cognite.com",
        "projects": [
          {
            "projectUrlName": "publicdata",
            "groups": [62353240994493, 7356024348897575]
          }
        ]
      }""");
    await state.authorize();
    expect(state.authenticated, true);
    expect(state.accessToken, 'an_access_token');
    state.logOut();
    expect(state.authenticated, false);
  });
}
