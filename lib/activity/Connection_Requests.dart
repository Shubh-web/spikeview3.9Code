import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/activity/FullImageViewPager.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/modal/RequestedTagListModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class ConnectionRequests extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ConnectionRequestsState();
  }
}

class ConnectionRequestsState extends State<ConnectionRequests> {
  SharedPreferences prefs;
  String userIdPref, userProfilePath;
  List<RequestedTagModel> tagList = new List();

  //--------------------------api Calling for tag------------------
  Future apiCallingForTag() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_CONNECTION_LIST + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            tagList.clear();
            tagList = ParseJson
                .parseRequestedTagList(response.data['result']['Requested']);
            if (tagList != null) {
              setState(() {
                tagList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAccept(connectionId, index, type) async {
    try {
      Map map = {
        "connectId": int.parse(connectionId),
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "status": type,
        "isActive": tagList[index].userIsActive
      };
      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_CONNECTION_UPDATE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            tagList.removeAt(index);
            ToastWrap.showToast(msg);
            setState(() {
              tagList;
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
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    userProfilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    apiCallingForTag();
  }

  @override
  void initState() {
    getSharedPreferences();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Container getListview(requestedTagModel, index) {
      return new Container(
          padding: new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
          height: 150.0,
          child: new Card(
              elevation: 5.0,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: requestedTagModel.patner.profilePicture != null &&
                            requestedTagModel.patner.profilePicture != "null" &&
                            requestedTagModel.patner.profilePicture != ""
                        ? new Container(
                            height: 150.0,
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.fill,
                              placeholder: 'assets/profile/user_on_user.png',
                              image: Constant.IMAGE_PATH_SMALL +
                                  ParseJson.getSmallImage(
                                      requestedTagModel.patner.profilePicture),
                            ))
                        : new Container(
                            height: 150.0,
                            child: new Image.asset(
                                "assets/profile/user_on_user.png"),
                          ),
                    flex: 3,
                  ),
                  new Expanded(
                    child: PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        0.0,
                        0.0,
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextViewWrap.textView(
                                requestedTagModel.patner.lastName == null ||
                                        requestedTagModel.patner.lastName ==
                                            "null" ||
                                        requestedTagModel.patner.lastName == ""
                                    ? requestedTagModel.patner.firstName
                                    : requestedTagModel.patner.firstName +
                                        " " +
                                        requestedTagModel.patner.lastName,
                                TextAlign.right,
                                Colors.black,
                                18.0,
                                FontWeight.bold),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                5.0,
                                0.0,
                                0.0,
                                TextViewWrap.textView(
                                    requestedTagModel.patner.email == null ||
                                            requestedTagModel.patner.email ==
                                                "null" ||
                                            requestedTagModel.patner.email == ""
                                        ? ""
                                        : requestedTagModel.patner.email,
                                    TextAlign.right,
                                    Colors.grey,
                                    15.0,
                                    FontWeight.normal)),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                15.0,
                                0.0,
                                0.0,
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: PaddingWrap.paddingAll(
                                          5.0,
                                          new InkWell(
                                            child:  new Container(
                                                height: 40.0,
                                                decoration: new BoxDecoration(
                                                    border: new Border.all(
                                                        color: Colors.grey[300])),
                                                child: new Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    new Image.asset(
                                                      "assets/login/check.png",
                                                      height: 20.0,
                                                      width: 20.0,
                                                    ),
                                                    new Text(
                                                      "  Accept",
                                                      style: new TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                )),
                                            onTap: () {
                                              apiCallingForAccept(
                                                  requestedTagModel.connectId,
                                                  index,
                                                  "Accepted");
                                            },
                                          )),
                                      flex: 1,
                                    ),
                                    new Expanded(
                                      child: PaddingWrap.paddingAll(
                                          5.0,
                                          new InkWell(
                                            child: new Container(
                                                height: 40.0,
                                                decoration: new BoxDecoration(
                                                    border: new Border.all(
                                                        color: Colors.grey[300])),
                                                child: new Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    new Image.asset(
                                                      "assets/login/delete.png",
                                                      height: 20.0,
                                                      width: 20.0,
                                                    ),
                                                    new Text(
                                                      "  Reject",
                                                      style: new TextStyle(
                                                          color: Colors.black),
                                                    )
                                                  ],
                                                )),
                                            onTap: () {
                                              apiCallingForAccept(
                                                  requestedTagModel.connectId,
                                                  index,
                                                  "Rejected");
                                            },
                                          )),
                                      flex: 1,
                                    ),
                                  ],
                                ))
                          ],
                        )),
                    flex: 7,
                  ),
                ],
              )));
    }

    return tagList.length > 0
        ? new ListView.builder(
            itemCount: tagList.length,
            itemBuilder: (BuildContext context, int position) {
              return getListview(tagList[position], position);
            })
        : new Center(
            child: new Text(
              "You have no pending request.",
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          );
  }
}
