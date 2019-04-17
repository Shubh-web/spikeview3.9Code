import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/drawer/SearchFriend.dart';
import 'package:spike_view_project/modal/ConnectionNotificationModel.dart';
import 'package:spike_view_project/parentProfile/EditParentProfile.dart';
import 'package:spike_view_project/parentProfile/ParentProfile.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/AddAchievment.dart';
import 'package:spike_view_project/gateway/ChangePassword.dart';
import 'package:spike_view_project/activity/Connections.dart';
import 'package:spike_view_project/gateway/Login_Widget.dart';
import 'package:spike_view_project/chat/Message.dart';
import 'package:spike_view_project/profile/ProfileSharingLog.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/home/home.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class DashBoardWidgetParent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new DashBoardStateParent();
  }
}

class DashBoardStateParent extends State<DashBoardWidgetParent> {
  bool isHome = true;
  bool isConnection = false;
  bool isMessage = false;
  bool isMore = false;
  static StreamController syncDoneController = StreamController.broadcast();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  bool changes = false;
  String profilePath = "",userIdPref;
  ConnectionNotificationModel connectionNotificationModel;

  ontapBottomNavigationBar(value) {
    switch (value) {
      case 1:
        {
          setState(() {
            isHome = true;
            isConnection = false;
            isMessage = false;
            isMore = false;
          });
          print("clicked 1");

          break;
        }
      case 2:
        {
          setState(() {
            isHome = false;
            isConnection = true;
            isMessage = false;
            isMore = false;
          });
          if (connectionNotificationModel != null &&
              connectionNotificationModel.connectionCount != "0" &&connectionNotificationModel.connectionCount != "" &&
              connectionNotificationModel.connectionCount != "null") {
            apiCallingForUpdateFeed(
                "0",connectionNotificationModel.messagingCount,connectionNotificationModel.notificationCount
            );
          }

          print("clicked 2");
          break;
        }
      case 3:
        {
          /*  Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => new AddAchievmentForm()));*/
          print("clicked 3");
          break;
        }
      case 4:
        {
          setState(() {
            isHome = false;
            isConnection = false;
            isMessage = true;
            isMore = false;
          });
          if (connectionNotificationModel != null &&
              connectionNotificationModel.messagingCount != "0" &&connectionNotificationModel.messagingCount != "" &&
              connectionNotificationModel.messagingCount != "null") {
            apiCallingForUpdateFeed(
                connectionNotificationModel.connectionCount,"0",connectionNotificationModel.notificationCount
            );
          }
          print("clicked 4");
          break;
        }
      case 5:
        {
          _scaffoldKey.currentState.openEndDrawer();

          print("clicked 5");
          break;
        }
    }
  }

  Future apiCallingForGetNotificationCount() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_NOTIFICATION_COUNT + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            connectionNotificationModel =
                ParseJson.parseConnectionNotification(response.data['result']);
            if (connectionNotificationModel != null) {
              setState(() {
                connectionNotificationModel;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUpdateFeed(
      connectionCount, messageCount, notificationCount) async {
    try {
      Map map = {
        "userId": int.parse(userIdPref),
        "connectionCount": connectionCount,
        "messagingCount": messageCount,
        "notificationCount": notificationCount
      };
      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_NOTIFICATION_UPDATE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            connectionNotificationModel = new ConnectionNotificationModel(
                connectionCount, messageCount, notificationCount);

            setState(() {
              connectionNotificationModel;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }
  getSharedPrefrence() async {
    prefs = await SharedPreferences.getInstance();
    profilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    userIdPref = prefs.getString(UserPreference.USER_ID);
    print("profilepath:-" + profilePath);
    apiCallingForGetNotificationCount();
  }

  @override
  void initState() {
    getSharedPrefrence();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final title = new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Image.asset(
          "assets/logo.png",
          width: 150.0,
          height: 50.0,
        )
      ],
    );

    final search = PaddingWrap.paddingAll(
        10.0,
        new InkWell(
          child: new Image.asset(
            "assets/navigation/search.png",
            width: 30.0,
            height: 30.0,
          ),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new SearchFriend()));
          },
        ));
    onTapChangePass() {
      prefs.setString(
          UserPreference.USER_ID, prefs.get(UserPreference.PARENT_ID));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new ChangePassword("", false)),
      );
    }

