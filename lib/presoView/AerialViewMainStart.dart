import 'dart:async';
import 'dart:math';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:spike_view_project/presoView/AnimMain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/chat/ChatListWithHeader.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/ToastWrap.dart';

import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/customViews/CustomViews.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileEducationModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/presoView/BubbleParticleModel.dart';
import 'package:spike_view_project/presoView/EmailShareWidgetPreso.dart';
import 'package:spike_view_project/presoView/ParticlePainter.dart';
import 'package:spike_view_project/profile/EmailShareWidget.dart';
import 'package:spike_view_project/profile/ShareUserProfileView.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:spike_view_project/presoView/simple_animations/rendering.dart';
import 'package:spike_view_project/presoView/scatter_dependency/flutter_scatter.dart';
import 'package:spike_view_project/presoView/scatter_dependency/src/rendering/scatter.dart';
import 'package:spike_view_project/presoView/scatter_dependency/src/widgets/scatter.dart';

const SCALE_FRACTION = 0.7;
const SCALE_FRACTION_BLURR = 0.61;
const FULL_SCALE = 1.0;
const PAGER_HEIGHT = 165.0;

class Particles extends StatefulWidget {
  ProfileInfoModal profileInfoModal;
  List<double> spiderChartList;
  List<ProfileEducationModal> userEducationList;
  List<String> spiderChartName;

  List<double> mainSpiderChartList;
  List<String> mainSpiderChartName;
  List<NarrativeModel> pReviousNarrativeList = new List<NarrativeModel>();
  List<Recomdation> addedRecommendationtList;
  List<Recomdation> recommendationtList;
  List<NarrativeModel> narrativeList;
  List<NarrativeModel> achivmentListOnly = new List();
  List<NarrativeModel> mainNarrativeList;
  List<int> indexRemoveList;
  int accomplishmentCount;
  List<double> spiderChartListCopy = new List<double>();
  List<String> spiderChartNameCopy = new List<String>();
  int achievmentCount = 0;
  String strAccCount = "",
      strRecCount = "";
  int currentPage = 0;

