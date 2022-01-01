import 'package:flutter/material.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //var appState = Provider.of<AppStateModel>(context);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey, Theme.of(context).primaryColor]),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Image.asset('assets/actingweb-header-small.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.loginWelcomeText,
              ),
            ),
            Container(
              height: 80.0,
              width: 120.0,
              constraints:
                  const BoxConstraints(maxHeight: 200.0, maxWidth: 150.0),
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
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
