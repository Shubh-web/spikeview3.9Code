import 'dart:async';

import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/material.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/group/GroupDetailWidget.dart';
import 'package:spike_view_project/notification/model/NotificationModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/chat/ChatRoom.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class NotificationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new NotificationWidgetState();
  }
}

class NotificationWidgetState extends State<NotificationWidget> {
  List<NotificationModel> dataList = new List();

  SharedPreferences prefs;
  String userIdPref;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    fetchPost();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    print("==================== INIT STATE");
  }

//==========================================================

  //--------------------------Profile Info api ------------------
  Future fetchPost() async {
    try {
      Response response = await new ApiCalling().apiCall(context,
          Constant.ENDPOINT_NOTIFICATION_ALL + userIdPref + "&skip=0", "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            dataList.clear();
            dataList = ParseJson.parseNotification(response.data['result']);
            if (dataList != null) {
              setState(() {
                dataList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForDeleteFeed(model, index) async {
    try {
      Map map = {"notificationId": int.parse(model.notificationId)};
      Response response = await new ApiCalling().apiCallDeleteWithMapData(
          context, Constant.ENDPOINT_NOTIFICATION_DELETE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            dataList.removeAt(index);
            setState(() {
              dataList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget getMoreDropDown(model, index) {
      return new PopupMenuButton<String>(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Image.asset(
              "assets/profile/post/user_more.png",
              width: 20.0,
              height: 20.0,
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
                    apiCallingForDeleteFeed(model, index);
                  },
                ),
                value: "0",
              ),
            ],
      );
    }

    Container getCellItem(NotificationModel model, int index1) {
      return new Container(
          color: (index1 % 2 == 0) ? Colors.white : new Color(0XFFF2F6F9),
          child: new Column(
            children: <Widget>[
              new Container(
                padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                height: 110.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                          height: 70.0,
                          width: 70.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: model.profilePicture == null
                                ? ""
                                : Constant.IMAGE_PATH + model.profilePicture,
                          )),
                      flex: 0,
                    ),
                    new Expanded(
                      child: new Column(
                        children: <Widget>[
                          new Container(
                              height: 98.0,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Align(
                                      alignment: Alignment.topRight,
                                      child: getMoreDropDown(model, index1)),
                                  new Padding(
                                      padding: new EdgeInsets.fromLTRB(
                                          5.0, 5.0, 5.0, 5.0),
                                      child: new Row(
                                        children: <Widget>[
                                          new Expanded(
                                            child: new Text(
                                              model.text.contains("groupId=")
                                                  ? model.text.substring(
                                                      0,
                                                      model.text
                                                          .indexOf("groupId="))
                                                  : model.text,
                                              maxLines: 2,
                                              style: new TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            flex: 1,
                                          ),
                                        ],
                                      )),
                                  new Align(
                                      alignment: Alignment.bottomRight,
                                      child: new Text(
                                        model.dateTime,
                                        textAlign: TextAlign.left,
                                      ))
                                ],
                              )),
                        ],
                      ),
                      flex: 4,
                    )
                  ],
                ),
              ),
            ],
          ));
    }

    void onItemClick(int index) async {
      if (dataList[index].text.contains("groupId")) {
        List<String> list = dataList[index].text.split(" ");
        String groupId = list[list.length - 1].replaceAll("groupId=", "");
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new GroupDetailWidget(groupId)));
      }
    }

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
    return new Scaffold(
      backgroundColor: new Color(0XFFF7F7F9),
      appBar: new AppBar(
        automaticallyImplyLeading: false,  titleSpacing: 2.0,
        brightness: Brightness.light,
        leading: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new InkWell(
              child: new Image.asset(
                "assets/profile/post/back_arrow_blue.png",
                height: 25.0,
                width: 25.0,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        title: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Text(
              "NOTIFICATIONS",
              style: new TextStyle(color: new Color(ColorValues.BLUE_COLOR)),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: new ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (BuildContext ctxt, int Index) {
            return GestureDetector(
              child: getCellItem(dataList[Index], Index),
              onTap: () => onItemClick(Index),
            );
          }),
    );
  }
}
