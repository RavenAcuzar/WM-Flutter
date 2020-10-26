import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget customBackButton(BuildContext context, [passValue]) {
  return Positioned(
    top: 0.0,
    left: 0.0,
    right: 0.0,
    child: AppBar(
      title: Text(''), // You can add title here
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () async {
          if (MediaQuery.of(context).orientation == Orientation.landscape) {
            await SystemChrome.setPreferredOrientations(
                [DeviceOrientation.portraitUp]);
          }
          if (passValue != null)
              Navigator.pop(context, passValue);
            else
              Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.transparent, //You can make this transparent
      elevation: 0.0, //No shadow
    ),
  );
}
