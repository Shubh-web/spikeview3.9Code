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
import 'package:spike_view_project/modal/TagModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class LikeDetailWidget extends StatefulWidget {
  List<Likes> likesList;

  LikeDetailWidget(this.likesList);

  @override
  LikeDetailWidgetState createState() {
    return new LikeDetailWidgetState(likesList);
  }
}

class LikeDetailWidgetState extends State<LikeDetailWidget> {
  List<Likes> likesList;
  SharedPreferences prefs;
  BuildContext context;
  String userIdPref, userProfilePath;

  LikeDetailWidgetState(this.likesList);

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    userProfilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
  }

  @override
  void initState() {
    getSharedPreferences();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    // Build a Form widget using the _formKey we created above
    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            backgroundColor: new Color(0XFFF7F7F9),
            appBar: new AppBar(
              titleSpacing: 2.0,
              brightness: Brightness.light,
              title:

              new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              new Text(
              "LIKED BY",
                style: new TextStyle(color: new Color(0XFF617082)),
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
            body: new ListView.builder(
                itemCount: likesList.length,
                itemBuilder: (BuildContext context, int position) {
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
                                    placeholder:
                                        'assets/profile/user_on_user.png',
                                    image: Constant.IMAGE_PATH_SMALL +
                                        ParseJson.getSmallImage(
                                            likesList[position].profilePicture),
                                  )),
                            ),
                            flex: 0,
                          ),
                          new Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  PaddingWrap.paddingfromLTRB(
                                      5.0,0.0,0.0,2.0,
                                      TextViewWrap.textView(
                                          likesList[position].name,
                                          TextAlign.start,
                                          Colors.black,
                                          18.0,
                                          FontWeight.bold)),
                                  PaddingWrap.paddingfromLTRB(
                                      5.0,0.0,0.0,0.0,
                                      TextViewWrap.textView(
                                          likesList[position].title=="null"?"":likesList[position].title,
                                          TextAlign.start,
                                          Colors.grey,
                                          16.0,
                                          FontWeight.normal)),
                                ],
                              ),
                              flex: 2),
                        ],
                      ));
                })));
  }
}
