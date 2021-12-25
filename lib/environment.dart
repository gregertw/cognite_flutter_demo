/// Environment config variables to be passed in as part of CI/CD
class Environment {
  static const String firebaseVapidKey = String.fromEnvironment(
      "FIREBASE_VAPID_KEY",
      defaultValue:
          "BCKRpKeIZ7-0iWQGbOe6rcTGW1kvAGbyDNPH4Waw-Yzs2cRPJ5xsKUvoybBp2l7KIBx7W2SYh1T9kKh3dlG2KHw");
  // Default values here are client ids for the test version of first_app
  // in app stores and on the web.
  static const String clientIdAAD = String.fromEnvironment("CLIENTID_AAD",
      defaultValue: "b304cfeaaf2710cf250a");
  static const String secretAAD =
      String.fromEnvironment("SECRET_GITHUB_APP", defaultValue: "");
}
