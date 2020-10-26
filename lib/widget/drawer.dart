import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wednesday_message/network/api_user_service.dart';
import 'package:wednesday_message/network/api_video_service.dart';
import 'package:wednesday_message/routes/Routes.dart';

class AppDrawer extends StatelessWidget {
  final UserService _user = UserService();
  
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Color.fromARGB(
            255, 13, 58, 121), //This will change the drawer background to blue.
        //other styles
      ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),
            Divider(),
            _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                route: Routes.home,
                context: context),
            if (_user.getUserId() != null)
              _createDrawerItem(
                  icon: Icons.playlist_play,
                  text: 'Playlist',
                  route: Routes.playlist,
                  context: context),
            Divider(),
            if (_user.getUserId() != null)
              ListTile(
                leading: Icon(Icons.power_settings_new, color: Colors.white),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Log out?'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('No'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CupertinoDialogAction(
                            child: Text('Yes'),
                            onPressed: () async {
                              _user.logout();
                              VideoService().clear();
                              NavigatorState navigator = Navigator.of(context);
                              Route route = ModalRoute.of(context);
                              await _removeBelow(navigator, route);
                              await navigator.pushReplacementNamed(Routes.home);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            if (_user.getUserId() == null)
              _createDrawerItem(
                icon: Icons.exit_to_app,
                text: 'Login',
                route: Routes.login,
                context: context,
                isPushTypeNav: true,
              ),
          ],
        ),
      ),
    );
  }
  Future<void> _removeBelow(NavigatorState nav, Route route) async {
    nav.removeRouteBelow(route);
    await Future.delayed(Duration(milliseconds: 50)); //delay to dispose home
  }

  Widget _createHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Center(
        child: Image(
          image: AssetImage('assets/images/sidemenu_banner.png'),
        ),
      ),
    );
  }

  Widget _createDrawerItem(
      {IconData icon,
      String text,
      String route,
      BuildContext context,
      bool isPushTypeNav = false}) {
        print(ModalRoute.of(context).settings.name);
    return Container(
      color: ModalRoute.of(context).settings.name == route
          ? Colors.white24
          : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        onTap: isPushTypeNav
            ? () => Navigator.popAndPushNamed(context, route)
            : () => {
                  if (ModalRoute.of(context).settings.name != route)
                    Navigator.pushReplacementNamed(context, route)
                  else
                    Navigator.pop(context),
                },
      ),
    );
  }
}
