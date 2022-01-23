import 'package:flutter/material.dart';
import 'package:cognite_flutter_demo/models/appstate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TokenLoginPage extends StatelessWidget {
  TokenLoginPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppStateModel>(context);
    return Container(
      alignment: Alignment.center,
      height: 170.0,
      width: 500.0,
      constraints: const BoxConstraints(maxHeight: 170.0, maxWidth: 500.0),
      child: ListTile(
        leading: Icon((appState.authenticated ? Icons.check_box : Icons.error)),
        trailing: BackButton(
          onPressed: () => appState.manualToken = false,
        ),
        title: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: '',
                style: const TextStyle(
                  fontFamily: "Poppins",
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.loginButtonField,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.loginButtonFieldError;
                  }
                  appState.logIn(value);
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.loginStatusMsg)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(AppLocalizations.of(context)!.loginError)),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.loginButtonToken),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
