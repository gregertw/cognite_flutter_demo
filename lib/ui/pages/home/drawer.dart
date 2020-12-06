import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';

class HomePageDrawer extends StatelessWidget {
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
              showSimpleNotification(
                  Text(S.of(context).drawerLocalisationResultTitle),
                  leading: Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Colors.blue.shade300,
                  ),
                  subtitle: Text(S.of(context).drawerLocalisationResultMsg +
                      appState.locale),
                  duration: Duration(seconds: 4),
                  position: NotificationPosition.bottom);
            },
          ),
          ListTile(
            key: Key("DrawerMenuTile_About"),
            title: Text(S.of(context).drawerAbout),
            onTap: () {
              showSimpleNotification(Text(S.of(context).drawerAboutTitle),
                  leading: Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Colors.blue.shade300,
                  ), trailing: Builder(builder: (context) {
                return FlatButton(
                  textColor: Colors.yellow,
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                    launch(
                        "https://github.com/gregertw/cognite-flutter-demo/issues");
                  },
                  child: Text(
                    "https://github.com/gregertw/cognite-flutter-demo/issues",
                    style: TextStyle(color: Colors.amber),
                  ),
                );
              }),
                  subtitle: Text(S.of(context).drawerAboutMessage),
                  duration: Duration(seconds: 4),
                  position: NotificationPosition.bottom);
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
