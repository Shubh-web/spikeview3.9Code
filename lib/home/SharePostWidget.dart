import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spike_view_project/home/AddMyConnectionSharePost.dart';
import 'package:spike_view_project/home/AddTagWidget.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/TagModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';

import 'package:intl/intl.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';
///
/// Toggles play/pause on tap (accompanied by a fading status icon).
///
/// Plays (looping) on initialization, and mutes on deactivation.
class VideoPlayPause extends StatefulWidget {
  final VideoPlayerController controller;
  bool isPlay=false;
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
        child: new VideoPlayer(controller),
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

// Create a Form Widget
class SharePostWidget extends StatefulWidget {
  ProfileInfoModal profileInfoModal;
  UserPostModal userPostModal;

  SharePostWidget(this.profileInfoModal, this.userPostModal);

  @override
  SharePostWidgetState createState() {
    return new SharePostWidgetState(userPostModal);
  }
}

class SharePostWidgetState extends State<SharePostWidget> {
  SharedPreferences prefs;
  String userIdPref, token, userProfilePath;
  String isType = "Public";
  TextEditingController edtController;
  UserPostModal userPostModal;
  String sasToken, containerName, strPrefixPathforFeed;
  List<String> selectedtScopeList = new List();
  SharePostWidgetState(this.userPostModal);

  static const platform = const MethodChannel('samples.flutter.io/battery');

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    userProfilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    token = prefs.getString(UserPreference.USER_TOKEN);
    setState(() {
      userProfilePath;
    });
    strPrefixPathforFeed = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_FEED +
        "/";
  }

  @override
  void initState() {
    getSharedPreferences();
    edtController = new TextEditingController(text: '');
    // TODO: implement initState

    super.initState();
  }

  //-------------------------------------Api Calling for feed--------------------------

