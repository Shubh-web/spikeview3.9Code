import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/group/model/GroupDetailModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
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

class InviteMemberWidget extends StatefulWidget {
  GroupDetailModel groupDetailModel;
  ProfileInfoModal profileInfoModal;

  InviteMemberWidget(this.groupDetailModel, this.profileInfoModal);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new InviteMemberWidgetState();
  }
}

class InviteMemberWidgetState extends State<InviteMemberWidget> {
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
  List<ProfileInfoModal> selectedList = new List();

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

          print("clicked 2");
          break;
        }
      case 3:
        {
          /*  Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => new AddAchievmentForm()));*/

          syncDoneController.add("success");
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

  //--------------------------My Narratives Info api ------------------
  Future apiCallingForFrindList() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, "ui/user?roleId=1&isActive=true", "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            friendList.clear();
            friendList = ParseJson.parseUserFriendList(
                response.data['result'], userIdPref);
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

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    apiCallingForFrindList();
  }

  @override
  void initState() {
    getSharedPreferences();
    // TODO: implement initState
    _IsSearching = false;
    _IsSearching = false;
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
    super.initState();
  }

  Future apiCallingForInvite() async {
    try {
      Map map = {
        "members": selectedList.map((item) => item.toJson()).toList(),
        "groupId": int.parse(widget.groupDetailModel.groupId),
        "firstName": widget.groupDetailModel.adminName,
        "lastName": "",
        "email": "",
        "invitedBy": widget.groupDetailModel.adminName
      };


      //{"members":[{"userId":468}],"groupId":177,"firstName":"DRAFT PUNK","lastName":"","email":"","invitedBy":"DRAFT PUNK"}
      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_INVITE_MEMBER, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data['message'];
          if (status == "Success") {
            ToastWrap.showToast(message);
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    onTapInvite() {
      selectedList.clear();
      for (ProfileInfoModal model in friendList) {
        if (model.isSelected) {
          selectedList.add(model);
        }
      }
      if (selectedList.length > 0) {
        apiCallingForInvite();
      } else {
        ToastWrap.showToast("Please select at least 1 member..");
      }
    }

    List<Padding> _buildSearchList() {
      if (_searchText.isEmpty) {
        return new List.generate(friendList.length, (int index) {
          return new Padding(
              padding: new EdgeInsets.all(0.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                      10.0,
                      new Container(
                          width: 50.0,
                          height: 50.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.fill,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: Constant.IMAGE_PATH_SMALL +
                                ParseJson.getSmallImage(
                                    friendList[index].profilePicture),
                          )),
                    ),
                    flex: 0,
                  ),
                  new Expanded(
                      child: PaddingWrap.paddingAll(
                          5.0,
                          TextViewWrap.textView(
                              friendList[index].lastName == "" ||
                                      friendList[index].lastName == "null"
                                  ? friendList[index].firstName
                                  : friendList[index].firstName +
                                      " " +
                                      friendList[index].lastName,
                              TextAlign.start,
                              Colors.black,
                              18.0,
                              FontWeight.bold)),
                      flex: 2),
                  new Expanded(
                      child: PaddingWrap.paddingAll(
                          5.0,
                          new SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: new Theme(
                                  data: new ThemeData(
                                    unselectedWidgetColor: Color(0xFFABB9D7),
                                  ),
                                  child: new Checkbox(
                                    value: friendList[index].isSelected,
                                    onChanged: (bool value) {
                                      if (friendList[index].isSelected)
                                        friendList[index].isSelected = false;
                                      else
                                        friendList[index].isSelected = true;

                                      setState(() {
                                        friendList[index].isSelected;
                                      });
                                    },
                                  )))),
                      flex: 0),
                ],
              ));
        });
      } else {
        List<ProfileInfoModal> _searchList = List();
        for (int i = 0; i < friendList.length; i++) {
          String name = friendList[i].firstName;
          if (name.toLowerCase().contains(_searchText.toLowerCase())) {
            _searchList.add(friendList[i]);
          }
        }
        return new List.generate(_searchList.length, (int index) {
          return new Padding(
              padding: new EdgeInsets.all(0.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                      10.0,
                      new Container(
                          width: 50.0,
                          height: 50.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.fill,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: Constant.IMAGE_PATH_SMALL +
                                ParseJson.getSmallImage(
                                    _searchList[index].profilePicture),
                          )),
                    ),
                    flex: 0,
                  ),
                  new Expanded(
                      child: PaddingWrap.paddingAll(
                          5.0,
                          TextViewWrap.textView(
                              _searchList[index].lastName == "" ||
                                      _searchList[index].lastName == "null"
                                  ? _searchList[index].firstName
                                  : _searchList[index].firstName +
                                      " " +
                                      _searchList[index].lastName,
                              TextAlign.start,
                              Colors.black,
                              18.0,
                              FontWeight.bold)),
                      flex: 2),
                  new Expanded(
                      child: PaddingWrap.paddingAll(
                          5.0,
                          new SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: new Theme(
                                  data: new ThemeData(
                                    unselectedWidgetColor: Color(0xFFABB9D7),
                                  ),
                                  child: new Checkbox(
                                    value: _searchList[index].isSelected,
                                    onChanged: (bool value) {
                                      if (_searchList[index].isSelected)
                                        _searchList[index].isSelected = false;
                                      else
                                        _searchList[index].isSelected = true;

                                      setState(() {
                                        _searchList[index].isSelected;
                                      });
                                    },
                                  )))),
                      flex: 0),
                ],
              ));
          ;
        });
      }
    }

    final search2 = PaddingWrap.paddingAll(
        5.0,
        new Container(
            padding: new EdgeInsets.all(5.0),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.blue, width: 2.0),
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                    bottomRight: const Radius.circular(40.0),
                    bottomLeft: const Radius.circular(40.0))),
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    /* new Expanded(
                      child: new TextFormField(
                          controller: _searchQuery,
                          decoration: new InputDecoration(
                            contentPadding: const EdgeInsets.all(5.0),
                            border: InputBorder.none,
                            hintText: 'Search',
                            labelStyle: new TextStyle(
                                fontSize: 12.0, color: const Color(0xFF757575)),
                          )),
                      flex: 1,
                    ),*/
                    new Expanded(
                      child: new TextField(
                          controller: _searchQuery,
                          autocorrect: false,
                          decoration: new InputDecoration(
                            contentPadding: const EdgeInsets.all(5.0),
                            border: InputBorder.none,
                            hintText: 'Search',
                            labelStyle: new TextStyle(
                                fontSize: 12.0, color: const Color(0xFF757575)),
                          )),
                      flex: 1,
                    ),
                    new Expanded(
                      child: PaddingWrap.paddingAll(
                          3.0,
                          new Image.asset(
                            "assets/navigation/search.png",
                            width: 25.0,
                            height: 25.0,
                          )),
                      flex: 0,
                    )
                  ],
                ),
              ],
            )));

    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 2.0,
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
        body: new Stack(
          children: <Widget>[
            new Positioned(
                bottom: 50.0,
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: new ListView(
                  children: <Widget>[
                    new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSearchList())
                  ],
                )),
            new Align(
              alignment: Alignment.bottomRight,
              child: new Container(
                  width: double.infinity,
                  height: 50.0,
                  child: new RaisedButton(
                    color: new Color(ColorValues.BLUE_COLOR),
                    child: new Text(
                      'Invite',
                      style: new TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                    onPressed: onTapInvite,
                  )),
            )
          ],
        ));
  }
}
