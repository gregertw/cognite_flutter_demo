import 'package:flutter/material.dart';
import 'package:first_app/models/appstate.dart';
import 'package:provider/provider.dart';
import 'package:first_app/generated/l10n.dart';

class ConfigPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context, listen: false);
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
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                child: new Column(children: <Widget>[
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
                        labelText: "Enter project",
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
                          return "Project cannot be empty";
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
                        labelText: "Enter base URL",
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
                          return "URL cannot be empty";
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
                        labelText: "Enter API key",
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
                          return "API key cannot be empty";
                        } else {
                          return null;
                        }
                      },
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
                        labelText: "Enter external timeseries id",
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
                          return "Timeseries id cannot be empty";
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
                        labelText: "Enter number of days in initial range",
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
                    child: RaisedButton(
                      textTheme: Theme.of(context).buttonTheme.textTheme,
                      color: Theme.of(context).buttonColor,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          appState.verifyCDF();
                          Navigator.of(context).popAndPushNamed('/HomePage');
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Not able to access CDF project')));
                        }
                      },
                      child: Text('Ok'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
