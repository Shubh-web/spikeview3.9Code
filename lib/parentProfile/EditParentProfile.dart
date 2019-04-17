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
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class EditParentProfile extends StatefulWidget {
  @override
  EditParentProfileState createState() {
    return new EditParentProfileState();
  }
}

class EditParentProfileState extends State<EditParentProfile> {
  SharedPreferences prefs;
  String userIdPref, token;
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      add1Controller,
      add2Controller,
      cityController,
      stateController,
      zipController,
      countryController;
  String strFirstName,
      strLastName,
      strEmmail,
      strAdd1,
      strAdd2,
      strCity,
      strState,
      strZipcode,
      strCountry;
  ProfileInfoModal profileInfoModal;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    profileApi();
  }

  @override
  void initState() {
    getSharedPreferences();
    firstNameController = new TextEditingController(text: "");
    lastNameController = new TextEditingController(text: "");
    emailController = new TextEditingController(text: "");
    add1Controller = new TextEditingController(text: "");
    add2Controller = new TextEditingController(text: "");
    cityController = new TextEditingController(text: "");
    stateController = new TextEditingController(text: "");
    zipController = new TextEditingController(text: "");
    countryController = new TextEditingController(text: "");
    super.initState();
  }

//--------------------------Profile Info api ------------------
  Future profileApi() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_PERSONAL_INFO + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            profileInfoModal =
                ParseJson.parseMapUserProfile(response.data['result']);
            if (profileInfoModal != null) {
              firstNameController.text = profileInfoModal.firstName;
              lastNameController.text = profileInfoModal.lastName;
              emailController.text = profileInfoModal.email;

              add1Controller.text = profileInfoModal.address.street1;
              add2Controller.text = profileInfoModal.address.street2;
              cityController.text = profileInfoModal.address.city;
              stateController.text = profileInfoModal.address.state;
              zipController.text = profileInfoModal.address.zip;
              countryController.text = profileInfoModal.address.country;

              setState(() {
                firstNameController;
                profileInfoModal;
                add1Controller;
                add2Controller;
                cityController;
                stateController;
                zipController;
                countryController;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Api Calling ------------------
  Future apiCallingForEdit() async {
    try {
      Response response;

      Map map = {
        "userId": int.parse(userIdPref),
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "roleId": 2,
        "isActive": profileInfoModal.isActive,
        "address": {
          "street1": add1Controller.text,
          "street2": add2Controller.text,
          "city": cityController.text,
          "state": stateController.text,
          "country": countryController.text,
          "zip": zipController.text
        }
      };
      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_USER_COVER_PHOTO_UPDATE, map);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            Navigator.pop(context, "push");
          }
        }
      }
    } catch (e) {
      e.toString();
    }
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

    final firnameUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: firstNameController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'Please enter first name.' : null,
          onSaved: (val) => strFirstName = val,
        ));

    final lastNameui = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: lastNameController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'Please enter last name.' : null,
          onSaved: (val) => strFirstName = val,
        ));

    final email = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: emailController,
          enabled: false,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: InputBorder.none,
          ),
          onSaved: (val) => strFirstName = val,
        ));

    final add1 = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: add1Controller,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Street Adress Line1",
            hintStyle: new TextStyle(color: Colors.grey),
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strAdd1 = val,
        ));

    final add2 = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: add2Controller,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Street Adress Line2",
            hintStyle: new TextStyle(color: Colors.grey),
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strAdd2 = val,
        ));

    final city = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: cityController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strCity = val,
        ));

    final state = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: stateController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strState = val,
        ));

    final zipcode = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: zipController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strZipcode = val,
        ));

    final country = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          controller: countryController,
          decoration: new InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strCountry = val,
        ));
    final submitButton = PaddingWrap.paddingfromLTRB(
        0.0,
        10.0,
        0.0,
        0.0,
        new FlatButton(
          color: new Color(ColorValues.BLUE_COLOR),
          child: new Container(
            height: 50.0,
            width: double.infinity,
            child: new Center(
                child: new Text(
              "Save",
              style: new TextStyle(color: Colors.white),
            )),
          ),
          onPressed: () {
            final form = _formKey.currentState;
            form.save();
            if (form.validate()) {
              apiCallingForEdit();
            }
          },
        ));
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
                    "EDIT PROFILE",
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
            body: new Theme(
                data: new ThemeData(hintColor: Colors.grey[300]),
                child: Form(
                    key: _formKey,
                    child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            bottom: 50.0,
                            left: 0.0,
                            top: 0.0,
                            right: 0.0,
                            child: new ListView(
                              children: <Widget>[
                                PaddingWrap.paddingAll(
                                    10.0,
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "First Name",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          firnameUi,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "Last Name ",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          lastNameui,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "Email",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          email,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "Address",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          add1,
                                          PaddingWrap.paddingfromLTRB(
                                            0.0,
                                            10.0,
                                            0.0,
                                            0.0,
                                            add2,
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        15.0,
                                                        0.0,
                                                        0.0,
                                                        getTextLabel(
                                                            "City",
                                                            16.0,
                                                            new Color(
                                                                0XFFA8B3B9),
                                                            FontWeight.normal)),
                                                    city,
                                                  ],
                                                ),
                                                flex: 1,
                                              ),
                                              new Expanded(
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        15.0,
                                                        0.0,
                                                        0.0,
                                                        getTextLabel(
                                                            "State",
                                                            16.0,
                                                            new Color(
                                                                0XFFA8B3B9),
                                                            FontWeight.normal)),
                                                    state,
                                                  ],
                                                ),
                                                flex: 1,
                                              )
                                            ],
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        15.0,
                                                        0.0,
                                                        0.0,
                                                        getTextLabel(
                                                            "Zipcode",
                                                            16.0,
                                                            new Color(
                                                                0XFFA8B3B9),
                                                            FontWeight.normal)),
                                                    zipcode,
                                                  ],
                                                ),
                                                flex: 1,
                                              ),
                                              new Expanded(
                                                child: new Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    PaddingWrap.paddingfromLTRB(
                                                        0.0,
                                                        15.0,
                                                        0.0,
                                                        0.0,
                                                        getTextLabel(
                                                            "Country",
                                                            16.0,
                                                            new Color(
                                                                0XFFA8B3B9),
                                                            FontWeight.normal)),
                                                    country,
                                                  ],
                                                ),
                                                flex: 1,
                                              )
                                            ],
                                          )
                                        ]))
                              ],
                            )),
                        new Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: submitButton),
                      ],
                    )))));
  }
}
