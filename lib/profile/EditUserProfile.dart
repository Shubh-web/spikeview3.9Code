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
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const kGoogleApiKey = "AIzaSyBmHbr9LxE6t5TbTriu_Vkgd8BdFU8A67w";

// to get places detail (lat/lng)
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// Create a Form Widget
class EditUserProfile extends StatefulWidget {
  ProfileInfoModal profileInfoModal;

  EditUserProfile(this.profileInfoModal);

  @override
  EditUserProfileState createState() {
    return new EditUserProfileState(profileInfoModal);
  }
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class EditUserProfileState extends State<EditUserProfile> {
  EditUserProfileState(this.profileInfoModal);

  int groupValue = 0;
  SharedPreferences prefs;
  String userIdPref, token;
  bool isAddMore = false;
  bool isCCReq = false;
  bool isReqParent = false;
  String isGender = "Female";
  String isMostCloselyIdentified = "Female";
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController,
      lastNameController,
      titleController,
      mobileController,
      add1Controller,
      add2Controller,
      cityController,
      stateController,
      zipController,
      countryController,
      addEmailController,
      tagLineController,
      dobController;
  int strDateOfBirth;
  String strFirstName = "",
      strTitle = "",
      strMobile,
      strLastName = "",
      strEmmail,
      strAdd1,
      strAdd2,
      strCity,
      strState,
      strZipcode,
      strCountry,
      strTagline,
      strAddEmail;
  ProfileInfoModal profileInfoModal;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  bool isName(String em) {
    /*  String emailRegexp =
        r'^([a-zA-Z])$';


    RegExp(r"^[a-zA-Z]+$").hasMatch(em)


    RegExp regExp = RegExp(emailRegexp);
ToastWrap.showToast(regExp.hasMatch(em).toString());*/

    return RegExp(r"^[a-zA-Z]+$").hasMatch(em);
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
  }

  //--------------------------Api Calling ------------------
  Future apiCallingForEdit() async {
    try {
      CustomProgressLoader.showLoader(context);
      Response response;
      bool usCitizen = false;
      if (groupValue == 1) usCitizen = true;
      if (addEmailController.text != "") {
        bool isParent = true;
        for (int i = 0; i < profileInfoModal.parentList.length; i++) {
          if (profileInfoModal.parentList[i].email == addEmailController.text) {
            isParent=false;
            break;
          } else {}

        }

        if (isParent) {
          profileInfoModal.parentList
              .add(new ParentModal(addEmailController.text, ""));
        } else {
          ToastWrap.showToast("Email already exist.!");
        }
      }

      Map map = {
        "userId": int.parse(userIdPref),
        "roleId": 1,
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "gender": isMostCloselyIdentified,
        "genderAtBirth": isGender,
        "dob": strDateOfBirth,
        "usCitizenOrPR": usCitizen,
        "parents":
            profileInfoModal.parentList.map((item) => item.toJson()).toList(),
        "address": {
          "street1": add1Controller.text,
          "street2": add2Controller.text,
          "city": cityController.text,
          "state": stateController.text,
          "country": countryController.text,
          "zip": zipController.text
        },
        "requireParentApproval": isReqParent,
        "ccToParents": isCCReq,
        "summary": profileInfoModal.summary,
        "tagline": tagLineController.text,
        "mobileNo": mobileController.text,
        "title": strTitle
      };
      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_PARENT_PERSONAL_INFO, map);
      CustomProgressLoader.cancelLoader(context);
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
  void initState() {
    getSharedPreferences();
    firstNameController = new TextEditingController(
        text: profileInfoModal.firstName == null ||
                profileInfoModal.firstName == "null"
            ? ""
            : profileInfoModal.firstName);
    lastNameController = new TextEditingController(
        text: profileInfoModal.lastName == null ||
                profileInfoModal.lastName == "null"
            ? ""
            : profileInfoModal.lastName);

    titleController = new TextEditingController(
        text: profileInfoModal.title == null || profileInfoModal.title == "null"
            ? ""
            : profileInfoModal.title);
    mobileController = new TextEditingController(
        text:
            profileInfoModal.mobileNo == "0" ? "" : profileInfoModal.mobileNo);
    add1Controller =
        new TextEditingController(text: profileInfoModal.address.street1);
    add2Controller =
        new TextEditingController(text: profileInfoModal.address.street2);
    cityController =
        new TextEditingController(text: profileInfoModal.address.city);
    stateController =
        new TextEditingController(text: profileInfoModal.address.state);
    zipController =
        new TextEditingController(text: profileInfoModal.address.zip);
    countryController =
        new TextEditingController(text: profileInfoModal.address.country);
    addEmailController = new TextEditingController(text: "");
    if (profileInfoModal.gender != null &&
        profileInfoModal.gender != "null" &&
        profileInfoModal.gender != "") {
      isMostCloselyIdentified = profileInfoModal.gender;
    }
    if (profileInfoModal.genderAtBirth != null &&
        profileInfoModal.genderAtBirth != "null" &&
        profileInfoModal.genderAtBirth != "") {
      isGender = profileInfoModal.genderAtBirth;
    }

    if (profileInfoModal.requireParentApproval == "true") isReqParent = true;

    if (profileInfoModal.ccToParents == "true") isCCReq = true;

    if (profileInfoModal.usCitizenOrPR == "true") groupValue = 1;

    tagLineController =
        new TextEditingController(text: profileInfoModal.tagline=="null"?"":profileInfoModal.tagline);
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(profileInfoModal.dob));
    dobController = new TextEditingController(
        text: new DateFormat("dd-MM-yyyy").format(date));
    strDateOfBirth = int.parse(profileInfoModal.dob);
    isMostCloselyIdentified = profileInfoModal.gender;
    isGender = profileInfoModal.genderAtBirth;
    super.initState();
  }

  /* bool isName(String em) {
    if(! Pattern.matches(".*[a-zA-Z]+.*", str1))
      return true;
    else return false;


    String emailRegexp = r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]';
    RegExp regExp = RegExp(emailRegexp);

    print("ismatch:-"+regExp.hasMatch(em).toString());
    return regExp.hasMatch(em);
  }
*/
  Mode _mode = Mode.overlay;

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
      maxLength: 20,
      controller: firstNameController,
      decoration: new InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          counterText: "",
          hintText: "First Name",
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey[300],
          ))),
      validator: (val) =>
          !isName(val) ? 'Please enter valid first name.' : null,
      onSaved: (val) => strFirstName = val,
    ));

    final lastNameui = new Container(
        child: new TextFormField(
      keyboardType: TextInputType.text,
      maxLength: 20,
      controller: lastNameController,
      decoration: new InputDecoration(
          filled: true,
          hintText: "Last Name",
          fillColor: Colors.transparent,
          counterText: "",
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey[300],
          ))),
      validator: (val) =>
          !isName(val) ? 'Please enter valid  last name.' : null,
      onSaved: (val) => strLastName = val,
    ));

    final titleUi = new Container(
        child: new TextFormField(
      keyboardType: TextInputType.text,
      controller: titleController,
      maxLength: 50,
      decoration: new InputDecoration(
          filled: true,
          hintText: "Title",
          fillColor: Colors.transparent,
          counterText: "",
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey[300],
          ))),
      validator: (val) => val.isEmpty ? 'Please enter title.' : null,
      onSaved: (val) => strTitle = val,
    ));
    final mobile = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          maxLength: 15,
          keyboardType: TextInputType.number,
          controller: mobileController,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Mobile Number",
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strMobile = val,
        ));

    final add1 = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new InkWell(
          child: new TextFormField(
            keyboardType: TextInputType.text,
            controller: add1Controller,
            enabled: false,
            decoration: new InputDecoration(
              filled: true,
              hintText: "Street Adress Line1",
              hintStyle: new TextStyle(color: Colors.grey),
              fillColor: Colors.transparent,
              border: InputBorder.none,
            ),
            onSaved: (val) => strAdd1 = val,
          ),
          onTap: () {
            _handlePressButton();
          },
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
            hintText: "City",
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
            hintText: "State",
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
            hintText: "Zipcode",
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
            hintText: "Country",
            fillColor: Colors.transparent,
            border: InputBorder.none,
          ),
          onSaved: (val) => strCountry = val,
        ));
    final tagline = new Container(
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          maxLength: 100,
          controller: tagLineController,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Enter Tagline",
            fillColor: Colors.transparent,
            counterText: "",
            border: InputBorder.none,
          ),
          onSaved: (val) => strTagline = val.trim(),
        ));

    final addMoreEmail = new Container(
        child: new TextFormField(
      keyboardType: TextInputType.text,
      controller: addEmailController,
      decoration: new InputDecoration(
          filled: true,
          hintText: "parent@yourmail.com",
          hintStyle: new TextStyle(color: Colors.grey),
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey[300],
          ))),
      validator: (val) =>
          val.length > 0 ? !isEmail(val) ? 'Please enter email.' : null : null,
    ));

    Padding getGenderUi() {
      return PaddingWrap.paddingAll(
          5.0,
          new Row(
            children: <Widget>[
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/female.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Female", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isGender == "Female"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  25.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isGender = "Female";
                      setState(() {
                        isGender;
                      });
                    },
                  )),
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/male.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Male", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isGender == "Male"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  25.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isGender = "Male";
                      setState(() {
                        isGender;
                      });
                    },
                  )),
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/non_binary.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Non-Binary", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isGender == "Non-Binary"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  15.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isGender = "Non-Binary";
                      setState(() {
                        isGender;
                      });
                    },
                  )),
            ],
          ));
    }

    Padding getMostCloselyidentifiedUi() {
      return PaddingWrap.paddingAll(
          5.0,
          new Row(
            children: <Widget>[
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/female.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Female", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isMostCloselyIdentified == "Female"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  25.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isMostCloselyIdentified = "Female";
                      setState(() {
                        isMostCloselyIdentified;
                      });
                    },
                  )),
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/male.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Male", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isMostCloselyIdentified == "Male"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  25.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isMostCloselyIdentified = "Male";
                      setState(() {
                        isMostCloselyIdentified;
                      });
                    },
                  )),
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/non_binary.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("Non-Binary", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isMostCloselyIdentified == "Non-Binary"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  15.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isMostCloselyIdentified = "Non-Binary";
                      setState(() {
                        isMostCloselyIdentified;
                      });
                    },
                  )),
              new Container(
                  height: 80.0,
                  width: 80.0,
                  child: new InkWell(
                    child: new Stack(children: <Widget>[
                      new Column(children: <Widget>[
                        new Image.asset(
                          "assets/profile/user/na.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        getTextLabel("NA", 13.0, new Color(0XFFA8B3B9),
                            FontWeight.normal),
                      ]),
                      isMostCloselyIdentified == "NA"
                          ? new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  25.0,
                                  0.0,
                                  new Image.asset(
                                    "assets/profile/user/tick.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )))
                          : new Container()
                    ]),
                    onTap: () {
                      isMostCloselyIdentified = "NA";
                      setState(() {
                        isMostCloselyIdentified;
                      });
                    },
                  )),
            ],
          ));
    }

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
            firstNameController.text = firstNameController.text.trim();
            lastNameController.text = lastNameController.text.trim();
            titleController.text = titleController.text.trim();
            mobileController.text = mobileController.text.trim();
            add1Controller.text = add1Controller.text.trim();
            add2Controller.text = add2Controller.text.trim();
            cityController.text = cityController.text.trim();
            stateController.text = stateController.text.trim();
            zipController.text = zipController.text.trim();
            countryController.text = countryController.text.trim();
            addEmailController.text = addEmailController.text.trim();
            tagLineController.text = tagLineController.text.trim();

            form.save();
            if (form.validate()) {
              apiCallingForEdit();
            }
          },
        ));

    Future<Null> selectDob(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.parse("1800-01-01"),
        lastDate: new DateTime.now(),
      );
      if (picked != null) {
        strDateOfBirth = picked.millisecondsSinceEpoch;
        String date = new DateFormat("dd-MM-yyyy").format(picked);
        String date2 = new DateFormat("yyyy-MM-dd").format(picked);
        print(date);
        setState(() {
          dobController = new TextEditingController(text: date);
        });
      }
    }

    final dateOBUI = new InkWell(
        child: new Container(
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.grey[300])),
            child: new TextField(
              keyboardType: TextInputType.text,
              controller: dobController,
              decoration: new InputDecoration(
                enabled: false,
                hintText: "Date Of Birth",
                labelStyle: new TextStyle(
                    fontSize: 12.0, color: const Color(0xFF757575)),
                prefixIcon: new GestureDetector(
                    child: new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: new Icon(
                    Icons.calendar_today,
                    size: 25.0,
                  ),
                )),
              ),
            )),
        onTap: () {
          setState(() {
            selectDob(context);
          });
        });

    void ownerTypeSelection(int a) {
      print("Button click here");
      setState(() {
        switch (a) {
          case 0:
            groupValue = 0;

            break;

          case 1:
            groupValue = 1;

            break;
        }
      });
    }

    Row radiobtnForUsCitiZen() {
      return new Row(children: <Widget>[
        new Radio(
          activeColor: new Color(ColorValues.BLUE_COLOR),
          onChanged: (int a) => ownerTypeSelection(a),
          value: 1,
          groupValue: groupValue,
        ),
        new Text("Yes"),
        new Padding(
          padding: new EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
          child: new Radio(
            value: 0,
            activeColor: new Color(ColorValues.BLUE_COLOR),
            onChanged: (int a) => ownerTypeSelection(a),
            groupValue: groupValue,
          ),
        ),
        new Text("No"),
      ]);
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            key: homeScaffoldKey,
            appBar: new AppBar(
              titleSpacing: 2.0,
              brightness: Brightness.light,
              title: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    "EDIT PERSONAL INFORMATION",
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
                                              2.0,
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
                                              2.0,
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
                                              2.0,
                                              getTextLabel(
                                                  "Title",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          titleUi,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              2.0,
                                              getTextLabel(
                                                  "Date Of Birth",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          dateOBUI,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              2.0,
                                              getTextLabel(
                                                  "Mobile",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          mobile,
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              2.0,
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
                                                        2.0,
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
                                                        2.0,
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
                                                        2.0,
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
                                                        2.0,
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
                                          ),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "With what gender do you most closely identified",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          getMostCloselyidentifiedUi(),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "What gender were you assigned at birth",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          getGenderUi(),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "Are you US citizen or permanent resident?",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          radiobtnForUsCitiZen(),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              0.0,
                                              getTextLabel(
                                                  "Parent Email (Optional)",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          new Column(
                                              children: new List.generate(
                                                  profileInfoModal.parentList
                                                      .length, (int index) {
                                            return PaddingWrap.paddingfromLTRB(
                                                0.0,
                                                5.0,
                                                0.0,
                                                5.0,
                                                new Container(
                                                    decoration:
                                                        new BoxDecoration(
                                                            border: new Border
                                                                    .all(
                                                                color:
                                                                    Colors.grey[
                                                                        300])),
                                                    child: new TextFormField(
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          new TextEditingController(
                                                              text: profileInfoModal
                                                                  .parentList[
                                                                      index]
                                                                  .email),
                                                      enabled: false,
                                                      decoration:
                                                          new InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey[200],
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    )));
                                          })),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              0.0,
                                              0.0,
                                              2.0,
                                              new InkWell(
                                                child: getTextLabel(
                                                    "Add More Email",
                                                    16.0,
                                                    new Color(0XFFA8B3B9),
                                                    FontWeight.normal),
                                                onTap: () {
                                                  isAddMore = true;
                                                  setState(() {
                                                    isAddMore;
                                                  });
                                                },
                                              )),
                                          isAddMore
                                              ? addMoreEmail
                                              : new Container(),
                                          PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              15.0,
                                              0.0,
                                              2.0,
                                              getTextLabel(
                                                  "Tagline",
                                                  16.0,
                                                  new Color(0XFFA8B3B9),
                                                  FontWeight.normal)),
                                          tagline,
                                          new Row(
                                            children: <Widget>[
                                              PaddingWrap.paddingAll(
                                                  0.0,
                                                  new SizedBox(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      child: new Theme(
                                                          data: new ThemeData(
                                                            unselectedWidgetColor:
                                                                Color(
                                                                    0xFFABB9D7),
                                                          ),
                                                          child: new Checkbox(
                                                            value: isCCReq,
                                                            onChanged:
                                                                (bool value) {
                                                              if (isCCReq)
                                                                isCCReq = false;
                                                              else
                                                                isCCReq = true;

                                                              setState(() {
                                                                isCCReq;
                                                              });
                                                            },
                                                          )))),
                                              new Text(
                                                  "CC required for parents"),
                                            ],
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              PaddingWrap.paddingAll(
                                                  0.0,
                                                  new SizedBox(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      child: new Theme(
                                                          data: new ThemeData(
                                                            unselectedWidgetColor:
                                                                Color(
                                                                    0xFFABB9D7),
                                                          ),
                                                          child: new Checkbox(
                                                            value: isReqParent,
                                                            onChanged:
                                                                (bool value) {
                                                              if (isReqParent)
                                                                isReqParent =
                                                                    false;
                                                              else
                                                                isReqParent =
                                                                    true;

                                                              setState(() {
                                                                isReqParent;
                                                              });
                                                            },
                                                          )))),
                                              new Text(
                                                  "Require parent approval"),
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

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      components: [
        Component(Component.country, "ind"),
        Component(Component.country, "uk")
      ],
    );

    displayPrediction(p, homeScaffoldKey.currentState);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;

      final lng = detail.result.geometry.location.lng;
      List<String> s = p.description.split(",");
      //Locale locale = p.getLocale();

      print("addres:-" + s.last);
      print("addres:-" + s.toString());
      print("addres:-" + p.description);
      final coordinates = new Coordinates(lat, lng);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${first.coordinates} : ${first.thoroughfare}");
      print("${first.addressLine} : ${first.adminArea}");
      print("${first.countryName} : ${first.postalCode}");
      print("${first.locality} : ${first.subLocality}");
      print("${first.adminArea} : ${first.subAdminArea}");
      setState(() {
        add1Controller.text =
            first.addressLine != null && first.addressLine != "null"
                ? first.addressLine
                : "";
        add2Controller.text =
            first.subLocality != null && first.subLocality != "null"
                ? first.subLocality
                : "";
        cityController.text =
            first.subAdminArea != null && first.subAdminArea != "null"
                ? first.subAdminArea
                : "";
        stateController.text =
            first.adminArea != null && first.adminArea != "null"
                ? first.adminArea
                : "";
        countryController.text =
            first.countryName != null && first.countryName != "null"
                ? first.countryName
                : "";
        zipController.text =
            first.postalCode != null && first.postalCode != "null"
                ? first.postalCode
                : "";
      });
      /*  scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );*/
    }
  }
}