  Particles(this.profileInfoModal,
      this.spiderChartList,
      this.spiderChartName,
      this.userEducationList,
      this.narrativeList,
      this.mainNarrativeList,
      this.indexRemoveList,
      this.mainSpiderChartList,
      this.mainSpiderChartName,
      this.accomplishmentCount,
      this.addedRecommendationtList,
      this.recommendationtList,
      this.achievmentCount,
      this.strAccCount,
      this.strRecCount);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> with TickerProviderStateMixin {
  //static const _rotationChannel = const MethodChannel('zgadula/orientation');
  List<NarrativeModel> narrativeListLocal = new List();

  final Random random = Random();
  String time = "2:0 min";
  final List<ParticleModel> particles = [];

  List<int> indexRemoveList = new List();
  int indexData = 0;

  // Bottom Navigation Animation variable
  AnimationController _bottomNavController,
      _topNavController,
      _frame2BodyController,
      _spiderChartTextBodyController,
      _thankYouTextBodyController,
      _profilePictureController,
      _profilePictureControllerGone,
      _frame2ProfilePictureController,
      spideChartAnimationController;
  Animation<Offset> bottomNavOffset,
      topNavOffset,
      frame2BodyOffset,
      spiderChartTextBodyOffset;

  Animation<double> spiderChartAnimation;

  String userIdPref;
  int previousPage = 0;

  // Profile Picture Animation
  Animation _animation;
  bool visible = false;
  bool isShowAll = false;

  // My Sotry page Animation

  AnimationController animationControllerMyStory;
  Animation<double> animationMyStory;

  // For Frame 2
  //bool isFrame2Showing = false;
  int frameNo = 0,
      subFrame = 0;

  // For Education Frame 3

  double viewPortFraction = 0.22;

  PageController pageController;

  int currentPage = 0;

  double page = 2.0;

  int narrativeCount = 0;
  int acheivementListCount = 0;
  int reccomendationListCount = 0;

  AnimationController animationController;
  Animation animation;

  AnimationController thankYouAnimcontroller;
  Animation<Offset> thankYouAnimoffset;

  bool isPaused = false;
  bool isFilterOpen = false;

  double imageWidth = 210.0,
      imageHeight = 210.0;

  AnimationController controller;
  Animation<Offset> offset, offset1;
  List<Widget> widgets;
  bool isBackPressed = false;
  int dataIndex = 1;
  Timer actionControllerHandlerTimer;
  bool isActionButtonShowing = false; // V2.0
  PageController _controller; // V2.0
  bool _executeFutureForSliding = true;
  bool firstBigCircleIssueHandler = false;

  int timeFrame_0 = 10,
      timeFrame_1 = 5,
      timeFrame_2 = 10, // Spider Chart
      timeFrame_3 = 0, // Education Pager Circle View
      timeFrame_4, // Not in Scope Already Merged with 3
      timeFrame_5 = 5, // All Achievement List
      timeFrame_6 = 5, // All Recommendation
      timeFrame_7 = 10,
      imageSlideDuration = 2,
      educationCircleSlideDuration = 2,
      updatedTimeForFrameNavigation;
  double resultStamp;

  // V2.0 for Image sliding automatically
//  void _animateSlider(pagerList) {
//    Future.delayed(Duration(seconds: 2)).then((_) {
//
//      if(_executeFutureForSliding){
//        int nextPage = _controller.page.round() + 1;
//        if (nextPage == pagerList.length) {
//          nextPage = 0;
//          _controller.jumpToPage(nextPage);
//          _executeFutureForSliding = false;
//          //navigationCondition
//        } else {
//          _controller
//              .animateToPage(nextPage,
//              duration: Duration(seconds: 1), curve: Curves.linear)
//              .then((_) => _animateSlider(pagerList));
//        }
//
//      }
//
//    });
//  }
  Timer t, t1, timer, educationTimer;

  void timerScheduleForNavigation(int time) {
    cancelNavigationTimer();
    timer = Timer.periodic(Duration(seconds: time), (timer) {
      if (!isPaused && frameNo != 7) {
        isBackPressed = false;
        _navigationBtnClick(true);
      }
    });
  }

  void cancelNavigationTimer() {
    if (timer != null) {
      timer.cancel(); // Cancel Exsiting Timer
    }
  }

  void calculateTotalNavigationTime() {
    if (widget.userEducationList.length > 2) {
      timeFrame_3 = timeFrame_3 +
          widget.userEducationList.length * educationCircleSlideDuration;

      timeFrame_3 =
          timeFrame_3 + 5; // Addeed 5 more seconds to navigate neext slide
    } else {
      timeFrame_3 = 10;
    }

    updatedTimeForFrameNavigation =
        timeFrame_0 + timeFrame_1 + timeFrame_2 + timeFrame_3;

    // For Achievment
    if (narrativeListLocal != null) {
      for (int i = 0; i < narrativeListLocal.length; i++) {
        for (int j = 0; j < narrativeListLocal[i].achivmentList.length; j++) {
          print("ASSETS LIST " +
              narrativeListLocal[i]
                  .achivmentList[j]
                  .assestList
                  .length
                  .toString());
          if (narrativeListLocal[i].achivmentList[j].assestList.length > 2) {
            updatedTimeForFrameNavigation = updatedTimeForFrameNavigation +
                ((narrativeListLocal[i].achivmentList[j].assestList.length) *
                    imageSlideDuration);
          } else {
            updatedTimeForFrameNavigation = updatedTimeForFrameNavigation + 5;
          }
        }
      }
    }
    // For Recommendation
    if (widget.addedRecommendationtList != null &&
        widget.addedRecommendationtList.length > 0) {
      updatedTimeForFrameNavigation = updatedTimeForFrameNavigation +
          (widget.addedRecommendationtList.length * 5);
    }

    resultStamp = updatedTimeForFrameNavigation / 60;

    int decimals = 2;
    int fac = pow(10, decimals);
    resultStamp = (resultStamp * fac).round() / fac;
  }

  void _animateSlider(pagerList, txt) {
    if (pagerList == null || pagerList.length == 0 || pagerList.length == 1) {
      imageSlideDuration = 5;
    } else {
      imageSlideDuration = 2;
    }
    t = Timer(Duration(seconds: imageSlideDuration), () {
      print("outerLoop _executeFutureForSliding" +
          _executeFutureForSliding.toString());
      if (_executeFutureForSliding) {
        int nextPage = _controller.page.round() + 1;

        if (nextPage == pagerList.length) {
          nextPage = 0;
          if (t != null) {
            print("Cancel t here");
            t.cancel();
          }
          cancelNavigationTimer();
          _controller.jumpToPage(nextPage);

          //
          _executeFutureForSliding = false;

          isBackPressed = false;

          if (!isPaused) {
            _navigationBtnClick(true);
          } else {
            isShowAll = true;
          }
          print("outerLoop next" + nextPage.toString());

          //navigationCondition
        } else {
          print("last index called" + nextPage.toString());
          if (nextPage == pagerList.length) {
            nextPage = 0;
            print("outerLoop next last index called" + nextPage.toString());
          }

          _controller
              .animateToPage(nextPage,
              duration: Duration(seconds: imageSlideDuration),
              curve: Curves.linear)
              .then((_) => _animateSlider(pagerList, "continue"));

          isShowAll = false;
        }
      }
    });
  }

  void _animateEducationCircle() {
    educationTimer = Timer(Duration(milliseconds: 1500), () {
      if (!isFilterOpen) {
        int nextPage = pageController.page.round() + 1;
        if (nextPage == widget.userEducationList.length) {
          nextPage = 0;
          educationTimer.cancel();
          //_navigationBtnClick(true);
        } else {
          educationTimer.cancel();
          pageController
              .animateToPage(nextPage,
              duration: Duration(milliseconds: 1500), curve: Curves.linear)
              .then((_) => _animateEducationCircle());
        }
      }
    });
  }

  @override
  void dispose() {
    _bottomNavController.dispose();
    _topNavController.dispose();
    _profilePictureController.dispose();
    _frame2ProfilePictureController.dispose();
    _frame2BodyController.dispose();
    _profilePictureControllerGone.dispose();
    spideChartAnimationController.dispose();
    _spiderChartTextBodyController.dispose();
    animationControllerMyStory.dispose();
    _thankYouTextBodyController.dispose();

    super.dispose();
  }

  refresh() async {
    widget.spiderChartName.clear();
    widget.spiderChartList.clear();
    widget.spiderChartListCopy.clear();
    widget.spiderChartNameCopy.clear();
    widget.spiderChartList.addAll(widget.mainSpiderChartList);
    widget.spiderChartName.addAll(widget.mainSpiderChartName);

    setState(() {
      widget.spiderChartList;
      widget.spiderChartName;
    });

    widget.narrativeList = await widget.mainNarrativeList
        .map((item) => new NarrativeModel.clone(item))
        .toList();
    setState(() {
      widget.narrativeList;
    });
    //  Navigator.pop(context);
  }

//  void initBgCircleAnim() {
//    animationController = AnimationController(
//      duration: Duration(
//        seconds: 3,
//      ),
//      vsync: this,
//    );
//    animation = Tween(begin: 1.0, end: 2.0).animate(animationController);
//
//    animationController.addStatusListener(circleAnimationStatusListener);
//    animationController.forward();
//  }

  void initBgCircleAnim() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 0.1))
        .animate(controller);

    offset1 = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 0.1))
        .animate(controller);

    controller.addStatusListener(circleAnimationStatusListener);

    controller.forward();
  }

  void circleAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      controller.forward();
    }
  }


  void thankYouAnimationStatusListener() {
    if (thankYouAnimcontroller.status == AnimationStatus.completed) {
      thankYouAnimcontroller.reverse();
    } else if (thankYouAnimcontroller.status == AnimationStatus.dismissed) {
      thankYouAnimcontroller.forward();
    }
  }

  void initThankYouPageAnim() {
    thankYouAnimcontroller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    thankYouAnimoffset =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
            .animate(thankYouAnimcontroller);

    // thankYouAnimcontroller.addStatusListener(thankYouAnimationStatusListener);
    thankYouAnimcontroller.forward();
  }

  SharedPreferences prefs;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
  }

  @override
  void initState() {
    AutoOrientation.landscapeAutoMode();
//    try {
//      _rotationChannel.invokeMethod('setLandscape');
//    } catch (error) {
//      print("############ Error on landscape");
//    }
//

    // setOrientation();

    List.generate(10, (index) {
      particles.add(ParticleModel(random));
    });

    super.initState();
    calculateTotalNavigationTime();
    timerScheduleForNavigation(timeFrame_0);

    getSharedPreferences();
    initBgCircleAnim();
    initThankYouPageAnim();

    _profilePictureController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    _profilePictureControllerGone =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    _frame2ProfilePictureController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    _bottomNavController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 0));

    _topNavController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));

    _frame2BodyController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _thankYouTextBodyController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    bottomNavOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(_bottomNavController);

    topNavOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(_topNavController);

    frame2BodyOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(_frame2BodyController);

    _spiderChartTextBodyController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    spiderChartTextBodyOffset =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
            .animate(_spiderChartTextBodyController);

    spideChartAnimationController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);

    _animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _profilePictureController,
      curve: Curves.fastOutSlowIn,
    ));

    _profilePictureController.forward();
    _frame2BodyController.forward();
    spideChartAnimationController.forward();
    _spiderChartTextBodyController.forward();
    _thankYouTextBodyController.forward();
    thankYouAnimcontroller.forward();
    _topNavController.forward();

    _bottomNavController.forward();

    // Animate the Profile Information
    Timer _timer = new Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        visible = true;
      });
    });

    // Spider Chart Animation Initilization

    spiderChartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: spideChartAnimationController,
        curve: Interval(
          0,
          0.5,
          curve: Curves.decelerate,
        ),
      ),
    );

    pageController = PageController(
        initialPage: currentPage, viewportFraction: viewPortFraction);

    for (int i = 0; i < widget.narrativeList.length; i++) {
      if (widget.narrativeList[i].achivmentList.length > 0) {
        narrativeListLocal.add(widget.narrativeList[i]);
      }
    }

    setDataForWorldCloud();

    setState(() {
      narrativeListLocal;
    });

    print("wid get.achivmentList" + narrativeListLocal.length.toString());
  }

  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Get Profile Picture View

    final double width = MediaQuery
        .of(context)
        .size
        .width;

    print(width);

    var profilePictureView = new AnimatedBuilder(
        animation: frameNo == 1
            ? _frame2ProfilePictureController
            : frameNo == 2
            ? _profilePictureControllerGone
            : _profilePictureController,
        builder: (BuildContext context, Widget child) {
          return isBackPressed
              ? new Container(
            height: imageHeight,
            width: imageWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: FadeInImage.assetNetwork(
                fit: BoxFit.cover,
                placeholder: 'assets/profile/user_on_user.png',
                image: widget.profileInfoModal != null
                    ? Constant.IMAGE_PATH_SMALL +
                    ParseJson.getMediumImage(
                        widget.profileInfoModal.profilePicture)
                    : "",
              ),
            ),
          )
              : new Transform(
              transform: Matrix4.translationValues(
                  _animation.value * width, 0.0, 0.0),
              child: new Padding(
                  padding: EdgeInsets.fromLTRB(
                      0.0, 0.0, frameNo == 1 ? 100.0 : 0.0, 0.0),
                  child: new Container(
                    height: imageHeight,
                    width: imageWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        placeholder: 'assets/profile/user_on_user.png',
                        image: widget.profileInfoModal != null
                            ? Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(
                                widget.profileInfoModal.profilePicture)
                            : "",
                      ),
                    ),
                  )));
        });

    var profileTextInfo = new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 30.0, 0.0),
        child: AnimatedOpacity(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Hello, I am",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: Constant.customRegular,
                    color: Color(ColorValues.HEADING_COLOR_EDUCATION),
                    fontSize: 28.0),
              ),
              new Flexible(
                  child: new Text(
                    widget.profileInfoModal == null
                        ? ""
                        : widget.profileInfoModal.lastName == "" ||
                        widget.profileInfoModal.lastName == "null"
                        ? widget.profileInfoModal.firstName
                        : widget.profileInfoModal.firstName +
                        " " +
                        widget.profileInfoModal.lastName,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: Constant.customRegular,
                        color: Color(ColorValues.BLUE_COLOR_BOTTOMBAR),
                        fontSize: 37.0),
                  )),
              new Text(
                widget.profileInfoModal == null
                    ? ""
                    : widget.profileInfoModal.tagline == null ||
                    widget.profileInfoModal.tagline == "null"
                    ? ""
                    : widget.profileInfoModal.tagline,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: Constant.customRegular,
                    color: Color(ColorValues.HEADING_COLOR_EDUCATION),
                    fontSize: 20.0),
              )
            ],
          ),
          duration: Duration(seconds: 1),
          opacity: visible ? 1.0 : 0.0,
        ));

    AnimatedOpacity getHeader(String title) {
      return AnimatedOpacity(
        child: new Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 100.0,
              color:
              Color(ColorValues.GRAY_HEADER_PRESSO_VIEW).withOpacity(0.34),
              fontFamily: Constant.customRegular),
        ),
        duration: Duration(seconds: 1),
        opacity: frameNo == 1 ||
            frameNo == 3 ||
            frameNo == 5 ||
            frameNo == 6 ||
            frameNo == 2
            ? 1.0
            : 0.0,
      );
    }

    var fram2BodyText = frameNo == 1
        ? new Expanded(
      child:
      /* new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
              child:*/
      new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: SlideTransition(
                position: frame2BodyOffset,
                child: new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 50.0),
                    child: new SingleChildScrollView(
                        child: new Text(
                          widget.profileInfoModal != null ||
                              widget.profileInfoModal != "null"
                              ? widget.profileInfoModal.summary == null ||
                              widget.profileInfoModal.summary == "null"
                              ? ""
                              : widget.profileInfoModal.summary
                              : "",
                          textAlign: TextAlign.justify,
                          maxLines: 25,
                          style: TextStyle(
                              fontFamily: Constant.customRegular,
                              fontSize: 16.0,
                              color: Color(
                                  ColorValues.HEADING_COLOR_EDUCATION)),
                        ))),
              )),
        ],
      ),
      flex: 1,
    )
        : new Container(
      width: 0.0,
    );

    var spiderChartView = ScaleTransition(
      scale: spiderChartAnimation,
      child: new Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: new Container(
              height: 240.0,
              width: 240.0,
              child: Container(
                  child: new Center(
                    child: SpiderChart(
                      data: widget.spiderChartList,
                      name: widget.spiderChartName,
                      outerLineColor: new Color(0xffbdc7ce).withOpacity(0.6),
                      innerLineColor: new Color(0xffbdc7ce).withOpacity(0.6),
                      dotColor: Colors.orange,
                      bgFillColor: new Color(0xFF00040c).withOpacity(.6),
                      maxValue:
                      12, // the maximum value that you want to represent (essentially sets the data scale of the chart)
                    ),
                  )))),
    );

    var thankYouPage = new Padding(
        padding: EdgeInsets.fromLTRB(00.0, 30.0, 20.0, 0.0),
        child: SlideTransition(
            position: thankYouAnimoffset,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                frameNo == 7
                    ? new Container(
                  height: 120.0,
                  width: 120.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: 'assets/profile/user_on_user.png',
                      image: widget.profileInfoModal != null
                          ? Constant.IMAGE_PATH_SMALL +
                          ParseJson.getMediumImage(
                              widget.profileInfoModal.profilePicture)
                          : "",
                    ),
                  ),
                )
                    : new Container(
                  height: 0.0,
                ),
                new Text(
                  frameNo == 7
                      ? widget.profileInfoModal == null
                      ? ""
                      : widget.profileInfoModal.lastName == "" ||
                      widget.profileInfoModal.lastName == "null"
                      ? widget.profileInfoModal.firstName
                      : widget.profileInfoModal.firstName +
                      " " +
                      widget.profileInfoModal.lastName
                      : "Here is my",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: Constant.customRegular,
                      color: Color(ColorValues.WHITE),
                      fontSize: frameNo == 7 ? 20.0 : 28.0),
                ),
                new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Column(
                          children: <Widget>[
                            new Text(
                              widget.accomplishmentCount == 0
                                  ? "0"
                                  : widget.accomplishmentCount
                                  .toString()
                                  .length ==
                                  1
                                  ? "0" +
                                  widget.accomplishmentCount.toString()
                                  : widget.accomplishmentCount.toString(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontFamily: Constant.customRegular,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Color(ColorValues.BLUE_COLOR_BOTTOMBAR),
                                  fontSize: 40.0),
                            ),
                            new Text(
                              "Accomplishments",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontFamily: Constant.customRegular,
                                  fontWeight: FontWeight.bold,
                                  color: Color(ColorValues.WHITE),
                                  fontSize: 18.0),
                            ),
                          ],
                        ),
                        new Container(
                          width: 80.0,
                        ),
                        new Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: new Column(
                              children: <Widget>[
                                new Text(
                                  widget.addedRecommendationtList.length == 0
                                      ? "0"
                                      : widget.addedRecommendationtList.length
                                      .toString()
                                      .length ==
                                      1
                                      ? "0" +
                                      widget.addedRecommendationtList
                                          .length
                                          .toString()
                                      : widget
                                      .addedRecommendationtList.length
                                      .toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: Constant.customRegular,
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          ColorValues.BLUE_COLOR_BOTTOMBAR),
                                      fontSize: 40.0),
                                ),
                                new Text(
                                  "Recommendations",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: Constant.customRegular,
                                      fontWeight: FontWeight.bold,
                                      color: Color(ColorValues.WHITE),
                                      fontSize: 18.0),
                                ),
                              ],
                            ))
                      ],
                    )),
                new SizedBox(
                  height: 10.0,
                ),
                frameNo == 7
                    ? new Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: new Text(
                      "Thanks for watching",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: Constant.customRegular,
                          fontWeight: FontWeight.bold,
                          color: Color(ColorValues.WHITE),
                          fontSize: 30.0),
                    ))
                    : Container(
                  height: 0.0,
                )
              ],
            )));

    //-------------------- Education Pager view -------------------------------
    Widget circleOffer(model, double scale) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: new Stack(
            children: <Widget>[
              Container(
                //margin: EdgeInsets.only(bottom: 10),
                height: PAGER_HEIGHT * scale,
                width: PAGER_HEIGHT * scale,
                child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent, width: 5)),
                    child: new Stack(
                      children: <Widget>[
                        FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'assets/profile/img_default.png',
                          image: Constant.IMAGE_PATH + model.logo,
                        ),
                        model.isBlurr
                            ? new Container(
                            color: Colors.white.withOpacity(0.6))
                            : new Container(color: Colors.transparent)
                      ],
                    )),
              ),
            ],
          ));
    }

    var pagerViewForEducation = ListView(
      children: <Widget>[
        Container(
          height: PAGER_HEIGHT,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                setState(() {
                  page = pageController.page;
                });
              }
            },
            child: PageView.builder(
              onPageChanged: (pos) {
                setState(() {
                  currentPage = pos;

                  // Reset All items
                  for (int i = 0; i < widget.userEducationList.length; i++) {
                    widget.userEducationList[i].isBlurr = true;
                  }
                  //widget.userEducationList[0].isBlurr = false;
                  // widget.userEducationList[1].isBlurr = false;

                  if (widget.userEducationList.length > 0) {
                    if (widget.userEducationList.length <= 2) {
                      if (widget.userEducationList.length == 1) {
                        widget.userEducationList[0].isBlurr = false;
                      } else {
                        widget.userEducationList[0].isBlurr = false;
                        widget.userEducationList[1].isBlurr = false;
                      }
                    } else {
                      if (currentPage == 1) {
                        widget.userEducationList[0].isBlurr = false;
                        widget.userEducationList[1].isBlurr = false;
                        widget.userEducationList[2].isBlurr = false;
                      }

                      if (currentPage == 0) {
                        widget.userEducationList[0].isBlurr = false;
                        widget.userEducationList[1].isBlurr = false;
                        widget.userEducationList[2].isBlurr = true;
                      }
                      if (currentPage > 1) {
                        widget.userEducationList[currentPage].isBlurr = false;
                        widget.userEducationList[currentPage + 1].isBlurr =
                        false;
                        widget.userEducationList[currentPage - 1].isBlurr =
                        false;
                      }

                      if (currentPage == widget.userEducationList.length - 1) {
                        widget
                            .userEducationList[
                        widget.userEducationList.length - 2]
                            .isBlurr = false;
                      }
                    }
                  }
                });
              },
              //physics: BouncingScrollPhysics(),
              controller: pageController,
              itemCount: widget.userEducationList.length,
              itemBuilder: (context, index) {
                if (widget.userEducationList.length > 0) {
                  if (widget.userEducationList.length <= 2) {
                    if (widget.userEducationList.length == 1) {
                      widget.userEducationList[0].isBlurr = false;
                    } else {
                      widget.userEducationList[0].isBlurr = false;
                      widget.userEducationList[1].isBlurr = false;
                    }
                  } else if (currentPage == 0) {
                    widget.userEducationList[0].isBlurr = false;
                    widget.userEducationList[1].isBlurr = false;
                    widget.userEducationList[2].isBlurr = true;
                  }
                  if (widget.userEducationList.length > 2) if (currentPage ==
                      widget.userEducationList.length - 1) {
                    widget.userEducationList[currentPage].isBlurr = false;
                    widget.userEducationList[currentPage - 1].isBlurr = false;
                    widget.userEducationList[currentPage - 2].isBlurr = true;
                  }

                  /* double scale = max(SCALE_FRACTION,
                      (FULL_SCALE - (index - page).abs()) + viewPortFraction);

                  if (widget.userEducationList[index].isBlurr) {
                    scale = max(SCALE_FRACTION_BLURR,
                        (FULL_SCALE - (index - page).abs()) + viewPortFraction);
                  }*/

                  double scale = 1.0;
                  if (currentPage == index) {
                    print("Here is the Circle check");
                    scale = 1.0;
                  } else if (widget.userEducationList[index].isBlurr) {
                    print("Here is the Circle check");
                    scale = 0.6;
                  } else {
                    scale = 0.7;
                  }

                  return circleOffer(widget.userEducationList[index], scale);
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Column(
            children: <Widget>[
              Text(
                widget.userEducationList.length > 0
                    ? widget.userEducationList[currentPage].institute
                    : "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              new Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    widget.userEducationList.length > 0
                        ? widget.userEducationList[currentPage].fromYear +
                        " - " +
                        widget.userEducationList[currentPage].toYear +
                        " | " +
                        widget.userEducationList[currentPage].fromGrade +
                        " - " +
                        widget.userEducationList[currentPage].toGrade
                        : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ))
            ],
          ),
        ),
      ],
    );

    Widget getworldCloudView() {
      final screenSize = MediaQuery
          .of(context)
          .size;
      final ratio = screenSize.width / screenSize.height;

      return Center(
        child: FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
            children: widgets,
          ),
        ),
      );
    }

    String getConvertedDateStamp3(String time) {
      if (time != "null") {
        int millis = int.tryParse(time);
        var now = new DateTime.fromMillisecondsSinceEpoch(millis);
        var formatter = new DateFormat('MMM, yyyy');
        String formatted = formatter.format(now);
        return formatted;
      } else {
        //  strEnd = getConvertedDateStamp(new DateTime.now().millisecondsSinceEpoch.toString());
        var formatter = new DateFormat('MMM, yyyy');
        return formatter.format(new DateTime.now());
      }
    }

    String getConvertedDateStamp2(String time) {
      if (time != "null") {
        int millis = int.tryParse(time);
        var now = new DateTime.fromMillisecondsSinceEpoch(millis);
        var formatter = new DateFormat('MMM, dd yyyy');
        String formatted = formatter.format(now);
        return formatted;
      } else {
        //  strEnd = getConvertedDateStamp(new DateTime.now().millisecondsSinceEpoch.toString());
        var formatter = new DateFormat('MMM, dd yyyy');
        return formatter.format(new DateTime.now());
      }
    }

    Widget getViewBasedOnTheIndex(child) {
      firstBigCircleIssueHandler = false;

      print("Child Info" + child);
      switch (frameNo) {
        case 0:
          return new Stack(
            children: <Widget>[
              getHeader(""),
              new Center(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      fram2BodyText,
                      new SizedBox(
                        width: 100.0,
                      ),
                      new Expanded(
                        child: profilePictureView,
                        flex: 0,
                      ),
                      new SizedBox(
                        width: 100.0,
                      ),
                      new Expanded(child: profileTextInfo, flex: 1),
                    ],
                  )),
            ],
          );

          break;

        case 1:
          return new Stack(
            children: <Widget>[
              new Positioned(top: -30, child: getHeader("about me")),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: PaddingWrap.paddingfromLTRB(
                        80.0,
                        0.0,
                        0.0,
                        0.0,
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            /*  new SizedBox(
                          width: 80.0,
                        ),*/
                            fram2BodyText
                          ],
                        )),
                    flex: 1,
                  ),
                  new Expanded(
                    child: new Container(),
                    flex: 1,
                  ),
                ],
              ),
              PaddingWrap.paddingfromLTRB(
                  0.0,
                  0.0,
                  130.0,
                  0.0,
                  new Align(
                      alignment: Alignment.centerRight,
                      child: new Padding(
                          padding: EdgeInsets.only(top: 28.0),
                          child: new AnimatedBuilder(
                              animation: frameNo == 1
                                  ? _frame2ProfilePictureController
                                  : frameNo == 2
                                  ? _profilePictureControllerGone
                                  : _profilePictureController,
                              builder: (BuildContext context, Widget child) {
                                return new Transform(
                                  transform: Matrix4.translationValues(
                                      _animation.value * 300, 0.0, 0.0),
                                  child: new Container(
                                    height: imageHeight,
                                    width: imageWidth,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FadeInImage.assetNetwork(
                                        fit: BoxFit.cover,
                                        placeholder:
                                        'assets/profile/user_on_user.png',
                                        image: widget.profileInfoModal != null
                                            ? Constant.IMAGE_PATH_SMALL +
                                            ParseJson.getMediumImage(widget
                                                .profileInfoModal
                                                .profilePicture)
                                            : "",
                                      ),
                                    ),
                                  ),
                                );
                              }))))
            ],
          );

          break;

        case 2:
        // Second View Called with Animation
        //V2.0
          return new Stack(
            children: <Widget>[
              new Positioned(top: -30, child: getHeader("my spikeview")),
              new Center(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // new SizedBox(width: 35.0),
                      new Expanded(
                        child: PaddingWrap.paddingfromLTRB(
                            35.0, 20.0, 0.0, 0.0, spiderChartView),
                        flex: 1,
                      ),
                      new Expanded(
                        child: ScaleTransition(
                          scale: animationMyStory,
                          child: new Container(
                              child: new Padding(
                                padding: EdgeInsets.fromLTRB(
                                    10.0, 10.0, 0.0, 0.0),
//                  child: Wrap(
//                    children: _buildChoiceListForSpikeUser(),
//                  ),
                                child: getworldCloudView(),
                              )),
                        ),
                        flex: 1,
                      ),

                      // thankYouPage,
                    ],
                  )),
            ],
          );
          break;

        case 3:
          firstBigCircleIssueHandler = true;
          _animateEducationCircle();
          return new Stack(children: <Widget>[
            new Positioned(top: -30, child: getHeader("education")),
            new Center(
                child: new Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: pagerViewForEducation))
          ]);

          break;

        case 4:
        // MY STORY

        // SKIP FOR V 2.0

          return new Padding(
              padding: EdgeInsets.fromLTRB(20.0, 50.0, 0.0, 0.0),
              child: ScaleTransition(
                scale: animationMyStory,
                child: new Container(
                    child: new Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
//                  child: Wrap(
//                    children: _buildChoiceListForSpikeUser(),
//                  ),

                      child: getworldCloudView(),
                    )),
              ));

          break;

        case 5:
        // Maintain the Achievement List
        // V2.0

          print("Case 5 Called ");
          if (t != null) {
            print("Cancel t here");
            t.cancel();
          }

          _controller = new PageController(initialPage: 0, keepPage: false);
          _executeFutureForSliding = true;

          setState(() {
            _controller;
          });

          _animateSlider(
              narrativeListLocal[narrativeCount]
                  .achivmentList[acheivementListCount]
                  .assestList,
              "next");

          // Set Navigation Timer According to the Images
          if (narrativeListLocal[narrativeCount]
              .achivmentList[acheivementListCount]
              .assestList
              .length >
              2) {
            timerScheduleForNavigation(narrativeListLocal[narrativeCount]
                .achivmentList[acheivementListCount]
                .assestList
                .length *
                4); // Automatic Navigate After all Image visited
          } else {
            timerScheduleForNavigation(timeFrame_5);
          }

          return new Stack(children: <Widget>[
            new Positioned(
                top: -30,
                child: getHeader(
                    narrativeListLocal[narrativeCount].name.toLowerCase())),
            new Center(
                child: new Padding(
                  padding: EdgeInsets.only(top: 120.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // This makes the blue container full width.
                      Expanded(
                        child: Container(
                          child: Center(
                            child: new Center(
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        height: 220.0,
                                        child: narrativeListLocal[narrativeCount]
                                            .achivmentList[acheivementListCount]
                                            .assestList
                                            .length ==
                                            0
                                            ? new Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                40.0, 3.0, 0.0, 15.0),
                                            child: new Container(
                                              height: 220.0,
                                              child: new Image.asset(
                                                "assets/aerial/default_img.png",
                                                height: 220.0,
                                                fit: BoxFit.fill,
                                              ),
                                            ))
                                            : PageIndicatorContainer(
                                          pageView: PageView.builder(
                                            controller: _controller,
                                            itemBuilder: (context, position) {
                                              return new Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      40.0, 3.0, 0.0, 15.0),
                                                  child: new Stack(
                                                    children: <Widget>[
                                                      new Container(
                                                          height: 220.0,
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            fit: BoxFit.fill,
                                                            width:
                                                            double.infinity,
                                                            height: 220.0,
                                                            placeholder:
                                                            'assets/aerial/default_img.png',
                                                            image: Constant
                                                                .IMAGE_PATH +
                                                                narrativeListLocal[narrativeCount]
                                                                    .achivmentList[
                                                                acheivementListCount]
                                                                    .assestList[
                                                                position]
                                                                    .file,
                                                          )),
                                                      narrativeListLocal[
                                                      narrativeCount]
                                                          .achivmentList[
                                                      acheivementListCount]
                                                          .assestList
                                                          .length ==
                                                          1
                                                          ? new Container(
                                                        height: 0.0,
                                                      )
                                                          : new Container(
                                                        height: 220.0,
                                                        width:
                                                        double.infinity,
                                                        child:
                                                        new Image.asset(
                                                          "assets/newDesignIcon/navigation/layer_image.png",
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )
                                                    ],
                                                  ));
                                            },
                                            itemCount:
                                            narrativeListLocal[narrativeCount]
                                                .achivmentList[
                                            acheivementListCount]
                                                .assestList
                                                .length, // Can be null
                                          ),
                                          align: IndicatorAlign.bottom,
                                          length: narrativeListLocal[
                                          narrativeCount]
                                              .achivmentList[acheivementListCount]
                                              .assestList
                                              .length,
                                          indicatorSpace: 5.0,
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 10.0, 10.0, 25.0),
                                          indicatorColor: narrativeListLocal[
                                          narrativeCount]
                                              .achivmentList[
                                          acheivementListCount]
                                              .assestList
                                              .length ==
                                              1
                                              ? Colors.transparent
                                              : new Color(0xffc4c4c4),

                                          indicatorSelectorColor:
                                          narrativeListLocal[narrativeCount]
                                              .achivmentList[
                                          acheivementListCount]
                                              .assestList
                                              .length ==
                                              1
                                              ? Colors.transparent
                                              : Colors.white,
                                          shape: IndicatorShape.circle(size: 5),
                                          // shape: IndicatorShape.roundRectangleShape(size: Size.square(12),cornerSize: Size.square(3)),
                                          // shape: IndicatorShape.oval(size: Size(12, 8)),
                                        ),
                                      ),
                                      flex: 1,
                                    ),
                                    new Expanded(
                                        child: new Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              new Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      30.0, 0.0, 30.0, 0.0),
                                                  child: new Text(
                                                      narrativeListLocal[narrativeCount]
                                                          .achivmentList[
                                                      acheivementListCount]
                                                          .title,
                                                      textAlign: TextAlign
                                                          .start,
                                                      style: new TextStyle(
                                                          fontFamily:
                                                          Constant
                                                              .customRegular,
                                                          height: 0.8,
                                                          fontSize: 26.0,
                                                          color: Color(
                                                              ColorValues
                                                                  .HEADING_COLOR_EDUCATION)))),
                                              new Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      30.0, 2.0, 30.0, 0.0),
                                                  child: new Text(
                                                      narrativeListLocal[narrativeCount]
                                                          .achivmentList[acheivementListCount]
                                                          .fromDate ==
                                                          "null"
                                                          ? ""
                                                          : getConvertedDateStamp2(
                                                          narrativeListLocal[narrativeCount]
                                                              .achivmentList[
                                                          acheivementListCount]
                                                              .fromDate) +
                                                          " - " +
                                                          getConvertedDateStamp2(
                                                              narrativeListLocal[narrativeCount]
                                                                  .achivmentList[
                                                              acheivementListCount]
                                                                  .toDate),
                                                      textAlign: TextAlign
                                                          .start,
                                                      style: new TextStyle(
                                                          fontFamily:
                                                          Constant
                                                              .customRegular,
                                                          fontSize: 14.0,
                                                          color: Color(
                                                              ColorValues
                                                                  .GREY_TEXT_COLOR)))),
                                              new SizedBox(
                                                height: 10.0,
                                              ),
                                              new SingleChildScrollView(
                                                  child: new Container(
                                                      height: 80.0,
                                                      child: new Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                              30.0, 0.0, 30.0,
                                                              0.0),
                                                          child: new Text(
                                                              narrativeListLocal[narrativeCount]
                                                                  .achivmentList[
                                                              acheivementListCount]
                                                                  .description,
                                                              textAlign:
                                                              TextAlign.justify,
                                                              style: new TextStyle(
                                                                  fontFamily: Constant
                                                                      .customRegular,
                                                                  fontSize: 14.0,
                                                                  color: Color(
                                                                      ColorValues
                                                                          .HEADING_COLOR_EDUCATION)))))),
                                            ]),
                                        flex: 1),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          ]);

          break;

        case 6:
        // Maintain the recommendation View  List

        //timerScheduleForNavigation(timeFrame_6);
          return new Stack(children: <Widget>[
            new Positioned(top: -30, child: getHeader("recommendations")),
            new Stack(
              children: <Widget>[
                new Positioned(
                    left: 60.0,
                    right: 60.0,
                    top: 100.0,
                    bottom: 20.0,
                    child: new ListView(
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                                "\"" +
                                    widget
                                        .addedRecommendationtList[
                                    reccomendationListCount]
                                        .recommendation +
                                    "\"",
                                textAlign: TextAlign.justify,
                                style: new TextStyle(
                                    fontFamily: Constant.customRegular,
                                    fontSize: 16.0,
                                    color: Color(
                                        ColorValues.HEADING_COLOR_EDUCATION))),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                20.0,
                                0.0,
                                0.0,
                                new Text(
                                    widget
                                        .addedRecommendationtList[
                                    reccomendationListCount]
                                        .recommender
                                        .lastName ==
                                        null ||
                                        widget
                                            .addedRecommendationtList[
                                        reccomendationListCount]
                                            .recommender
                                            .lastName ==
                                            "null"
                                        ? widget
                                        .addedRecommendationtList[
                                    reccomendationListCount]
                                        .recommender
                                        .firstName
                                        : widget
                                        .addedRecommendationtList[
                                    reccomendationListCount]
                                        .recommender
                                        .firstName +
                                        " " +
                                        widget
                                            .addedRecommendationtList[
                                        reccomendationListCount]
                                            .recommender
                                            .lastName,
                                    textAlign: TextAlign.start,
                                    style: new TextStyle(
                                        fontFamily: Constant.customRegular,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Color(ColorValues
                                            .HEADING_COLOR_EDUCATION)))),
                            widget
                                .addedRecommendationtList[
                            reccomendationListCount]
                                .recommender
                                .title ==
                                null ||
                                widget
                                    .addedRecommendationtList[
                                reccomendationListCount]
                                    .recommender
                                    .title ==
                                    "null" ||
                                widget
                                    .addedRecommendationtList[
                                reccomendationListCount]
                                    .recommender
                                    .title ==
                                    ""
                                ? new Container(
                              height: 0.0,
                            )
                                : new Text(
                                widget
                                    .addedRecommendationtList[
                                reccomendationListCount]
                                    .recommender
                                    .title,
                                textAlign: TextAlign.start,
                                style: new TextStyle(
                                    fontFamily: Constant.customRegular,
                                    fontSize: 14.0,
                                    color: Color(ColorValues
                                        .HEADING_COLOR_EDUCATION))),
                            new SizedBox(
                              height: 5.0,
                            ),
                            new RichText(
                              textAlign: TextAlign.start,
                              text: new TextSpan(
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: "For: ",
                                      style: new TextStyle(
                                          fontFamily: Constant.customRegular,
                                          fontSize: 14.0,
                                          color: Color(ColorValues
                                              .HEADING_COLOR_EDUCATION))),
                                  new TextSpan(
                                      text: widget
                                          .addedRecommendationtList[
                                      reccomendationListCount]
                                          .level2Competency +
                                          "  |  " +
                                          getConvertedDateStamp3(widget
                                              .addedRecommendationtList[
                                          reccomendationListCount]
                                              .repliedDate),
                                      style: new TextStyle(
                                          fontFamily: Constant.customBold,
                                          fontSize: 16.0,
                                          color: Color(ColorValues
                                              .HEADING_COLOR_EDUCATION))),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
                /*  new Positioned(
                    left: 35.0,
                    right: 35.0,
                    bottom: 35.0,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                            widget
                                .addedRecommendationtList[
                                    reccomendationListCount]
                                .recommender
                                .firstName,
                            textAlign: TextAlign.start,
                            style: new TextStyle(
                                fontFamily: Constant.customRegular,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Color(
                                    ColorValues.HEADING_COLOR_EDUCATION))),
                        new Text(
                            widget
                                .addedRecommendationtList[
                                    reccomendationListCount]
                                .recommender
                                .title,
                            textAlign: TextAlign.start,
                            style: new TextStyle(
                                fontFamily: Constant.customRegular,
                                fontSize: 14.0,
                                color: Color(
                                    ColorValues.HEADING_COLOR_EDUCATION))),
                        new SizedBox(
                          height: 5.0,
                        ),
                        new RichText(
                          textAlign: TextAlign.start,
                          text: new TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                  text: "For: ",
                                  style: new TextStyle(
                                      fontFamily: Constant.customRegular,
                                      fontSize: 14.0,
                                      color: Color(ColorValues
                                          .HEADING_COLOR_EDUCATION))),
                              new TextSpan(
                                  text: widget
                                          .addedRecommendationtList[
                                              reccomendationListCount]
                                          .level2Competency +
                                      "  |  " +
                                      getConvertedDateStamp3(widget
                                          .addedRecommendationtList[
                                              reccomendationListCount]
                                          .repliedDate),
                                  style: new TextStyle(
                                      fontFamily: Constant.customBold,
                                      fontSize: 16.0,
                                      color: Color(ColorValues
                                          .HEADING_COLOR_EDUCATION))),
                            ],
                          ),
                        ),
                      ],
                    ))*/
              ],
            )
          ]);

          break;

        case 7:
        // Thanks View
          initThankYouPageAnim();
          return new Stack(
            children: <Widget>[
              new Center(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new SizedBox(width: 35.0),
                      widget.spiderChartList.length > 0
                          ? PaddingWrap.paddingfromLTRB(
                          0.0, 20.0, 0.0, 0.0, spiderChartView)
                          : PaddingWrap.paddingfromLTRB(
                          0.0,
                          20.0,
                          0.0,
                          0.0,
                          new Container(
                            height: 250.0,
                            width: 250.0,
                          )),
                      new Expanded(child: Container()),
                      // spiderChartTextBody,
                      thankYouPage,
                    ],
                  )),
            ],
          );
      }
    }

    refreshWhenIsShareTrue() async {
      widget.narrativeList = await widget.mainNarrativeList
          .map((item) => new NarrativeModel.clone(item))
          .toList();
      setState(() {
        widget.narrativeList;
      });
    }

    void educationRemoveConfromationDialog() async {
      refreshWhenIsShareTrue();
      String onTap = "cancel";
      setState(() {
        isFilterOpen = true;
        isPaused = true;
      });
      print("clicked data");
      widget.spiderChartName.clear();
      widget.spiderChartList.clear();
      widget.spiderChartListCopy.clear();
      widget.spiderChartNameCopy.clear();
      widget.spiderChartList.addAll(widget.mainSpiderChartList);
      widget.spiderChartName.addAll(widget.mainSpiderChartName);
      widget.pReviousNarrativeList.clear();
      widget.pReviousNarrativeList.addAll(widget.narrativeList);
      setState(() {
        widget.spiderChartName;
        widget.spiderChartList;
      });
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) =>
          new WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
              },
              child: new Scaffold(
                  backgroundColor: Colors.black38,
                  body: new Stack(
                    children: <Widget>[
                      new Positioned(
                          right: 12.0,
                          left: 12.0,
                          top: 10.0,
                          bottom: 68.0,
                          child: new Container(
                              height: 300.0,
                              color: Colors.white,
                              child: new Stack(
                                children: <Widget>[
                                  new Container(
                                    height: 60.0,
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            PaddingWrap.paddingfromLTRB(
                                                16.0,
                                                14.0,
                                                0.0,
                                                8.0,
                                                TextViewWrap.textView(
                                                    "Filter",
                                                    TextAlign.center,
                                                    new Color(0xff151515),
                                                    16.0,
                                                    FontWeight.normal)),
                                          ],
                                        ),
                                        CustomViews.getSepratorLine(),
                                      ],
                                    ),
                                  ),
                                  PaddingWrap.paddingfromLTRB(
                                      0.0,
                                      60.0,
                                      0.0,
                                      0.0,
                                      ListView(children: <Widget>[
                                        ModalBottomSheet(widget.narrativeList)
                                      ]))
                                ],
                              ))),
                      new Positioned(
                        right: 0.0,
                        left: 0.0,
                        bottom: 10.0,
                        child: new Align(
                          alignment: Alignment.bottomCenter,
                          child: PaddingWrap.paddingfromLTRB(
                              12.0,
                              0.0,
                              12.0,
                              0.0,
                              new Container(
                                  color: Colors.white,
                                  padding: new EdgeInsets.all(10.0),
                                  height: 51.0,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "Cancel",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .GREY_TEXT_COLOR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.pop(context);
                                            widget.narrativeList.clear();
                                            widget.narrativeList.addAll(
                                                widget.pReviousNarrativeList);
                                            setState(() {
                                              widget.narrativeList;
                                              isFilterOpen = false;
                                              isPaused = false;

                                              // _animateEducationCircle();
                                            });
                                          },
                                        ),
                                        flex: 1,
                                      ),
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "Apply",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .BLUE_COLOR_BOTTOMBAR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              isFilterOpen = false;
                                              isPaused = false;
                                              onTap = "Apply";
                                              _animateEducationCircle();
                                            });
                                          },
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  ))),
                        ),
                      ),
                    ],
                  ))));

      if (frameNo == 5 && onTap == "Apply") {
        setState(() {
          frameNo = 3;
          timerScheduleForNavigation(timeFrame_3);
          narrativeCount = 0;
          acheivementListCount = 0;
        });
      }

      for (int i = 0; i < widget.narrativeList.length; i++) {
        try {
          widget.narrativeList[i].achivmentList.clear();
          widget.mainNarrativeList[i].imoportanceValue =
              widget.narrativeList[i].imoportanceValue;

          widget.narrativeList[i].achivmentList = await widget
              .mainNarrativeList[i].achivmentList
              .map((item) => new Achivment.clone(item))
              .toList();
          indexRemoveList.clear();
          for (int j = 0;
          j < widget.narrativeList[i].achivmentList.length;
          j++) {
            if (int.parse(
                widget.narrativeList[i].achivmentList[j].importance) >=
                widget.narrativeList[i].imoportanceValue.toInt()) {
              String s = "";
            } else {
              indexRemoveList.add(j);
            }
          }

          for (int k = 0; k < indexRemoveList.length; k++) {
            if (k == 0)
              widget.narrativeList[i].achivmentList
                  .removeAt(indexRemoveList[k]);
            else
              widget.narrativeList[i].achivmentList
                  .removeAt(indexRemoveList[k] - k);
          }
        } catch (e) {
          e.toString();
        }

        for (int j = 0; j < widget.spiderChartName.length; j++) {
          if (widget.narrativeList[i].achivmentList.length > 0) {
            if (widget.narrativeList[i].name == widget.spiderChartName[j]) {
              widget.spiderChartNameCopy.add(widget.spiderChartName[j]);
              widget.spiderChartListCopy.add(widget.spiderChartList[j]);
            }
          }
        }

        if (i == widget.narrativeList.length - 1) {
          if (widget.spiderChartName.length ==
              widget.spiderChartListCopy.length) {
            setState(() {
              widget.spiderChartListCopy;
              widget.spiderChartNameCopy;
              widget.spiderChartName;
              widget.spiderChartList;
            });
          } else {
            widget.spiderChartName.clear();
            widget.spiderChartList.clear();
            widget.spiderChartList.addAll(widget.spiderChartListCopy);
            widget.spiderChartName.addAll(widget.spiderChartNameCopy);
            setState(() {
              widget.spiderChartListCopy;
              widget.spiderChartNameCopy;
              widget.spiderChartName;
              widget.spiderChartList;
            });
          }

          setState(() {
            widget.narrativeList;
          });
        }
      }
      widget.accomplishmentCount = 0; //
      for (int i = 0; i < widget.narrativeList.length; i++) {
        if (widget.narrativeList[i].achivmentList.length > 0) {
          widget.accomplishmentCount = widget.accomplishmentCount +
              widget.narrativeList[i].achivmentList.length;
        }
      }
      narrativeListLocal.clear();
      for (int i = 0; i < widget.narrativeList.length; i++) {
        if (widget.narrativeList[i].achivmentList.length > 0) {
          narrativeListLocal.add(widget.narrativeList[i]);
        }
      }

      setState(() {
        widget.accomplishmentCount;
        widget.mainNarrativeList;
        narrativeListLocal;
      });
    }

    Widget getCircleViewForBackGround(Color circleColor) {
      return new Positioned(
          left: 0.0,
          bottom: 0.0,
          top: 0.0,
          right: 0.0,
          child: new Container(
            child: new Stack(
              children: <Widget>[
                frameNo != 1
                    ? new Positioned(
                    top: -20,
                    left: -20,
                    child: SlideTransition(
                        position: offset,
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(80 / 2),
                              ),
                              color: circleColor,
                            ),
                          ),
                        )))
                    : new Positioned(
                    top: 110,
                    left: 30,
                    child: SlideTransition(
                        position: offset,
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(80 / 2),
                              ),
                              color: circleColor,
                            ),
                          ),
                        ))),
                frameNo != 1
                    ? new Positioned(
                    top: 80,
                    right: 80,
                    child: new Align(
                        alignment: Alignment.topRight,
                        child: SlideTransition(
                            position: offset,
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(60 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            ))))
                    : new Container(width: 0.0),
                frameNo != 1
                    ? new Positioned(
                    top: 30.0,
                    left: 50.0,
                    right: 40.0,
                    child: new Align(
                        alignment: Alignment.topCenter,
                        child: SlideTransition(
                            position: offset,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            ))))
                    : new Container(width: 0.0),
                frameNo != 1
                    ? new Positioned(
                    top: 80.0,
                    left: 100.0,
                    right: 10.0,
                    child: new Align(
                        alignment: Alignment.center,
                        child: SlideTransition(
                            position: offset,
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            ))))
                    : new Container(width: 0.0),

                frameNo == 1
                    ? new Positioned(
                    right: 200,
                    bottom: -30,
                    child: new Align(
                        alignment: Alignment.bottomRight,
                        child: SlideTransition(
                            position: offset,
                            child: Center(
                              child: Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(230 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            ))))
                    : new Positioned(
                    right: -30,
                    bottom: -30,
                    child: new Align(
                        alignment: Alignment.bottomRight,
                        child: SlideTransition(
                            position: offset,
                            child: Center(
                              child: Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(230 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            )))),

//                new Positioned(
//                    left: -50,
//                    bottom: -50,
//                    child: new Align(
//                        alignment: Alignment.bottomLeft,
//                        child: SlideTransition(
//                            position: offset,
//                            child:Center(
//                              child: Container(
//                                width: 120,
//                                height: 120,
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(120 / 2),
//                                  ),
//                                  color: Colors.orangeAccent,
//                                ),
//                              ),)
//
//                        ))),
                frameNo != 1
                    ? new Positioned(
                    bottom: 40.0,
                    left: 50.0,
                    right: 40.0,
                    child: new Align(
                        alignment: Alignment.bottomCenter,
                        child: SlideTransition(
                            position: offset1,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40 / 2),
                                  ),
                                  color: circleColor,
                                ),
                              ),
                            ))))
                    : new Container(
                  width: 0.0,
                )
              ],
            ),
          ));
    }

    showConformationDialog() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) =>
          new WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
              },
              child: new Scaffold(
                  backgroundColor: Colors.black38,
                  body: new Stack(
                    children: <Widget>[
                      new Positioned(
                          right: 0.0,
                          left: 0.0,
                          bottom: 40.0,
                          child: new Container(
                              height: 200.0,
                              color: Colors.transparent,
                              child: new Stack(
                                children: <Widget>[
                                  PaddingWrap.paddingfromLTRB(
                                      13.0,
                                      20.0,
                                      13.0,
                                      0.0,
                                      ListView(children: <Widget>[
                                        new Container(
                                          height: 145.0,
                                          padding: new EdgeInsets.all(10.0),
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: new Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Text(
                                                  "Do you really want to switch?",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 5,
                                                  style: new TextStyle(
                                                      color: new Color(
                                                          ColorValues
                                                              .HEADING_COLOR_EDUCATION),
                                                      height: 1.2,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                      "customRegular"),
                                                ),
                                              ]),
                                        )
                                      ])),
                                ],
                              ))),
                      new Positioned(
                        right: 0.0,
                        left: 0.0,
                        bottom: 10.0,
                        child: new Align(
                          alignment: Alignment.bottomCenter,
                          child: PaddingWrap.paddingfromLTRB(
                              13.0,
                              0.0,
                              13.0,
                              0.0,
                              new Container(
                                  color: Colors.white,
                                  padding: new EdgeInsets.all(10.0),
                                  height: 51.0,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "No",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .GREY_TEXT_COLOR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.of(context,
                                                rootNavigator: true)
                                                .pop('dialog');
                                          },
                                        ),
                                        flex: 1,
                                      ),
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "Yes",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .BLUE_COLOR_BOTTOMBAR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.pop(context);
                                            SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.portraitDown,
                                            ]);
                                            Navigator.of(context)
                                                .pushReplacement(
                                                new MaterialPageRoute(
                                                    builder: (BuildContext
                                                    context) =>
                                                    new ShareUserProfileView(
                                                        widget.profileInfoModal,
                                                        widget
                                                            .userEducationList,
                                                        widget.narrativeList,
                                                        widget
                                                            .mainNarrativeList,
                                                        widget
                                                            .recommendationtList,
                                                        widget
                                                            .addedRecommendationtList,
                                                        widget.achievmentCount,
                                                        widget.strAccCount,
                                                        widget.strRecCount,
                                                        widget.spiderChartList,
                                                        widget.spiderChartName,
                                                        widget
                                                            .spiderChartListCopy,
                                                        widget
                                                            .spiderChartNameCopy,
                                                        widget
                                                            .mainSpiderChartList,
                                                        widget
                                                            .mainSpiderChartName)));
                                          },
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  ))),
                        ),
                      ),
                    ],
                  ))));
    }

    exitConfirmationDialog() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) =>
          new WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
              },
              child: new Scaffold(
                  backgroundColor: Colors.black38,
                  body: new Stack(
                    children: <Widget>[
                      new Positioned(
                          right: 0.0,
                          left: 0.0,
                          bottom: 40.0,
                          child: new Container(
                              height: 193.0,
                              color: Colors.transparent,
                              child: new Stack(
                                children: <Widget>[
                                  PaddingWrap.paddingfromLTRB(
                                      13.0,
                                      20.0,
                                      13.0,
                                      0.0,
                                      ListView(children: <Widget>[
                                        new Container(
                                          height: 145.0,
                                          padding: new EdgeInsets.all(10.0),
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: new Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Text(
                                                  "Are you sure you want to exit from Presentation view?",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 5,
                                                  style: new TextStyle(
                                                      color: new Color(
                                                          ColorValues
                                                              .HEADING_COLOR_EDUCATION),
                                                      height: 1.2,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                      "customRegular"),
                                                ),
                                              ]),
                                        )
                                      ])),
                                ],
                              ))),
                      new Positioned(
                        right: 0.0,
                        left: 0.0,
                        bottom: 10.0,
                        child: new Align(
                          alignment: Alignment.bottomCenter,
                          child: PaddingWrap.paddingfromLTRB(
                              13.0,
                              0.0,
                              13.0,
                              0.0,
                              new Container(
                                  color: Colors.white,
                                  padding: new EdgeInsets.all(10.0),
                                  height: 51.0,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "No",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .GREY_TEXT_COLOR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.of(context,
                                                rootNavigator: true)
                                                .pop('dialog');
                                          },
                                        ),
                                        flex: 1,
                                      ),
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Container(
                                              child: new Text(
                                                "Yes",
                                                textAlign: TextAlign.center,
                                                style: new TextStyle(
                                                    color: new Color(ColorValues
                                                        .BLUE_COLOR_BOTTOMBAR),
                                                    fontSize: 16.0,
                                                    fontFamily: 'customRegular'),
                                              )),
                                          onTap: () {
                                            Navigator.pop(context);
                                            AutoOrientation.portraitAutoMode();
                                            refresh();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  ))),
                        ),
                      ),
                    ],
                  ))));
    }

    void finish() {
      exitConfirmationDialog();
    }

    Widget getNavigationBottomView(isFirstChild) {
      if (isFirstChild) {
        return new Positioned(
            top: 20.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: SlideTransition(
              position: bottomNavOffset,
              child: new Container(
                //color: Colors.black45.withOpacity(0.4),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/newDesignIcon/aerialView/pressoview_controller_filterbg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    // Fake ICon for manage sapce
                                  },
                                  child: Image.asset(
                                    '',
                                    width: 35.0,
                                    height: 35.0,
                                  ))),
                          new Expanded(
                            child: new Text(""),
                            flex: 1,
                          ),
                          new InkWell(
                            child: new Padding(
                                padding:
                                EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                child: new Column(
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Image.asset(
                                          'assets/newDesignIcon/aerialView/linearview.png',
                                          width: 18.0,
                                          height: 18.0),
                                    ),
                                    new Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: new Text(
                                          "Linear View",
                                          style: TextStyle(
                                              fontFamily:
                                              Constant.customRegular,
                                              fontSize: 14,
                                              color: Colors.white),
                                        ))
                                  ],
                                )),
                            onTap: () {
                              showConformationDialog();
                            },
                          ),
                          new Padding(
                              padding:
                              EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
                              child: new InkWell(
                                child: new Column(
                                  children: <Widget>[
                                    new Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Image.asset(
                                            'assets/newDesignIcon/aerialView/av_filter.png',
                                            width: 18.0,
                                            height: 18.0)),
                                    new Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: new Text(
                                          "Filter",
                                          style: TextStyle(
                                              fontFamily:
                                              Constant.customRegular,
                                              fontSize: 14,
                                              color: Colors.white),
                                        ))
                                  ],
                                ),
                                onTap: () {
                                  _settingModalBottomSheet(context);
                                  educationRemoveConfromationDialog();
                                },
                              )),
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                              child: new InkWell(
                                child: new Column(
                                  children: <Widget>[
                                    new Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Image.asset(
                                            'assets/newDesignIcon/aerialView/share.png',
                                            width: 21.0,
                                            height: 21.0)),
                                    new Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: new Text(
                                          "Share",
                                          style: TextStyle(
                                              fontFamily:
                                              Constant.customRegular,
                                              fontSize: 14,
                                              color: Colors.white),
                                        ))
                                  ],
                                ),
                                onTap: () {
                                  _settingModalBottomSheet(context);

                                  shareSelectionDialog();
                                },
                              )),
                          new Expanded(
                            child: new Text(""),
                            flex: 1,
                          ),
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    finish();
                                  },
                                  child: Image.asset(
                                    'assets/newDesignIcon/aerialView/av_cross.png',
                                    width: 30.0,
                                    height: 30.0,
                                  ))),
                        ],
                      ),
                      new Expanded(
                        child: new Text(""),
                        flex: 1,
                      ),
                      new Row(
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    if (frameNo != 0) {
                                      _backNavigationBtnClick();
                                    } else {
                                      finish();
                                    }
                                  },
                                  child: Image.asset(
                                    /* frameNo > 0
                                          ?*/
                                      'assets/newDesignIcon/aerialView/av_previous.png'
                                      /*  : ""*/,
                                      width: 35.0,
                                      height: 35.0))),
                          new Expanded(
                            child: new Text(
                              "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontFamily: Constant.customRegular),
                            ),
                            flex: 1,
                          ),

