import 'dart:async';
import 'package:keyboard_avoider/keyboard_avoider.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/activity/FullImageViewPager.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/home/AddPost.dart';
import 'package:spike_view_project/home/AddTagWidget.dart';
import 'package:spike_view_project/home/CommentListWidget.dart';
import 'package:spike_view_project/home/LikeDetailWidget.dart';
import 'package:spike_view_project/home/SharePostWidget.dart';
import 'package:spike_view_project/home/TagDetailWidget.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:chewie/chewie.dart';

class VideoPlayPause extends StatefulWidget {
  final VideoPlayerController controller;
  bool isPlay = false;

  VideoPlayPause(this.controller);

  @override
  State createState() {
    return new _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  FadeAnimation imageFadeAnim =
  new FadeAnimation(child: new Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.pause();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new GestureDetector(
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new VideoPlayer(controller),
            ),
            new MaterialControls(
              controller: controller,
              fullScreen: false,
              autoPlay: true,
            ),
          ],
        ),
        onTap: () {
          if (!controller.value.initialized) {
            return;
          }
          if (controller.value.isPlaying) {
            imageFadeAnim =
            new FadeAnimation(child: new Icon(Icons.pause, size: 100.0));
            controller.pause();
          } else {
            imageFadeAnim = new FadeAnimation(
                child: new Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      new Center(child: imageFadeAnim),
    ];

    if (!controller.value.initialized) {
      children.add(new Center(child: const CupertinoActivityIndicator()));
    }

    return new Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  FadeAnimation({this.child, this.duration: const Duration(milliseconds: 500)});

  @override
  _FadeAnimationState createState() => new _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
    new AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? new Opacity(
      opacity: 1.0 - animationController.value,
      child: widget.child,
    )
        : new Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

/// A widget connecting its life cycle to a [VideoPlayerController].
class PlayerLifeCycle extends StatefulWidget {
  final VideoWidgetBuilder childBuilder;
  final String uri;

  PlayerLifeCycle(this.uri, this.childBuilder);

  @override
  _PlayerLifeCycleState createState() => new _PlayerLifeCycleState();
}

class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  _PlayerLifeCycleState();

  @override
  void initState() {
    super.initState();
    controller = new VideoPlayerController.network(widget.uri);
    controller.addListener(() {
      if (controller.value.isBuffering) {
        print(controller.value.errorDescription);
      }
    });

    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new HomeWidgetState();
  }
}

class HomeWidgetState extends State<HomeWidget> {
  String userIdPref, token, profile_image_path;
  bool isShare = false;
  bool isComment = false;
  int offset = 0;
  bool isLoadMore = true;
  String strComment = "";
  TextEditingController commentControl = new TextEditingController(text: "");
  List<UserPostModal> userPostList = new List<UserPostModal>();
  SharedPreferences prefs;
  StreamSubscription<dynamic> _streamSubscription;
  ProfileInfoModal profileInfoModal;
  bool isReadMore = false;
  final ScrollController _scrollController = ScrollController();

  void onTapLike(userPostModal) {
    apiCallingForAddLike(userPostModal.feedId, userPostModal);
  }

  void onTapShare(userPostModel) async {
    String result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
        new SharePostWidget(profileInfoModal, userPostModel)));

    if (result == "push") {
      apiCallingForUserPost();
    }
  }

//--------------------------Profile Info api ------------------
  Future profileApi() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_PERSONAL_INFO + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            profileInfoModal =
                ParseJson.parseMapUserProfile(response.data['result']);
            if (profileInfoModal != null) {
              setState(() {
                profileInfoModal;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAddComment(feedId, comment, userpostModal) async {
    try {
      Map map = {
        "feedId": feedId,
        "userId": int.parse(userIdPref),
        "comment": comment,
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "name": "",
        "title": "",
        "profilePicture": "",
        "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
        "lastActivityType": "CommentOnFeed"
      };

      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_ADD_FEED_COMMENT, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            userpostModal.isCommented = true;
            List<Likes> likesList = new List();
            userpostModal.commentList.add(new CommentData(
                response.data["result"]["commentId"].toString(),
                comment,
                userIdPref,
                "a few seconds ago",
                profile_image_path,
                profileInfoModal.lastName == "" ||
                    profileInfoModal.lastName == "null"
                    ? profileInfoModal.firstName
                    : profileInfoModal.firstName +
                    " " +
                    profileInfoModal.lastName,
                "",
                userIdPref,
                likesList,
                false));
            setState(() {
              userPostList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAddLike(feedId, userpostModal) async {
    try {
      bool isLike = false;
      if (userpostModal.isLike) {
        isLike = false;
      } else {
        isLike = true;
      }
      Map map = {
        "feedId": feedId,
        "userId": int.parse(userIdPref),
        "isLike": isLike,
        "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
        "lastActivityType": "LikeFeed"
      };

      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_ADD_LIKE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            if (userpostModal.isLike) {
              userpostModal.isLike = false;
              userpostModal.likeList.removeLast();
            } else {
              userpostModal.isLike = true;
              userpostModal.likeList.add(new Likes(
                  userIdPref,
                  profileInfoModal.lastName == "null"
                      ? profileInfoModal.firstName
                      : profileInfoModal.firstName +
                      " " +
                      profileInfoModal.lastName,
                  profile_image_path,
                  "student"));
            }
            setState(() {
              userpostModal;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUserPost() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, "ui/feed/postList?userId=$userIdPref&skip=0", "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            userPostList.clear();
            userPostList =
                ParseJson.parseHomeData(response.data['result'], userIdPref);
            if (userPostList.length > 0) {
              setState(() {
                userPostList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUserPostLoadMore() async {
    try {
      print("offsetvalue" + offset.toString());
      Response response = await new ApiCalling().apiCall(
          context,
          "ui/feed/postList?userId=$userIdPref&skip=" + offset.toString(),
          "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            List<UserPostModal> userPostListNew =
            ParseJson.parseHomeData(response.data['result'], userIdPref);
            if (userPostListNew.length > 0) {
              userPostList.addAll(userPostListNew);
              setState(() {
                userPostList;
              });
            } else {
              isLoadMore = false;
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForDeleteFeed(userPostModal, index) async {
    try {
      Map map = {"feedId": userPostModal.feedId};
      Response response = await new ApiCalling().apiCallDeleteWithMapData(
          context, Constant.ENDPOINT_FEED_DELETE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            userPostList.removeAt(index);
            setState(() {
              userPostList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUpdateFeed(userPostModal, visibility, scopeList) async {
    try {
      Map map = {
        "feedId": userPostModal.feedId,
        "visibility": visibility,
        "scope": scopeList.map((item) => item).toList()
      };
      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_FEED_UPDATE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            userPostModal.visibility = visibility;
            setState(() {
              userPostModal;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    profile_image_path = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    token = prefs.getString(UserPreference.USER_TOKEN);

    await apiCallingForUserPost();
    await profileApi();
  }

  onAddComment(feedId, comment, userPostModal) {
    apiCallingForAddComment(feedId, comment, userPostModal);
    print("Comments : " + comment + "feedid:- $feedId");
  }

  @override
  void initState() {
    // TODO: implement initState
    getSharedPreferences();
    //-------------listener for add button click (Dashboard) -------------------------
    _streamSubscription =
        DashBoardState.syncDoneController.stream.listen((value) {
          onTapAddPost(value);
        });
    super.initState();
  }

  void onTapAddPost(String result) async {
    String result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new AddPost(profileInfoModal, "")));

    if (result == "push") {
      apiCallingForUserPost();
    }
  }

  void onTapViewAllComments(commentList, feedId, userPostModel) async {
    String result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new CommentListWidget(
            commentList,
            profile_image_path,
            feedId,
            profileInfoModal.lastName == "" ||
                profileInfoModal.lastName == "null"
                ? profileInfoModal.firstName
                : profileInfoModal.firstName + " " + profileInfoModal.lastName,
            userPostModel,
            userIdPref)));

    if (result == "push") {
      // apiCallingForUserPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    InkWell shareView(userPostModel) {
      return new InkWell(
        child: PaddingWrap.paddingAll(
            10.0,
            new Image.asset(
              "assets/home/share_inactive.png",
              height: 30.0,
              width: 30.0,
            )),
        onTap: () {
          onTapShare(userPostModel);
        },
      );
    }

    isCount1(imageurl) {
      return Image.network(
        Constant.IMAGE_PATH_SMALL + ParseJson.getMediumImage(imageurl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      );
    }

    isCount2(imageurl1, imageurl2) {
      return new Row(
        children: <Widget>[
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl1),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          ),
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl2),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          )
        ],
      );
    }

    isCount3(imageurl1, imageurl2, imageurl3) {
      return new Column(
        children: <Widget>[
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl1),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          ),
          new Expanded(
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl2),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                ),
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl3),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                )
              ],
            ),
            flex: 1,
          ),
        ],
      );
    }

    isCount4(imageurl1, imageurl2, imageurl3, imageurl4, imageCount) {
      return new Column(
        children: <Widget>[
          new Expanded(
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl1),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                ),
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl2),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                )
              ],
            ),
            flex: 1,
          ),
          new Expanded(
            child: new Stack(children: <Widget>[
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                        2.0,
                        Image.network(
                          Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(imageurl3),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                        )),
                    flex: 1,
                  ),
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                        2.0,
                        Image.network(
                          Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(imageurl4),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                        )),
                    flex: 1,
                  )
                ],
              ),
              imageCount > 4
                  ? new Positioned(
                child: new Container(
                    color: Colors.black12,
                    child: new Text(
                      (imageCount - 4).toString() + "+ more",
                      style: new TextStyle(color: Colors.white),
                    )),
                bottom: 20.0,
                right: 10.0,
              )
                  : new Container(
                height: 1.0,
              )
            ]),
            flex: 1,
          ),
        ],
      );
    }

