import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';

class ReloadMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var hbm = Provider.of<HeartBeatModel>(context, listen: false);
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              child: InkWell(
                key: Key('HomePage_ReloadInkwell'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: hbm.loading,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 15, maxHeight: 15),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
