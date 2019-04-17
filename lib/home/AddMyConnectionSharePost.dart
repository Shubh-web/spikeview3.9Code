import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class AddMyConnectionSharePost extends StatefulWidget {
  String title;
  AddMyConnectionSharePost(this.title);
  @override
  AddMyConnectionSharePostState createState() {
    return new AddMyConnectionSharePostState();
  }
}

class AddMyConnectionSharePostState extends State<AddMyConnectionSharePost> {
  List<TagModel> tagList = new List();
  List<String> selectedUerId=new List();
  SharedPreferences prefs;
  BuildContext context;
  String userIdPref, userProfilePath;

  //--------------------------api Calling for tag------------------
  Future apiCallingForTag() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_USER_CONNECTION_LIST + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            tagList =
                ParseJson.parseTagList(response.data['result']['Accepted']);
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
    this.context = context;

    onTapOkBtn(){
      for(int i=0;i<tagList.length;i++){
        if(tagList[i].isSelected)
          selectedUerId.add(tagList[i].userId);
      }
      Navigator.pop(context,selectedUerId);
    }
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
                  widget.title,
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
            body: new Stack(
              children: <Widget>[
                new Positioned(
                    bottom: 50.0,
                    right: 0.0,
                    left: 0.0,
                    top: 0.0,
                    child: new ListView.builder(
                        itemCount: tagList.length,
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
                                                    tagList[position]
                                                        .profilePicture),
                                          )),
                                    ),
                                    flex: 0,
                                  ),
                                  new Expanded(
                                      child: PaddingWrap.paddingAll(
                                          5.0,
                                          TextViewWrap.textView(
                                              tagList[position].lastName ==
                                                          "" ||
                                                      tagList[position]
                                                              .lastName ==
                                                          "null"
                                                  ? tagList[position].firstName
                                                  : tagList[position]
                                                          .firstName +
                                                      " " +
                                                      tagList[position]
                                                          .lastName,
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
                                                    unselectedWidgetColor:
                                                        Color(0xFFABB9D7),
                                                  ),
                                                  child: new Checkbox(
                                                    value: tagList[position]
                                                        .isSelected,
                                                    onChanged: (bool value) {
                                                      if (tagList[position]
                                                          .isSelected)
                                                        tagList[position]
                                                            .isSelected = false;
                                                      else
                                                        tagList[position]
                                                            .isSelected = true;

                                                      setState(() {
                                                        tagList[position]
                                                            .isSelected;
                                                      });
                                                    },
                                                  )))),
                                      flex: 0),
                                ],
                              ));
                        })),
                new Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    left: 0.0,
                    child: new Container(
                        height: 50.0,
                        child: new FlatButton(
                            color: new Color(ColorValues.BLUE_COLOR),
                            onPressed: () {
                              onTapOkBtn();
                            },
                            child: new Text(
                              "OK",
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0),
                            ))))
              ],
            )));
  }
}
