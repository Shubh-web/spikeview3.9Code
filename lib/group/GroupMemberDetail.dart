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
import 'package:spike_view_project/group/model/GroupDetailModel.dart';
import 'package:spike_view_project/group/model/GroupModel.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileShareLogModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class GroupMemberDetail extends StatefulWidget {
  GroupDetailModel groupDetailModel;

  GroupMemberDetail(this.groupDetailModel);

  @override
  GroupMemberDetailState createState() {
    return new GroupMemberDetailState();
  }
}

class GroupMemberDetailState extends State<GroupMemberDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
          appBar: new AppBar(
            titleSpacing: 2.0,
            brightness: Brightness.light,
            title: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text(
                  "MEMBERS",
                  style: new TextStyle(color: new Color(0XFF58616D)),
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
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: new List.generate(
                        widget.groupDetailModel.memberList.length, (int index) {
                      return new InkWell(
                        child: new Container(
                            padding:
                                new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                            height: 130.0,
                            child: new Card(
                                elevation: 5.0,
                                child: new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: widget
                                                      .groupDetailModel
                                                      .memberList[index]
                                                      .profilePicture !=
                                                  null &&
                                              widget
                                                      .groupDetailModel
                                                      .memberList[index]
                                                      .profilePicture !=
                                                  "null" &&
                                              widget
                                                      .groupDetailModel
                                                      .memberList[index]
                                                      .profilePicture !=
                                                  ""
                                          ? new Container(
                                              height: 100.0,
                                              child: FadeInImage.assetNetwork(
                                                fit: BoxFit.fill,
                                                placeholder:
                                                    'assets/group/group_default.png',
                                                image: Constant
                                                        .IMAGE_PATH_SMALL +
                                                    ParseJson.getSmallImage(
                                                        widget
                                                            .groupDetailModel
                                                            .memberList[index]
                                                            .profilePicture),
                                              ))
                                          : new Container(
                                              height: 100.0,
                                              child: new Image.asset(
                                                "assets/group/group_default.png",
                                                fit: BoxFit.fill,
                                              ),
                                            ),
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
                                              widget
                                                          .groupDetailModel
                                                          .memberList[index]
                                                          .isAdmin ==
                                                      "true"
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: new Container(
                                                        padding:
                                                            new EdgeInsets.all(
                                                                3.0),
                                                        color: new Color(
                                                            ColorValues
                                                                .BLUE_COLOR),
                                                        child: new Text(
                                                          "Admin",
                                                          style: new TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12.0),
                                                        ),
                                                      ),
                                                    )
                                                  : widget
                                                              .groupDetailModel
                                                              .memberList[index]
                                                              .status ==
                                                          "Invited"
                                                      ? Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: new Container(
                                                            padding:
                                                                new EdgeInsets
                                                                    .all(3.0),
                                                            color: Colors.green,
                                                            child: new Text(
                                                              "Invited",
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                          ),
                                                        )
                                                      : new Container(
                                                          padding:
                                                              new EdgeInsets
                                                                  .all(7.0),
                                                        ),
                                              new Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  TextViewWrap.textView(
                                                      widget
                                                                  .groupDetailModel
                                                                  .memberList[
                                                                      index]
                                                                  .lastName !=
                                                              "null"
                                                          ? widget
                                                                  .groupDetailModel
                                                                  .memberList[
                                                                      index]
                                                                  .firstName +
                                                              widget
                                                                  .groupDetailModel
                                                                  .memberList[
                                                                      index]
                                                                  .lastName
                                                          : widget
                                                              .groupDetailModel
                                                              .memberList[index]
                                                              .firstName,
                                                      TextAlign.start,
                                                      Colors.black,
                                                      19.0,
                                                      FontWeight.bold),
                                                  PaddingWrap.paddingfromLTRB(
                                                      0.0,
                                                      5.0,
                                                      0.0,
                                                      0.0,
                                                      TextViewWrap.textView(
                                                          widget
                                                                      .groupDetailModel
                                                                      .memberList[
                                                                          index]
                                                                      .tagline ==
                                                                  "null"
                                                              ? ""
                                                              : widget
                                                                  .groupDetailModel
                                                                  .memberList[
                                                                      index]
                                                                  .tagline,
                                                          TextAlign.right,
                                                          new Color(0XFF96A2AD),
                                                          15.0,
                                                          FontWeight.normal)),
                                                  new Row(
                                                    children: <Widget>[
                                                      PaddingWrap.paddingfromLTRB(
                                                          0.0,
                                                          0.0,
                                                          0.0,
                                                          0.0,
                                                          TextViewWrap.textView(
                                                              widget
                                                                  .groupDetailModel
                                                                  .memberList[
                                                                      index]
                                                                  .email,
                                                              TextAlign.right,
                                                              new Color(
                                                                  0XFF96A2AD),
                                                              15.0,
                                                              FontWeight
                                                                  .normal)),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          )),
                                      flex: 7,
                                    ),
                                  ],
                                ))),
                        onTap: () {},
                      );
                    })),
              )
            ],
          ),
        ));
  }
}
