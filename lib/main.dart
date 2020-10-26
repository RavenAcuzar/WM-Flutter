import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wednesday_message/provider/connection_provider.dart';
import 'package:wednesday_message/routes/Routes.dart';

import 'module/home/home_page_view.dart';
import 'module/login/login_page_view.dart';

import 'module/playlist/playlist_page_view.dart';
import 'package:wednesday_message/util/globals.dart' as global;



Map<int, Color> color =
{
50:Color.fromRGBO(136,14,79, .1),
100:Color.fromRGBO(136,14,79, .2),
200:Color.fromRGBO(136,14,79, .3),
300:Color.fromRGBO(136,14,79, .4),
400:Color.fromRGBO(136,14,79, .5),
500:Color.fromRGBO(136,14,79, .6),
600:Color.fromRGBO(136,14,79, .7),
700:Color.fromRGBO(136,14,79, .8),
800:Color.fromRGBO(136,14,79, .9),
900:Color.fromRGBO(136,14,79, 1),
};

void main() async {
  await GetStorage.init();
  GetStorage().writeIfNull(global.isLoggedinKey, false);
  runApp(WMApp());
  }


class WMApp extends StatefulWidget {
  @override
  _WMAppState createState() => _WMAppState();
}

class _WMAppState extends State<WMApp> {
  @override
  void initState() {
    super.initState();
    ConnectivityService().init();
    print('INITIATE MAIN');
  }
  @override
  void dispose() {
    ConnectivityService().dispose();
    print('DISPOSED MAIN');
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom = MaterialColor(0xFF0D3A79, color);
    return MaterialApp(
    theme: new ThemeData(primarySwatch: colorCustom, canvasColor: Colors.grey[300]),
    // home: SplashScreen(),
    initialRoute: '/home',
    routes: {
      Routes.home: (context) => HomePage(),
      Routes.login: (context) => LoginPage(),
      //Routes.now_playing: (context) => NowPlayingPage(),
      Routes.playlist: (context) => PlaylistPage(),
      //Routes.search: (context) => SearchPage(),
    },
  );
  }
}


