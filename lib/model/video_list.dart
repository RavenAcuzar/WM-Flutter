import 'dart:convert';

class Video {
  final String vidId;
  final String image;
  final String date;
  final String duration;
  final String title;
  final String subs;
  final String description;

  Video(
      {this.vidId,
      this.image,
      this.title,
      this.subs,
      this.description,
      this.date,
      this.duration});
  factory Video.fromJson(Map<String, dynamic> json) => Video(
      vidId: json['bcid'],
      image: json['image'],
      date: json['days'],
      duration: json['time'],
      title: json['title'],
      subs: json['language'],
      description: json['description']);

  Map<String, dynamic> toJson() => {
        'vidId': vidId,
        'image': image,
        'date': date,
        'duration': duration,
        'title': title,
        'subs': subs,
        'description': description,
      };
}

class VideoList {
  final List<Video> videos;

  VideoList({this.videos});

  factory VideoList.fromRawJson(String str) =>
      VideoList.fromJson(json.decode(str));

  factory VideoList.fromJson(List<dynamic> json) =>
      VideoList(videos: List<Video>.from(json.map((x) => Video.fromJson(x))));

  List<dynamic> toJson() => [
        List<Video>.from(videos.map((x) => x.toJson())),
      ];
}
