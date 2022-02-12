# cognite-flutter.demo: Flutter demo app for Cognite Data Fusion (CDF)

**Maintainer**: Greger Wedel, <https://github.com/gregertw>

[![Codemagic build status](https://api.codemagic.io/apps/60ee9f3aab96b9ef01461e55/60ee9f3aab96b9ef01461e54/status_badge.svg)](https://codemagic.io/apps/60ee9f3aab96b9ef01461e55/60ee9f3aab96b9ef01461e54/latest_build)

## Web version

This app can run on any Flutter supported platform. The [web version is hosted on Github](https://gregertw.github.io/cognite-flutter-demo-web/).

## iOS and Android versions

Due to the work related to releasing official apps, the iOS and Adroid versions of this demo app are available as tests
previews. You can download the Android version from <https://www.dropbox.com/s/7km191vo48vlnig/cognite_flutter_demo.apk?dl=1> and the iOS app is available from Testflight at <https://testflight.apple.com/join/pQvpBwxx>.

## MacOS version

A MacOS installer can be [downloaded](https://www.dropbox.com/sh/yw7b5x51x1lkosz/AABm9t96G3sCSSwOia76mqBRa?dl=1)
and copied directly to your Application folder.

## About this repository

The purpose of this app is to demonstrate how to use Flutter to access the Cognite Data Fusion platform (CDF). Log in with
your Azure ActiveDirectory user that has access to a CDF project. You also need an external id to a timeseries to explore.

The app uses a Dart SDK that can be found at <https://github.com/gregertw/cognite-sdk-dart>.

## Syncfusion

This app uses Syncfusion packages for displaying charts under a community license. In order to use this repository and build your own app using the same code, you either have to replace the Syncfusion packages with an alternative (e.g. <https://pub.dev/packages/charts_flutter>) or you have to get a license.

See more details on:
<https://github.com/syncfusion/flutter-widgets/tree/master/packages/syncfusion_flutter_core>

## Disclaimer

Although developed by an employee of Cognite, this SDK has been developed as part
of a personal tinkering project, and there are no guarantees that this SDK will be
kept updated or extended. It is shared Apache-2 licensed for the benefit of anybody
who may have a need for a Dart SDK or may want to contribute.

## Contributing

All activity related to this SDK is on Github. Please use the issue tracker to submit
bugs or feature suggestions, or even better: submit a PR!
