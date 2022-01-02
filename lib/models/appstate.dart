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

  String? _cdfCluster;
  String? _cdfProject;
  String _cdfTimeSeriesId = '';
  int? _cdfProjectId;
  int _cdfNrOfDays = 10;
  // Used to calculate resolution, the bigger the more points in a range are loaded.
  // This is injected into ChartState and HeartbeatState.
  int _resolutionFactor = 420000;
  StatusModel _cdfStatus = StatusModel();
  late CDFApiClient _apiClient;

  bool get authenticated => _authenticated;
  bool get isWeb => web;
  String? get userToken => _authClient!.accessToken;
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
  List<String>? get cdfProjects => _cdfStatus.projects ?? [cdfProject];
  String get cdfURL => 'https://' + cdfCluster + '.cognitedata.com';
  int get cdfProjectId => _cdfProjectId ?? 0;
  int get resolutionFactor => _resolutionFactor;

  List<String> get scopes =>
      <String>['User.Read', 'openid', 'profile', 'offline_access'];
  List<String> get scopesApi =>
      <String>[cdfURL + '/user_impersonation', cdfURL + '/IDENTITY'];

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
    } else {
      _authClient = AuthClient(
          clientId: Environment.clientIdAAD,
          clientSecret: Environment.secretAAD,
          provider: 'aad',
          web: web);
    }
    refreshSession();
    // this will load locale from prefs
    // Note that you need to use
    // Intl.defaultLocale = appState.localeAbbrev;
    // in your main page(s) builders to apply a loaded locale from prefs
    // as the widget tree will not automatically refresh until build time
    // See lib/ui/pages/home/index.dart for an example.
    setLocale(null);
    _cdfTimeSeriesId = prefs!.getString('cdfTimeSeriesId') ?? '';
    //_cdfTimeSeriesId = prefs!.getString('cdfTimeSeriesId') ??
    //    'fitbit_c2009283ac84526e9f0e01ef4cc9fa2a';
    if (authenticated) {
      initialiseCDF();
    } else {
      // Ensure _apiClient is initialised
      _apiClient = CDFMockApiClient();
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
    _cdfCluster = prefs!.getString('cdfCluster');
    _cdfProject = prefs!.getString('cdfProject');
    _authClient!.fromString(prefs!.getString('session') ?? '');
    if (_authClient!.isValid && !_authClient!.isExpired) {
      _authenticated = true;
      notifyListeners();
      return true;
    }
    logOut();
    return false;
  }

  /// Triggers  a popup for login to the Identity Provider
  Future<bool> authorize([String? provider]) async {
    _authClient!.scopes = scopes;
    _authClient!.scopesApi = scopesApi;
    var res = await _authClient!.authorizeOrRefresh(provider);
    if (res) {
      prefs!.setString('session', _authClient.toString());
      _authenticated = true;
      initialiseCDF();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  // Clears out and deletes the token as well as in sharedpreferences.
  void logOut() {
    _authClient?.closeSessions();
    _authenticated = false;
    _cdfProject = null;
    _cdfCluster = null;
    prefs!.remove('session');
    prefs!.remove('cdfCluster');
    prefs!.remove('cdfProject');
    notifyListeners();
  }

  /// Will be called multiple times, to retrieve info about logged in user and then projects
  Future<bool> initialiseCDF() async {
    if (!mock) {
      if (cdfCluster.isNotEmpty &&
          auth!.accessToken.isNotEmpty &&
          cdfURL.isNotEmpty) {
        _apiClient = CDFApiClient(
            project: _cdfProject ?? '',
            token: auth!.accessToken,
            baseUrl: cdfURL,
            logLevel: Level.error,
            httpAdapter: GenericHttpClientAdapter());
      } else {
        return false;
      }
    }
    try {
      _cdfStatus = await _apiClient.getStatus();
      log.d(_cdfStatus);
    } catch (e) {
      return false;
    }
    if (!_cdfStatus.loggedIn) {
      logOut();
      return false;
    }
    sendAnalyticsEvent('login', {'user': _cdfStatus.user});
    notifyListeners();
    return true;
  }
}
