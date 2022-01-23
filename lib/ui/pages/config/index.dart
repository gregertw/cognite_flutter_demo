import 'package:cognite_flutter_demo/ui/pages/login/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/globals.dart';

class ConfigPage extends StatelessWidget {
  ConfigPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context, listen: false);
    if (appState.cdfNrOfDays == 0) {
      appState.cdfNrOfDays = (MediaQuery.of(context).size.width / 160).round();
    }
    log.i('Media width: ${MediaQuery.of(context).size.width}');
    final logo = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Image.asset('assets/actingweb-header-small.png'),
    );
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey, Theme.of(context).primaryColor]),
        ),
        child: SingleChildScrollView(
          key: const Key('ConfigPage_ScrollView'),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    logo,
                    const Padding(padding: EdgeInsets.only(top: 10.0)),
                    Text(
                      AppLocalizations.of(context)!.configConfigureCDF,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10.0)),
                    const ProjectPage(),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        initialValue: appState.cdfTimeSeriesId,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.configTimeseriesId,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onSaved: (String? val) {
                          appState.cdfTimeSeriesId = val;
                        },
                        validator: (val) {
                          if (val!.isEmpty) {
                            return AppLocalizations.of(context)!
                                .configTimeseriesIdEmpty;
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        initialValue: appState.cdfNrOfDays.toString(),
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.configNrOfDays,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (String? val) {
                          appState.cdfNrOfDays = int.parse(val!);
                        },
                        style: const TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: ElevatedButton(
                        key: const Key('LocationPage_OkButton'),
                        style: ElevatedButton.styleFrom(
                          elevation: 20.0,
                          onPrimary: Theme.of(context).primaryColorLight,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.of(context).popAndPushNamed('/HomePage');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .configProjectFailed)));
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.okButton),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
