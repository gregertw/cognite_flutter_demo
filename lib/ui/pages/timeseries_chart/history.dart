import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cognite_cdf_demo/models/heartbeatstate.dart';

void historyDialog(BuildContext context) {
  var hbm = Provider.of<HeartBeatModel>(context, listen: false);
  List<Widget> dialogs = List<Widget>();
  int i = 1;
  hbm.apiClient.history.forEach((element) {
    dialogs.add(SimpleDialogOption(
      child: Text(
          "$i: ${element.path} (${DateTime.fromMillisecondsSinceEpoch(element.timestampStart).toLocal().toIso8601String()})"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 4.0,
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .focusedBorder
                        .borderSide
                        .color),
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text("${element.method} - ${element.path}"),
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * (4 / 5),
                  width: MediaQuery.of(context).size.width * (4 / 5),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      (element.method == 'GET')
                          ? ListTile(
                              title: Text('Request - GET'),
                            )
                          : ExpansionTile(
                              title: Text('Request'),
                              children: [
                                Text(
                                    "${JsonEncoder.withIndent('  ').convert(element.request)} ")
                              ],
                            ),
                      ExpansionTile(
                        title: Text('Response'),
                        children: [
                          Text(
                              "${JsonEncoder.withIndent('  ').convert(element.response)} ")
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
  });
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('Request History'),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 4.0,
              color: Theme.of(context)
                  .inputDecorationTheme
                  .focusedBorder
                  .borderSide
                  .color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        children: dialogs,
      );
    },
  );
}
