import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'tokenlogin.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    final logo = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Image.asset('assets/actingweb-header-small.png'),
    );
    var welcomeText = AppLocalizations.of(context)!.loginWelcomeText;
    final welcome = Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(
        welcomeText,
      ),
    );
    Column body;
    if (appState.cdfCluster.isEmpty) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo,
          Container(
            width: 400.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: const ClusterPage(),
          ),
        ],
      );
    } else if (!appState.authenticated) {
      if (appState.manualToken) {
        body = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [logo, welcome, TokenLoginPage()],
        );
      } else {
        body = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [logo, welcome, const AuthPage()],
        );
      }
    } else if (appState.cdfProject.isEmpty) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
      );
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [logo, welcome],
      );
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(10.0),
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
    final List<DropdownMenuItem<String>> dropDownMenuItems =
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
      leading: const Icon(Icons.timer),
      trailing: DropdownButton<String>(
        key: const Key('ProjectDropDownMenu'),
        items: dropDownMenuItems,
        underline: Container(),
        value: (appState.cdfProject != '')
            ? appState.cdfProject
            : appState.cdfProjects?[0],
        onChanged: (value) {
          appState.cdfProject = value;
          appState.initialiseCDF();
        },
      ),
    );
  }
}

class ClusterPage extends StatelessWidget {
  const ClusterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      SizedBox(
        width: 350.0,
        height: 25.0,
        child: Theme(
          data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                  selectionColor: Colors.blueAccent)),
          child: TextFormField(
            key: const Key('ClusterTextButton'),
            autocorrect: false,
            autofocus: true,
            textAlign: TextAlign.end,
            cursorColor: Theme.of(context).colorScheme.onPrimary,
            initialValue:
                appState.cdfCluster.isEmpty ? 'api' : appState.cdfCluster,
            decoration: InputDecoration(
              labelText: 'CDF Cluster',
              labelStyle: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontFamily: "Poppins",
              ),
              isDense: false,
              contentPadding: EdgeInsets.zero,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onPrimary),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            keyboardType: TextInputType.text,
            onFieldSubmitted: (String? value) {
              appState.cdfCluster = value;
            },
          ),
        ),
      )
    ]);
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    return Container(
      constraints: const BoxConstraints(maxHeight: 260.0, maxWidth: 200.0),
      alignment: Alignment.topCenter,
      child: Form(
        key: formKey,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  key: const Key('LoginPage_LoginButton'),
                  style: TextButton.styleFrom(
                      minimumSize: const Size(200.0, 40.0),
                      maximumSize: const Size(250.0, 40.0),
                      backgroundColor: Theme.of(context).focusColor,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    formKey.currentState!.validate();
                    appState.authorize();
                  },
                  child: Text(AppLocalizations.of(context)!.loginButton),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 150.0,
                      height: 20.0,
                      child: TextFormField(
                        autocorrect: false,
                        textAlign: TextAlign.end,
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        initialValue: appState.aadId.isNotEmpty
                            ? appState.aadId
                            : 'common',
                        decoration: InputDecoration(
                          labelText: 'AAD id',
                          labelStyle: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            fontFamily: "Poppins",
                          ),
                          isDense: false,
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          appState.aadId = val ?? 'common';
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                TextButton(
                  key: const Key('LoginPage_LoginTokenButton'),
                  style: TextButton.styleFrom(
                      minimumSize: const Size(200.0, 40.0),
                      maximumSize: const Size(250.0, 40.0),
                      backgroundColor: Theme.of(context).focusColor,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    // Flag the use of a manual token
                    appState.manualToken = true;
                  },
                  child: Text(
                    AppLocalizations.of(context)!.loginButtonToken,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                BackButton(
                  onPressed: () => appState.logOut(),
                ),
              ],
            )),
      ),
    );
  }
}
