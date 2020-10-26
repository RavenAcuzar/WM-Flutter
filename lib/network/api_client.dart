
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../util/nothing.dart';
import '../util/request_type.dart';
import '../util/request_type_exception.dart';

class ApiClient {
  //Base url
  static const String _apiURL='https://cums.the-v.net/site.aspx';
  
  final Client _client;

  ApiClient(this._client);

  Future<Response> request({@required RequestType requestType, dynamic body = Nothing}) async {
  try{
    switch (requestType) {
      
      case RequestType.GET:
        return await _client.get("$_apiURL");
      case RequestType.POST:
        return await _client.post("$_apiURL",
            headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: body);
      case RequestType.DELETE:
        return await _client.delete("$_apiURL");
      default:
        return throw RequestTypeNotFoundException("The HTTP request mentioned is not found");
    }
    } catch(e){
      //print(e);
      return null;
    }
  }
}
