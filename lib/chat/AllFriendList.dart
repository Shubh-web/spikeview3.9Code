import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spike_view_project/chat/ChatRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
//import 'package:spike_view_project/chat/ChatRoom.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/group/GroupDetailWidget.dart';
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

class AllFriendList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new AllFriendListState();
  }
}

class AllFriendListState extends State<AllFriendList> {
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
  List<ConnectionListModel> friendList = new List();

  Future fetchPost() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_CHAT_LIST + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            friendList.clear();
            friendList = ParseJson.parseChatData(response.data['result']);
            if (friendList != null) {
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
    fetchPost();
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
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final search2 = PaddingWrap.paddingAll(
        5.0,
        new TextField(
            controller: _searchQuery,autofocus: true,
            autocorrect: false,
            decoration: new InputDecoration(
              contentPadding: const EdgeInsets.all(5.0),
              border: InputBorder.none,
              hintText: 'Search here..',
              labelStyle: new TextStyle(
                  fontSize: 12.0, color: const Color(0xFF757575)),
            )));

    onTapItem(index) async{
    await  Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
          new ChatRoomHome(friendList[index], "","")));
    Navigator.pop(context,"push");
    }

    List<InkWell> _buildSearchList2() {
      if (_searchText.isEmpty) {
        return new List.generate(friendList.length, (int index) {
          return new InkWell(
              child: PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Container(
                            width: 60.0,
                            height: 60.0,
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.cover,
                              placeholder: 'assets/profile/user_on_user.png',
                              image: Constant.IMAGE_PATH_SMALL +
                                  ParseJson.getSmallImage(
                                      friendList[index].partnerProfilePicture),
                            ),
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
                                    friendList[index].partnerLastName==null||  friendList[index].partnerLastName=="null"?friendList[index].partnerFirstName:     friendList[index].partnerFirstName +
                                        " " +
                                        friendList[index].partnerLastName,
                                    TextAlign.center,
                                    Colors.grey,
                                    14.0,
                                    FontWeight.normal),
                               /* TextViewWrap.textView(
                                    friendList[index].lastMessage,
                                    TextAlign.center,
                                    Colors.grey,
                                    14.0,
                                    FontWeight.normal),*/
                              ],
                            )),
                        flex: 4,
                      ),
                    ],
                  )),
              onTap: () {
                print(friendList[index].partnerFirstName);
                setState(() {
                  print("list");
                  _IsSearching = false;
                });
                onTapItem(index);


              });
        });
      } else {
        List<ConnectionListModel> _searchList = List();
        for (int i = 0; i < friendList.length; i++) {
          String name = friendList[i].partnerFirstName;
          if (name.toLowerCase().contains(_searchText.toLowerCase())) {
            _searchList.add(friendList[i]);
          }
        }
        return new List.generate(_searchList.length, (int index) {
          return new InkWell(
              child: PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Container(
                          width: 60.0,
                          height: 60.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: Constant.IMAGE_PATH_SMALL +
                                ParseJson.getSmallImage(
                                    _searchList[index].partnerProfilePicture),
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

                                    _searchList[index].partnerLastName==null||  _searchList[index].partnerLastName=="null"?_searchList[index].partnerFirstName:     _searchList[index].partnerFirstName +
                                        " " +
                                        _searchList[index].partnerLastName

                                  ,
                                    TextAlign.right,
                                    Colors.black,
                                    16.0,
                                    FontWeight.bold),
                                /*TextViewWrap.textView(
                                    _searchList[index].lastMessage,
                                    TextAlign.center,
                                    Colors.grey,
                                    14.0,
                                    FontWeight.normal),*/
                              ],
                            )),
                        flex: 4,
                      ),
                    ],
                  )),
              onTap: () {
                print(_searchList[index].partnerFirstName);
                setState(() {
                  print("list");
                  _IsSearching = false;
                });
                onTapItem(index);
              });
        });
      }
    }

    return new Scaffold(
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
        body: friendList.length > 0
            ? new ListView(
                children: <Widget>[
                  new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildSearchList2())
                ],
              )
            : new Center(
                child: new Text(
                  "No connection found,please add friends",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ));
  }
}
