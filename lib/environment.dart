/// Environment config variables to be passed in as part of CI/CD
class Environment {
  static const String firebaseVapidKey = String.fromEnvironment(
      "FIREBASE_VAPID_KEY",
      defaultValue:
          "BCKRpKeIZ7-0iWQGbOe6rcTGW1kvAGbyDNPH4Waw-Yzs2cRPJ5xsKUvoybBp2l7KIBx7W2SYh1T9kKh3dlG2KHw");
  static const String clientIdAAD = String.fromEnvironment("CLIENTID_AAD",
      defaultValue: "1d14eab0-4754-4be1-b9c6-63fdadddf778");
  static const String secretAAD =
      String.fromEnvironment("SECRET_AAD", defaultValue: "");
}
