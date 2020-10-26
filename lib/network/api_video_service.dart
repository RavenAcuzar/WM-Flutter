import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:wednesday_message/model/video_list.dart';
import 'package:wednesday_message/util/request_type.dart';

import 'api_client.dart';

class VideoService{
  VideoService._privateConstructor();
  static final VideoService _apiResponse = VideoService._privateConstructor();
  factory VideoService() => _apiResponse;

  int _page = 1;
  List<Video> _videoList = List<Video>();
  ApiClient apiClient = ApiClient(Client());

  StreamController<List<Video>> _vidStreamController;

  void init() => _vidStreamController = StreamController<List<Video>>();

  Stream<List<Video>> get videoStream => _vidStreamController.stream;

  getVideoList(bool initialLoad) async {
    try {
      if (initialLoad) {
        if (_videoList.length == 0) {
          final resp =
              await apiClient.request(requestType: RequestType.POST, body: {
            'action': 'Video_GetSearch',
            'keyword': 'Wednesday Message',
            'count': '4',
            'page': _page.toString(),
          });
          print(resp);
          if (resp.statusCode == 200) {
            var newVids = VideoList.fromRawJson(resp.body);
            //print(newVids.videos);
            _videoList.addAll(newVids.videos);

            _vidStreamController.sink.add(_videoList);
            _page++;
            try {
              if (newVids.videos.length == 0) {
                _vidStreamController.sink.addError("No Data Available");
              }
            } catch (e) {}
          } else {
            _vidStreamController.sink.addError("Error! Something went wrong!");
          }
        } else {
          _vidStreamController.sink.add(_videoList);
        }
      } else {
        final resp =
            await apiClient.request(requestType: RequestType.POST, body: {
          'action': 'Video_GetSearch',
          'keyword': 'Wednesday Message',
          'count': '4',
          'page': _page.toString(),
        });
        if (resp.statusCode == 200) {
          var newVids = VideoList.fromRawJson(resp.body);
          //print(newVids.videos);
          _videoList.addAll(newVids.videos);

          _vidStreamController.sink.add(_videoList);
          _page++;
          try {
            if (newVids.videos.length == 0) {
              _vidStreamController.sink.addError("No Data Available");
            }
          } catch (e) {}
        } else {
          _vidStreamController.sink.addError("Error! Something went wrong!");
        }
      }
    } on SocketException {
      _vidStreamController.sink
          .addError(SocketException("No Internet Connection"));
    } catch (err) {
      _vidStreamController.sink.addError(err.toString());
    }
  }

  Future<void> refreshVideoList() async {
    _videoList.clear();
    _page = 1;
    getVideoList(false);
  }
  void clear() {
    _videoList.clear();
    _page=1;
  }

  void dispose() => _vidStreamController.close();

}