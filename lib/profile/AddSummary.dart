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
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class AddSummary extends StatefulWidget {
  String title, summary = "";

  AddSummary(this.title, this.summary);

  @override
  AddSummaryState createState() {
    return new AddSummaryState();
  }
}

class AddSummaryState extends State<AddSummary> {
  SharedPreferences prefs;
  String userIdPref, token, summary = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController addSummary;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
  }

  //--------------------------Api Calling ------------------
  Future apiCalling() async {
    try {
      CustomProgressLoader.showLoader(context);
      Response response;

      Map map = {"summary": addSummary.text, "userId": userIdPref};
      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_USER_COVER_PHOTO_UPDATE, map);
      CustomProgressLoader.cancelLoader(context);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            Navigator.pop(context, addSummary.text);
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
    addSummary = new TextEditingController(
        text: widget.summary != "null" ? widget.summary : "");
    setState(() {
      addSummary;
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above

    final skillUi = new Container(
        /*  decoration:
        new BoxDecoration(border: new Border(bottom: new BorderSide(color: Colors.black54))),
     */
        child: new InkWell(
      child: new TextFormField(
        maxLines: null,
        maxLength: 500,
        controller: addSummary,
        keyboardType: TextInputType.multiline,
        decoration: new InputDecoration(
          filled: true,
          labelText: "Enter Summary",
          fillColor: Colors.transparent,
        ),
      ),
      onTap: () {},
    ));
    return new Scaffold(
        appBar: new AppBar(
          titleSpacing: 2.0,
          brightness: Brightness.light,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[new Text(widget.title)],
          ),
        ),
        body: new Stack(
          children: <Widget>[
            new Positioned(
                bottom: 50.0, right: 0.0, left: 0.0, top: 0.0, child: skillUi),
            new Positioned(
                bottom: 0.0,
                right: 0.0,
                left: 0.0,
                child: new Container(
                    height: 50.0,
                    child: new FlatButton(
                        color: Colors.blue,
                        onPressed: () {
                          addSummary.text=addSummary.text.trim();
                          if (addSummary.text != "") apiCalling();
                          else
                            ToastWrap.showToast("write something..");
                        },
                        child: new Text(
                          "Save",
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0),
                        ))))
          ],
        ));
  }
}
