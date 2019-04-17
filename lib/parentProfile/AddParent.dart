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
class AddParent extends StatefulWidget {
  String title;

  AddParent(this.title);

  @override
  AddParentState createState() {
    return new AddParentState();
  }
}

class AddParentState extends State<AddParent> {
  SharedPreferences prefs;
  String userIdPref, token;
  final _formKey = GlobalKey<FormState>();

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
  }

  String strFirstName, strLastName, strEmail;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  //--------------------------Api Calling ------------------
  Future apiCalling() async {
    try {
      CustomProgressLoader.showLoader(context);
      Response response;

      Map map = {
        "roleId": 2,
        "firstName": strFirstName,
        "lastName": strLastName,
        "email": strEmail.toLowerCase(),
        "partnerId": userIdPref
      };
      response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_PARENT_ADD, map);
      CustomProgressLoader.cancelLoader(context);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            Navigator.pop(context, "push");
          }else{
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

    final firstName = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 20,
          decoration: new InputDecoration(
            filled: true,
            hintText: "First Name",counterText: "",
            hintStyle: new TextStyle(color:  new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'can\'t be empty.' : null,
          onSaved: (val) => strFirstName = val,
        ));

    final lastName = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 15,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Last Name",counterText: "",
            hintStyle: new TextStyle(color:  new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),

          onSaved: (val) => strLastName = val,
        ));

    final email = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Email Name",
            hintStyle: new TextStyle(color:  new Color(0XFFB1B4C0)),
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => !isEmail(val) ? 'Not a valid email.' : null,
          onSaved: (val) => strEmail = val,
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
                children: <Widget>[           new Text(widget.title,style: new TextStyle(color: new Color(0XFF58616D)),)],)



   ,automaticallyImplyLeading: false,
              backgroundColor: new Color(0XFFF3F3F3),
              actions: <Widget>[ new InkWell(child:new Image.asset(
                "assets/profile/parent/p_cros.png",
               height: 30.0,width: 30.0,
              ),onTap: (){
                Navigator.pop(context);
              },)],
            ),
            body: new Theme(
                data: new ThemeData(hintColor: Colors.grey[300]),
                child:new Stack(children: <Widget>[ new Positioned(
                bottom: 80.0,
                  right: 0.0,
                  left: 0.0,
                  top: 0.0,child: ListView(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: PaddingWrap.paddingAll(10.0,new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              getTextLabel("First Name", 16.0, new Color(0XFFB1B4C0),
                                  FontWeight.normal)),
                          firstName,
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              getTextLabel("Last Name", 16.0,  new Color(0XFFB1B4C0),
                                  FontWeight.normal)),
                          lastName,
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              getTextLabel("Email", 16.0,  new Color(0XFFB1B4C0),
                                  FontWeight.normal)),
                          email,

                        ]),
                      ),
                    )
                  ],
                ),
                ), new Positioned(
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
                    ))],))));
  }
}
