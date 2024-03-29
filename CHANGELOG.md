# CHANGELOG

## Dec 11, 2022

* Bump to version 0.5.4+9
* Upgrade to Flutter 3.3.8
* Fix api scope request issue
* Change to new ActiveDirectory provider and app registration
* Allow any CDF cluster (not predefined list)
* Refactor auth to use AAD more directly

## Feb 12, 2022

* Add MacOS support
* Bump to version 0.5.3+8

## Jan 23 2022

* Add support for ActiveDirectory ID so you can log in from guest AAD or common
* Refactor aad auth to be just a sub-class to oauth2_client
* Bump version to 0.5.2+7

## Jan 14, 2022

* Add token login as option in login flow, improve error handling
* Fix error in AndroidManifest package names
* Upgrade syncfusion to 19.4.41
* Introduce failed as flag for failed loads in heartbeatstate
* Bump version to 0.5.1+6

## Jan 2, 2022

* Migratated to new Flutter 2.8.1 compatible template (first_app)
* Got new OAuth2 support with the first_app template
* Extended to support Azure ActiveDirectory
* Fix bug where granularity was included in request for raw datapoints
* Bump to version 0.5.0+5

## Jul 11, 2021

* Another full update of dependencies
* Add new form field for token to support OpenID Connect token
* Various cleanups due to updates to CDF SDK null-safety updates
* Update style.dart to be a simplified version to facilitate easier updates later
* Upgrade to version 0.4.0

## Jun 6, 2021

* Migrate to null-safety
* Upgrade all dependencies

## Jan 30, 2020

* Clean up template-dir with screenshots

## Dec 15, 2020

* Increase test coverage with more widget tests
* Fix [#2](https://github.com/gregertw/cognite_flutter_demo/issues/2)
* Add support for double-tap/click to zoom and buttons to pan [#3](https://github.com/gregertw/cognite_flutter_demo/issues/3)
* Improve build predictibility for Android (still need to do flutter build apk --debug, then --profile before flutter build apk)
* Release of 0.3.0

## Nov 30, 2020

* Initial version 0.2.0 available on Github Pages
