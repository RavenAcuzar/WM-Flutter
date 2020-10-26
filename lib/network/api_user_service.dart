import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:wednesday_message/util/globals.dart' as global;
import 'package:wednesday_message/model/network_response.dart';
import 'package:wednesday_message/model/user.dart';
import 'package:wednesday_message/util/request_type.dart';

import 'api_client.dart';

class UserService {
  UserService._privateConstructor();
  static final UserService _apiResponse = UserService._privateConstructor();
  factory UserService() => _apiResponse;
  User _user;

  ApiClient apiClient = ApiClient(Client());

  void init() => GetStorage().read(global.userIDKey) != null ? _user = User(GetStorage().read(global.userIDKey)) : _user = null;

  Future<bool> login({String username, String password}) async {
    try {
      final resp =
          await apiClient.request(requestType: RequestType.POST, body: {
        'action': 'checklogin',
        'username': username,
        'password': password,
      });
      if (resp.statusCode == 200) {
        var res = NetworkResponse.fromRawJson(resp.body);
        if (res.message != '') {
          //save userid to memory
          //save image data to memory
          _user = User(res.message);
          GetStorage().write(global.isLoggedinKey, true);
          GetStorage().write(global.userIDKey, res.message);
          return true;
        } else {
          return throw('Invalid Username or Password!');
        }
      } else {
        return throw('Oops! Something went wrong!');
      }
    } on SocketException {
      return throw('No internet connection!');
    } catch (err) {
      return throw('Oops! Something went wrong!');
    }
  }

  void logout() async {
    await GetStorage().write(global.isLoggedinKey, false);
    await GetStorage().write(global.userIDKey, null);
    _user = null;
  }

  getUserImage() => _user != null ? _user.avatar : null;
  getUserId() => _user != null ? _user.id : null;
}