    void onTapTagSelectedConnection(userPostModel) async {
      List<TagsPost> result = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new AddTagWidget("MY CONNECTIONS")));

      if (result != null) {
        List<TagsPost> scopeList = new List();
        scopeList = result;
        if (scopeList.length > 0)
          apiCallingForUpdateFeed(
              userPostModel, "SelectedConnections", scopeList);
      }
    }

    Widget getMoreDropDown(userPostModal, index) {
      return new PopupMenuButton<String>(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Image.asset(
              "assets/profile/post/user_more.png",
              width: 25.0,
              height: 25.0,
            )
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          PopupMenuItem(
            child: new InkWell(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      10.0,
                      5.0,
                      10.0,
                      new Image.asset(
                        "assets/profile/post/delete_fill.png",
                        width: 30.0,
                        height: 30.0,
                      )),
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      15.0,
                      5.0,
                      10.0,
                      TextViewWrap.textView(
                          "Delete",
                          TextAlign.center,
                          new Color(ColorValues.BLUE_COLOR),
                          16.0,
                          FontWeight.normal))
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                apiCallingForDeleteFeed(userPostModal, index);
              },
            ),
            value: "0",
          ),
          userPostModal.visibility == "Public"
              ? new PopupMenuItem(
            height: 0.0,
            child: new Container(
              height: 0.0,
            ),
          )
              : PopupMenuItem(
            child: new InkWell(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      10.0,
                      5.0,
                      10.0,
                      new Image.asset(
                        "assets/profile/post/public.png",
                        width: 30.0,
                        height: 30.0,
                      )),
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      15.0,
                      5.0,
                      10.0,
                      TextViewWrap.textView(
                          "Public",
                          TextAlign.center,
                          new Color(ColorValues.BLUE_COLOR),
                          16.0,
                          FontWeight.normal))
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                List<String> scopeList = new List();
                apiCallingForUpdateFeed(
                    userPostModal, "Public", scopeList);
              },
            ),
            value: "1",
          ),
          userPostModal.visibility == "Private"
              ? new PopupMenuItem(
            height: 0.0,
            child: new Container(
              height: 0.0,
            ),
          )
              : PopupMenuItem(
            child: new InkWell(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      10.0,
                      5.0,
                      10.0,
                      new Image.asset(
                        "assets/profile/post/private.png",
                        width: 30.0,
                        height: 30.0,
                      )),
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      15.0,
                      5.0,
                      10.0,
                      TextViewWrap.textView(
                          "Private",
                          TextAlign.center,
                          new Color(ColorValues.BLUE_COLOR),
                          16.0,
                          FontWeight.normal))
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                List<String> scopeList = new List();
                apiCallingForUpdateFeed(
                    userPostModal, "Private", scopeList);
              },
            ),
            value: "2",
          ),
          userPostModal.visibility == "SelectedConnections"
              ? new PopupMenuItem(
            height: 0.0,
            child: new Container(
              height: 0.0,
            ),
          )
              : PopupMenuItem(
            child: new InkWell(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      10.0,
                      5.0,
                      10.0,
                      new Image.asset(
                        "assets/profile/post/selected_connections.png",
                        width: 30.0,
                        height: 30.0,
                      )),
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      15.0,
                      5.0,
                      10.0,
                      TextViewWrap.textView(
                          "Selected Connections",
                          TextAlign.center,
                          new Color(ColorValues.BLUE_COLOR),
                          16.0,
                          FontWeight.normal))
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                onTapTagSelectedConnection(userPostModal);
              },
            ),
            value: "3",
          ),
          userPostModal.visibility == "AllConnections"
              ? new PopupMenuItem(
            height: 0.0,
            child: new Container(
              height: 0.0,
            ),
          )
              : PopupMenuItem(
            child: new InkWell(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      10.0,
                      5.0,
                      10.0,
                      new Image.asset(
                        "assets/profile/post/all_connections.png",
                        width: 30.0,
                        height: 30.0,
                      )),
                  PaddingWrap.paddingfromLTRB(
                      5.0,
                      15.0,
                      5.0,
                      10.0,
                      TextViewWrap.textView(
                          "All Connections",
                          TextAlign.center,
                          new Color(ColorValues.BLUE_COLOR),
                          16.0,
                          FontWeight.normal))
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                List<String> scopeList = new List();
                apiCallingForUpdateFeed(
                    userPostModal, "AllConnections", scopeList);
              },
            ),
            value: "4",
          ),
        ],
      );
    }

    getEvent(userPostModal) {
      return new Column(
        children: <Widget>[
          userPostModal.lastActivityType == "CreateFeed" &&
              userPostModal.tagList.length > 0
              ? new Column(
            children: <Widget>[
              PaddingWrap.paddingAll(
                10.0,
                new Row(
                  children: <Widget>[
                    new InkWell(
                      child: TextViewWrap.textView(
                          userPostModal.lastName == null ||
                              userPostModal.lastName == "null"
                              ? userPostModal.firstName
                              : userPostModal.firstName +
                              " " +
                              userPostModal.lastName,
                          TextAlign.start,
                          new Color(ColorValues.BLUE_COLOR),
                          15.0,
                          FontWeight.normal),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new UserProfilePage(
                                userPostModal.postedBy, false,"")));
                      },
                    ),
                    new InkWell(
                      child: new Row(children: <Widget>[
                        TextViewWrap.textView(
                            " is with  ",
                            TextAlign.start,
                            Colors.black,
                            15.0,
                            FontWeight.normal),
                        TextViewWrap.textView(
                            " " +
                                userPostModal.tagList.length.toString() +
                                " others",
                            TextAlign.start,
                            new Color(ColorValues.BLUE_COLOR),
                            15.0,
                            FontWeight.normal)
                      ]),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new TagDetailWidget(
                                userPostModal.tagList)));
                      },
                    ),
                  ],
                ),
              ),
              new Divider(color: Colors.grey[300]),
            ],
          )
              : userPostModal.lastActivityType == "LikeFeed" &&
              userPostModal.likeList.length > 0
              ? new InkWell(
            child: new Column(
              children: <Widget>[
                PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      TextViewWrap.textView(
                          userPostModal
                              .likeList[
                          userPostModal.likeList.length - 1]
                              .name,
                          TextAlign.start,
                          new Color(ColorValues.BLUE_COLOR),
                          15.0,
                          FontWeight.normal),
                      TextViewWrap.textView(
                          " likes this  ",
                          TextAlign.start,
                          Colors.black,
                          15.0,
                          FontWeight.normal),
                    ],
                  ),
                ),
                new Divider(color: Colors.grey[300]),
              ],
            ),
            onTap: () {
              if (userPostModal
                  .likeList[userPostModal.likeList.length - 1]
                  .userId ==
                  userIdPref) {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new UserProfilePage(userIdPref, true,"")));
              } else {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new UserProfilePage(
                        userPostModal
                            .likeList[
                        userPostModal.likeList.length - 1]
                            .userId,
                        false,"")));
              }
            },
          )
              : userPostModal.lastActivityType == "CommentOnFeed" &&
              userPostModal.commentList.length > 0
              ? new InkWell(
            child: new Column(
              children: <Widget>[
                PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      TextViewWrap.textView(
                          userPostModal
                              .commentList[userPostModal
                              .commentList.length -
                              1]
                              .name,
                          TextAlign.start,
                          new Color(ColorValues.BLUE_COLOR),
                          15.0,
                          FontWeight.normal),
                      TextViewWrap.textView(
                          " commented on this  ",
                          TextAlign.start,
                          Colors.black,
                          15.0,
                          FontWeight.normal),
                    ],
                  ),
                ),
                new Divider(color: Colors.grey[300]),
              ],
            ),
            onTap: () {
              if (userPostModal
                  .commentList[
              userPostModal.commentList.length - 1]
                  .userId ==
                  userIdPref) {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new UserProfilePage(userIdPref, true,"")));
              } else {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new UserProfilePage(
                        userPostModal
                            .commentList[userPostModal
                            .commentList.length -
                            1]
                            .userId,
                        false,"")));
              }
            },
          )
              : userPostModal.tagList.length > 0
              ? new Column(
            children: <Widget>[
              PaddingWrap.paddingAll(
                10.0,
                new Row(
                  children: <Widget>[
                    new InkWell(
                      child: TextViewWrap.textView(
                          userPostModal.lastName == null ||
                              userPostModal.lastName ==
                                  "null"
                              ? userPostModal.firstName
                              : userPostModal.firstName +
                              " " +
                              userPostModal.lastName,
                          TextAlign.start,
                          new Color(ColorValues.BLUE_COLOR),
                          15.0,
                          FontWeight.normal),
                      onTap: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                new UserProfilePage(
                                    userIdPref,
                                    true,"")));
                      },
                    ),
                    new InkWell(
                      child: new Row(children: <Widget>[
                        TextViewWrap.textView(
                            "is with",
                            TextAlign.start,
                            Colors.black,
                            15.0,
                            FontWeight.normal),
                        TextViewWrap.textView(
                            userPostModal.tagList.length
                                .toString() +
                                " others",
                            TextAlign.start,
                            new Color(ColorValues.BLUE_COLOR),
                            15.0,
                            FontWeight.normal)
                      ]),
                      onTap: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                new TagDetailWidget(
                                    userPostModal
                                        .tagList)));
                      },
                    ),
                  ],
                ),
              ),
              new Divider(color: Colors.grey[300]),
            ],
          )
              : new Container(
            height: 0.0,
          )
        ],
      );
    }

    onTapLikeText(userPostModal) {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
          new LikeDetailWidget(userPostModal.likeList)));
    }

    Padding getListView(userPostModal, index) {
      return PaddingWrap.paddingAll(
          3.0,
          new Card(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  getEvent(userPostModal),
                  PaddingWrap.paddingAll(
                      10.0,
                      new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Center(
                              child: userPostModal.profilePicture != "null"
                                  ? new Container(
                                  width: 60.0,
                                  height: 60.0,
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    placeholder:
                                    'assets/profile/user_on_user.png',
                                    image: Constant.IMAGE_PATH_SMALL +
                                        ParseJson.getSmallImage(
                                            userPostModal.profilePicture),
                                  ))
                                  : new Image.asset(
                                "assets/profile/user_on_user.png",
                                height: 60.0,
                                width: 60.0,
                              ),
                            ),
                            flex: 1,
                          ),
                          new Expanded(
                            child: PaddingWrap.paddingAll(
                                5.0,
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    TextViewWrap.textView(
                                        userPostModal.lastName == "null"
                                            ? userPostModal.firstName
                                            : userPostModal.firstName +
                                            " " +
                                            userPostModal.lastName,
                                        TextAlign.left,
                                        Colors.black,
                                        16.0,
                                        FontWeight.bold),
                                    userPostModal.title == "null"
                                        ? new Container(
                                      height: 1.0,
                                    )
                                        : TextViewWrap.textView(
                                        userPostModal.title,
                                        TextAlign.center,
                                        Colors.grey,
                                        14.0,
                                        FontWeight.normal),
                                  ],
                                )),
                            flex: 4,
                          ),
                          new Expanded(
                            child: userIdPref == userPostModal.postedBy
                                ? getMoreDropDown(userPostModal, index)
                                : new Container(
                              height: 1.0,
                            ),
                            flex: 0,
                          )
                        ],
                      )),
                  userPostModal.postdata.imageList.length == 0
                      ? new Container(
                    height: 1.0,
                  )
                      : new InkWell(
                    child: new Container(
                      height: 200.0,
                      child: userPostModal.postdata.imageList.length == 1
                          ? isCount1(userPostModal.postdata.imageList[0])
                          : userPostModal.postdata.imageList.length == 2
                          ? isCount2(userPostModal.postdata.imageList[0],
                          userPostModal.postdata.imageList[1])
                          : userPostModal.postdata.imageList.length == 3
                          ? isCount3(
                          userPostModal.postdata.imageList[0],
                          userPostModal.postdata.imageList[1],
                          userPostModal.postdata.imageList[2])
                          : isCount4(
                          userPostModal.postdata.imageList[0],
                          userPostModal.postdata.imageList[1],
                          userPostModal.postdata.imageList[2],
                          userPostModal.postdata.imageList[3],
                          userPostModal
                              .postdata.imageList.length),
                    ),
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new FullIMageView(
                              userPostModal.postdata.imageList)));
                    },
                  ),
                  userPostModal.postdata.imageList.length > 0 ||
                      userPostModal.postdata.media == null ||
                      userPostModal.postdata.media == "" ||
                      userPostModal.postdata.media == "null"
                      ? new Container(
                    height: 1.0,
                  )
                      : new Container(
                    height: 200.0,
                    child: new Center(
                      child: new Center(
                          child: new AspectRatio(
                            aspectRatio: 3 / 2,
                            child: new PlayerLifeCycle(
                                Constant.IMAGE_PATH +
                                    userPostModal.postdata.media,
                                    (BuildContext context,
                                    VideoPlayerController controller) =>
                                new VideoPlayPause(controller)),
                          )),
                    ),
                  ),
                  userPostModal.postdata.imageList.length == 0
                      ? new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      PaddingWrap.paddingfromLTRB(
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        userPostModal.postdata.text == "" ||
                            userPostModal.postdata.text == "null" ||
                            userPostModal.postdata.text == "\n"
                            ? new Container(
                          height: 1.0,
                        )
                            : PaddingWrap.paddingfromLTRB(
                            10.0,
                            0.0,
                            0.0,
                            5.0,
                            userPostModal.isReadMore
                                ? new Text(
                              userPostModal.postdata.text,
                              textAlign: TextAlign.left,
                              maxLines: null,
                              style: new TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0),
                            )
                                : TextViewWrap.textView(
                                userPostModal.postdata.text,
                                TextAlign.left,
                                Colors.black,
                                16.0,
                                FontWeight.normal)),
                      ),
                      userPostModal.postdata.text.length > 120
                          ? new Align(
                          alignment: Alignment.bottomRight,
                          child: new InkWell(
                            child: PaddingWrap.paddingfromLTRB(
                                10.0,
                                10.0,
                                5.0,
                                5.0,
                                TextViewWrap.textView(
                                    userPostModal.isReadMore
                                        ? "Hide"
                                        : "Read More",
                                    TextAlign.left,
                                    new Color(ColorValues.BLUE_COLOR),
                                    14.0,
                                    FontWeight.normal)),
                            onTap: () {
                              if (userPostModal.isReadMore) {
                                userPostModal.isReadMore = false;
                              } else {
                                userPostModal.isReadMore = true;
                              }
                              setState(() {
                                userPostModal.isReadMore;
                              });
                            },
                          ))
                          : new Container(
                        height: 0.0,
                      ),
                    ],
                  )
                      : new Container(
                    height: 1.0,
                  ),
                  new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Row(
                            children: <Widget>[
                              userPostModal.isLike
                                  ? new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/like.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  onTapLike(userPostModal);
                                },
                              )
                                  : new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/like_inactive.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  onTapLike(userPostModal);
                                },
                              ),
                              userPostModal.isCommented
                                  ? new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/comment.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  //  onTapComment(userPostModal);
                                },
                              )
                                  : new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/comment_inactive.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  //onTapComment(userPostModal);
                                },
                              ),
                              shareView(userPostModal),
                            ],
                          )),
                      new Expanded(
                          child: PaddingWrap.paddingfromLTRB(
                              0.0,
                              0.0,
                              10.0,
                              0.0,
                              new Text(
                                userPostModal.dateTime,
                                textAlign: TextAlign.right,
                              ))),
                    ],
                  ),
                  PaddingWrap.paddingAll(
                      10.0,
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          userPostModal.likeList.length > 0
                              ? new InkWell(
                            child: TextViewWrap.textView(
                                userPostModal.likeList.length == 1
                                    ? "1 Like"
                                    : userPostModal.likeList.length
                                    .toString() +
                                    " Likes",
                                TextAlign.left,
                                Colors.black,
                                18.0,
                                FontWeight.bold),
                            onTap: () {
                              onTapLikeText(userPostModal);
                            },
                          )
                              : new Container(
                            height: 1.0,
                          ),
                          userPostModal.postdata.imageList.length > 0
                              ? new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              PaddingWrap.paddingfromLTRB(
                                0.0,
                                0.0,
                                0.0,
                                0.0,
                                userPostModal.postdata.text == "" ||
                                    userPostModal.postdata.text ==
                                        "null" ||
                                    userPostModal.postdata.text == "\n"
                                    ? new Container(
                                  height: 1.0,
                                )
                                    : PaddingWrap.paddingfromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    5.0,
                                    userPostModal.isReadMore
                                        ? new Text(
                                      userPostModal.postdata.text,
                                      textAlign: TextAlign.left,
                                      maxLines: null,
                                      style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0),
                                    )
                                        : TextViewWrap.textView(
                                        userPostModal.postdata.text,
                                        TextAlign.left,
                                        Colors.black,
                                        16.0,
                                        FontWeight.normal)),
                              ),
                              userPostModal.postdata.text.length > 120
                                  ? new Align(
                                  alignment: Alignment.bottomRight,
                                  child: new InkWell(
                                    child: PaddingWrap.paddingfromLTRB(
                                        10.0,
                                        10.0,
                                        5.0,
                                        5.0,
                                        TextViewWrap.textView(
                                            userPostModal.isReadMore
                                                ? "Hide"
                                                : "Read More",
                                            TextAlign.left,
                                            new Color(
                                                ColorValues.BLUE_COLOR),
                                            14.0,
                                            FontWeight.normal)),
                                    onTap: () {
                                      if (userPostModal.isReadMore) {
                                        userPostModal.isReadMore = false;
                                      } else {
                                        userPostModal.isReadMore = true;
                                      }
                                      setState(() {
                                        userPostModal.isReadMore;
                                      });
                                    },
                                  ))
                                  : new Container(
                                height: 0.0,
                              ),
                            ],
                          )
                              : new Container(
                            height: 1.0,
                          ),
                          userPostModal.commentList.length > 1
                              ? new InkWell(
                            child: PaddingWrap.paddingfromLTRB(
                              0.0,
                              10.0,
                              0.0,
                              0.0,
                              TextViewWrap.textView(
                                  "View all " +
                                      userPostModal.commentList.length
                                          .toString() +
                                      " comments",
                                  TextAlign.left,
                                  Colors.grey,
                                  16.0,
                                  FontWeight.bold),
                            ),
                            onTap: () {
                              onTapViewAllComments(userPostModal.commentList,
                                  userPostModal.feedId, userPostModal);
                            },
                          )
                              : new Container(
                            height: 1.0,
                          ),
                          new Padding(
                              padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                              child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: new List.generate(
                                      userPostModal.commentList.length > 1
                                          ? 1
                                          : userPostModal.commentList.length,
                                          (int index) {
                                        return PaddingWrap.paddingAll(
                                            5.0,
                                            new Column(
                                              children: <Widget>[
                                                new Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    new Expanded(
                                                      child: new Center(
                                                        child: new Container(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            child: FadeInImage
                                                                .assetNetwork(

                                                              placeholder:
                                                              'assets/profile/user_on_user.png',
                                                              image: Constant
                                                                  .IMAGE_PATH_SMALL +
                                                                  ParseJson.getSmallImage(userPostModal
                                                                      .commentList[
                                                                  userPostModal
                                                                      .commentList
                                                                      .length -
                                                                      1]
                                                                      .profilePicture),
                                                            )),
                                                      ),
                                                      flex: 1,
                                                    ),
                                                    new Expanded(
                                                      child: new Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          TextViewWrap.textView(
                                                              userPostModal
                                                                  .commentList[
                                                              userPostModal
                                                                  .commentList
                                                                  .length -
                                                                  1]
                                                                  .comment,
                                                              TextAlign.left,
                                                              new Color(ColorValues
                                                                  .HOME_TEXT_COLOUR),
                                                              16.0,
                                                              FontWeight.bold),


                                                          new Text( userPostModal
                                                              .commentList[
                                                          userPostModal
                                                              .commentList
                                                              .length -
                                                              1]
                                                              .comment,textAlign:TextAlign.left,
                                                              style:new TextStyle(color:new Color(ColorValues
                                                                  .HOME_TEXT_COLOUR),fontSize: 16.0,fontWeight: FontWeight.bold)
                                                          ),
                                                          new Row(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.end,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.end,
                                                            children: <Widget>[
                                                              new Text(
                                                                userPostModal
                                                                    .commentList[
                                                                userPostModal
                                                                    .commentList
                                                                    .length -
                                                                    1]
                                                                    .dateTime,
                                                                textAlign:
                                                                TextAlign.left,
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      flex: 4,
                                                    )
                                                  ],
                                                ),
                                                new Divider(color: Colors.grey[300]),
                                              ],
                                            ));
                                      }))),
                          PaddingWrap.paddingAll(
                              5.0,
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Expanded(
                                    child: profile_image_path != null &&
                                        profile_image_path != "" &&
                                        profile_image_path != "null"
                                        ? new Center(
                                      child: new Container(
                                          width: 50.0,
                                          height: 50.0,
                                          child: FadeInImage.assetNetwork(
                                            fit: BoxFit.fill,
                                            width: double.infinity,
                                            placeholder:
                                            'assets/profile/user_on_user.png',
                                            image: Constant.IMAGE_PATH_SMALL +
                                                ParseJson.getSmallImage(
                                                    profile_image_path),
                                          )),
                                    )
                                        : new Image.asset(
                                      "assets/profile/user_on_user.png",
                                      height: 50.0,
                                      width: 50.0,
                                    ),
                                    flex: 1,
                                  ),
                                  new Expanded(
                                    child: new TextField(
                                      controller: userPostModal.txtController,maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      onChanged: (s) {
                                        if (s.length > 0) {
                                          userPostModal.isCommentIconVisible = true;
                                        } else {
                                          userPostModal.isCommentIconVisible =
                                          false;
                                        }
                                        setState(() {
                                          userPostModal.isCommentIconVisible;
                                        });
                                      },
                                      decoration: userPostModal.isCommentIconVisible
                                          ? new InputDecoration(
                                          border: InputBorder.none,counterText: "",
                                          filled: true,
                                          hintText: "Add Comment..",
                                          fillColor: Colors.transparent,
                                          suffixIcon: new InkWell(
                                            child: new Image.asset(
                                              "assets/home/send.png",
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            onTap: () {
                                              userPostModal
                                                  .isCommentIconVisible = false;
                                              onAddComment(
                                                  userPostModal.feedId,
                                                  userPostModal
                                                      .txtController.text,
                                                  userPostModal);
                                              userPostModal.txtController.text =
                                              "";
                                              setState(() {
                                                userPostModal.txtController;
                                                userPostModal
                                                    .isCommentIconVisible;
                                              });
                                            },
                                          ))
                                          : new InputDecoration(
                                        border: InputBorder.none,
                                        filled: true,
                                        hintText: "Add Comment..",
                                        fillColor: Colors.transparent,
                                      ),
                                    ),
                                    flex: 4,
                                  )
                                ],
                              )),
                        ],
                      ))
                ],
              )));
    }

    Padding getListViewPost(userPostModal, index) {
      return PaddingWrap.paddingAll(
          3.0,
          new Card(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getEvent(userPostModal),
                    PaddingWrap.paddingAll(
                        10.0,
                        new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new Center(
                                  child: userPostModal.profilePicture != "null"
                                      ? new Container(
                                      width: 60.0,
                                      height: 60.0,
                                      child: FadeInImage.assetNetwork(
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        placeholder:
                                        'assets/profile/user_on_user.png',
                                        image: Constant.IMAGE_PATH_SMALL +
                                            ParseJson.getSmallImage(
                                                userPostModal.profilePicture),
                                      ))
                                      : new Image.asset(
                                    "assets/profile/user_on_user.png",
                                    height: 60.0,
                                    width: 60.0,
                                  )),
                              flex: 1,
                            ),
                            new Expanded(
                              child: PaddingWrap.paddingAll(
                                  5.0,
                                  new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      TextViewWrap.textView(
                                          userPostModal.lastName == "null"
                                              ? userPostModal.firstName
                                              : userPostModal.firstName +
                                              " " +
                                              userPostModal.lastName,
                                          TextAlign.left,
                                          Colors.black,
                                          16.0,
                                          FontWeight.bold),
                                      userPostModal.title == "null"
                                          ? new Container(
                                        height: 1.0,
                                      )
                                          : TextViewWrap.textView(
                                          userPostModal.title,
                                          TextAlign.center,
                                          Colors.grey,
                                          14.0,
                                          FontWeight.normal),
                                      TextViewWrap.textView(
                                          userPostModal.dateTime,
                                          TextAlign.center,
                                          Colors.black,
                                          14.0,
                                          FontWeight.normal)
                                    ],
                                  )),
                              flex: 4,
                            ),
                            new Expanded(
                              child: userIdPref == userPostModal.postedBy
                                  ? getMoreDropDown(userPostModal, index)
                                  : new Container(
                                height: 1.0,
                              ),
                              flex: 0,
                            )
                          ],
                        )),
                    userPostModal.shareText == "null" ||
                        userPostModal.shareText == ""
                        ? new Container(
                      height: 1.0,
                    )
                        : new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                          0.0,
                          0.0,
                          0.0,
                          0.0,
                          userPostModal.shareText == "" ||
                              userPostModal.shareText == "null" ||
                              userPostModal.shareText == "\n"
                              ? new Container(
                            height: 1.0,
                          )
                              : PaddingWrap.paddingfromLTRB(
                              10.0,
                              0.0,
                              0.0,
                              5.0,
                              userPostModal.isReadMore
                                  ? new Text(
                                userPostModal.shareText,
                                textAlign: TextAlign.left,
                                maxLines: null,
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0),
                              )
                                  : TextViewWrap.textView(
                                  userPostModal.shareText,
                                  TextAlign.left,
                                  Colors.black,
                                  16.0,
                                  FontWeight.normal)),
                        ),
                        userPostModal.shareText.length > 120
                            ? new Align(
                            alignment: Alignment.bottomRight,
                            child: new InkWell(
                              child: PaddingWrap.paddingfromLTRB(
                                  10.0,
                                  10.0,
                                  5.0,
                                  5.0,
                                  TextViewWrap.textView(
                                      userPostModal.isReadMore
                                          ? "Hide"
                                          : "Read More",
                                      TextAlign.left,
                                      new Color(ColorValues.BLUE_COLOR),
                                      14.0,
                                      FontWeight.normal)),
                              onTap: () {
                                if (userPostModal.isReadMore) {
                                  userPostModal.isReadMore = false;
                                } else {
                                  userPostModal.isReadMore = true;
                                }
                                setState(() {
                                  userPostModal.isReadMore;
                                });
                              },
                            ))
                            : new Container(
                          height: 0.0,
                        ),
                      ],
                    ),
                    PaddingWrap.paddingAll(
                        3.0,
                        new Card(
                            elevation: 5.0,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                PaddingWrap.paddingAll(
                                    10.0,
                                    new Row(
                                      children: <Widget>[
                                        new Expanded(
                                          child: userPostModal
                                              .postOwnerProfilePicture !=
                                              "null"
                                              ? new Center(
                                              child: new Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child:
                                                  FadeInImage.assetNetwork(
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    placeholder:
                                                    'assets/profile/user_on_user.png',
                                                    image: Constant
                                                        .IMAGE_PATH_SMALL +
                                                        ParseJson.getSmallImage(
                                                            userPostModal
                                                                .postOwnerProfilePicture),
                                                  )))
                                              : new Image.asset(
                                            "assets/profile/user_on_user.png",
                                            height: 40.0,
                                            width: 40.0,
                                          ),
                                          flex: 1,
                                        ),
                                        new Expanded(
                                          child: PaddingWrap.paddingAll(
                                              5.0,
                                              new Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: <Widget>[
                                                  TextViewWrap.textView(
                                                      userPostModal
                                                          .postOwnerLastName ==
                                                          "null"
                                                          ? userPostModal
                                                          .postOwnerFirstName
                                                          : userPostModal
                                                          .postOwnerFirstName +
                                                          " " +
                                                          userPostModal
                                                              .postOwnerLastName,
                                                      TextAlign.left,
                                                      Colors.black,
                                                      16.0,
                                                      FontWeight.bold),
                                                  userPostModal.postOwnerTitle ==
                                                      "null"
                                                      ? new Container(
                                                    height: 1.0,
                                                  )
                                                      : TextViewWrap.textView(
                                                      userPostModal
                                                          .postOwnerTitle,
                                                      TextAlign.center,
                                                      Colors.grey,
                                                      14.0,
                                                      FontWeight.normal),
                                                ],
                                              )),
                                          flex: 4,
                                        )
                                      ],
                                    )),
                                userPostModal.postdata.text == "" ||
                                    userPostModal.postdata.text == "null" ||
                                    userPostModal.postdata.text == "\n"
                                    ? new Container(
                                  height: 1.0,
                                )
                                    : new Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    PaddingWrap.paddingfromLTRB(
                                      0.0,
                                      0.0,
                                      0.0,
                                      0.0,
                                      userPostModal.postdata.text == "" ||
                                          userPostModal.postdata.text ==
                                              "null" ||
                                          userPostModal.postdata.text ==
                                              "\n"
                                          ? new Container(
                                        height: 1.0,
                                      )
                                          : PaddingWrap.paddingfromLTRB(
                                          10.0,
                                          0.0,
                                          0.0,
                                          5.0,
                                          userPostModal.isShareMore
                                              ? new Text(
                                            userPostModal
                                                .postdata.text,
                                            textAlign:
                                            TextAlign.left,
                                            maxLines: null,
                                            style: new TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0),
                                          )
                                              : TextViewWrap.textView(
                                              userPostModal
                                                  .postdata.text,
                                              TextAlign.left,
                                              Colors.black,
                                              16.0,
                                              FontWeight.normal)),
                                    ),
                                    userPostModal.postdata.text.length > 120
                                        ? new Align(
                                        alignment: Alignment.bottomRight,
                                        child: new InkWell(
                                          child:
                                          PaddingWrap.paddingfromLTRB(
                                              10.0,
                                              10.0,
                                              5.0,
                                              5.0,
                                              TextViewWrap.textView(
                                                  userPostModal
                                                      .isShareMore
                                                      ? "Hide"
                                                      : "Read More",
                                                  TextAlign.left,
                                                  new Color(ColorValues
                                                      .BLUE_COLOR),
                                                  14.0,
                                                  FontWeight.normal)),
                                          onTap: () {
                                            if (userPostModal
                                                .isShareMore) {
                                              userPostModal.isShareMore =
                                              false;
                                            } else {
                                              userPostModal.isShareMore =
                                              true;
                                            }
                                            setState(() {
                                              userPostModal.isShareMore;
                                            });
                                          },
                                        ))
                                        : new Container(
                                      height: 0.0,
                                    ),
                                  ],
                                ),
                                userPostModal.postdata.imageList.length == 0
                                    ? new Container(
                                  height: 1.0,
                                )
                                    : new InkWell(
                                  child: new Container(
                                    padding: new EdgeInsets.all(5.0),
                                    height: 200.0,
                                    child: userPostModal.postdata.imageList.length == 1
                                        ? isCount1(userPostModal
                                        .postdata.imageList[0])
                                        : userPostModal.postdata.imageList.length == 2
                                        ? isCount2(
                                        userPostModal
                                            .postdata.imageList[0],
                                        userPostModal
                                            .postdata.imageList[1])
                                        : userPostModal.postdata.imageList.length == 3
                                        ? isCount3(
                                        userPostModal.postdata
                                            .imageList[0],
                                        userPostModal.postdata
                                            .imageList[1],
                                        userPostModal.postdata
                                            .imageList[2])
                                        : isCount4(
                                        userPostModal.postdata
                                            .imageList[0],
                                        userPostModal.postdata.imageList[1],
                                        userPostModal.postdata.imageList[2],
                                        userPostModal.postdata.imageList[3],
                                        userPostModal.postdata.imageList.length),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                            new FullIMageView(
                                                userPostModal.postdata
                                                    .imageList)));
                                  },
                                ),
                                userPostModal.postdata.imageList.length > 0 ||
                                    userPostModal.postdata.media == null ||
                                    userPostModal.postdata.media == "" ||
                                    userPostModal.postdata.media == "null"
                                    ? new Container(
                                  height: 1.0,
                                )
                                    : new Container(
                                    height: 200.0,
                                    child: new Center(
                                        child: new AspectRatio(
                                          aspectRatio: 3 / 2,
                                          child: new PlayerLifeCycle(
                                              Constant.IMAGE_PATH +
                                                  userPostModal.postdata.media,
                                                  (BuildContext context,
                                                  VideoPlayerController
                                                  controller) =>
                                              new VideoPlayPause(controller)),
                                        ))),
                              ],
                            ))),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new Row(
                              children: <Widget>[
                                userPostModal.isLike
                                    ? new InkWell(
                                  child: PaddingWrap.paddingAll(
                                      10.0,
                                      new Image.asset(
                                        "assets/home/like.png",
                                        height: 30.0,
                                        width: 30.0,
                                      )),
                                  onTap: () {
                                    onTapLike(userPostModal);
                                  },
                                )
                                    : new InkWell(
                                  child: PaddingWrap.paddingAll(
                                      10.0,
                                      new Image.asset(
                                        "assets/home/like_inactive.png",
                                        height: 30.0,
                                        width: 30.0,
                                      )),
                                  onTap: () {
                                    onTapLike(userPostModal);
                                  },
                                ),
                                userPostModal.isCommented
                                    ? new InkWell(
                                  child: PaddingWrap.paddingAll(
                                      10.0,
                                      new Image.asset(
                                        "assets/home/comment.png",
                                        height: 30.0,
                                        width: 30.0,
                                      )),
                                  onTap: () {
                                    //  onTapComment(userPostModal);
                                  },
                                )
                                    : new InkWell(
                                  child: PaddingWrap.paddingAll(
                                      10.0,
                                      new Image.asset(
                                        "assets/home/comment_inactive.png",
                                        height: 30.0,
                                        width: 30.0,
                                      )),
                                  onTap: () {
                                    //   onTapComment(userPostModal);
                                  },
                                ),
                                shareView(userPostModal),
                              ],
                            )),
                        new Expanded(
                            child: PaddingWrap.paddingfromLTRB(
                                0.0,
                                0.0,
                                10.0,
                                0.0,
                                new Text(
                                  userPostModal.shareTime,
                                  textAlign: TextAlign.right,
                                ))),
                      ],
                    ),
                    PaddingWrap.paddingAll(
                        10.0,
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            userPostModal.likeList.length > 0
                                ? new InkWell(
                              child: TextViewWrap.textView(
                                  userPostModal.likeList.length == 1
                                      ? "1 Like"
                                      : userPostModal.likeList.length
                                      .toString() +
                                      " Likes",
                                  TextAlign.left,
                                  Colors.black,
                                  18.0,
                                  FontWeight.bold),
                              onTap: () {
                                onTapLikeText(userPostModal);
                              },
                            )
                                : new Container(
                              height: 1.0,
                            ),
                            userPostModal.commentList.length > 1
                                ? new InkWell(
                                child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  10.0,
                                  0.0,
                                  0.0,
                                  TextViewWrap.textView(
                                      "View all " +
                                          userPostModal.commentList.length
                                              .toString() +
                                          " comments",
                                      TextAlign.left,
                                      Colors.grey,
                                      16.0,
                                      FontWeight.bold),
                                ),
                                onTap: () {
                                  onTapViewAllComments(
                                      userPostModal.commentList,
                                      userPostModal.feedId,
                                      userPostModal);
                                })
                                : new Container(
                              height: 1.0,
                            ),
                            new Padding(
                                padding:
                                new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: new List.generate(
                                        userPostModal.commentList.length > 1
                                            ? 1
                                            : userPostModal.commentList.length,
                                            (int index) {
                                          return PaddingWrap.paddingAll(
                                              5.0,
                                              new Column(
                                                children: <Widget>[
                                                  new Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      new Expanded(
                                                        child: new Center(
                                                          child: new Container(
                                                              width: 50.0,
                                                              height: 50.0,
                                                              child: FadeInImage
                                                                  .assetNetwork(

                                                                placeholder:
                                                                'assets/profile/user_on_user.png',
                                                                image: Constant
                                                                    .IMAGE_PATH_SMALL +
                                                                    ParseJson.getSmallImage(userPostModal
                                                                        .commentList[
                                                                    userPostModal
                                                                        .commentList
                                                                        .length -
                                                                        1]
                                                                        .profilePicture),
                                                              )),
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      new Expanded(
                                                        child: new Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          children: <Widget>[
                                                           /* TextViewWrap.textView(
                                                                userPostModal
                                                                    .commentList[
                                                                userPostModal
                                                                    .commentList
                                                                    .length -
                                                                    1]
                                                                    .comment,
                                                                TextAlign.left,
                                                                new Color(ColorValues
                                                                    .HOME_TEXT_COLOUR),
                                                                16.0,
                                                                FontWeight.bold),*/


                                                            new Text( userPostModal
                                                                .commentList[
                                                            userPostModal
                                                                .commentList
                                                                .length -
                                                                1]
                                                                .comment,textAlign:TextAlign.left,
                                                            style:new TextStyle(color:new Color(ColorValues
                                                                .HOME_TEXT_COLOUR),fontSize: 16.0,fontWeight: FontWeight.bold)
                                                            ),
                                                            new Row(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                              children: <Widget>[
                                                                new Text(
                                                                  userPostModal
                                                                      .commentList[
                                                                  userPostModal
                                                                      .commentList
                                                                      .length -
                                                                      1]
                                                                      .dateTime,
                                                                  textAlign:
                                                                  TextAlign.left,
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        flex: 4,
                                                      )
                                                    ],
                                                  ),
                                                  new Divider(color: Colors.grey[300]),
                                                ],
                                              ));
                                        }))),
                            PaddingWrap.paddingAll(
                                5.0,
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Expanded(
                                      child: profile_image_path != null &&
                                          profile_image_path != "" &&
                                          profile_image_path != "null"
                                          ? new Center(
                                        child: new Container(
                                            width: 50.0,
                                            height: 50.0,
                                            child: FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              placeholder:
                                              'assets/profile/user_on_user.png',
                                              image:
                                              Constant.IMAGE_PATH_SMALL +
                                                  ParseJson.getSmallImage(
                                                      profile_image_path),
                                            )),
                                      )
                                          : new Image.asset(
                                        "assets/profile/user_on_user.png",
                                        height: 50.0,
                                        width: 50.0,
                                      ),
                                      flex: 1,
                                    ),
                                    new Expanded(
                                      child: new TextField(
                                        controller: userPostModal.txtController,
                                        keyboardType: TextInputType.text,maxLength: 200,
                                        onChanged: (s) {
                                          if (s.length > 0) {
                                            userPostModal.isCommentIconVisible =
                                            true;
                                          } else {
                                            userPostModal.isCommentIconVisible =
                                            false;
                                          }
                                          setState(() {
                                            userPostModal.isCommentIconVisible;
                                          });
                                        },
                                        decoration: userPostModal
                                            .isCommentIconVisible
                                            ? new InputDecoration(
                                            border: InputBorder.none,counterText: "",
                                            filled: true,
                                            hintText: "Add Comment..",
                                            fillColor: Colors.transparent,
                                            suffixIcon: new InkWell(
                                              child: new Image.asset(
                                                "assets/home/send.png",
                                                width: 30.0,
                                                height: 30.0,
                                              ),
                                              onTap: () {
                                                userPostModal
                                                    .isCommentIconVisible =
                                                false;
                                                onAddComment(
                                                    userPostModal.feedId,
                                                    userPostModal
                                                        .txtController.text,
                                                    userPostModal);
                                                userPostModal
                                                    .txtController.text = "";
                                                setState(() {
                                                  userPostModal.txtController;
                                                  userPostModal
                                                      .isCommentIconVisible;
                                                });
                                              },
                                            ))
                                            : new InputDecoration(
                                          border: InputBorder.none,
                                          filled: true,
                                          hintText: "Add Comment..",
                                          fillColor: Colors.transparent,
                                        ),
                                      ),
                                      flex: 4,
                                    )
                                  ],
                                )),
                          ],
                        ))
                  ])));
    }

    return userPostList.length > 0
        ?  KeyboardAvoider(
        autoScroll: true,
        child : new ListView.builder(
     controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: userPostList.length,
        itemBuilder: (BuildContext context, int position) {
          if (userPostList.length - 1 == position) {
            ++offset;
            if (isLoadMore) apiCallingForUserPostLoadMore();
          }
          if (userPostList[position].postOwner == "null")
            return getListView(userPostList[position], position);
          else
            return getListViewPost(userPostList[position], position);
        }))
        : new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        PaddingWrap.paddingAll(15.0,  new Image.asset(
            "assets/no_feed_new.png",
          )),
          TextViewWrap.textView(
              "No Feed Yet.",
              TextAlign.left,
              Colors.black,
              20.0,
              FontWeight.bold),
          PaddingWrap.paddingfromLTRB(
              30.0,
              15.0,
              30.0,
              5.0,
              TextViewWrap.textView(
                  " Start posting with people around you.",
                  TextAlign.center,
                  Colors.grey[400],
                  15.0,
                  FontWeight.bold))
        ],),
    );
  }
}