//                          new Padding(
//                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//                              child: FlatButton(
//                                  onPressed: () {
//                                    setState(() {
//                                      isPaused = isPaused ? false : true;
//                                    });
//                                  },
//                                  child: Image.asset(
//                                      isPaused
//                                          ? 'assets/newDesignIcon/aerialView/playagain.png'
//                                          : 'assets/newDesignIcon/aerialView/av_pause.png',
//                                      width: 35.0,
//                                      height: 35.0))),
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    if (frameNo != 7) _navigationBtnClick(true);
                                  },
                                  child: Image.asset(
                                    frameNo != 7
                                        ? 'assets/newDesignIcon/aerialView/av_next.png'
                                        : "",
                                    width: 35.0,
                                    height: 35.0,
                                  ))),
                        ],
                      ),
                    ],
                  )),
            ));
      } else {
        return new Positioned(
            top: 20.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: SlideTransition(
              position: bottomNavOffset,
              child: new Container(
//                  color: frameNo == 2 || frameNo == 4 || frameNo==7
//                      ? Colors.white.withOpacity(0.2)
//                      : Colors.black.withOpacity(0.4),

                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/newDesignIcon/aerialView/pressoview_controller_filterbg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    // Fake ICon for manage sapce
                                  },
                                  child: Image.asset(
                                    '',
                                    width: 35.0,
                                    height: 35.0,
                                  ))),
                          new Expanded(
                            child: new Text(""),
                            flex: 1,
                          ),
                          new InkWell(
                            child: new Padding(
                                padding:
                                EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                child: new Column(
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Image.asset(
                                          'assets/newDesignIcon/aerialView/linearview.png',
                                          width: 18.0,
                                          height: 18.0),
                                    ),
                                    new Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: new Text(
                                          "Linear View",
                                          style: TextStyle(
                                              fontFamily:
                                              Constant.customRegular,
                                              fontSize: 14,
                                              color: Colors.white),
                                        ))
                                  ],
                                )),
                            onTap: () {
                              showConformationDialog();
                            },
                          ),
                          new Padding(
                            padding: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
                            child: new InkWell(
                              child: new Column(
                                children: <Widget>[
                                  new Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Image.asset(
                                          'assets/newDesignIcon/aerialView/av_filter.png',
                                          width: 18.0,
                                          height: 18.0)),
                                  new Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: new Text(
                                        "Filter",
                                        style: TextStyle(
                                            fontFamily: Constant.customRegular,
                                            fontSize: 14,
                                            color: Colors.white),
                                      ))
                                ],
                              ),
                              onTap: () {
                                _settingModalBottomSheet(context);
                                educationRemoveConfromationDialog();
                              },
                            ),
                          ),
                          new Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                            child: new InkWell(
                              child: new Column(
                                children: <Widget>[
                                  new Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Image.asset(
                                          'assets/newDesignIcon/aerialView/share.png',
                                          width: 21.0,
                                          height: 21.0)),
                                  new Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: new Text(
                                        "Share",
                                        style: TextStyle(
                                            fontFamily: Constant.customRegular,
                                            fontSize: 14,
                                            color: Colors.white),
                                      ))
                                ],
                              ),
                              onTap: () {
                                _settingModalBottomSheet(context);
                                shareSelectionDialog();
                              },
                            ),
                          ),
                          new Expanded(
                            child: new Text(""),
                            flex: 1,
                          ),
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    finish();
                                  },
                                  child: Image.asset(
                                    'assets/newDesignIcon/aerialView/av_cross.png',
                                    width: 30.0,
                                    height: 30.0,
                                  ))),
                        ],
                      ),
                      new Expanded(
                        child: new Text(""),
                        flex: 1,
                      ),
                      new Row(
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    if (frameNo != 0) {
                                      _backNavigationBtnClick();
                                    } else {
                                      finish();
                                    }
                                  },
                                  child: Image.asset(
                                    /* frameNo > 0
                                          ? */
                                      'assets/newDesignIcon/aerialView/av_previous.png'
                                      /*  : ""*/,
                                      width: 35.0,
                                      height: 35.0))),
                          new Expanded(
                            child: new Text(
                              "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontFamily: Constant.customRegular),
                            ),
                            flex: 1,
                          ),

