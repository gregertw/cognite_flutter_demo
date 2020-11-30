# cognite-flutter.demo: Flutter demo app for Cognite Data Fusion (CDF)

**Maintainer**: Greger Wedel, https://github.com/gregertw

## Web version

This app can run on any Flutter supported platform. The [web version is hosted on Github](https://gregertw.github.io/cognite-flutter-demo-web/).

## About this repository

The purpose of this app is to demonstrate how to use Flutter to access the Cognite Data Fusion platform (CDF). You 
can get access a public data set hosted on CDF on [Open Industrial Data](https://openindustrialdata.com/get-started/). Get an access key, use `publicdata` as project and find a timeseries to explore, e.g. `pi:160623`is an example. 
**NOTE!!!** You will NOT find data the last 7 days, so you need to specify > 7 days in the configuration.

The app uses a Dart SDK that can be found at https://github.com/gregertw/cognite-sdk-dart.

## Syncfusion

This app uses Syncfusion packages for displaying charts under a community license. In order to use this repository and build your own app using the same code, you either have to replace the Syncfusion packages with an alternative (e.g. https://pub.dev/packages/charts_flutter) or you have to get a license. 

See more details on:
https://github.com/syncfusion/flutter-widgets/tree/master/packages/syncfusion_flutter_core

**NOTE!!!** The current syncfusion version has an issue with nullsafety. In the syncfusion_flutter_core package, the
pubspec.yaml file has `pedantic: ">=1.9.0 <1.9.9"` as a dependency. This has to be changed to `pedantic: ^1.10.0-nullsafety`. You can clone the 18.3.51 package in the directory above this app and do the change in 
`packages/syncfusion_flutter_core/pubspec.yaml`.

## Disclaimer

Although developed by an employee of Cognite, this SDK has been developed as part
of a personal tinkering project, and there are no guarantees that this SDK will be
kept updated or extended. It is shared Apache-2 licensed for the benefit of anybody 
who may have a need for a Dart SDK or may want to contribute.

## Contributing

All activity related to this SDK is on Github. Please use the issue tracker to submit
bugs or feature suggestions, or even better: submit a PR!
