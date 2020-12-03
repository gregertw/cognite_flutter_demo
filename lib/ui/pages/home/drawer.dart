import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cognite_cdf_demo/models/appstate.dart';
import 'package:cognite_cdf_demo/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageDrawer extends StatelessWidget {
  void _showFlushbar(BuildContext context, String title, String msg,
      {String linkText}) {
    if (linkText == null) {
      Flushbar(
        title: title,
        message: msg,
        icon: Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.blue.shade300,
        ),
        leftBarIndicatorColor: Colors.blue.shade300,
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      Flushbar(
        title: title,
        message: msg,
        mainButton: FlatButton(
          onPressed: () {
            launch(linkText);
          },
          child: Text(
            linkText,
            style: TextStyle(color: Colors.amber),
          ),
        ),
        icon: Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.blue.shade300,
        ),
        leftBarIndicatorColor: Colors.blue.shade300,
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          buildDrawerHeader(context),
          ListTile(
            key: Key("DrawerMenuTile_Config"),
            title: Text(S.of(context).drawerConfig),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).popAndPushNamed('/ConfigPage');
            },
          ),
          ListTile(
            key: Key("DrawerMenuTile_Localisation"),
            title: Text(S.of(context).drawerLocalisation),
            subtitle: Text(appState.locale),
            onTap: () {
              // Here you should have a widget to select among
              // supported locales. This is just a quick and dirty
              // switch
              appState.switchLocale();
              _showFlushbar(
                  context,
                  S.of(context).drawerLocalisationResultTitle,
                  S.of(context).drawerLocalisationResultMsg + appState.locale);
            },
          ),
          ListTile(
            key: Key("DrawerMenuTile_About"),
            title: Text(S.of(context).drawerAbout),
            onTap: () {
              _showFlushbar(context, S.of(context).drawerAboutTitle,
                  S.of(context).drawerAboutMessage,
                  linkText:
                      "https://github.com/gregertw/cognite-flutter-demo/issues");
            },
          ),
          ListTile(
            key: Key('DrawerMenuTile_LogOut'),
            leading: new Icon(
              Icons.exit_to_app,
              color: Color(0xe81751ff),
            ),
            trailing: Text(S.of(context).logoutButton),
            onTap: () {
              appState.logOut();
            },
          ),
        ],
      ),
    );
  }
}

Widget buildDrawerHeader(BuildContext context) {
  var appState = Provider.of<AppStateModel>(context);
  return UserAccountsDrawerHeader(
    key: Key("DrawerMenu_Header"),
    accountName: Text(appState.cdfProject == null
        ? S.of(context).drawerHeaderInitialName
        : appState.cdfProject),
    accountEmail: Text(appState.cdfLoggedIn == true
        ? '(${S.of(context).drawerHeaderLoggedIn})'
        : '(${S.of(context).drawerHeaderLoggedOut})'),
    onDetailsPressed: () => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        var container = Container(
          key: Key("DrawerMenu_BottomSheet"),
          alignment: Alignment.center,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
          ),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(S.of(context).drawerProjectName),
                subtitle: Text(appState.cdfProject == null
                    ? S.of(context).drawerEmptyProject
                    : appState.cdfProject),
              ),
              ListTile(
                title: Text(S.of(context).drawerButtomSheetProjectId),
                subtitle: Text(appState.cdfProjectId == null
                    ? ''
                    : appState.cdfProjectId.toString()),
              ),
              ListTile(
                title: Text(S.of(context).drawerButtomSheetApiKeyId),
                subtitle: Text(appState.cdfApiKeyId == null
                    ? ''
                    : appState.cdfApiKeyId.toString()),
              ),
            ],
          ),
        );
        return container;
      },
    ),
    currentAccountPicture: CircleAvatar(
      child: Image.asset('assets/actingweb-header-small.png'),
      backgroundColor: Colors.white,
    ),
  );
}
