import 'package:flutter/material.dart';
import 'package:wednesday_message/model/video_list.dart';
import 'package:wednesday_message/module/now-playing/now_playing_page_view.dart';
import 'package:wednesday_message/provider/playlist_provider.dart';
import 'package:wednesday_message/widget/drawer.dart';

class PlaylistPage extends StatefulWidget {
  static const String routeName = '/playlist';
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //Test only
  PlaylistProvider _playlistProvider = PlaylistProvider();
  List<Video> _vids = List<Video>();

  @override
  void initState() {
    super.initState();
    _initializePlaylist();
  }

  @override
  void dispose() {
    //dispose code here
    super.dispose();
  }

  _initializePlaylist() async{
    print("Initialize playlist");
      var pl = await _playlistProvider.getAllPlaylist();
      setState(() {
        _vids = pl;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          playlistHeader(),
          if (_vids.length > 0) playListContent(),
          if (_vids.length == 0)
            Expanded(
              child: Center(
                child: Text(
                  'No Videos added yet',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget playlistHeader() {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          child: _vids.length > 0
              ? Image.network(
                  _vids[0].image,
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/wm_splash.png',
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 13,
          bottom: 15,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              _vids.length > 0
                  ? 'PLAYLIST (${_vids.length.toString()})'
                  : 'PLAYLIST',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          right: 11,
          bottom: 15,
          child: OutlineButton.icon(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 15),
            textColor: Colors.white,
            borderSide: BorderSide(
              width: 2.0,
              color: Colors.white,
              style: BorderStyle.solid,
            ),
            disabledBorderColor: Colors.grey[700],
            disabledTextColor: Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: _vids.length>0? () =>
                //play all
                Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NowPlayingPage(vidList: _vids),
              ),
            ).then((val)=>val?_initializePlaylist():null):null,
            icon: Icon(Icons.playlist_play),
            label: Text('Play All'),
          ),
        ),
        Positioned(
          left: 5,
          top: 25,
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState.openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget playListContent() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
        itemCount: _vids.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              List<Video> _v = List<Video>();
              _v.add(_vids[index]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NowPlayingPage(vidList: _v),
                ),
              );
            },
            isThreeLine: true,
            leading: Image.network(_vids[index].image),
            title: Text(_vids[index].title),
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () async{
                int rows = await _playlistProvider.removeToPlaylist(_vids[index].vidId);
                if(rows>0){
                  _initializePlaylist();
                }
              },
            ),
            subtitle: Text(
                '${_vids[index].duration}\nDate Published: ${_vids[index].date}'),
          );
        },
      ),
    );
  }
}