    onTapSignOut() async {
      prefs.setBool(UserPreference.LOGIN_STATUS, false);
      prefs.setBool(UserPreference.IS_PASSWORD_CHANGED, false);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => new LoginPage()),
      );
    }

    showSignoutDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        child: new Dialog(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              new Padding(
                  padding: new EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 30.0),
                  child: new Text("Are you sure You want to Signout..?")),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Expanded(
                    child: new Container(),
                    flex: 1,
                  ),
                  new Expanded(
                    child: new Row(
                      children: <Widget>[
                        new InkWell(
                          child: new Padding(
                              padding: new EdgeInsets.fromLTRB(
                                  10.0, 10.0, 20.0, 10.0),
                              child: new Text(
                                "Cancel",
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              )),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                        ),
                        new InkWell(
                          child: new Padding(
                              padding: new EdgeInsets.fromLTRB(
                                  10.0, 10.0, 20.0, 10.0),
                              child: new Text(
                                "Ok",
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              )),
                          onTap: () {
                            onTapSignOut();
                          },
                        ),
                      ],
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    onTapProfile() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new EditParentProfile()));
      if (result == "push") {
        syncDoneController.add("success");
      }
    }

    final drawer = new Container(
        width: 70.0,
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Drawer(
          child: new Container(
              color: new Color(ColorValues.NAVIGATION_DRAWER_BG_COLOUR),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  new InkWell(
                    child:  PaddingWrap.paddingfromLTRB(
                          20.0,
                          30.0,
                          20.0,
                          5.0,
                          /*  new Image.asset(
                          "assets/navigation/user.png",
                          height: 30.0,
                          width: 30.0,
                        )*/

                          new SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: new ClipOval(
                                  child: FadeInImage.assetNetwork(
                                fit: BoxFit.fill,
                                placeholder: 'assets/profile/user_on_user.png',
                                image: Constant.IMAGE_PATH_SMALL +
                                    ParseJson.getMediumImage(profilePath),
                                width: 40.0,
                                height: 40.0,
                              )))),


                    onTap: () {
                      Navigator.of(context).pop();
                      onTapProfile();
                    },
                  ),
                  new InkWell(
                    child: PaddingWrap.paddingfromLTRB(
                        5.0,
                        20.0,
                        0.0,
                        5.0,
                        new Image.asset(
                          "assets/navigation/change_password.png",
                          height: 30.0,
                          width: 30.0,
                        )),
                    onTap: () {
                      onTapChangePass();
                    },
                  ),
                  new InkWell(
                    child: PaddingWrap.paddingfromLTRB(
                        5.0,
                        20.0,
                        0.0,
                        5.0,
                        new Image.asset(
                          "assets/navigation/signout.png",
                          height: 30.0,
                          width: 30.0,
                        )),
                    onTap: () {
                      showSignoutDialog();
                    },
                  ),
                ],
              )),
        ));

    /*  final bottomBar = BottomAppBar(
      child: new Container(
        height: 50.0,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: new InkWell(
              child: new Image.asset(
                "assets/botombar/home.png",
                width: 25.0,
                height: 25.0,
              ),
              onTap: () {
                ontapBottomNavigationBar(1);
              },
            )),
            Expanded(
              child: new InkWell(
                child: new Image.asset(
                  "assets/botombar/connections.png",
                  width: 25.0,
                  height: 25.0,
                ),
                onTap: () {
                  ontapBottomNavigationBar(2);
                },
              ),
            ),
            Expanded(
              child: new InkWell(
                child: new Image.asset(
                  "assets/botombar/message.png",
                  width: 25.0,
                  height: 25.0,
                ),
                onTap: () {
                  ontapBottomNavigationBar(4);
                },
              ),
            ),
            Expanded(
              child: new InkWell(
                child: new Image.asset(
                  "assets/botombar/more.png",
                  width: 25.0,
                  height: 25.0,
                ),
                onTap: () {
                  ontapBottomNavigationBar(5);
                },
              ),
            ),
          ],
        ),
      ),
    );*/
    final bottomBar = BottomAppBar(
      child: new Container(
        height: 50.0,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new InkWell(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        "assets/botombar/home.png",
                        width: 25.0,
                        height: 25.0,
                      ),
                      isHome
                          ? PaddingWrap.paddingfromLTRB(
                              0.0,
                              5.0,
                              0.0,
                              0.0,
                              new Container(
                                height: 3.0,
                                width: 30.0,
                                color: new Color(ColorValues.BLUE_COLOR),
                              ))
                          : new Container(
                              height: 0.0,
                            )
                    ],
                  ),
                  onTap: () {
                    ontapBottomNavigationBar(1);
                  }),
            ),
            Expanded(
                child: new InkWell(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        connectionNotificationModel == null ||
                                connectionNotificationModel.connectionCount ==
                                    "null" ||
                                connectionNotificationModel.connectionCount ==
                                    "" ||
                                int.parse(connectionNotificationModel
                                        .connectionCount) ==
                                    0
                            ? new Image.asset(
                                "assets/botombar/connections.png",
                                width: 25.0,
                                height: 25.0,
                              )
                            : new Stack(
                                children: <Widget>[
                                  new Image.asset(
                                    "assets/botombar/connections.png",
                                    width: 25.0,
                                    height: 25.0,
                                  ),
                                  new Positioned(
                                    top: 1.0,
                                    right: 0.0,
                                    child: new Stack(
                                      children: <Widget>[
                                        new Icon(Icons.brightness_1,
                                            size: 18.0, color: Colors.red),
                                        new Positioned(
                                          top: 2.0,
                                          right: 5.0,
                                          child: new Text(
                                              connectionNotificationModel
                                                  .connectionCount,
                                              style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                        isConnection
                            ? PaddingWrap.paddingfromLTRB(
                                0.0,
                                5.0,
                                0.0,
                                0.0,
                                new Container(
                                  height: 3.0,
                                  width: 30.0,
                                  color: new Color(ColorValues.BLUE_COLOR),
                                ))
                            : new Container(
                                height: 0.0,
                              )
                      ],
                    ),
                    onTap: () {
                      ontapBottomNavigationBar(2);
                    })),
            Expanded(
                child: new InkWell(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        connectionNotificationModel == null ||
                                connectionNotificationModel.messagingCount ==
                                    "null" ||
                                connectionNotificationModel.messagingCount ==
                                    "" ||
                                int.parse(connectionNotificationModel
                                        .messagingCount) ==
                                    0
                            ? new Image.asset(
                                "assets/botombar/message.png",
                                width: 25.0,
                                height: 25.0,
                              )
                            : new Stack(
                                children: <Widget>[
                                  new Image.asset(
                                    "assets/botombar/message.png",
                                    width: 25.0,
                                    height: 25.0,
                                  ),
                                  new Positioned(
                                    top: 1.0,
                                    right: 0.0,
                                    child: new Stack(
                                      children: <Widget>[
                                        new Icon(Icons.brightness_1,
                                            size: 18.0, color: Colors.red),
                                        new Positioned(
                                          top: 2.0,
                                          right: 5.0,
                                          child: new Text(
                                              connectionNotificationModel
                                                  .messagingCount,
                                              style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                        isMessage
                            ? PaddingWrap.paddingfromLTRB(
                                0.0,
                                5.0,
                                0.0,
                                0.0,
                                new Container(
                                  height: 3.0,
                                  width: 30.0,
                                  color: new Color(ColorValues.BLUE_COLOR),
                                ))
                            : new Container(
                                height: 0.0,
                              )
                      ],
                    ),
                    onTap: () {
                      ontapBottomNavigationBar(4);
                    })),
            Expanded(
                child: new InkWell(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Image.asset(
                          "assets/botombar/more.png",
                          width: 25.0,
                          height: 25.0,
                        ),
                        isMore
                            ? PaddingWrap.paddingfromLTRB(
                                0.0,
                                5.0,
                                0.0,
                                0.0,
                                new Container(
                                  height: 3.0,
                                  width: 30.0,
                                  color: new Color(ColorValues.BLUE_COLOR),
                                ))
                            : new Container(
                                height: 0.0,
                              )
                      ],
                    ),
                    onTap: () {
                      ontapBottomNavigationBar(5);
                    })),
          ],
        ),
      ),
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          brightness: Brightness.light,
          automaticallyImplyLeading: false,  titleSpacing: 2.0,
          backgroundColor: new Color(ColorValues.NAVIGATION_DRAWER_BG_COLOUR),
          title: title,
          actions: <Widget>[search]),
      endDrawer: drawer,
      body: isHome
          ? new ParentProfilePage()
          : isConnection ? new ConnectionsWidget() : new MessageWidget(),
      bottomNavigationBar: bottomBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
