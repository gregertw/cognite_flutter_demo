import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Trick to load correct http adapter dependent on browser or app compile
import 'httpadapter.dart' if (dart.library.html) 'webhttpadapter.dart';
import 'package:cognite_flutter_demo/providers/auth.dart';
import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';
import 'package:cognite_flutter_demo/globals.dart';
import 'package:cognite_flutter_demo/environment.dart';

class AppStateModel with ChangeNotifier {
  bool _authenticated = false;
  final AuthUserInfo _userInfo = AuthUserInfo();
  String? _locale;
  late Locale _currentLocale;
  bool mock;
  bool web;
  SharedPreferences? prefs;
  FirebaseAnalytics? analytics;
  AuthClient? _authClient;

  String _aadId = '';
  String? _cdfCluster;
  bool _manualToken = false;
  String? _cdfProject;
  String _cdfTimeSeriesId = '';
  int? _cdfProjectId;
  int _cdfNrOfDays = 0;
  // Used to calculate resolution, the bigger the more points in a range are loaded.
  // This is injected into ChartState and HeartbeatState.
  int _resolutionFactor = 420000;
  StatusModel _cdfStatus = StatusModel();
  late CDFApiClient _apiClient;

  bool get manualToken => _manualToken;
  set manualToken(b) {
    _manualToken = b;
    notifyListeners();
  }

  bool get authenticated => _authenticated;
  bool get isWeb => web;
  String get aadId => _aadId;
  String? get accessToken => _authClient!.accessToken;
  String? get idToken => _authClient!.idToken;
  String? get refreshToken => _authClient!.refreshToken;
  DateTime? get expires => _authClient!.expires;
  String get email => _userInfo.email ?? '';
  String get name => _userInfo.name ?? '';
  String? get localeAbbrev => _locale;
  Locale get locale => _currentLocale;
  AuthClient? get auth => _authClient;
  String get cdfCluster => _cdfCluster ?? '';
  String get cdfProject => _cdfProject ?? '';
  List<String>? get cdfProjects =>
      _cdfStatus.projects ?? [_cdfStatus.project ?? ''];
  String get cdfURL => 'https://' + cdfCluster + '.cognitedata.com';
  int get cdfProjectId => _cdfProjectId ?? 0;
  int get resolutionFactor => _resolutionFactor;

  List<String> get scopes =>
      <String>['User.Read', 'openid', 'profile', 'offline_access'];
  List<String> get scopesApi =>
      <String>[cdfURL + '/user_impersonation', cdfURL + '/IDENTITY'];

  set aadId(String s) {
    _aadId = s;
    prefs!.setString('aadId', s);
  }

  set cdfCluster(s) {
    _cdfCluster = s;
    prefs!.setString('cdfCluster', s);
    notifyListeners();
  }

  set resolutionFactor(i) => _resolutionFactor = i;
  set cdfProject(s) {
    _cdfProject = s;
    prefs!.setString('cdfProject', s);
    notifyListeners();
  }

  String get cdfTimeSeriesId => _cdfTimeSeriesId;
  set cdfTimeSeriesId(s) {
    _cdfTimeSeriesId = s;
    prefs!.setString('cdfTimeSeriesId', s);
  }

  bool get cdfLoggedIn => _cdfStatus.loggedIn;

  int get cdfNrOfDays => _cdfNrOfDays;
  set cdfNrOfDays(i) {
    _cdfNrOfDays = i;
    prefs!.setInt('cdfNrOfDays', i);
  }

  CDFApiClient get apiClient => _apiClient;

  AppStateModel(
      {this.prefs, this.analytics, this.mock = false, this.web = false}) {
    if (mock) {
      _authClient = AuthClient(
          provider: 'mock', clientId: '', clientSecret: '', web: web);
      _apiClient = CDFMockApiClient();
    } else {
      _authClient = AuthClient(
          clientId: Environment.clientIdAAD,
          clientSecret: Environment.secretAAD,
          provider: 'aad',
          web: web);
      // Ensure _apiClient is initialised, it will have to be reinitialised later when
      // token/apikey and project are known.
      _apiClient = CDFApiClient(
          project: '',
          apikey: null,
          baseUrl: cdfURL,
          logLevel: Level.error,
          httpAdapter: GenericHttpClientAdapter());
    }
    refreshSession();
    // this will load locale from prefs
    // Note that you need to use
    // Intl.defaultLocale = appState.localeAbbrev;
    // in your main page(s) builders to apply a loaded locale from prefs
    // as the widget tree will not automatically refresh until build time
    // See lib/ui/pages/home/index.dart for an example.
    setLocale(null);
    if (authenticated) {
      initialiseCDF();
    }
  }

  /// Use to set locale explicitly.
  void setLocale(String? loc) {
    if (prefs == null) {
      return;
    }
    if (loc == null) {
      loc = prefs!.getString('locale');
      loc ??= Intl.getCurrentLocale().substring(0, 2);
    }
    _locale = loc;
    prefs!.setString('locale', loc);
    _currentLocale = Locale(loc);
    notifyListeners();
  }

  /// Rotates through the supported locales.
  void switchLocale() {
    const _locales = AppLocalizations.supportedLocales;
    if (_locales.length == 1) {
      return;
    }
    int ind = 0;
    _locales.asMap().forEach((key, value) {
      if (value.languageCode == _locale) {
        ind = key + 1;
      }
    });
    if (ind >= _locales.length) {
      ind = 0;
    }
    setLocale(_locales[ind].languageCode);
  }

