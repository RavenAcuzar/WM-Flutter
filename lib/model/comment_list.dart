import 'dart:convert';

class Comment {
  final String name;
  final String avatar;
  final String comment;
  

  Comment(
      {this.name,
      this.avatar,
      this.comment});
  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
     name: json['CreatedBy'],
     avatar: 'https://api.the-v.net/site/picture?id=${json['UserId']}',
     comment: json['Comment']);

  Map<String, dynamic> toJson() => {
        'name':name,
        'avatar':avatar,
        'comment':comment,
      };
}

class CommentList {
  final List<Comment> comments;

  CommentList({this.comments});

  factory CommentList.fromRawJson(String str) =>
      CommentList.fromJson(json.decode(str));

  factory CommentList.fromJson(List<dynamic> json) =>
      CommentList(comments: List<Comment>.from(json.map((x) => Comment.fromJson(x))));

  List<dynamic> toJson() => [
        List<Comment>.from(comments.map((x) => x.toJson())),
      ];
}
