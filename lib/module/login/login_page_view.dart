import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wednesday_message/network/api_user_service.dart';
import 'package:wednesday_message/routes/Routes.dart';
import 'package:wednesday_message/widget/backButton.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserService _apiUserService = UserService();
  VideoPlayerController _controller;
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showError = false;
  String _errorMsg = '';
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/WMApp15s.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size?.width ?? 0,
                height: _controller.value.size?.height ?? 0,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Color.fromARGB(150, 0, 0, 0)),
          ),
          customBackButton(context),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 55.0),
            child: Form(
              key: _formKey,
              child: loginFormUI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginFormUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        appIcon(),
        if (_showError)
          Center(
            child: Text(
              _errorMsg,
              style: TextStyle(
                color: Colors.red[200],
                fontSize: 18.0,
              ),
            ),
          ),
        textField(
          placeholder: 'Username',
          txtController: _userNameCtrl,
        ),
        textField(
          placeholder: 'Password',
          typePassword: true,
          txtController: _passwordCtrl,
        ),
        submitButton(),
      ],
    );
  }

  Widget textField(
      {String placeholder,
      bool typePassword = false,
      TextEditingController txtController}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Container(
        height: 50,
        child: TextFormField(
          controller: txtController,
          cursorColor: Colors.white,
          keyboardType: typePassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          style: TextStyle(color: Colors.white),
          obscureText: typePassword,
          validator: (value) {
            if (value.isEmpty) {
              return typePassword
                  ? 'Password is required'
                  : 'Username is Required';
            } else
              return null;
          },
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon() {
    return Expanded(
      child: Center(
        child: Image(
          image: AssetImage('assets/images/wm_newlogo.png'),
        ),
      ),
    );
  }

  Widget submitButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: Container(
        height: 60.0,
        child: FlatButton(
          color: Color.fromARGB(255, 18, 78, 160),
          textColor: Colors.white,
          splashColor: Colors.blueAccent,
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _apiUserService
                  .login(
                      username: _userNameCtrl.text,
                      password: _passwordCtrl.text)
                  .then((isLog) {
                _loginSuccess(isLog);
              }).catchError((val) {
                setState(() {
                  _showError = true;
                  _errorMsg = val;
                });
              });
            }
          },
          child: Text(
            'LOGIN',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }

  _loginSuccess(bool isLog) async {
    if (isLog) {
      NavigatorState navigator = Navigator.of(context);
      Route route = ModalRoute.of(context);
      await _removeBelow(navigator, route);
      await navigator.pushReplacementNamed(Routes.home);
    } else {
      _showError = true;
    }
  }

  Future<void> _removeBelow(NavigatorState nav, Route route) async {
    nav.removeRouteBelow(route);
    await Future.delayed(Duration(milliseconds: 50)); //delay to dispose home
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
