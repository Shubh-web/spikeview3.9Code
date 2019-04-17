import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/group/GroupDetailWidget.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/parentProfile/ParentProfileWithHeader.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/AddAchievment.dart';
import 'package:spike_view_project/gateway/ChangePassword.dart';
import 'package:spike_view_project/activity/Connections.dart';
import 'package:spike_view_project/gateway/Login_Widget.dart';
import 'package:spike_view_project/chat/Message.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/home/home.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class SearchFriend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SearchFriendState();
  }
}

class SearchFriendState extends State<SearchFriend> {
  bool isHome = true;
  bool isConnection = false;
  bool isMessage = false;
  bool isMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static StreamController syncDoneController = StreamController.broadcast();
  TextEditingController _searchQuery = new TextEditingController(text: "");
  bool _IsSearching;
  String _searchText = "", previousText = "";
  SharedPreferences prefs;
  String userIdPref, token;
  int previousLength = 0;
  List<ProfileInfoModal> friendList = new List();

  //--------------------------My Narratives Info api ------------------
  Future apiCallingForFrindList() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_FRIEND_LIST + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            friendList.clear();
            friendList = ParseJson.parseUserFriendList(response.data['result'],userIdPref);
            if (friendList.length > 0) {
              setState(() {
                friendList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------My Narratives Info api ------------------
  Future apiCallingForFrindList2(s) async {
    try {
      if(s.length>2) {
        previousText = _searchQuery.text;
        Response response = await new ApiCalling()
            .apiCall(
            context, Constant.ENDPOINT_SEARCH + s + "&like=true", "get");
        if (response != null) {
          if (response.statusCode == 200) {
            String status = response.data[LoginResponseConstant.STATUS];
            if (status == "Success") {
              friendList.clear();
              friendList =
                  ParseJson.parseUserFriendList(response.data['result'],userIdPref);
              if (friendList.length > 0) {
                setState(() {
                  friendList;
                });
              }
            }
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
    token = prefs.getString(UserPreference.USER_TOKEN);
  }
  @override
  void initState() {
    getSharedPreferences();
    // TODO: implement initState
    _IsSearching = false;
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        if (_searchQuery.text.length > 2) {

        if(previousText!=_searchQuery.text) {
          Timer _timer = new Timer(const Duration(milliseconds: 400), () {
            previousText = _searchQuery.text;
            apiCallingForFrindList2(_searchQuery.text);
            setState(() {
              _IsSearching = true;
              _searchText = _searchQuery.text;
            });
          });
        }

        }

      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<InkWell> _buildSearchList() {
      //    if (_searchText.isEmpty) {
      return new List.generate(friendList.length, (int index) {
        return new InkWell(
            child: PaddingWrap.paddingAll(
                10.0,
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Center(
                        child:friendList[index].groupImage!="null"&&friendList[index].groupImage!=""?new Container(
                          width: 60.0,
                          height: 60.0,
                          child:  FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/group/group_default.png',
                            image:      Constant.IMAGE_PATH_SMALL +
                                ParseJson.getSmallImage(
                                    friendList[index]
                                        .groupImage),
                          ),):  friendList[index].profilePicture != "null"
                            ? new Container(
                                width: 60.0,
                                height: 60.0,
                               child:  FadeInImage.assetNetwork(
                                 fit: BoxFit.cover,
                                 placeholder: 'assets/profile/user_on_user.png',
                                 image:      Constant.IMAGE_PATH_SMALL +
                                     ParseJson.getSmallImage(
                                         friendList[index]
                                             .profilePicture),
                               ),)
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
                                  friendList[index].groupId!="null"&&friendList[index].groupId!=""?friendList[index].groupName:   friendList[index].lastName == "null"
                                      ? friendList[index].firstName
                                      : friendList[index].firstName +
                                          " " +
                                          friendList[index].lastName,
                                  TextAlign.right,
                                  Colors.black,
                                  16.0,
                                  FontWeight.bold),
                              friendList[index].title == "null"
                                  ? new Container(
                                      height: 1.0,
                                    )
                                  : TextViewWrap.textView(
                                      friendList[index].title,
                                      TextAlign.center,
                                      Colors.grey,
                                      14.0,
                                      FontWeight.normal),
                            ],
                          )),
                      flex: 4,
                    ),
                  ],
                )),
            onTap: () {
              print(friendList[index].firstName);
              setState(() {
                print("list");
                _IsSearching = false;
              });
              Navigator.of(context).pop();
              if(friendList[index].groupId!="null"&&friendList[index].groupId!=""){
               Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new GroupDetailWidget(friendList[index].groupId)));

              }else {
                if(friendList[index].roleId=="2"){
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new ParentProfilePageWithHeader(friendList[index].userId)));
                }else  if (userIdPref != friendList[index].userId)
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new UserProfilePage(friendList[index].userId, false,"")));
              }
            });
      });



    }

    final search2 = PaddingWrap.paddingAll(
        5.0,
        new TextField(
            controller: _searchQuery,
            autocorrect: false
          /*  onChanged: (s) {
              s=s.trim();
              if (s.length > 2) {
                if (s.length > previousLength) {
                  print("text :-" + s);
                  if (s.length > previousText.length) {
                    if (s.contains(previousText)) {
                      s = s.replaceFirst(previousText, "");
                      setState(() {
                        _searchQuery.text = s;
                      });
                    }
                  }
                  apiCallingForFrindList2(s);
                }
              }
              previousLength = s.length;
              setState(() {
                previousLength;
              });
            }*/,autofocus: true,
            decoration: new InputDecoration(
              contentPadding: const EdgeInsets.all(5.0),
              border: InputBorder.none,
              hintText: 'Search here..',
              labelStyle: new TextStyle(
                  fontSize: 12.0, color: const Color(0xFF757575)),
            )));

    return
      new WillPopScope(
          onWillPop: (){
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.pop(context);
          },
          child:
      new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            automaticallyImplyLeading: false,  titleSpacing: 2.0,
            brightness: Brightness.light,
            leading: new InkWell(
              child: new Image.asset(
                "assets/profile/post/back_arrow_blue.png",
                height: 25.0,
                width: 25.0,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: new Color(ColorValues.NAVIGATION_DRAWER_BG_COLOUR),
            title: search2),
        body: friendList.length>0?  new ListView(
          children: <Widget>[
           new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSearchList())
          ],
        ): new Center(
    child: new Text(
    "",
      style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
    )));
  }
}
