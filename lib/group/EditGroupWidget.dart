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
import 'package:spike_view_project/group/model/GroupDetailModel.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class EditGroupWidget extends StatefulWidget {
  GroupDetailModel groupDetailModel;

  EditGroupWidget(this.groupDetailModel);

  @override
  EditGroupWidgetState createState() {
    return new EditGroupWidgetState();
  }
}

class EditGroupWidgetState extends State<EditGroupWidget> {
  SharedPreferences prefs;
  String userIdPref, token;
  final _formKey = GlobalKey<FormState>();

  TextEditingController txtNameController,
      txtAboutController,
      txtOtherController;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
  }

  String strGroupName, strAbout, strOtherInfo;
  bool isPrivate = false;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  //--------------------------Api Calling ------------------
  Future apiCalling() async {
    try {
      Response response;

      String type = "public";
      if (isPrivate) type = "private";

      Map map = {
        "groupId": int.parse(widget.groupDetailModel.groupId),
        "groupName": strGroupName,
        "aboutGroup": strAbout,
        "otherInfo": strOtherInfo,
        "type": type
      };
      response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_UPDATE_GROUP, map);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            Navigator.pop(context, "push");
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
    getSharedPreferences();

    txtAboutController =
        new TextEditingController(text: widget.groupDetailModel.aboutGroup);
    txtNameController =
        new TextEditingController(text: widget.groupDetailModel.groupName);
    txtOtherController =
        new TextEditingController(text: widget.groupDetailModel.otherInfo);

    if (widget.groupDetailModel.type == "public")
      isPrivate = false;
    else
      isPrivate = true;

    setState(() {
      isPrivate;
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    Text getTextLabel(txt, size, color, fontWeight) {
      return new Text(
        txt,
        style:
            new TextStyle(fontSize: size, color: color, fontWeight: fontWeight),
      );
    }

    final groupName = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: txtNameController,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Group Name",
            hintStyle: new TextStyle(color: new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'Please enter group name.' : null,
          onSaved: (val) => strGroupName = val,
        ));

    final aboutGroupUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: txtAboutController,
          maxLines: 4,
          decoration: new InputDecoration(
            filled: true,
            hintText: "About Group",
            hintStyle: new TextStyle(color: new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'Please enter group motive' : null,
          onSaved: (val) => strAbout = val,
        ));

    final otherInfoUi = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: txtOtherController,
          maxLines: 4,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Example: Group Policies",
            hintStyle: new TextStyle(color: new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strOtherInfo = val,
        ));

    void _checkValidation() async {
      final form = _formKey.currentState;
      form.save();
      if (form.validate()) {
        try {
          apiCalling();
        } catch (e) {
          CustomProgressLoader.cancelLoader(context);
        }
      } else {
        print("Failure 00");
      }
    }

    final submitButton = Padding(
        padding:
            new EdgeInsets.only(left: 0.0, top: 30.0, right: 0.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: _checkValidation,
              color: new Color(ColorValues.BLUE_COLOR),
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('SAVE ',
                      style: TextStyle(
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));

    final cancelButton = Padding(
        padding:
            new EdgeInsets.only(left: 5.0, top: 30.0, right: 0.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: () {},
              color: Colors.red,
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('DELETE ',
                      style: TextStyle(
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));

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
                    "EDIT GROUP",
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
            body: new Theme(
                data: new ThemeData(hintColor: Colors.grey[300]),
                child: new Stack(
                  children: <Widget>[
                    new Positioned(
                      bottom: 80.0,
                      right: 0.0,
                      left: 0.0,
                      top: 0.0,
                      child: ListView(
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: PaddingWrap.paddingAll(
                              10.0,
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        15.0,
                                        0.0,
                                        0.0,
                                        getTextLabel(
                                            "Group Name",
                                            16.0,
                                            new Color(0XFFB1B4C0),
                                            FontWeight.normal)),
                                    groupName,
                                    PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        15.0,
                                        0.0,
                                        0.0,
                                        getTextLabel(
                                            "About Group",
                                            16.0,
                                            new Color(0XFFB1B4C0),
                                            FontWeight.normal)),
                                    aboutGroupUi,
                                    PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        15.0,
                                        0.0,
                                        0.0,
                                        getTextLabel(
                                            "Other Information",
                                            16.0,
                                            new Color(0XFFB1B4C0),
                                            FontWeight.normal)),
                                    otherInfoUi,
                                    PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        10.0,
                                        0.0,
                                        0.0,
                                        new Row(
                                          children: <Widget>[
                                            PaddingWrap.paddingfromLTRB(
                                                0.0,
                                                0.0,
                                                5.0,
                                                0.0,
                                                TextViewWrap.textView(
                                                    "Public  ",
                                                    TextAlign.start,
                                                    new Color(
                                                        ColorValues.BLUE_COLOR),
                                                    14.0,
                                                    FontWeight.normal)),
                                            isPrivate
                                                ? new GestureDetector(
                                                    onHorizontalDragEnd:
                                                        (DragEndDetails
                                                            details) {
                                                      setState(() {
                                                        isPrivate = false;
                                                      });
                                                    },
                                                    child: new Center(
                                                        child: new Padding(
                                                            padding:
                                                                new EdgeInsets
                                                                        .fromLTRB(
                                                                    0.0,
                                                                    0.0,
                                                                    10.0,
                                                                    0.0),
                                                            child:
                                                                new Image.asset(
                                                              "assets/group/private_toggle.png",
                                                              width: 50.0,
                                                              height: 50.0,
                                                            ))))
                                                : new GestureDetector(
                                                    onHorizontalDragEnd:
                                                        (DragEndDetails
                                                            details) {
                                                      setState(() {
                                                        isPrivate = true;
                                                      });
                                                    },
                                                    child: new Center(
                                                        child: new Padding(
                                                            padding:
                                                                new EdgeInsets
                                                                        .fromLTRB(
                                                                    0.0,
                                                                    0.0,
                                                                    10.0,
                                                                    0.0),
                                                            child:
                                                                new Image.asset(
                                                              "assets/group/public_toggle.png",
                                                              width: 50.0,
                                                              height: 50.0,
                                                            )))),
                                            TextViewWrap.textView(
                                                "Private",
                                                TextAlign.start,
                                                new Color(
                                                    ColorValues.BLUE_COLOR),
                                                14.0,
                                                FontWeight.normal),
                                          ],
                                        )),
                                  ]),
                            ),
                          )
                        ],
                      ),
                    ),
                    new Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        left: 0.0,
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: submitButton,
                              flex: 1,
                            ),
                          ],
                        ))
                  ],
                ))));
  }
}
