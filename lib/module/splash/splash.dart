
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wednesday_message/routes/Routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController _controller;
  
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/images/splash.mp4')
      ..addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          // setState(() {
          //   _visible = false;
          // });
          Navigator.of(context).pushReplacementNamed(Routes.home);
        }
      })
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(false);
        // Ensure the first frame is shown after the video is initialized
        setState(() {
          
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size?.width ?? 0,
            height: _controller.value.size?.height ?? 0,
            child: VideoPlayer(_controller),
          ),
        ),
    );
  }
}
