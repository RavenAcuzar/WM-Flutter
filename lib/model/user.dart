class User {
  final String id;
  final String avatar;

  User(String id,[String avatar]):
  this.id = id, this.avatar='https://api.the-v.net/site/picture?id=$id';
  
}