  Future apiCalling() async {
    try {
      CustomProgressLoader.showLoader(context);

      Map map = {
        "feedId": userPostModal.feedId,
        "postedBy": int.parse(userIdPref),
        "postOwner": int.parse(userPostModal.postedBy),
        "visibility": isType,
        "scope": selectedtScopeList.map((item) => item).toList(),
        "shareTime": new DateTime.now().millisecondsSinceEpoch,
        "shareText": edtController.text,
        "isActive": widget.profileInfoModal.isActive,
        "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
        "lastActivityType": "ShareFeed"
      };



      Response response = await new ApiCalling()
          .apiCallPostWithMapData(context, Constant.ENDPOINT_SHARE_FEED, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);

            CustomProgressLoader.cancelLoader(context);
            Navigator.pop(context, "push");
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    onTapPostButton() async {
      apiCalling();
    }
    void onTapTagSelectedConnection() async {
      List<String> result = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new AddMyConnectionSharePost("MY CONNECTIONS")));

      if (result != null) {
        try {
          selectedtScopeList = result;
        }catch(e){
          e.toString();
        }
      }
    }
    void _settingModalBottomSheet(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  new Container(
                      height: 40.0,
                      color: new Color(0XFF3B79E0),
                      child: new TextFormField(
                        textAlign: TextAlign.center,
                        enabled: false,
                        controller: new TextEditingController(text: 'STATUS'),
                        keyboardType: TextInputType.text,
                        style:
                            new TextStyle(color: Colors.white, fontSize: 17.0),
                        decoration: new InputDecoration(
                            filled: true,
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            suffixIcon: new InkWell(
                              child: PaddingWrap.paddingfromLTRB(
                                  5.0,
                                  5.0,
                                  5.0,
                                  5.0,
                                  new Image.asset(
                                    "assets/profile/post/cross_white.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )),
                      )),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "Public"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
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
                      isType = "Public";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "Private"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
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

                      isType = "Private";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "AllConnections"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
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

                      isType = "AllConnections";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "SelectedConnections"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
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


                      onTapTagSelectedConnection();
                      isType = "SelectedConnections";
                      setState(() {
                        isType;
                      });
                    },
                  ),

                  /* PaddingWrap.paddingfromLTRB(
                      0.0,
                      40.0,
                      0.0,
                      0.0,
                      new FlatButton(
                        color: new Color(ColorValues.BLUE_COLOR),
                        child: new Container(
                          height: 50.0,
                          width: double.infinity,
                          child: new Center(
                              child: new Text(
                            "Save",
                            style: new TextStyle(color: Colors.white),
                          )),
                        ),
                        onPressed: () {},
                      ))*/
                ],
              ),
            );
          });
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

    Padding getListView(userPostModal) {
      return PaddingWrap.paddingAll(
          3.0,
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                        Constant.IMAGE_PATH_SMALL +
                                            ParseJson.getSmallImage(
                                                userPostModal.profilePicture),
                                      )))),
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
                                    TextAlign.right,
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
                      )
                    ],
                  )),
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
                        TextViewWrap.textView(
                            userPostModal.postdata.text,
                            TextAlign.left,
                            Colors.black,
                            16.0,
                            FontWeight.normal)),
              ),
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
                      onTap: () {},
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
                      child:


                        new Center(
                      child: new AspectRatio(
                      aspectRatio: 3 / 2,

                        child:
                        new PlayerLifeCycle(
                            Constant.IMAGE_PATH +
                                userPostModal.postdata.media ,
                                (BuildContext context, VideoPlayerController controller) =>


                            new VideoPlayPause(controller)),
                      )
                        ,
                      ),
                    ),
            ],
          ));
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            backgroundColor: new Color(0XFFF7F7F9),
            appBar: new AppBar(
              titleSpacing: 2.0,
              brightness: Brightness.light,
              title: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    "SHARE",
                    style: new TextStyle(color: new Color(0XFF617082)),
                  )
                ],
              ),
              automaticallyImplyLeading: false,
              backgroundColor: new Color(0XFFF3F3F3),
              actions: <Widget>[
                new InkWell(
                  child: new Image.asset(
                    "assets/profile/parent/p_cros.png",
                    height: 30.0,
                    width: 30.0,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                  height: userPostModal.postdata.imageList.length > 0 ||
                          userPostModal.postdata.media != null &&
                              userPostModal.postdata.media != "" &&
                              userPostModal.postdata.media != "null"
                      ? 580.0
                      : 430.0,
                  child: new Stack(
                    children: <Widget>[
                      new Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        left: 0.0,
                        top: 70.0,
                        child: new Container(
                            child: new Card(
                                elevation: 2.0,
                                child: new Column(
                                  children: <Widget>[
                                    PaddingWrap.paddingfromLTRB(
                                        5.0,
                                        30.0,
                                        5.0,
                                        0.0,
                                        new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new TextField(
                                              maxLines: 3,
                                              controller: edtController,
                                              maxLength: 2000,
                                              keyboardType: TextInputType.text,
                                              textAlign: TextAlign.start,
                                              decoration: new InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                hintText: "Write Here..",
                                                hintStyle: new TextStyle(
                                                    color: Colors.grey),
                                                fillColor: Colors.transparent,
                                              ),
                                            ),
                                            PaddingWrap.paddingAll(
                                                10.0,
                                                new Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    isType == "Public"
                                                        ? new InkWell(
                                                            child: new Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: <
                                                                  Widget>[
                                                                new Image.asset(
                                                                  "assets/profile/post/public.png",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  height: 30.0,
                                                                  width: 30.0,
                                                                ),
                                                                PaddingWrap.paddingAll(
                                                                    5.0,
                                                                    TextViewWrap.textView(
                                                                        "Public",
                                                                        TextAlign
                                                                            .center,
                                                                        new Color(ColorValues
                                                                            .BLUE_COLOR),
                                                                        16.0,
                                                                        FontWeight
                                                                            .bold))
                                                              ],
                                                            ),
                                                            onTap: () {
                                                              _settingModalBottomSheet(
                                                                  context);
                                                            })
                                                        : isType == "Private"
                                                            ? new InkWell(
                                                                child: new Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: <
                                                                      Widget>[
                                                                    new Image
                                                                        .asset(
                                                                      "assets/profile/post/private.png",
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      height:
                                                                          30.0,
                                                                      width:
                                                                          30.0,
                                                                    ),
                                                                    PaddingWrap.paddingAll(
                                                                        5.0,
                                                                        TextViewWrap.textView(
                                                                            "Private",
                                                                            TextAlign.center,
                                                                            new Color(ColorValues.BLUE_COLOR),
                                                                            16.0,
                                                                            FontWeight.bold))
                                                                  ],
                                                                ),
                                                                onTap: () {
                                                                  _settingModalBottomSheet(
                                                                      context);
                                                                })
                                                            : isType ==
                                                                    "All Connections"
                                                                ? new InkWell(
                                                                    child:
                                                                        new Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: <
                                                                          Widget>[
                                                                        new Image
                                                                            .asset(
                                                                          "assets/profile/post/all_connections.png",
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          height:
                                                                              30.0,
                                                                          width:
                                                                              30.0,
                                                                        ),
                                                                        PaddingWrap.paddingAll(
                                                                            5.0,
                                                                            TextViewWrap.textView(
                                                                                "All Connections",
                                                                                TextAlign.center,
                                                                                new Color(ColorValues.BLUE_COLOR),
                                                                                16.0,
                                                                                FontWeight.bold))
                                                                      ],
                                                                    ),
                                                                    onTap: () {
                                                                      _settingModalBottomSheet(
                                                                          context);
                                                                    })
                                                                : new InkWell(
                                                                    child:
                                                                        new Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: <
                                                                          Widget>[
                                                                        new Image
                                                                            .asset(
                                                                          "assets/profile/post/selected_connections.png",
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          height:
                                                                              30.0,
                                                                          width:
                                                                              30.0,
                                                                        ),
                                                                        PaddingWrap.paddingAll(
                                                                            5.0,
                                                                            TextViewWrap.textView(
                                                                                "Selected Connections",
                                                                                TextAlign.center,
                                                                                new Color(ColorValues.BLUE_COLOR),
                                                                                16.0,
                                                                                FontWeight.bold))
                                                                      ],
                                                                    ),
                                                                    onTap: () {
                                                                      _settingModalBottomSheet(
                                                                          context);
                                                                    }),
                                                  ],
                                                )),
                                            new Divider(
                                                color: Colors.grey[300]),
                                            getListView(userPostModal)
                                          ],
                                        )),
                                  ],
                                ))),
                      ),
                      new Positioned(
                        top: 0.0,
                        left: 10.0,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              child: userProfilePath == null ||
                                      userProfilePath == "null" ||
                                      userProfilePath == ""
                                  ? new Image.asset(
                                      "assets/profile/user_on_user.png",
                                      fit: BoxFit.fill,
                                    )
                                  : new Image.network(
                                      Constant.IMAGE_PATH_SMALL +
                                          ParseJson.getSmallImage(
                                            userProfilePath,
                                          ),
                                      fit: BoxFit.fill,
                                    ),
                              width: 100.0,
                              height: 120.0,
                              padding: new EdgeInsets.fromLTRB(
                                  10.0, 20.0, 0.0, 20.0),
                            ),
                            PaddingWrap.paddingfromLTRB(
                                5.0,
                                0.0,
                                5.0,
                                25.0,
                                new Text(
                                  widget.profileInfoModal.lastName == "" ||
                                          widget.profileInfoModal.lastName ==
                                              "null"
                                      ? widget.profileInfoModal.firstName
                                      : widget.profileInfoModal.firstName +
                                          " " +
                                          widget.profileInfoModal.lastName,
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ))
                          ],
                        ),
                      ),
                      new Positioned(
                        top: 20.0,
                        right: 20.0,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new InkWell(
                              child: new Container(
                                child: new Image.asset(
                                  "assets/profile/post/post.png",
                                  fit: BoxFit.fill,
                                ),
                                width: 80.0,
                                height: 80.0,
                                padding: new EdgeInsets.fromLTRB(
                                    30.0, 40.0, 0.0, 0.0),
                              ),
                              onTap: () {
                                onTapPostButton();
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )));
  }
}