//                          new Padding(
//                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//                              child: FlatButton(
//                                  onPressed: () {
//                                    setState(() {
//                                      isPaused = isPaused ? false : true;
//                                    });
//                                  },
//                                  child: Image.asset(
//                                      isPaused
//                                          ? 'assets/newDesignIcon/aerialView/playagain.png'
//                                          : 'assets/newDesignIcon/aerialView/av_pause.png',
//                                      width: 35.0,
//                                      height: 35.0))),
                          new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: FlatButton(
                                  onPressed: () {
                                    if (frameNo != 7) _navigationBtnClick(true);
                                  },
                                  child: Image.asset(
                                    frameNo != 7
                                        ? 'assets/newDesignIcon/aerialView/av_next.png'
                                        : "",
                                    width: 35.0,
                                    height: 35.0,
                                  ))),
                        ],
                      ),
                    ],
                  )),
            ));
      }
    }

    return new WillPopScope(
        onWillPop: () {
          finish();
        },
        child: new Material(
          child: new InkWell(
            child: frameNo == 5 || frameNo == 3
                ? Container(
              child: new Stack(
                children: <Widget>[
                  new Positioned(
                    left: 0.0,
                    bottom: 0.0,
                    top: 0.0,
                    right: 0.0,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: "",
                      image: widget.profileInfoModal != null
                          ? Constant.IMAGE_PATH_SMALL +
                          ParseJson.getMediumImage(
                              widget.profileInfoModal.coverImage)
                          : "",
                    ),
                  ),

                  new Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      top: 0.0,
                      right: 0.0,
                      child: new Image.asset(
                        "assets/newDesignIcon/aerialView/bg_white.png",
                        fit: BoxFit.fill,
                      )),
                  getCircleViewForBackGround(
                      Color(0xffC3DBED).withOpacity(0.3)),
                  //  getShareTopView(),
                  new Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      top: 0.0,
                      right: 0.0,
                      child: getViewBasedOnTheIndex("")),
                  getNavigationBottomView(true)
                ],
              ),
            )
                : frameNo == 3
                ? Container(
              child: new Stack(
                children: <Widget>[
                  new Positioned(
                    left: 0.0,
                    bottom: 0.0,
                    top: 0.0,
                    right: 0.0,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: "",
                      image: widget.profileInfoModal != null
                          ? Constant.IMAGE_PATH_SMALL +
                          ParseJson.getMediumImage(
                              widget.profileInfoModal.coverImage)
                          : "",
                    ),
                  ),

                  new Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      top: 0.0,
                      right: 0.0,
                      child: new Image.asset(
                        "assets/newDesignIcon/aerialView/bg_white.png",
                        fit: BoxFit.fill,
                      )),

                  getCircleViewForBackGround(
                      Color(0xffC3DBED).withOpacity(0.3)),
                  //  getShareTopView(),
                  new Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      top: 0.0,
                      right: 0.0,
                      child: getViewBasedOnTheIndex("")),
                  getNavigationBottomView(true)
                ],
              ),
            )
                : AnimatedCrossFade(
                duration: Duration(milliseconds: 3000),
                firstChild: Container(
                  child: new Stack(
                    children: <Widget>[
                      new Positioned(
                        left: 0.0,
                        bottom: 0.0,
                        top: 0.0,
                        right: 0.0,
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: "",
                          image: widget.profileInfoModal != null
                              ? Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(widget
                                  .profileInfoModal.coverImage)
                              : "",
                        ),
                      ),

                      new Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          top: 0.0,
                          right: 0.0,
                          child: new Image.asset(
                            frameNo == 2
                                ? "assets/newDesignIcon/aerialView/bg_black.png"
                                : "assets/newDesignIcon/aerialView/bg_white.png",
                            fit: BoxFit.fill,
                          )),

                      frameNo == 7 || frameNo == 2
                          ? getCircleViewForBackGround(
                          Color(0xffbdc7ce).withOpacity(0.3))
                          : getCircleViewForBackGround(
                          Color(0xffC3DBED).withOpacity(0.3)),
                      //  getShareTopView(),
                      new Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          top: 0.0,
                          right: 0.0,
                          child: Rendering(
                            builder: (context, time) {
                              //_simulateParticles(time);
                              return CustomPaint(
                                //painter: ParticlePainter(particles, time, false),
                                  child:
                                  getViewBasedOnTheIndex("First"));
                            },
                          )),
                      getNavigationBottomView(true)
                    ],
                  ),
                ),
                secondChild: Container(
                  child: new Stack(
                    children: <Widget>[
                      new Positioned(
                        left: 0.0,
                        bottom: 0.0,
                        top: 0.0,
                        right: 0.0,
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: "",
                          image: widget.profileInfoModal != null
                              ? Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(widget
                                  .profileInfoModal.coverImage)
                              : "",
                        ),
                      ),
                      new Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          top: 0.0,
                          right: 0.0,
                          child: new Image.asset(
                            frameNo == 7 || frameNo == 2
                                ? "assets/newDesignIcon/aerialView/bg_black.png"
                                : "assets/newDesignIcon/aerialView/bg_white.png",
                            fit: BoxFit.fill,
                          )),
                      frameNo == 7 || frameNo == 2
                          ? getCircleViewForBackGround(
                          Color(0xffbdc7ce).withOpacity(0.3))
                          : getCircleViewForBackGround(
                          Color(0xffC3DBED).withOpacity(0.3)),
                      new Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          top: 0.0,
                          right: 0.0,
                          child: Rendering(
                            builder: (context, time) {
                              // _simulateParticles(time);
                              return CustomPaint(
                                //  painter:ParticlePainter(particles, time, true),
                                  child:
                                  getViewBasedOnTheIndex("Second"));
                            },
                          )),
                      getNavigationBottomView(false)
                    ],
                  ),
                ),
                crossFadeState:
                frameNo == 4 || frameNo == 7 || frameNo == 2
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst),
            onTap: () {
              _settingModalBottomSheet(context);
              _settingModalTopSheet(context);
            },
          ),
        ));
  }

  void _settingModalBottomSheet(context) {
    print("control chnages " + isActionButtonShowing.toString());

    //  if (frameNo != 7) {
    if (isActionButtonShowing) {
      isPaused = false;
      isActionButtonShowing = false;
      /*   if (frameNo == 5) {
        if (isShowAll) {
          _navigationBtnClick(true);
        }
      }*/
    } else {
      isActionButtonShowing = true;
      isPaused = true;
      if (actionControllerHandlerTimer != null)
        actionControllerHandlerTimer.cancel();
    }
    print("control chnages after " + isActionButtonShowing.toString());


    if (frameNo != 7) {
      setState(() {
        isPaused;
      });
    }
    switch (_bottomNavController.status) {
      case AnimationStatus.completed:
        _bottomNavController.reverse();

        break;
      case AnimationStatus.dismissed:
        _bottomNavController.forward();

        break;
      default:
    }
  }

  void _settingModalTopSheet(context) {
    print(_topNavController.status);
    switch (_topNavController.status) {
      case AnimationStatus.completed:
        _topNavController.reverse();
        break;
      case AnimationStatus.dismissed:
        _topNavController.forward();
        break;
      default:
    }
  }

  void showFrame2BodyText() {
    switch (_frame2BodyController.status) {
      case AnimationStatus.completed:
        _frame2BodyController.reverse();
        break;
      case AnimationStatus.dismissed:
        _frame2BodyController.forward();
        break;
      default:
    }
  }

  void showSpiderChartTextBodyText() {
    switch (_spiderChartTextBodyController.status) {
      case AnimationStatus.completed:
        _spiderChartTextBodyController.reverse();
        break;
      case AnimationStatus.dismissed:
        _spiderChartTextBodyController.forward();
        break;
      default:
    }
  }

  _navigationBtnClick(bool isNext) {
    if (frameNo == 5 && isNext) {
      // here we have to maintain the Acheivement list and data

      if (narrativeListLocal.length > 0 &&
          narrativeCount < narrativeListLocal.length - 1) {
        if (acheivementListCount <
            narrativeListLocal[narrativeCount].achivmentList.length - 1) {
          acheivementListCount = acheivementListCount + 1;
        } else {
          narrativeCount = narrativeCount + 1;
          acheivementListCount = 0;
        }
      } else {
        // All Achievements Visited  then navigate to the recommendation
        if (widget.addedRecommendationtList.length > 0) {
          frameNo = frameNo + 1;
          timerScheduleForNavigation(timeFrame_6);
        } else {
          frameNo = frameNo + 2;
        }

        narrativeCount = 0;
        print("Start Recommendation " + frameNo.toString());
        print("SIze of Recommendation " +
            widget.addedRecommendationtList.length.toString());
      }
    } else {
      if (frameNo == 6 && isNext) {
        // For Recommendation
        timerScheduleForNavigation(timeFrame_6);
        if (widget.addedRecommendationtList.length > 0 &&
            reccomendationListCount <
                widget.addedRecommendationtList.length - 1) {
          if (reccomendationListCount <
              widget.addedRecommendationtList.length - 1) {
            reccomendationListCount = reccomendationListCount + 1;
          } else {
            reccomendationListCount = 0;
          }
        } else {
          //All Recommendation's visited then Navigate to the Thank you page
          frameNo = frameNo + 1;
          // Start Frame No 7
          print("Start Thank you page  " + frameNo.toString());
        }
      } else {
        if (isNext) {
          frameNo = frameNo + 1;
          print("frame no sk" + frameNo.toString());
          if (frameNo == 3 && widget.userEducationList.length == 0) {
            print("no data education");
            frameNo = frameNo + 1;
          }
          if (frameNo == 4 && narrativeListLocal.length == 0) {
            print("no data achivment");
            if (widget.addedRecommendationtList.length > 0) {
              frameNo = frameNo + 2;
            } else {
              frameNo = frameNo + 3;
            }
          }
          isBackPressed = false;
        } else {
          frameNo = frameNo - 1;
          // timer.cancel();
          //timerScheduleForNavigation();
          isBackPressed = true;
        }
      }
    }
    switch (frameNo) {
      case 0:
      // First Frame Left to right
        previousPage = 0;
        _animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
          parent: _profilePictureController,
          curve: Curves.fastOutSlowIn,
        ));

        break;
      case 1:
      // About Me
        previousPage = 1;
        visible = false;

        _animation = Tween(begin: 0.0, end: 0.3).animate(CurvedAnimation(
          parent: _frame2ProfilePictureController,
          curve: Curves.fastOutSlowIn,
        ));

        _frame2ProfilePictureController.forward();
        timerScheduleForNavigation(timeFrame_1);
        break;
      case 2:
      // For Frame 3 change background first
        previousPage = 2;
        animationControllerMyStory = AnimationController(
          vsync: this,
          duration: Duration(seconds: 5),
        )
          ..addListener(() => setState(() {}));
        animationMyStory = CurvedAnimation(
          parent: animationControllerMyStory,
          curve: Curves.easeInOut,
        );

        animationControllerMyStory.forward();

        _animation = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(
          parent: _profilePictureControllerGone,
          curve: Curves.fastOutSlowIn,
        ));
        _profilePictureControllerGone.forward();

        // Spider Chart Animation Initilization

        spiderChartAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: spideChartAnimationController,
            curve: Interval(
              0,
              0.5,
              curve: Curves.decelerate,
            ),
          ),
        );

        showSpiderChartTextBodyText();
        timerScheduleForNavigation(timeFrame_2);
        break;
      case 3:
        previousPage = 4;
        //.Education Page view

