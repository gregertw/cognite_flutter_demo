import 'dart:async';
import 'dart:convert';
import 'package:cognite_flutter_demo/providers/aad.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/github_oauth2_client.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:http/http.dart' as http;

/// Use this as authProvider in [AuthClient] for mocked auth.
class MockOAuth2Client extends GitHubOAuth2Client {
  MockOAuth2Client(
      {required String redirectUri, required String customUriScheme})
      : super(redirectUri: redirectUri, customUriScheme: customUriScheme);

  Future<AccessTokenResponse> getMockedResponse() async {
    return AccessTokenResponse.fromMap({
      'access_token': 'an_access_token',
      'refresh_token': 'a_refresh_token',
      'token_type': 'bearer',
      'scope': '',
      'expires_in': 3600
    });
  }
}

class AuthUserInfo {
  String? email;
  String? username;
  String? name;
  String? firstname;
  String? lastname;
  String? avatarUrl;
  String? id;

  AuthUserInfo();

  /// Instantiate from a json based on provider id
  AuthUserInfo.from(Map<String, dynamic> info) {
    email = info['mail'];
    name ??= info['displayName'];
    username ??= info['userPrincipalName'];
    id ??= info['id'];
  }
}

/// Auth provider handling all interaction with the identity provider.
///
/// It can be used in three ways: preconfigured with a set of providers and all
/// parameters hardcoded in the class, provider configs set here and
/// [clientId], [redirectUrl], and/or [scopes] supplied,
/// or by supplying an [OAuth2Client] instance as [authProvider] (this
/// is used when mocking).
class AuthClient {
  /// ActiveDirectory ID
  String aadId = '';

  /// The client id supplied by the auth provider. Will override preconfigured providers in the class.
  String? clientId;

  /// The client secret to be used in token exchange. Needs to be protected.
  String? clientSecret;

  /// The scopes that should be requested from the auth provider. Will override preconfigured providers in the class.
  List<String>? scopes;

  /// The scopes that should be requested from the auth provider for the API access. Will override preconfigured providers in the class.
  List<String>? scopesApi;

  /// should be set to true if this app is running in a browser.
  final bool web;

  /// set to true if we mock
  final bool mock;

  /// A fully configured [OAuth2Client] that will override both preconfigured providers and
  /// [redirectUrl], [clientId], and [scopes].
  OAuth2Client? authProvider;

  static const Map<String, String> _userInfoUrls = {
    'host': 'graph.microsoft.com',
    'path': '/v1.0/me'
  };

  // convenience to hold refresh token
  String? _refreshToken;
  // convenience to hold access token
  String? _accessToken;
  // convenience to hold id token (OIDC)
  String? _idToken;
  DateTime _expiresToken = DateTime.now();

  /// Creates Authorization header
  Map<String, String> get authHeader =>
      {'Authorization': 'Bearer $accessToken'};

  /// Active acess token if authenticated.
  String get accessToken => _accessToken ?? '';

  /// Needed if token is retrieved outside OAuth2 flow
  set accessToken(s) => _accessToken = s;

  /// Refresh token if available.
  String get refreshToken => _refreshToken ?? '';

  /// Id token if OIDC is used.
  String get idToken => _idToken ?? '';

  /// Do we have an access token? (note: it may be expired)
  bool get isValid => _accessToken != null;

  /// The expiry timestamp of the access token
  DateTime get expires => _expiresToken;

  /// Has the access token expired?
  bool get isExpired => _expiresToken.difference(DateTime.now()).inSeconds <= 0;

  /// Should a refresh be done?
  bool get shouldRefresh => _refreshToken != null && !isValid;

  AuthClient({
    this.clientId = '',
    this.clientSecret = '',
    this.web = false,
    this.mock = false,
    this.authProvider,
    this.scopes,
    this.scopesApi,
    // For future OIDC support
    //this.discoveryUrl,
    //this.authzEndpoint,
    //this.tokenEndpoint
  }) {
    if (mock) {
      authProvider = MockOAuth2Client(redirectUri: '', customUriScheme: '');
      clientId = '';
      clientSecret = '';
    }
  }

