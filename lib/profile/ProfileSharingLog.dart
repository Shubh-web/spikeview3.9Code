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
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileShareLogModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class ProfileSharingLog extends StatefulWidget {
  String userId;

  ProfileSharingLog(this.userId);

  @override
  ProfileSharingLogState createState() {
    return new ProfileSharingLogState();
  }
}

class ProfileSharingLogState extends State<ProfileSharingLog> {
  List<ProfileShareModel> profileShareLogLIst = new List();

  Future apiCallForGetShareLog() async {
    try {
      Response response;
      response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_SHARE_LOG + widget.userId, "get");
      print(response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            profileShareLogLIst.clear();
            profileShareLogLIst =
                ParseJson.parseMapShareLog(response.data['result']);
            if (profileShareLogLIst.length > 0) {
              setState(() {
                profileShareLogLIst;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Api Calling for update user Status ------------------
  Future apiCallingForUpdateStudentStatus(index) async {
    try {
      Response response;

      Map map = {
        "sharedId": int.parse(profileShareLogLIst[index].sharedId),
        "isActive": profileShareLogLIst[index].isActive
      };

      response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_SHARE_UPDATE, map);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
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
    apiCallForGetShareLog();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above

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
                    "PROFILE SHARING LOG",
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
            body:profileShareLogLIst!=null&&profileShareLogLIst.length>0? new ListView(
              children: <Widget>[
                new Container(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: new List.generate(profileShareLogLIst.length,
                          (int index) {
                        return PaddingWrap.paddingAll(
                            10.0,
                            new Container(
                                height: 230.0,
                                child: new Stack(children: <Widget>[
                                  new Positioned(
                                      top: 40.0,
                                      left: 30.0,
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: new Container(
                                        decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.grey[300])),
                                        child: new Stack(
                                          children: <Widget>[
                                            new Positioned(
                                                top: 10.0,
                                                left: 90.0,
                                                right: 0.0,
                                                child: new Container(
                                                    child: new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    TextViewWrap.textViewSingleLine(
                                                        profileShareLogLIst[
                                                                        index]
                                                                    .shareToLastName ==
                                                                "null"
                                                            ? profileShareLogLIst[
                                                                    index]
                                                                .shareToFirstName
                                                            : profileShareLogLIst[
                                                                        index]
                                                                    .shareToFirstName +
                                                                " " +
                                                                profileShareLogLIst[
                                                                        index]
                                                                    .shareToLastName,
                                                        TextAlign.start,
                                                        Colors.black,
                                                        18.0,
                                                        FontWeight.bold),
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        5.0,
                                                        0.0,
                                                        0.0,
                                                        TextViewWrap
                                                            .textViewSingleLine(
                                                                profileShareLogLIst[
                                                                        index]
                                                                    .shareToEmail,
                                                                TextAlign.start,
                                                                new Color(
                                                                    0XFF929FA7),
                                                                16.0,
                                                                FontWeight
                                                                    .normal)),
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        10.0,
                                                        0.0,
                                                        0.0,
                                                        new Row(
                                                          children: <Widget>[
                                                            profileShareLogLIst[
                                                                            index]
                                                                        .isActive ==
                                                                    "true"
                                                                ? new GestureDetector(
                                                                    onHorizontalDragEnd:
                                                                        (DragEndDetails
                                                                            details) {
                                                                      setState(
                                                                          () {
                                                                        profileShareLogLIst[index].isActive =
                                                                            "false";

                                                                        apiCallingForUpdateStudentStatus(
                                                                            index);
                                                                      });
                                                                    },
                                                                    child: new Center(
                                                                        child: new Padding(
                                                                            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                                                            child: new Image.asset(
                                                                              "assets/profile/parent/active.png",
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                            ))))
                                                                : new GestureDetector(
                                                                    onHorizontalDragEnd: (DragEndDetails details) {
                                                                      setState(
                                                                          () {
                                                                        profileShareLogLIst[index].isActive =
                                                                            "true";
                                                                        apiCallingForUpdateStudentStatus(
                                                                            index);
                                                                      });
                                                                    },
                                                                    child: new Center(
                                                                        child: new Padding(
                                                                            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                                                            child: new Image.asset(
                                                                              "assets/profile/parent/inactive.png",
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                            )))),
                                                            TextViewWrap.textView(
                                                                "REVOKE",
                                                                TextAlign.start,
                                                                new Color(
                                                                    0XFF9DA9B6),
                                                                12.0,
                                                                FontWeight
                                                                    .normal),
                                                          ],
                                                        )),
                                                  ],
                                                ))),
                                            new Positioned(
                                                top: 120.0,
                                                left: 0.0,
                                                right: 0.0,
                                                child: new Container(
                                                    height: 80.0,
                                                    child: new Row(
                                                      children: <Widget>[
                                                        new Expanded(
                                                          child: new Column(
                                                            children: <Widget>[
                                                              TextViewWrap.textViewSingleLine(
                                                                  "Sharing Type",
                                                                  TextAlign
                                                                      .center,
                                                                  Colors.black,
                                                                  15.0,
                                                                  FontWeight
                                                                      .bold),
                                                              PaddingWrap.paddingAll(
                                                                  5.0,
                                                                  TextViewWrap.textViewSingleLine(
                                                                      profileShareLogLIst[
                                                                              index]
                                                                          .sharedType,
                                                                      TextAlign
                                                                          .center,
                                                                      new Color(
                                                                          ColorValues
                                                                              .BLUE_COLOR),
                                                                      15.0,
                                                                      FontWeight
                                                                          .bold)),
                                                            ],
                                                          ),
                                                          flex: 1,
                                                        ),
                                                        new Expanded(
                                                          child: new Column(
                                                            children: <Widget>[
                                                              TextViewWrap
                                                                  .textViewSingleLine(
                                                                      "Sharing Time",
                                                                      TextAlign
                                                                          .start,
                                                                      Colors
                                                                          .black,
                                                                      15.0,
                                                                      FontWeight
                                                                          .bold),
                                                              PaddingWrap.paddingAll(
                                                                  5.0,
                                                                  TextViewWrap.textViewMultiLine(
                                                                      profileShareLogLIst[
                                                                              index]
                                                                          .shareTime,
                                                                      TextAlign
                                                                          .center,
                                                                      new Color(
                                                                          ColorValues
                                                                              .BLUE_COLOR),
                                                                      15.0,
                                                                      FontWeight
                                                                          .normal)),
                                                            ],
                                                          ),
                                                          flex: 1,
                                                        ),
                                                        new Expanded(
                                                          child: new Column(
                                                            children: <Widget>[
                                                              TextViewWrap
                                                                  .textViewSingleLine(
                                                                      "Status",
                                                                      TextAlign
                                                                          .center,
                                                                      Colors
                                                                          .black,
                                                                      15.0,
                                                                      FontWeight
                                                                          .bold),
                                                              PaddingWrap.paddingAll(
                                                                  5.0,
                                                                  TextViewWrap.textViewSingleLine(
                                                                      profileShareLogLIst[index].isViewed ==
                                                                              "true"
                                                                          ? "Viewed"
                                                                          : "Unviewed",
                                                                      TextAlign
                                                                          .center,
                                                                      new Color(
                                                                          ColorValues
                                                                              .BLUE_COLOR),
                                                                      15.0,
                                                                      FontWeight
                                                                          .normal)),
                                                            ],
                                                          ),
                                                          flex: 1,
                                                        ),
                                                      ],
                                                    ))),
                                          ],
                                        ),
                                      )),
                                  new Positioned(
                                      top: 0.0,
                                      left: 0.0,
                                      child: new Container(
                                        width: 100.0,
                                        height: 120.0,
                                        color: Colors.grey[200],
                                        child: PaddingWrap.paddingAll(
                                            10.0,
                                            FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              placeholder:
                                                  'assets/profile/user_on_user.png',
                                              image: Constant.IMAGE_PATH_SMALL +
                                                  ParseJson.getSmallImage(
                                                      profileShareLogLIst[index]
                                                          .shareToprofilePicture),
                                            )),
                                      )),
                                ])));
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
                "No Sharing Log Yet.",
                TextAlign.left,
                Colors.black,
                20.0,
                FontWeight.bold),

          ],),
    )));
  }
}