//            Navigator.of(context).push(new MaterialPageRoute(
//                builder: (BuildContext context) => new ItCrowdPage(
//                )));
        timerScheduleForNavigation(timeFrame_3);
        break;
      case 4:
        previousPage = 5;
        // For Frame4 My Sotry
//            animationControllerMyStory = AnimationController(
//              vsync: this,
//              duration: Duration(seconds: 5),
//            )..addListener(() => setState(() {}));
//            animationMyStory = CurvedAnimation(
//              parent: animationControllerMyStory,
//              curve: Curves.easeInOut,
//            );
//
//            animationControllerMyStory.forward();

        // For V 2.0
        frameNo = frameNo + 1;
        break;
      case 7:
      // Thank You Screen

        thankYouAnimationStatusListener();
        break;
    }
    setState(() {
      showFrame2BodyText();
    });
  }

  _backNavigationBtnClick() {
    timerScheduleForNavigation(10);

    if (frameNo == 5) {
      setState(() {
        narrativeCount = 0;
        acheivementListCount = 0;
      });
      frameNo = frameNo - 2;
    } else {
      frameNo = frameNo - 1;
    }
    print("frame number add " + frameNo.toString());
    if (frameNo == 6 && widget.addedRecommendationtList.length == 0) {
      frameNo = 5;
      acheivementListCount = 0;
      narrativeCount = 0;
      print("frame number addedRecommendationtList " + frameNo.toString());
    }
    if (frameNo == 5 && narrativeListLocal.length == 0) {
      frameNo = frameNo - 2;
    }
    if (frameNo == 3 && widget.userEducationList.length == 0) {
      print("no data education");
      frameNo = frameNo - 1;
    }
    // timer.cancel();
    //timerScheduleForNavigation();
    isBackPressed = true;

    switch (frameNo) {
      case 0:
      // First Frame Left to right

        _profilePictureController.stop(canceled: true);
        _profilePictureControllerGone.stop(canceled: true);

        _frame2ProfilePictureController.stop(canceled: true);
        _frame2BodyController.stop(canceled: true);

        spideChartAnimationController.stop(canceled: true);
        _spiderChartTextBodyController.stop(canceled: true);

        spideChartAnimationController.stop(canceled: true);
        _thankYouTextBodyController.stop(canceled: true);
        visible = true;

        //  animationControllerMyStory.dispose();

        break;
      case 1:
      // About Me
        visible = false;

        _profilePictureControllerGone.reverse();

        _spiderChartTextBodyController.stop();
        _spiderChartTextBodyController.value = 1.0;

        _frame2BodyController.value = 1.0;

        break;
      case 2:
      // For Frame 3 change background first
        print("Canceld Spider chart");
//             spideChartAnimationController.stop(canceled: true);
//            _spiderChartTextBodyController.stop(canceled: true);
//
//             spideChartAnimationController.stop(canceled: true);
//             _thankYouTextBodyController.stop(canceled: true);

        _frame2BodyController.stop();
        _spiderChartTextBodyController.stop(canceled: true);

        break;
      case 3:
      //.Education Page view

        setState(() {
          narrativeCount = 0;
          acheivementListCount = 0;
        });
        break;
      case 4:
      // For Frame4 My Sotry
        frameNo = frameNo - 1; // V2.0
        setState(() {
          narrativeCount = 0;
          acheivementListCount = 0;
        });
        break;

      case 5:
        narrativeCount = 0;
        reccomendationListCount = 0;
        acheivementListCount = 0;
        break;
      case 6:
        narrativeCount = 0;
        acheivementListCount = 0;
        reccomendationListCount = 0;
        break;
      case 7:
      // Thank You Screen
        narrativeCount = 0;
        acheivementListCount = 0;
        reccomendationListCount = 0;
        spideChartAnimationController.stop(canceled: true);
        _thankYouTextBodyController.stop(canceled: true);
        break;
    }

    setState(() {
      showFrame2BodyText();
    });
  }

  // SHare ICon
  String shareName = "",
      shareEmail = "",
      shareLastName = "";

  onTapEmailShare() async {
    AutoOrientation.portraitAutoMode();

    List<String> dataList = await Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (BuildContext context) =>
            new EmailShareWidgetPreso(
                "SHARE WITH",
                userIdPref,
                widget.profileInfoModal,
                widget.narrativeList)));
    if (dataList != null && dataList.length > 0) {
      AutoOrientation.portraitAutoMode();
      refresh();
      Navigator.pop(context);
      //shareName = dataList[0];
      //shareLastName = dataList[1];
      // shareEmail = dataList[2];
      // apiCallForShare("Email");

    } else {
      AutoOrientation.landscapeAutoMode();
    }
  }

  void shareSelectionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) =>
        new WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
            },
            child: new Scaffold(
                backgroundColor: Colors.black38,
                body: new Stack(
                  children: <Widget>[
                    new Positioned(
                        right: 0.0,
                        left: 0.0,
                        bottom: 50.0,
                        child: new Container(
                            height: 185.0,
                            color: Colors.transparent,
                            child: new Stack(
                              children: <Widget>[
                                PaddingWrap.paddingfromLTRB(
                                    13.0,
                                    20.0,
                                    13.0,
                                    0.0,
                                    ListView(children: <Widget>[
                                      new Container(
                                        height: 130.0,
                                        width: double.infinity,
                                        color: Colors.white,
                                        child: new Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              new InkWell(
                                                child: new Container(
                                                    height: 40.0,
                                                    child: new Text(
                                                      "Share by Email",
                                                      textAlign:
                                                      TextAlign.center,
                                                      maxLines: 5,
                                                      style: new TextStyle(
                                                          color: new Color(
                                                              ColorValues
                                                                  .BLUE_COLOR_BOTTOMBAR),
                                                          height: 1.2,
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                          "customRegular"),
                                                    )),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  onTapEmailShare();
                                                },
                                              ),
                                              new Divider(
                                                color: new Color(
                                                  ColorValues.GREY_TEXT_COLOR,
                                                ),
                                              ),
                                              new InkWell(
                                                child: new Container(
                                                    padding:
                                                    new EdgeInsets.fromLTRB(
                                                        0.0,
                                                        10.0,
                                                        0.0,
                                                        0.0),
                                                    height: 40.0,
                                                    child: new Text(
                                                      "Share by Message",
                                                      textAlign:
                                                      TextAlign.center,
                                                      maxLines: 5,
                                                      style: new TextStyle(
                                                          color: new Color(
                                                              ColorValues
                                                                  .BLUE_COLOR_BOTTOMBAR),
                                                          height: 1.2,
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                          "customRegular"),
                                                    )),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  apiCallForShare("Message");
                                                },
                                              )
                                            ]),
                                      )
                                    ])),
                              ],
                            ))),
                    new Positioned(
                      right: 0.0,
                      left: 0.0,
                      bottom: 10.0,
                      child: new Align(
                        alignment: Alignment.bottomCenter,
                        child: PaddingWrap.paddingfromLTRB(
                            13.0,
                            0.0,
                            13.0,
                            0.0,
                            new Container(
                                color: Colors.white,
                                padding: new EdgeInsets.all(10.0),
                                height: 66.0,
                                child: new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: new InkWell(
                                        child: new Container(
                                            child: new Text(
                                              "Cancel",
                                              textAlign: TextAlign.center,
                                              style: new TextStyle(
                                                  color: new Color(
                                                      ColorValues
                                                          .GREY_TEXT_COLOR),
                                                  fontSize: 16.0,
                                                  fontFamily: 'customRegular'),
                                            )),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      flex: 1,
                                    ),
                                  ],
                                ))),
                      ),
                    ),
                  ],
                ))));
  }

  showSucessMsgLong(msg, context) {
    Timer _timer;

    print("timer on");
    _timer = new Timer(const Duration(milliseconds: 5000), () async {
      print("timer off");
      AutoOrientation.portraitAutoMode();
      Navigator.pop(context);
      Navigator.pop(context);
    });

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) =>
        new WillPopScope(
            onWillPop: () {},
            child: new GestureDetector(
              child: new Scaffold(
                backgroundColor: Colors.transparent,
                body: new Stack(
                  children: <Widget>[
                    new Positioned(
                        right: 0.0,
                        top: 55.0,
                        left: 0.0,
                        child: new Container(
                          height: 65.0,
                          padding: new EdgeInsets.fromLTRB(12.0, 10.0, 0, 10.0),
                          color: new Color(0xffF1EDC3),
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    text: msg,
                                    style: new TextStyle(
                                        color: new Color(0xff408738),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: Constant.customRegular),
                                  ),
                                )
                              ]),
                        )),
                  ],
                ),
              ),
              onTap: () {},
            )));
  }

  onChatWithHeader(link, sharedId) async {
    print("chatList");
//    if (isParent) {
//      print("chatList called");
//      prefs.setString(
//          UserPreference.USER_ID, prefs.getString(UserPreference.PARENT_ID));
//      await Navigator.of(context).push(new MaterialPageRoute(
//          builder: (BuildContext context) =>
//          new ChatListWithHeader(link, sharedId, userIdPref)));
//      refresh();
//      Navigator.pop(context);
//      // prefs.setString(UserPreference.USER_ID, userIdPref);
//    } else {
    print("chatList call");

    AutoOrientation.portraitAutoMode();
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
        new ChatListWithHeader(link, sharedId, userIdPref)));
    refresh();
    Navigator.pop(context);
    //}
  }

  // Chat share
  //--------------------------  api ------------------

  //--------------------------  api ------------------
  Future apiCallForShare(type) async {
    try {
      var isConnect = await ConectionDetecter.isConnected();
      if (isConnect) {
        Map map = {
          "sharedType": type,
          "profileOwner": int.parse(userIdPref),
          "firstName": shareName,
          "lastName": shareLastName,
          "email": shareEmail.toLowerCase(),
          "shareTime": new DateTime.now().millisecondsSinceEpoch,
          "shareConfiguration":
          widget.narrativeList.map((item) => item.toJson()).toList(),
          "sharedView": "aerial",
          "isActive": widget.profileInfoModal.isActive,
          "theme": ""
        };

        print(map.toString());
        Response response = await new ApiCalling().apiCallPostWithMapData(
            context, Constant.ENDPOINT_SHARE_PROFILE, map);

        print("response:-" + response.toString());
        if (response != null) {
          if (response.statusCode == 200) {
            String status = response.data[LoginResponseConstant.STATUS];
            String msg = response.data[LoginResponseConstant.MESSAGE];
            if (status == "Success") {
              String sharedId = response.data['result']['sharedId'].toString();
              String link = response.data['result']['link'].toString();
              print(link);

              if (type == "Email") {
                // ToastWrap.showToast(msg);
                refresh();
                showSucessMsgLong(msg, context);
              } else {
                // refresh();
                //chatlistRemove
                onChatWithHeader(link, sharedId);
              }
            }
          }
        }
      } else {
        ToastWrap.showToast("Please check your internet connection.", context);
      }
    } catch (e) {
      e.toString();
    }
  }

  // V 2.0

  void setDataForWorldCloud() {
    widgets = <Widget>[];
    for (var i = 0; i < narrativeListLocal.length; i++) {
      double textFont = 0.0;
      textFont =
          20.0 + (3 * narrativeListLocal[i].achivmentList.length.toDouble());
      if (textFont > 38.0) {
        textFont = 38.0;
      }

      widgets.add(ScatterItem(narrativeListLocal[i], textFont));
    }
  }
}

