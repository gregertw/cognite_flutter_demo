import 'package:flutter/material.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:provider/provider.dart';

class TokenLoginPage extends StatelessWidget {
  TokenLoginPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    return Container(
      alignment: Alignment.center,
      height: 80.0,
      width: 500.0,
      constraints: const BoxConstraints(maxHeight: 80.0, maxWidth: 500.0),
      child: ListTile(
        leading: Icon((appState.authenticated ? Icons.check_box : Icons.error)),
        trailing: BackButton(
          onPressed: () => appState.manualToken = false,
        ),
        title: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: '',
            style: const TextStyle(
              fontFamily: "Poppins",
            ),
            decoration: InputDecoration(
              labelText: 'Token/API key',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            obscureText: true,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (String? val) {
              appState.logIn(val ?? '');
            },
          ),
        ),
      ),
    );
  }
}
