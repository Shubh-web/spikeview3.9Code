import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:spike_view_project/drawer/SearchFriend.dart';
import 'package:spike_view_project/group/AddGroupWidget.dart';
import 'package:spike_view_project/group/GroupDetailWidget.dart';
import 'package:spike_view_project/group/model/GroupModel.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileShareLogModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class GroupBaseWidget extends StatefulWidget {
  String userId;

  GroupBaseWidget(this.userId);

  @override
  GroupBaseWidgetState createState() {
    return new GroupBaseWidgetState();
  }
}

class GroupBaseWidgetState extends State<GroupBaseWidget> {
  List<GroupModel> groupList = new List();

  Future apiCallForGet() async {
    try {
      Response response;
      response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_GROUPS + widget.userId, "get");
      print(response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            groupList.clear();
            groupList = ParseJson.parseGroupData(
                response.data['result'], widget.userId);
            if (groupList.length > 0) {
              setState(() {
                groupList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingDeleteGroup(index) async {
    try {
      CustomProgressLoader.showLoader(context);
      Response response;

      Map map = {"groupId": int.parse(groupList[index].groupId)};
      response = await new ApiCalling()
          .apiCallDeleteWithMapData(context, Constant.ENDPOINT_ADD_GROUP, map);
      CustomProgressLoader.cancelLoader(context);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            groupList.removeAt(index);
            setState(() {
              groupList;
            });
          } else {
            ToastWrap.showToast(msg);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAccept(groupId, index, type) async {
    try {
      Map map = {
        "groupId": int.parse(groupId),
        "userId": int.parse(widget.userId),
        "status": type
      };
      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_UPDATE_GROUP_REQUEST, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            apiCallForGet();
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForLeave(index) async {
    try {
      Response response;

      Map map = {
        "userId": int.parse(widget.userId),
        "groupId": int.parse(groupList[index].groupId)
      };
      response = await new ApiCalling()
          .apiCallPostWithMapData(context, Constant.ENDPOINT_LEAVE_GROUP, map);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            groupList.removeAt(index);
            setState(() {
              groupList;
            });
          } else {
            ToastWrap.showToast(msg);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  void initState() {
    apiCallForGet();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
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

    onTapAddGroup() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new AddGroupWidget()));

      if (result == "push") {
        apiCallForGet();
      }
    }

    showDialogDelete(orgName, index) {
      showDialog(
        context: context,
        barrierDismissible: false,
        child: new Dialog(
          child: new Container(
              height: 180.0,
              color: Colors.white,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                            child: new Text(
                              "Are you sure ?",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.grey),
                            )),
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                            child: new Text(
                              "You want to delete group $orgName  ?",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Colors.grey),
                            )),
                        new Container(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                PaddingWrap.paddingfromLTRB(
                                    5.0,
                                    0.0,
                                    5.0,
                                    0.0,
                                    new Container(
                                      decoration: new BoxDecoration(
                                          border: new Border.all(
                                              color: Colors.white)),
                                      height: 40.0,
                                      width: 100.0,
                                      child: new FlatButton(
                                          color: new Color(0XFFC74647),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            apiCallingDeleteGroup(index);
                                          },
                                          child: new Text("Delete",
                                              style: new TextStyle(
                                                  color: Colors.white))),
                                    )),
                                PaddingWrap.paddingfromLTRB(
                                    5.0,
                                    0.0,
                                    5.0,
                                    0.0,
                                    new Container(
                                      decoration: new BoxDecoration(
                                          border: new Border.all(
                                              color: Colors.white)),
                                      height: 40.0,
                                      width: 100.0,
                                      child: new FlatButton(
                                          color: Colors.black54,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: new Text("Cancel",
                                              style: new TextStyle(
                                                  color: Colors.white))),
                                    )),
                              ],
                            )),
                      ],
                    ),
                    flex: 4,
                  ),
                ],
              )),
        ),
      );
    }

    onTapListItem(groupId) async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new GroupDetailWidget(groupId)));
      if (result == "push") {
        apiCallForGet();
      }
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 2.0,
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
                    "GROUPS",
                    style: new TextStyle(color: new Color(ColorValues.BLUE_COLOR)),
                  )
                ],
              ),
              backgroundColor: Colors.white,
            ),
            body:groupList!=null&&groupList.length>0? new ListView(
              children: <Widget>[
                new Container(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          new List.generate(groupList.length, (int index) {
                        return new InkWell(
                          child: new Container(
                              padding:
                                  new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                              height: groupList[index].groupName.length > 30
                                  ? 190.0
                                  : 175.0,
                              child: new Card(
                                  elevation: 5.0,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new Container(
                                            height: groupList[index]
                                                        .groupName
                                                        .length >
                                                    30
                                                ? 190.0
                                                : 175.0,
                                            child: FadeInImage.assetNetwork(
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  'assets/group/group_default.png',
                                              image: Constant.IMAGE_PATH_SMALL +
                                                  ParseJson.getSmallImage(
                                                      groupList[index]
                                                          .groupImage),
                                            )),
                                        flex: 3,
                                      ),
                                      new Expanded(
                                        child: PaddingWrap.paddingfromLTRB(
                                            10.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                groupList[index].isAdmin
                                                    ? Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: new Container(
                                                          padding:
                                                              new EdgeInsets
                                                                  .all(3.0),
                                                          color: new Color(
                                                              ColorValues
                                                                  .BLUE_COLOR),
                                                          child: new Text(
                                                            "Admin",
                                                            style: new TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.0),
                                                          ),
                                                        ),
                                                      )
                                                    : new Container(
                                                        padding:
                                                            new EdgeInsets.all(
                                                                7.0),
                                                      ),
                                                new Text(
                                                  groupList[index].groupName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 19.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                PaddingWrap.paddingfromLTRB(
                                                    0.0,
                                                    5.0,
                                                    0.0,
                                                    0.0,
                                                    TextViewWrap.textView(
                                                        "Created on :- " +
                                                            groupList[index]
                                                                .creationDate,
                                                        TextAlign.right,
                                                        new Color(0XFF96A2AD),
                                                        13.0,
                                                        FontWeight.normal)),
                                                new Row(
                                                  children: <Widget>[
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        TextViewWrap.textView(
                                                            groupList[index]
                                                                    .type +
                                                                " Group | ",
                                                            TextAlign.right,
                                                            new Color(
                                                                0XFF96A2AD),
                                                            13.0,
                                                            FontWeight.normal)),
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        TextViewWrap.textView(
                                                            groupList[index]
                                                                        .memberList
                                                                        .length >
                                                                    0
                                                                ? groupList[index]
                                                                            .memberList
                                                                            .length ==
                                                                        1
                                                                    ? " 1 Member"
                                                                    : " " +
                                                                        groupList[index]
                                                                            .acceptCount
                                                                            .toString() +
                                                                        " Members"
                                                                : "",
                                                            TextAlign.right,
                                                            new Color(
                                                                0XFF96A2AD),
                                                            13.0,
                                                            FontWeight.normal))
                                                  ],
                                                ),
                                                PaddingWrap.paddingfromLTRB(
                                                    0.0,
                                                    15.0,
                                                    0.0,
                                                    0.0,
                                                    groupList[index].isAdmin
                                                        ? new Row(
                                                            children: <Widget>[
                                                              new Expanded(
                                                                child: PaddingWrap
                                                                    .paddingAll(
                                                                        5.0,
                                                                        new InkWell(
                                                                          child: new Container(
                                                                              height: 40.0,
                                                                              decoration: new BoxDecoration(border: new Border.all(color: new Color(0XFFAA191D), width: 0.25)),
                                                                              child: new Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: <Widget>[
                                                                                  new Text(
                                                                                    "Delete",
                                                                                    style: new TextStyle(color: new Color(0XFFAA191D)),
                                                                                  )
                                                                                ],
                                                                              )),
                                                                          onTap:
                                                                              () {
                                                                            showDialogDelete(groupList[index].groupName,
                                                                                index);
                                                                          },
                                                                        )),
                                                                flex: 1,
                                                              ),
                                                              new Expanded(
                                                                child:
                                                                    new Container(
                                                                  height: 0.0,
                                                                ),
                                                                flex: 1,
                                                              ),
                                                            ],
                                                          )
                                                        : groupList[index]
                                                                    .status ==
                                                                "Invited"
                                                            ? new Row(
                                                                children: <
                                                                    Widget>[
                                                                  new Expanded(
                                                                    child: PaddingWrap
                                                                        .paddingAll(
                                                                            5.0,
                                                                            new InkWell(
                                                                              child: new Container(
                                                                                  height: 40.0,
                                                                                  decoration: new BoxDecoration(border: new Border.all(color: Colors.grey[300], width: 0.5)),
                                                                                  child: new Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      new Image.asset(
                                                                                        "assets/login/check.png",
                                                                                        height: 20.0,
                                                                                        width: 20.0,
                                                                                      ),
                                                                                      new Text(
                                                                                        "  Accept",
                                                                                        style: new TextStyle(color: Colors.black),
                                                                                      )
                                                                                    ],
                                                                                  )),
                                                                              onTap: () {
                                                                                apiCallingForAccept(groupList[index].groupId, index, "Accepted");
                                                                              },
                                                                            )),
                                                                    flex: 1,
                                                                  ),
                                                                  new Expanded(
                                                                    child: PaddingWrap
                                                                        .paddingAll(
                                                                            5.0,
                                                                            new InkWell(
                                                                              child: new Container(
                                                                                  height: 40.0,
                                                                                  decoration: new BoxDecoration(border: new Border.all(color: Colors.grey[300], width: 0.5)),
                                                                                  child: new Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      new Image.asset(
                                                                                        "assets/login/delete.png",
                                                                                        height: 20.0,
                                                                                        width: 20.0,
                                                                                      ),
                                                                                      new Text(
                                                                                        "  Decline",
                                                                                        style: new TextStyle(color: Colors.black),
                                                                                      )
                                                                                    ],
                                                                                  )),
                                                                              onTap: () {
                                                                                apiCallingForAccept(groupList[index].groupId, index, "Rejected");
                                                                              },
                                                                            )),
                                                                    flex: 1,
                                                                  ),
                                                                ],
                                                              )
                                                            : groupList[index]
                                                                            .status ==
                                                                        "Accepted" &&
                                                                    (!groupList[
                                                                            index]
                                                                        .isAdmin)
                                                                ? new Row(
                                                                    children: <
                                                                        Widget>[
                                                                      new Expanded(
                                                                        child: PaddingWrap.paddingAll(
                                                                            5.0,
                                                                            new InkWell(
                                                                              child: new Container(
                                                                                  height: 40.0,
                                                                                  decoration: new BoxDecoration(border: new Border.all(color: Colors.grey[300], width: 0.5)),
                                                                                  child: new Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      new Text(
                                                                                        "Leave",
                                                                                        style: new TextStyle(color: new Color(ColorValues.BLUE_COLOR)),
                                                                                      )
                                                                                    ],
                                                                                  )),
                                                                              onTap: () {
                                                                                apiCallingForLeave(index);
                                                                              },
                                                                            )),
                                                                        flex: 1,
                                                                      ),
                                                                      new Expanded(
                                                                        child:
                                                                            new Container(
                                                                          height:
                                                                              0.0,
                                                                        ),
                                                                        flex: 1,
                                                                      ),
                                                                    ],
                                                                  )
                                                                : groupList[index]
                                                                            .status ==
                                                                        "Requested"
                                                                    ? PaddingWrap
                                                                        .paddingAll(
                                                                            5.0,
                                                                            new Text(
                                                                              "Pending for approval",
                                                                              style: new TextStyle(color: new Color(ColorValues.BLUE_COLOR)),
                                                                            ))
                                                                    : new Container(
                                                                        height:
                                                                            0.0,
                                                                      ))
                                              ],
                                            )),
                                        flex: 7,
                                      ),
                                    ],
                                  ))),
                          onTap: () {
                            onTapListItem(groupList[index].groupId);
                          },
                        );
                      })),
                )
              ],
            ):new Center(
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PaddingWrap.paddingAll(15.0,  new Image.asset(
              "assets/no_feed_new.png",
            )),
            TextViewWrap.textView(
                "No Group Yet.",
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
                    " Create Group and add people around you.",
                    TextAlign.center,
                    Colors.grey[400],
                    15.0,
                    FontWeight.bold))
          ],),
    ),
            floatingActionButton: new FloatingActionButton(
                elevation: 0.0,
                child: new Image.asset(
                  "assets/group/create_group_icon.png",
                  width: 42.0,
                  height: 42.0,
                ),
                backgroundColor: new Color(ColorValues.BLUE_COLOR),
                onPressed: () {
                  onTapAddGroup();
                })));
  }
}
