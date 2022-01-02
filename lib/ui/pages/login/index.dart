import 'package:flutter/material.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    final logo = Padding(
      padding: const EdgeInsets.all(40.0),
      child: Image.asset('assets/actingweb-header-small.png'),
    );
    var welcomeText = AppLocalizations.of(context)!.loginWelcomeText;
    final welcome = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        welcomeText,
      ),
    );
    Column body;
    if (appState.cdfCluster.isEmpty) {
      body = Column(
        children: [
          logo,
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10)),
            child: ClusterPage(),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else if (!appState.authenticated) {
      body = Column(
        children: [logo, welcome, const AuthPage()],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else if (appState.cdfProject.isEmpty) {
      body = Column(
        children: [
          logo,
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10)),
            child: const ProjectPage(),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      body = Column(
        children: [logo, welcome],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey, Theme.of(context).primaryColor]),
        ),
        child: body,
      ),
    );
  }
}

class ProjectPage extends StatelessWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    final List<DropdownMenuItem<String>> _dropDownMenuItems =
        appState.cdfProjects!
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              ),
            )
            .toList();
    return ListTile(
      title: const Text('CDF Project'),
      trailing: DropdownButton<String>(
        key: const Key('ProjectDropDownMenu'),
        items: _dropDownMenuItems,
        underline: Container(),
        value: appState.cdfProjects![0],
        onChanged: (value) {
          appState.cdfProject = value;
          appState.initialiseCDF();
        },
      ),
    );
  }
}

class ClusterPage extends StatelessWidget {
  ClusterPage({Key? key}) : super(key: key);

  static const menuItems = <String>['greenfield', 'bluefield', 'api'];
  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map(
        (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    return ListTile(
      title: const Text('CDF Cluster'),
      trailing: DropdownButton<String>(
        key: const Key('ClusterDropDownButton'),
        items: _dropDownMenuItems,
        underline: Container(),
        value: appState.cdfCluster.isEmpty ? 'api' : appState.cdfCluster,
        onChanged: (value) {
          // When we change cluster, we need to reauthenticate
          appState.logOut();
          appState.cdfCluster = value;
        },
      ),
    );
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      width: 120.0,
      constraints: const BoxConstraints(maxHeight: 200.0, maxWidth: 150.0),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            key: const Key('LoginPage_LoginButton'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(15),
            ),
            onPressed: () {
              Provider.of<AppStateModel>(context, listen: false)
                  .authorize('aad');
            },
            child: Text(AppLocalizations.of(context)!.loginButton),
          )),
    );
  }
}