  Future<AuthUserInfo> getUserInfo() async {
    if (isValid) {
      try {
        final http.Response httpResponse = await http.get(
            Uri(
                scheme: 'https',
                host: _userInfoUrls['host'],
                path: _userInfoUrls['path']),
            headers: authHeader);
        var res = httpResponse.statusCode == 200 ? httpResponse.body : '';
        if (res.isNotEmpty) {
          return AuthUserInfo.from(jsonDecode(res));
        }
      } catch (e) {
        return AuthUserInfo();
      }
    }
    return AuthUserInfo();
  }

  bool _parseAuthResult(AccessTokenResponse res) {
    if (!res.isValid()) {
      return false;
    }
    if (res.accessToken == null) {
      closeSessions();
      return false;
    }
    _accessToken = res.accessToken;
    if (res.respMap.containsKey('id_token')) {
      _idToken = res.respMap['id_token'];
    }
    // TODO: Set idtoken here.
    if (res.expirationDate != null) {
      _expiresToken = res.expirationDate!;
    } else {
      _expiresToken = DateTime.now().add(Duration(seconds: res.expiresIn ?? 0));
    }
    if (res.hasRefreshToken()) {
      _refreshToken = res.refreshToken;
    }
    return true;
  }

  /// Recreates a session from a json. This is not a constructor for the entire object.
  void fromJson(Map<String, dynamic> json) {
    _accessToken = json['accessToken'] == '' ? null : json['accessToken'];
    _refreshToken = json['refreshToken'] == '' ? null : json['refreshToken'];
    _idToken = json['idToken'] == '' ? null : json['idToken'];
    _expiresToken = DateTime.parse(json['expires']);
  }

  /// Creates a json map of the session.
  Map<String, dynamic> toJson() => {
        'accessToken': _accessToken ?? '',
        'refreshToken': _refreshToken ?? '',
        'idToken': _idToken ?? '',
        'expires': _expiresToken.toIso8601String()
      };

  /// Creates a string of the session for storing to SharedPreferences et al.
  ///
  /// NOTE!!! This string is security sensitive and must be persisted securely.
  @override
  String toString() {
    return json.encode(toJson());
  }

  /// Recreates the session from a string created by [toString].
  ///
  /// You should trigger [autorizeOrRefresh] afterwards at a point where
  /// user dialog for authentication can be shown (if needed).
  void fromString(String input) {
    if (input.isNotEmpty) fromJson(json.decode(input));
  }

  /// May present a UI dialog to the user.
  Future<bool> authorizeOrRefresh() async {
    if (authProvider is MockOAuth2Client) {
      return _parseAuthResult(
          await (authProvider as MockOAuth2Client).getMockedResponse());
    }
    if (_accessToken != null) {
      if (isExpired) {
        if (_refreshToken != null) {
          return _parseAuthResult(await authProvider!
              .refreshToken(_refreshToken!, clientId: clientId!));
        }
      }
    }
    closeSessions();
    try {
      var res = _parseAuthResult(await authProvider!.getTokenWithAuthCodeFlow(
          clientId: clientId!,
          scopes: scopes!, // + scopesApi!,
          clientSecret: clientSecret));
      if (res) {
        // Note: the first token is an OIDC token so you can retrieve user info
        //var info = await getUserInfo();
        if (_refreshToken != null) {
          (authProvider! as AADOauth2Client).scopesAPI = scopesApi!;
          return _parseAuthResult(await authProvider!
              .refreshToken(_refreshToken!, clientId: clientId!));
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clears out session
  void closeSessions() {
    _expiresToken = DateTime.now();
    _accessToken = null;
    _idToken = null;
    _refreshToken = null;
    return;
  }
}
