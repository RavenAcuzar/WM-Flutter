import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wednesday_message/model/comment_list.dart';
import 'package:wednesday_message/model/video_list.dart';
import 'package:wednesday_message/network/api_comment_service.dart';
import 'package:wednesday_message/network/api_user_service.dart';
import 'package:wednesday_message/provider/playlist_provider.dart';
import 'package:wednesday_message/widget/backButton.dart';

class NowPlayingPage extends StatefulWidget {
  static const String routeName = '/now-playing';
  final List<Video> vidList;
  NowPlayingPage({Key key, @required this.vidList}) : super(key: key);
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState(this.vidList);
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  List<Video> vids;
  bool _fromPlaylistPlayAll = true;
  int _currentIndex = 0;
  _NowPlayingPageState(this.vids);
  CommentService _apiResp = CommentService();
  UserService _userService = UserService();
  AnimationController controller;
  Animation animation;
  WebViewController _playerController;
  bool _isInPlaylist = false;
  bool _errorCommentSubmitted = false;
  final _commentText = TextEditingController();
  bool _isVideoError = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ));
    _apiResp.init();
    _userService.init();
    _fromPlaylistPlayAll = vids.length > 1 ? true : false;
    print(vids[_currentIndex].vidId);
    if (_userService.getUserId() != null) {
      // _isInPlaylist = await PlaylistProvider().checkIfVideoIsInPlaylist(vids[_currentIndex].vidId);
      _ifAddedToPlaylist();
    }
    _apiResp.getComments(vids[_currentIndex].vidId);
    //print(_userService.getUserId() != null);
  }

  @override
  void dispose() {
    _apiResp.dispose();
    controller.dispose();
    _commentText.dispose();
    super.dispose();
  }

  _ifAddedToPlaylist() async {
    var isAdded = await PlaylistProvider()
        .checkIfVideoIsInPlaylist(vids[_currentIndex].vidId);
    print("Fired! Playlist Value: $_isInPlaylist");
    setState(() {
      _isInPlaylist = isAdded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (MediaQuery.of(context).orientation == Orientation.landscape){
          await SystemChrome.setPreferredOrientations([ DeviceOrientation.portraitUp ]);
          //Navigator.of(context).pop();
          return true;
        }
        return true;
      },
      child: Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: _fromPlaylistPlayAll ? 300 : 250,
                ),
                _videoDetailsWidget(),
                _commentsListWidget(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                _videoPlayerWidget(),
                if (_fromPlaylistPlayAll &&
                    (MediaQuery.of(context).orientation ==
                        Orientation.portrait))
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {
                        print(controller.status);
                        switch (controller.status) {
                          case AnimationStatus.completed:
                            controller.reverse();
                            break;
                          case AnimationStatus.dismissed:
                            controller.forward();
                            break;
                          default:
                        }
                      },
                      color: Colors.grey[600],
                      textColor: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.play_arrow,
                          ),
                          Expanded(
                            child: Text(
                              vids[_currentIndex].title,
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          Text(
                              '${(_currentIndex + 1).toString()}/${vids.length.toString()}'),
                          Icon(
                            Icons.arrow_drop_down,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: Container(
                    height: MediaQuery.of(context).size.height - 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 20),
                      itemCount: vids.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: _currentIndex == index
                              ? Colors.grey[800]
                              : Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              onTap: () async {
                                _isInPlaylist = await PlaylistProvider()
                                    .checkIfVideoIsInPlaylist(
                                        vids[index].vidId);
                                setState(() {
                                  _currentIndex = index;
                                  _playerController.loadUrl(
                                      'https://players.brightcove.net/3745659807001/4JJdlFXsg_default/index.html?videoId=${vids[_currentIndex].vidId}');
                                  _apiResp.clear();
                                  _apiResp
                                      .getComments(vids[_currentIndex].vidId);
                                });
                              },
                              leading: Image(
                                image: NetworkImage(vids[index].image),
                              ),
                              title: _currentIndex == index
                                  ? Text(
                                      'Now Playing...',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey[300],
                                          fontStyle: FontStyle.italic),
                                    )
                                  : Text(
                                      vids[index].title,
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white),
                                    ),
                              subtitle: _currentIndex == index
                                  ? Text(
                                      vids[index].title,
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );    
  }

  Widget _videoPlayerWidget() {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height
              : 250,
          color: Colors.black,
          child: _isVideoError ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Video unavailable',
                style:TextStyle(
                  color: Colors.white70,
                  fontSize: 30.0,
                ),
                ),
                Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 60,
                ),
              ],
            ),
          ): WebView(
            initialUrl:
                'https://players.brightcove.net/3745659807001/4JJdlFXsg_default/index.html?videoId=${vids[_currentIndex].vidId}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController controller) {
              _playerController = controller;
            },
            
            onWebResourceError: (WebResourceError webviewerrr) {
              //print("THIS IS THE ERROR DOMAIN: " + webviewerrr.domain);
             // print("THIS IS THE ERROR URL: " + webviewerrr.failingUrl);
           // print("THIS IS THE ERROR DESC:" + webviewerrr.description);
           // print("Error!" + webviewerrr.failingUrl);
           if(webviewerrr.description == 'net::ERR_INTERNET_DISCONNECTED')
            {
            setState(() {
              _isVideoError = true;
            });
            }
        },
          ),
        ),
        if (MediaQuery.of(context).orientation == Orientation.portrait || _isVideoError)
          customBackButton(context, true),
      ],
    );
  }

  Widget _videoDetailsWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(50, 18, 78, 160),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                vids[_currentIndex].title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.language,
                    size: 15,
                    color: Colors.grey[700],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      vids[_currentIndex].subs,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Date Published: ${vids[_currentIndex].date}',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                vids[_currentIndex].description,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: FlatButton.icon(
                textColor: Color.fromARGB(255, 18, 78, 160),
                //color: Color.fromARGB(255, 18, 78, 160),
                onPressed: _userService.getUserId() != null
                    ? () async {
                        if (_isInPlaylist) {
                          //remove to playlist
                          var r = await PlaylistProvider()
                              .removeToPlaylist(vids[_currentIndex].vidId);
                          setState(() {
                            if (r > 0) {
                              _isInPlaylist = false;
                              if (_fromPlaylistPlayAll) {
                                vids.removeAt(_currentIndex);
                                _fromPlaylistPlayAll =
                                    vids.length > 1 ? true : false;
                                if (_currentIndex > 0)
                                  _currentIndex = _currentIndex - 1;
                                _apiResp.clear();
                                _apiResp.getComments(vids[_currentIndex].vidId);
                                _ifAddedToPlaylist();
                                _playerController.loadUrl(
                                    'https://players.brightcove.net/3745659807001/4JJdlFXsg_default/index.html?videoId=${vids[_currentIndex].vidId}');
                              }
                            }
                            //else show error
                          });
                        } else {
                          //add to playlist
                          var r = await PlaylistProvider()
                              .addToPlaylist(vids[_currentIndex]);
                          setState(() {
                            if (r > 0) _isInPlaylist = true;
                            //else show error
                          });
                        }
                      }
                    : null,
                label: _isInPlaylist
                    ? Text('Remove from Playlist')
                    : Text('Add to Playlist'),
                icon: _isInPlaylist
                    ? Icon(Icons.delete_sweep)
                    : Icon(Icons.playlist_add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentsForm() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Form(
        key: _formKey,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                    image: NetworkImage(_userService.getUserImage()),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                height: 70,
                width: 70,
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _commentText,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                validator: _commentInputValidator,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(5.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 18, 78, 160), width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(100, 18, 78, 160), width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[300], width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[300], width: 1.0),
                  ),
                  hintText: 'Comment...',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Container(
                width: 70,
                height: 70,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: Color.fromARGB(255, 18, 78, 160),
                  textColor: Colors.white,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _apiResp
                          .postComment(
                        videoId: vids[_currentIndex].vidId,
                        comment: _commentText.text,
                        userId: _userService.getUserId(),
                      )
                          .then((value) {
                        print(value);
                        if (value) {
                          setState(() {
                            _errorCommentSubmitted = false;
                          });
                          _commentText.clear();
                          FocusScope.of(context).unfocus();
                        } else
                          setState(() {
                            _errorCommentSubmitted = true;
                            _formKey.currentState?.validate();
                          });
                      }).catchError((err) {
                        setState(() {
                          _errorCommentSubmitted = true;
                          _formKey.currentState?.validate();
                        });
                      });
                    }
                  },
                  child: Center(
                    child: Text('Post'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _commentInputValidator(String val) {
    if (val.isEmpty) {
      return 'Please enter your comment';
    } else if (_errorCommentSubmitted) {
      return 'Error posting comment. Try again';
    } else {
      return null;
    }
  }

  Widget _commentsListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 18, 78, 160),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_userService.getUserId() != null) _commentsForm(),
        StreamBuilder<List<Comment>>(
          stream: _apiResp.commentStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No Comments here',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 20.0),
                  child: Column(
                    children: <Widget>[
                      for (var comment in snapshot.data)
                        ListTile(
                          isThreeLine: true,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image(
                              image: NetworkImage(comment.avatar),
                            ),
                          ),
                          title: Text(
                            comment.name,
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.grey[600]),
                          ),
                          subtitle: Text(
                            comment.comment,
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                );
              }
            }
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No Comments here',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      ],
    );
  }
}
