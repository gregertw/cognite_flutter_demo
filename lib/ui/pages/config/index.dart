import 'package:flutter/material.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/generated/l10n.dart';
import 'package:cognite_flutter_demo/globals.dart';

class ConfigPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context, listen: false);
    appState.cdfNrOfDays = (MediaQuery.of(context).size.width / 160).round();
    log.i('Media width: ${MediaQuery.of(context).size.width}');
    final logo = Padding(
      padding: EdgeInsets.all(20.0),
      child: Image.asset('assets/actingweb-header-small.png'),
    );
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey, Theme.of(context).primaryColor]),
        ),
        child: SingleChildScrollView(
          key: Key('ConfigPage_ScrollView'),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    logo,
                    new Padding(padding: EdgeInsets.only(top: 10.0)),
                    new Text(
                      S.of(context).configConfigureCDF,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    new Padding(padding: EdgeInsets.only(top: 10.0)),
                    new ListTile(
                      leading: const Icon(Icons.pages_rounded),
                      title: new TextFormField(
                        cursorColor: Theme.of(context).accentColor,
                        initialValue: appState.cdfProject,
                        decoration: new InputDecoration(
                          labelText: S.of(context).configProject,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        onSaved: (String val) {
                          appState.cdfProject = val;
                        },
                        validator: (val) {
                          if (val.length == 0) {
                            return S.of(context).configProjectEmpty;
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.text,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.web_rounded),
                      title: new TextFormField(
                        cursorColor: Theme.of(context).accentColor,
                        initialValue: appState.cdfURL,
                        decoration: new InputDecoration(
                          labelText: S.of(context).configBaseURL,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        onSaved: (String val) {
                          appState.cdfURL = val;
                        },
                        validator: (val) {
                          if (val.length == 0) {
                            return S.of(context).configBaseURLEmpty;
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.url,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.security_rounded),
                      title: new TextFormField(
                        cursorColor: Theme.of(context).accentColor,
                        initialValue: appState.cdfApiKey,
                        decoration: new InputDecoration(
                          labelText: S.of(context).configAPIkey,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        onSaved: (String val) {
                          appState.cdfApiKey = val;
                        },
                        validator: (val) {
                          if (val.length == 0) {
                            return S.of(context).configAPIkeyEmpty;
                          } else {
                            return null;
                          }
                        },
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.timer),
                      title: new TextFormField(
                        cursorColor: Theme.of(context).accentColor,
                        initialValue: appState.cdfTimeSeriesId,
                        decoration: new InputDecoration(
                          labelText: S.of(context).configTimeseriesId,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onSaved: (String val) {
                          appState.cdfTimeSeriesId = val;
                        },
                        validator: (val) {
                          if (val.length == 0) {
                            return S.of(context).configTimeseriesIdEmpty;
                          } else {
                            return null;
                          }
                        },
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.timer),
                      title: new TextFormField(
                        cursorColor: Theme.of(context).accentColor,
                        initialValue: appState.cdfNrOfDays.toString(),
                        decoration: new InputDecoration(
                          labelText: S.of(context).configNrOfDays,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (String val) {
                          appState.cdfNrOfDays = int.parse(val);
                        },
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    new Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: ElevatedButton(
                        key: Key('LocationPage_StartListeningButton'),
                        style: ElevatedButton.styleFrom(
                          elevation: 20.0,
                          onPrimary: Theme.of(context).primaryColorLight,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            appState.verifyCDF();
                            Navigator.of(context).popAndPushNamed('/HomePage');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(S.of(context).configProjectFailed)));
                          }
                        },
                        child: Text(S.of(context).okButton),
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
