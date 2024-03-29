import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognite_flutter_demo/models/heartbeatstate.dart';

class ReloadMarker extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  ReloadMarker({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 50,
            child: InkWell(
              key: const Key('HomePage_ReloadInkwell'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: Provider.of<HeartBeatModel>(context, listen: true)
                        .loading,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 15, maxHeight: 15),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
