
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectivityService {
  ConnectivityService._privateConstructor();
  static final ConnectivityService _a = ConnectivityService._privateConstructor();
  factory ConnectivityService() => _a;
  // Subscribe to the connectivity Chanaged Steam
  StreamSubscription _subs;
  bool _asumeInitialConnectionIsConnected = true;
  init() {
    _subs = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Use Connectivity() here to gather more info if you need t
      _getStatusFromResult(result);
    });
  }

  // Convert from the third part enum to our own enum
  void _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      if(!_asumeInitialConnectionIsConnected)
         Fluttertoast.showToast(
            msg: "Internet Connected",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
            _asumeInitialConnectionIsConnected = true;
        break;
      case ConnectivityResult.wifi:
       if(!_asumeInitialConnectionIsConnected)
         Fluttertoast.showToast(
            msg: "Internet Connected",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
             _asumeInitialConnectionIsConnected = true;
        break;
      case ConnectivityResult.none:
      _asumeInitialConnectionIsConnected = false;
        Fluttertoast.showToast(
            msg: "No Internet Connection",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
        break;
      default:
      _asumeInitialConnectionIsConnected = false;
        Fluttertoast.showToast(
            msg: "No Internet Connection",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 4,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
    }
  }
  void dispose()=> _subs.cancel();
}
