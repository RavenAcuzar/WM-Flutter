import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:wednesday_message/model/comment_list.dart';
import 'package:wednesday_message/model/network_response.dart';

import 'package:wednesday_message/model/result.dart';
import 'package:wednesday_message/util/request_type.dart';

import 'api_client.dart';

class CommentService{
  CommentService._privateConstructor();
  static final CommentService _apiResponse = CommentService._privateConstructor();
  factory CommentService() => _apiResponse;

  List<Comment> _comments;

  ApiClient apiClient = ApiClient(Client());

  StreamController<List<Comment>> _commentStreamController;

  void init() {
    _comments = List<Comment>();
    _commentStreamController = StreamController<List<Comment>>();
  }

  Stream<List<Comment>> get commentStream => _commentStreamController.stream;

  getComments(String videoId) async {
    try {
      final resp =
          await apiClient.request(requestType: RequestType.POST, body: {
        'action': 'Comment_GetComment',
        'title': videoId,
      });
      if (resp.statusCode == 200) {
        var coms = CommentList.fromRawJson(resp.body);
        print(coms.comments);
        _comments.addAll(coms.comments);
        _commentStreamController.sink.add(_comments);
        try {
          if (coms.comments.length == 0) {
            _commentStreamController.sink.addError("No Data Available");
          }
        } catch (e) {}
      } else {
        _commentStreamController.sink.addError("Error! Something went wrong!");
      }
    } on SocketException {
      _commentStreamController.sink
          .addError(SocketException("No Internet Connection"));
    } catch (err) {
      _commentStreamController.sink.addError(err.toString());
    }
  }

  Future<bool>postComment({String videoId, String comment,String userId}) async {
    try {
      print(comment);
      final resp =
          await apiClient.request(requestType: RequestType.POST, body: {
        'action': 'Comment_AddComment',
        'bcid': videoId,
        'userId': userId,
        'comment': comment,
        'ctype': 'Video'
      });
      if (resp.statusCode == 200) {
        var res = NetworkResponse.fromRawJson(resp.body);
        if(res.message=='True'){
          clear();
          getComments(videoId);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }on SocketException {
      throw Result.error('No internet connection!');
    } catch (err) {
      throw Result.error(err.toString());
    }
  }

  void clear() => _comments.clear();
  void dispose() => _commentStreamController.close();

}