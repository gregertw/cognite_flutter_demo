/// Environment config variables to be passed in as part of CI/CD
class Environment {
  static const String firebaseVapidKey = String.fromEnvironment(
      "FIREBASE_VAPID_KEY",
      defaultValue:
          "BCKRpKeIZ7-0iWQGbOe6rcTGW1kvAGbyDNPH4Waw-Yzs2cRPJ5xsKUvoybBp2l7KIBx7W2SYh1T9kKh3dlG2KHw");
  static const String clientIdAAD = String.fromEnvironment("CLIENTID_AAD",
      defaultValue: "05dc6b4f-5197-4ab9-9bd3-a515035237bf");
  static const String secretAAD =
      String.fromEnvironment("SECRET_AAD", defaultValue: "");
}