class ScatterItem extends StatelessWidget {
  ScatterItem(this.narrativeListLocal, this.textFont);

  NarrativeModel narrativeListLocal;

//  final int index;
  double heightDefault = 30.0;
  double widthDefault = 30.0;
  double textFont;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .body1
        .copyWith(
        fontSize: textFont,
        color: Colors.white,
        fontFamily: Constant.customRegular);

    final TextStyle Circlestyle = Theme
        .of(context)
        .textTheme
        .body1
        .copyWith(
        fontSize:
        15.0 + (3 * narrativeListLocal.achivmentList.length.toDouble()),
        color: Color(ColorValues.BOTTOAMBAR_ADD_BG_COLOUR),
        fontFamily: Constant.customBold);

    return RotatedBox(
      //quarterTurns: hashtag.rotated ? 1 : 0,
      quarterTurns: 0,
      child: new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              new Container(
                alignment: Alignment.center,
                height: heightDefault +
                    5 * (narrativeListLocal.achivmentList.length.toDouble()),
                width: widthDefault +
                    5 * (narrativeListLocal.achivmentList.length.toDouble()),
                decoration: new BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: new Align(
                  child: new Text(
                    narrativeListLocal.achivmentList.length > 9
                        ? narrativeListLocal.achivmentList.length.toString()
                        : "0" +
                        narrativeListLocal.achivmentList.length.toString(),
                    style: Circlestyle,
                  ),
                  alignment: Alignment.center,
                ),
              ),
              new SizedBox(
                width: 10.0,
              ),
              Text(
                narrativeListLocal.name,
                style: textStyle,
              )
            ],
          )),
    );
  }
}
