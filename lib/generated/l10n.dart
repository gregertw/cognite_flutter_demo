// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Cognite CDF Demo`
  String get appTitle {
    return Intl.message(
      'Cognite CDF Demo',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to ActingWeb`
  String get loginWelcomeText {
    return Intl.message(
      'Welcome to ActingWeb',
      name: 'loginWelcomeText',
      desc: '',
      args: [],
    );
  }

  /// `Loading events...`
  String get loginLoadEvents {
    return Intl.message(
      'Loading events...',
      name: 'loginLoadEvents',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get loginButton {
    return Intl.message(
      'Log in',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logoutButton {
    return Intl.message(
      'Log out',
      name: 'logoutButton',
      desc: '',
      args: [],
    );
  }

  /// `Start listening`
  String get startListening {
    return Intl.message(
      'Start listening',
      name: 'startListening',
      desc: '',
      args: [],
    );
  }

  /// `Stop listening`
  String get stopListening {
    return Intl.message(
      'Stop listening',
      name: 'stopListening',
      desc: '',
      args: [],
    );
  }

  /// `Lat: $lat, Long: $long`
  String get latitudeLongitude {
    return Intl.message(
      'Lat: \$lat, Long: \$long',
      name: 'latitudeLongitude',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get okButton {
    return Intl.message(
      'Ok',
      name: 'okButton',
      desc: '',
      args: [],
    );
  }

  /// `Click to view...`
  String get clickToView {
    return Intl.message(
      'Click to view...',
      name: 'clickToView',
      desc: '',
      args: [],
    );
  }

  /// `testuser@demoserver.io`
  String get drawerEmail {
    return Intl.message(
      'testuser@demoserver.io',
      name: 'drawerEmail',
      desc: '',
      args: [],
    );
  }

  /// `Click to view details...`
  String get drawerHeaderInitialName {
    return Intl.message(
      'Click to view details...',
      name: 'drawerHeaderInitialName',
      desc: '',
      args: [],
    );
  }

  /// `Project name`
  String get drawerProjectName {
    return Intl.message(
      'Project name',
      name: 'drawerProjectName',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get drawerEmptyProject {
    return Intl.message(
      '',
      name: 'drawerEmptyProject',
      desc: '',
      args: [],
    );
  }

  /// `Logged In`
  String get drawerHeaderLoggedIn {
    return Intl.message(
      'Logged In',
      name: 'drawerHeaderLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Logged Out`
  String get drawerHeaderLoggedOut {
    return Intl.message(
      'Logged Out',
      name: 'drawerHeaderLoggedOut',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get drawerConfig {
    return Intl.message(
      'Settings',
      name: 'drawerConfig',
      desc: '',
      args: [],
    );
  }

  /// `Refresh tokens`
  String get drawerRefreshTokens {
    return Intl.message(
      'Refresh tokens',
      name: 'drawerRefreshTokens',
      desc: '',
      args: [],
    );
  }

  /// `Tokens refreshed`
  String get drawerRefreshTokensResultTitle {
    return Intl.message(
      'Tokens refreshed',
      name: 'drawerRefreshTokensResultTitle',
      desc: '',
      args: [],
    );
  }

  /// `See user details for the new tokens.`
  String get drawerRefreshTokensResultMsg {
    return Intl.message(
      'See user details for the new tokens.',
      name: 'drawerRefreshTokensResultMsg',
      desc: '',
      args: [],
    );
  }

  /// `Get user info`
  String get drawerGetUserInfo {
    return Intl.message(
      'Get user info',
      name: 'drawerGetUserInfo',
      desc: '',
      args: [],
    );
  }

  /// `User info retrieved`
  String get drawerGetUserInfoResultTitle {
    return Intl.message(
      'User info retrieved',
      name: 'drawerGetUserInfoResultTitle',
      desc: '',
      args: [],
    );
  }

  /// `User details have been updated.`
  String get drawerGetUserInfoResultMsg {
    return Intl.message(
      'User details have been updated.',
      name: 'drawerGetUserInfoResultMsg',
      desc: '',
      args: [],
    );
  }

  /// `User info retrieval failed`
  String get drawerGetUserInfoFailedTitle {
    return Intl.message(
      'User info retrieval failed',
      name: 'drawerGetUserInfoFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try to refresh token first!`
  String get drawerGetUserInfoFailedMsg {
    return Intl.message(
      'Try to refresh token first!',
      name: 'drawerGetUserInfoFailedMsg',
      desc: '',
      args: [],
    );
  }

  /// `Current localisation`
  String get drawerLocalisation {
    return Intl.message(
      'Current localisation',
      name: 'drawerLocalisation',
      desc: '',
      args: [],
    );
  }

  /// `Locale changed`
  String get drawerLocalisationResultTitle {
    return Intl.message(
      'Locale changed',
      name: 'drawerLocalisationResultTitle',
      desc: '',
      args: [],
    );
  }

  /// `Changed to `
  String get drawerLocalisationResultMsg {
    return Intl.message(
      'Changed to ',
      name: 'drawerLocalisationResultMsg',
      desc: '',
      args: [],
    );
  }

  /// `Project id`
  String get drawerButtomSheetProjectId {
    return Intl.message(
      'Project id',
      name: 'drawerButtomSheetProjectId',
      desc: '',
      args: [],
    );
  }

  /// `Key id`
  String get drawerButtomSheetApiKeyId {
    return Intl.message(
      'Key id',
      name: 'drawerButtomSheetApiKeyId',
      desc: '',
      args: [],
    );
  }

  /// `Expires`
  String get drawerButtomSheetExpires {
    return Intl.message(
      'Expires',
      name: 'drawerButtomSheetExpires',
      desc: '',
      args: [],
    );
  }

  /// `Configure Cognite CDF Project`
  String get configConfigureCDF {
    return Intl.message(
      'Configure Cognite CDF Project',
      name: 'configConfigureCDF',
      desc: '',
      args: [],
    );
  }

  /// `Enter project`
  String get configProject {
    return Intl.message(
      'Enter project',
      name: 'configProject',
      desc: '',
      args: [],
    );
  }

  /// `Project cannot be empty`
  String get configProjectEmpty {
    return Intl.message(
      'Project cannot be empty',
      name: 'configProjectEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter base URL`
  String get configBaseURL {
    return Intl.message(
      'Enter base URL',
      name: 'configBaseURL',
      desc: '',
      args: [],
    );
  }

  /// `URL cannot be empty`
  String get configBaseURLEmpty {
    return Intl.message(
      'URL cannot be empty',
      name: 'configBaseURLEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter API key`
  String get configAPIkey {
    return Intl.message(
      'Enter API key',
      name: 'configAPIkey',
      desc: '',
      args: [],
    );
  }

  /// `API key cannot be empty`
  String get configAPIkeyEmpty {
    return Intl.message(
      'API key cannot be empty',
      name: 'configAPIkeyEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter external timeseries id`
  String get configTimeseriesId {
    return Intl.message(
      'Enter external timeseries id',
      name: 'configTimeseriesId',
      desc: '',
      args: [],
    );
  }

  /// `Timeseries id cannot be empty`
  String get configTimeseriesIdEmpty {
    return Intl.message(
      'Timeseries id cannot be empty',
      name: 'configTimeseriesIdEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter number of days in initial range`
  String get configNrOfDays {
    return Intl.message(
      'Enter number of days in initial range',
      name: 'configNrOfDays',
      desc: '',
      args: [],
    );
  }

  /// `Not able to access CDF project`
  String get configProjectFailed {
    return Intl.message(
      'Not able to access CDF project',
      name: 'configProjectFailed',
      desc: '',
      args: [],
    );
  }

  /// `Zoom In`
  String get chartZoomIn {
    return Intl.message(
      'Zoom In',
      name: 'chartZoomIn',
      desc: '',
      args: [],
    );
  }

  /// `Zoom Out`
  String get chartZoomOut {
    return Intl.message(
      'Zoom Out',
      name: 'chartZoomOut',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get chartReset {
    return Intl.message(
      'Reset',
      name: 'chartReset',
      desc: '',
      args: [],
    );
  }

  /// `Tooltip`
  String get chartTooltip {
    return Intl.message(
      'Tooltip',
      name: 'chartTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Markers`
  String get chartMarkers {
    return Intl.message(
      'Markers',
      name: 'chartMarkers',
      desc: '',
      args: [],
    );
  }

  /// `Maximum(on/off)`
  String get chartMaximum {
    return Intl.message(
      'Maximum(on/off)',
      name: 'chartMaximum',
      desc: '',
      args: [],
    );
  }

  /// `Minimum(on/off)`
  String get chartMinimum {
    return Intl.message(
      'Minimum(on/off)',
      name: 'chartMinimum',
      desc: '',
      args: [],
    );
  }

  /// `Average(on/off)`
  String get chartAverage {
    return Intl.message(
      'Average(on/off)',
      name: 'chartAverage',
      desc: '',
      args: [],
    );
  }

  /// `Raw Values < 1h (on/off)`
  String get chartRawValues {
    return Intl.message(
      'Raw Values < 1h (on/off)',
      name: 'chartRawValues',
      desc: '',
      args: [],
    );
  }

  /// `Continuous Variance(on/off)`
  String get chartContinuousVariance {
    return Intl.message(
      'Continuous Variance(on/off)',
      name: 'chartContinuousVariance',
      desc: '',
      args: [],
    );
  }

  /// `Discrete Variance(on/off)`
  String get chartDiscreteVariance {
    return Intl.message(
      'Discrete Variance(on/off)',
      name: 'chartDiscreteVariance',
      desc: '',
      args: [],
    );
  }

  /// `Count(on/off)`
  String get chartCount {
    return Intl.message(
      'Count(on/off)',
      name: 'chartCount',
      desc: '',
      args: [],
    );
  }

  /// `Interpolation(on/off)`
  String get chartInterpolation {
    return Intl.message(
      'Interpolation(on/off)',
      name: 'chartInterpolation',
      desc: '',
      args: [],
    );
  }

  /// `Step Interpolation(on/off)`
  String get chartStepInterpolation {
    return Intl.message(
      'Step Interpolation(on/off)',
      name: 'chartStepInterpolation',
      desc: '',
      args: [],
    );
  }

  /// `Total Variance(on/off)`
  String get chartTotalVariance {
    return Intl.message(
      'Total Variance(on/off)',
      name: 'chartTotalVariance',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'nb'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}