import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wednesday_message/model/video_list.dart';
import 'package:wednesday_message/util/globals.dart' as global;

class PlaylistProvider{
  PlaylistProvider._privateConstructor();
  static final PlaylistProvider _p = PlaylistProvider._privateConstructor();
  factory PlaylistProvider() => _p;

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
    return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }
  
  initDB() async {
    String path = join(await getDatabasesPath(), "WedMesDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS playlist("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "bcid CHAR(13) NOT NULL,"
                    "image TEXT NOT NULL,"
                    "days TEXT NOT NULL,"
                    "time TEXT NOT NULL,"
                    "title TEXT NOT NULL,"
                    "language TEXT NOT NULL,"
                    "description TEXT NOT NULL,"
                    "memid CHAR(36) NOT NULL)");
    });
  }

  addToPlaylist(Video video) async {
    var isAdded= await checkIfVideoIsInPlaylist(video.vidId);
    if(!isAdded){
    final db = await database;
    var res = await db.rawInsert(
      "INSERT Into playlist (bcid,image,days,time,title,language,description,memid)"
      " VALUES ('${video.vidId}','${video.image}','${video.date}','${video.duration}','${video.title}','${video.subs}','${video.description}','${GetStorage().read(global.userIDKey)}')");
    return res;
    } else {
      return 0;
    }
  }

  removeToPlaylist(String vidId) async{
    final db = await database;
    var res = await db.delete("playlist", where: "bcid = ? and memid = ?", whereArgs: [vidId, GetStorage().read(global.userIDKey)]);
    return res;
  }
  
  Future<List<Video>> getAllPlaylist() async {
    final db = await database;
    var res = await db.query("playlist", where: "memid = ?", whereArgs: [GetStorage().read(global.userIDKey)],orderBy: 'title DESC');
    List<Video> list =
        res.isNotEmpty ? res.map((c) => Video.fromJson(c)).toList() : [];
    return list;
  }

  Future<bool> checkIfVideoIsInPlaylist(String videoID) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM playlist WHERE memid = ? and bcid = ?',[GetStorage().read(global.userIDKey),videoID]);
    print(res);
    return res.isNotEmpty;
  }

}