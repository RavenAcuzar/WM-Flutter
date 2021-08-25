import 'package:flutter/material.dart';
import 'package:wednesday_message/model/video_list.dart';
import 'package:wednesday_message/module/now-playing/now_playing_page_view.dart';
import 'package:wednesday_message/network/api_user_service.dart';
import 'package:wednesday_message/network/api_video_service.dart';
import 'package:wednesday_message/widget/drawer.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  VideoService _apiResp = VideoService();
  UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _apiResp.init();
    _apiResp.getVideoList(true);
    _userService.init();
    print('INITIATE HOME');
  }

  @override
  void dispose() {
    _apiResp.dispose();
    print('DISPOSED HOME');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Image(
          image: AssetImage('assets/images/sidemenu_banner.png'),
          fit: BoxFit.contain,
          height: 32.0,
        ),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<List<Video>>(
          //initialData: [],
          stream: _apiResp.videoStream,
          builder: (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
            print(snapshot.hasError);
            if (snapshot.hasData) {
              print(snapshot.data);
              if (snapshot.data.length > 0) {
                return RefreshIndicator(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _createVideoCard(
                          vid: snapshot.data[0],
                          isLatest: true,
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              for (var vid in snapshot.data.sublist(1))
                                _createVideoCard(
                                  vid: vid,
                                  isLatest: false,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                              color: Color.fromARGB(255, 13, 58, 121),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(20),
                              disabledColor: Color.fromARGB(100, 13, 58, 121),
                              disabledTextColor: Colors.white,
                              onPressed:  () => _apiResp.getVideoList(false),
                              child: Text('LOAD MORE')),
                        ),
                      ],
                    ),
                  ),
                  onRefresh: _apiResp.refreshVideoList,
                );
              } else {
                return _homeShimmerUI();
              }
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Error! Something wrong!',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.7,
                          height: 5),
                    ),
                    OutlineButton(
                      textColor: Colors.grey[600],
                      onPressed: () => _apiResp.refreshVideoList(),
                      child: Text('RELOAD'),
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Colors.grey,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return _homeShimmerUI();
            }
          }),
    );
  }

  ShapeBorder _getShapeBorder(bool isLatest) {
    if (isLatest) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      );
    } else {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );
    }
  }

  Widget _getCardLabel(bool isLatest, String date) {
    if (isLatest) {
      return Positioned(
        top: 10.0,
        left: 0.0,
        child: Container(
          color: Color.fromARGB(220, 13, 58, 121),
          child: Padding(
            padding: EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
            child: Text(
              'LATEST',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        top: 10.0,
        left: 0.0,
        child: Container(
          color: Color.fromARGB(220, 13, 58, 121),
          child: Padding(
            padding: EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 8.0),
            child: Text(
              date,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
  }

  EdgeInsets _getVidPadding(bool isLatest) {
    if (isLatest) {
      return EdgeInsets.only(bottom: 0.0);
    } else {
      return EdgeInsets.only(bottom: 15.0);
    }
  }

  Widget _createVideoCard({Video vid, bool isLatest}) {
    List<Video> vidToList = [];
    vidToList.add(vid);
    //For Testing Purpose only
    // for(int test=0;test<10;test++){
    //   vidToList.add(new Video(date: 'August 12,2020',duration:'00:16:03',vidId:'6180327129001',image:"https://cf-images.ap-southeast-1.prod.boltdns.net/v1/static/3745659807001/463a3bc1-42e4-4e4c-bfae-bb1ef9924fd5/335ad35a-a9ba-4b4f-b13d-16b564e77be2/640x360/match/image.jpg",title: "Chief’s Wednesday Message 378",subs:"EN,AR,ID,FR,RU,SI,TA,TR,FA,VI",description:"Consistency involves belief and decision-making."));
    // }
    return Padding(
      padding: _getVidPadding(isLatest),
      child: GestureDetector(
        onTap: () {
          if (_userService.getUserId() != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NowPlayingPage(vidList: vidToList)));
          } else {
            if (isLatest) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NowPlayingPage(vidList: vidToList)));
            } else {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Login to view older videos.'),
                duration: Duration(seconds: 3),
              ));
            }
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: _getShapeBorder(isLatest),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                //latest video tile
                children: <Widget>[
                  FadeInImage(
                    height: 228,
                    width: MediaQuery.of(context).size.width,
                    placeholder:
                        AssetImage('assets/images/video_placeholder.jpg'),
                    image: NetworkImage(vid.image.trim()),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 228,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Color.fromARGB(100, 255, 255, 255),
                        size: 120.0,
                      ),
                    ),
                  ),
                  _getCardLabel(isLatest, vid.date),
                  Positioned(
                    bottom: 10.0,
                    right: 10.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(150, 255, 255, 255),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          vid.duration,
                          style: TextStyle(
                              color: Colors.black87,
                              //fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                isThreeLine: isLatest,
                title: Text(vid.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.language,
                          size: 15,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            vid.subs,
                          ),
                        ),
                      ],
                    ),
                    if (isLatest)
                      Text(
                        vid.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeShimmerUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _shimmerCard(true),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: _shimmerCard(false),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: _shimmerCard(false),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: _shimmerCard(false),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard(bool islatest) {
    return Padding(
      padding: _getVidPadding(islatest),
      child: Shimmer.fromColors(
        baseColor: Colors.grey,
        highlightColor: Colors.grey[300],
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: _getShapeBorder(islatest),
          child: Column(
            children: <Widget>[
              Container(
                height: 228,
                width: MediaQuery.of(context).size.width,
              ),
              ListTile(
                isThreeLine: islatest,
                title: Container(
                  height: 15,
                  width: 500,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 15,
                      width: 300,
                    ),
                    if (islatest)
                      Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
