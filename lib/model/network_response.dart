import 'dart:convert';

class NetworkResponse {
  final String message;

  NetworkResponse({this.message});

  factory NetworkResponse.fromRawJson(String str) =>
      NetworkResponse.fromJson(json.decode(str));

  factory NetworkResponse.fromJson(List<dynamic> json) =>
      NetworkResponse(message: json[0]['Data']);

  Map<String, dynamic> toJson() => {"Data": message};
}