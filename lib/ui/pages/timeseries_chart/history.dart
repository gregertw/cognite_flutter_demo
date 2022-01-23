import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';

void historyDialog(BuildContext context) {
  var hbm = Provider.of<HeartBeatModel>(context, listen: false);
  List<Widget> dialogs = [];
  int i = 1;
  for (var element in hbm.apiClient.history) {
    dialogs.add(SimpleDialogOption(
      child: Text(
          "$i: ${element.path} (${DateTime.fromMillisecondsSinceEpoch(element.timestampStart!).toLocal().toIso8601String()})"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text("${element.method} - ${element.path}"),
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * (4 / 5),
                  width: MediaQuery.of(context).size.width * (4 / 5),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      (element.method == 'GET')
                          ? const ListTile(
                              title: Text('Request - GET'),
                            )
                          : ExpansionTile(
                              title: const Text('Request'),
                              children: [
                                Text(
                                    "${const JsonEncoder.withIndent('  ').convert(element.request)} ")
                              ],
                            ),
                      ExpansionTile(
                        title: const Text('Response'),
                        children: [
                          Text(
                              "${const JsonEncoder.withIndent('  ').convert(element.response)} ")
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    ));
    i++;
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Request History'),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        children: dialogs,
      );
    },
  );
}
