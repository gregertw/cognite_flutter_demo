import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';

class AADOauth2Client extends OAuth2Client {
  AADOauth2Client(String aadId,
      {required String redirectUri, required String customUriScheme})
      : super(
            authorizeUrl:
                'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
            tokenUrl:
                'https://login.microsoftonline.com/common/oauth2/v2.0/token',
            redirectUri: redirectUri,
            customUriScheme: customUriScheme,
            credentialsLocation: CredentialsLocation.body) {
    if (aadId != 'common' && aadId.isNotEmpty) {
      authorizeUrl =
          'https://login.microsoftonline.com/$aadId/oauth2/v2.0/authorize';
      tokenUrl = 'https://login.microsoftonline.com/$aadId/oauth2/v2.0/token';
    }
  }

  List<String> scopesAPI = [];

  /// Refreshes an Access Token issuing a refresh_token grant to the OAuth2 server.
  @override
  Future<AccessTokenResponse> refreshToken(String refreshToken,
      {required String clientId,
      String? clientSecret,
      dynamic httpClient,
      List<String>? scopes}) async {
    final Map params =
        getRefreshUrlParams(refreshToken: refreshToken, scopes: scopesAPI);

    var response = await _performAuthorizedRequest(
        url: tokenUrl,
        clientId: clientId,
        params: params,
        httpClient: httpClient);

    return AccessTokenResponse.fromHttpResponse(response);
  }
}

/// Performs a post request to the specified [url],
/// adding authentication credentials as described here: https://tools.ietf.org/html/rfc6749#section-2.3
Future<http.Response> _performAuthorizedRequest(
    {required String url,
    required String clientId,
    Map? params,
    Map<String, String>? headers,
    httpClient}) async {
  httpClient ??= http.Client();

  headers ??= {};
  params ??= {};

  if (clientId.isNotEmpty) {
    params['client_id'] = clientId;
  }

  var response =
      await httpClient.post(Uri.parse(url), body: params, headers: headers);

  return response;
}

/// Returns the parameters needed for the refresh token request
Map<String, String> getRefreshUrlParams(
    {required String refreshToken, required List<String> scopes}) {
  final params = <String, String>{
    'grant_type': 'refresh_token',
    'refresh_token': refreshToken,
    'scope': serializeScopes(scopes)
  };

  return params;
}

String serializeScopes(List<String> scopes) {
  return scopes.map((s) => s.trim()).join(' ');
}