  /// Sends off a Firebase Analytics event.
  Future<void> sendAnalyticsEvent(
      String name, Map<String, dynamic>? params) async {
    if (analytics == null) {
      return;
    }
    await analytics!.logEvent(
      name: name,
      parameters: params,
    );
    // ignore: avoid_print
    print('Sent analytics events: $name');
  }

  /// Refreshes a session from sharedpreferences.
  Future<bool> refreshSession() async {
    if (prefs == null || _authClient == null) {
      return false;
    }
    _userInfo.email = prefs!.getString('email');
    _userInfo.name = prefs!.getString('name');
    _aadId = prefs!.getString('aadId') ?? '';
    _cdfCluster = prefs!.getString('cdfCluster');
    _cdfProject = prefs!.getString('cdfProject');
    _cdfTimeSeriesId = prefs!.getString('cdfTimeSeriesId') ?? '';
    //_cdfTimeSeriesId = prefs!.getString('cdfTimeSeriesId') ??
    //    'fitbit_c2009283ac84526e9f0e01ef4cc9fa2a';
    var apikey = prefs!.getString('cdfApiKey');
    if (apikey != null) {
      logIn(apikey);
    } else {
      _authClient!.fromString(prefs!.getString('session') ?? '');
      if (_authClient!.isValid && !_authClient!.isExpired) {
        _authenticated = true;
        if (!await initialiseCDF()) {
          logOut();
          return false;
        }
        notifyListeners();
        return true;
      }
      logOut();
    }

    return false;
  }

  /// Triggers  a popup for login to the Identity Provider
  Future<bool> authorize([String? provider]) async {
    _authClient!.scopes = scopes;
    _authClient!.scopesApi = scopesApi;
    if (aadId.isNotEmpty) {
      _authClient!.aadId = aadId;
    }
    var res = await _authClient!.authorizeOrRefresh(provider);
    if (res) {
      prefs!.setString('session', _authClient.toString());
      _authenticated = true;
      if (!await initialiseCDF()) {
        logOut();
        return false;
      }
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Sets the token or login
  void logIn(String token) async {
    auth!.accessToken = token;
    _authenticated = true;
    // Check if this was a token
    if (!await initialiseCDF()) {
      // This was not a valid IdP token, so try API key towards CDF directly
      auth!.accessToken = null;
      if (!await initialiseCDF(token)) {
        // token or apikey, none worked
        _authenticated = false;
        notifyListeners();
        return;
      }
    }
    prefs!.setString('session', _authClient.toString());
    prefs!.setString('cdfApiKey', token);
    notifyListeners();
  }

  // Clears out and deletes the token as well as in sharedpreferences.
  void logOut() {
    _authClient?.closeSessions();
    _authenticated = false;
    _cdfProject = null;
    _cdfCluster = null;
    _cdfTimeSeriesId = '';
    _cdfNrOfDays = 0;
    _apiClient.apikey = null;
    _manualToken = false;
    prefs!.remove('session');
    prefs!.remove('cdfApiKey');
    prefs!.remove('cdfCluster');
    prefs!.remove('cdfProject');
    prefs!.remove('cdfTimeSeriesId');
    prefs!.remove('cdfNrOfDays');
    if (mock) {
      _apiClient = CDFMockApiClient();
    } else {
      _apiClient = CDFApiClient(
          project: '',
          apikey: null,
          baseUrl: '',
          logLevel: Level.error,
          httpAdapter: GenericHttpClientAdapter());
    }
    notifyListeners();
  }

  /// Will be called multiple times, to retrieve info about logged in user and then projects
  Future<bool> initialiseCDF([String? apikey]) async {
    String? token;
    // If we have earlier used an apikey sucessfully, reuse if not explicitly supplied
    if (apikey == null &&
        _apiClient.apikey != null &&
        _apiClient.apikey!.isNotEmpty) {
      apikey = _apiClient.apikey;
    } else if (apikey == null && auth!.accessToken.isNotEmpty) {
      token = auth!.accessToken;
    }
    // If mock, we already have a mock apiclient
    if (!mock && cdfCluster.isNotEmpty && cdfURL.isNotEmpty) {
      if (cdfCluster.isEmpty || cdfURL.isEmpty) {
        return false;
      }
      _apiClient = CDFApiClient(
          project: cdfProject,
          token: token,
          apikey: apikey,
          baseUrl: cdfURL,
          logLevel: Level.error,
          httpAdapter: GenericHttpClientAdapter());
    }
    try {
      _cdfStatus = await _apiClient.getStatus();
      if (!mock) {
        bool reinit = false;
        switch (manualToken) {
          case true:
            if (_cdfStatus.projects == null && _cdfStatus.project!.isNotEmpty) {
              cdfProject = _cdfStatus.project;
              reinit = true;
            }
            break;
          case false:
            if ((_cdfStatus.projects != null &&
                    _cdfStatus.projects!.length == 1) &&
                _cdfStatus.project!.isNotEmpty) {
              cdfProject = _cdfStatus.project;
              reinit = true;
            }
            break;
        }
        if (reinit) {
          _apiClient = CDFApiClient(
              project: cdfProject,
              token: token,
              apikey: apikey,
              baseUrl: cdfURL,
              logLevel: Level.error,
              httpAdapter: GenericHttpClientAdapter());
          _cdfStatus = await _apiClient.getStatus();
        }
      }
      log.d(_cdfStatus);
    } catch (e) {
      _apiClient.apikey = null;
      return false;
    }
    if (!_cdfStatus.loggedIn) {
      _apiClient.apikey = null;
      return false;
    }
    sendAnalyticsEvent('login', {'user': _cdfStatus.user});
    notifyListeners();
    return true;
  }
}
