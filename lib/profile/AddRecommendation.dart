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
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:image_cropper/image_cropper.dart';

// Create a Form Widget
class AddRecommendationForm extends StatefulWidget {
  List<Level3Competencies> level3Competencylist;
  String strCompetencyTypeId, strcompetencyTypeName;

  AddRecommendationForm(this.level3Competencylist, this.strCompetencyTypeId,
      this.strcompetencyTypeName);

  @override
  AddRecommendationFormState createState() {
    return new AddRecommendationFormState(level3Competencylist);
  }
}

class AddRecommendationFormState extends State<AddRecommendationForm> {
  AddRecommendationFormState(this.level3Competencylist);

  String selectedImageType = "media",
      strPrefixPathforPhoto,
      strAzureImageUploadPath = "";
  final _formKey = GlobalKey<FormState>();
  String strTitle = "",
      strFirstName = "",
      strLastName = "",
      strEmail = "",
      strRecommendationTitle = "",
      strRequest = "";
  List<Assest> assestList = new List();
  File imagePath;
  TextEditingController fromDateController, toDateController;
  List<AcvhievmentSkillModel> skillList = new List();
  List<Level3Competencies> level3Competencylist;
  SharedPreferences prefs;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  Level3Competencies competencySelected;
  List<Skill> skeelSelectedList = new List();
  String sasToken, containerName;
  String userIdPref,
      profilePath,
      userName,
      userEmail,
      token,
      strCompetencyValue = "",
      strFromDate,
      strToDate,
      filterData = "",
      appliedFilter = "";
  Map<int, bool> filterStatus = new Map();
  DateTime fromDate;
  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  //--------------------------SaasToken  api ------------------
  Future callApiForSaas() async {
    try {
      Response response = await new ApiCalling().apiCall(
        context,
        Constant.ENDPOINT_SAS,
        "post",
      );
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            sasToken = response.data['result']['sasToken'];
            containerName = response.data['result']['container'];
            if (containerName != null && containerName != "")
              Constant.CONTAINER_NAME = containerName;
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //-------------------------------------Upload image on Azure --------------------------
  Future<String> uploadImgOnAzure(imagePath, prefixPath) async {
    try {
      if (sasToken != "" && containerName != "") {
        final String result = await platform.invokeMethod('getBatteryLevel', {
          "sasToken": sasToken,
          "imagePath": imagePath,
          "uploadPath": Constant.IMAGE_PATH + prefixPath
        });

        print("image_path" + result);
        return result;
      }
      return "";
    } on Exception catch (e) {
      return "";
    }
  }

//--------------------------Api Call for skills ------------------
  Future apiCallSkill() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_ACHIEVMENT_SKILLS, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            skillList.clear();
            skillList = ParseJson.parseMapSkillList(response.data['result']);
            if (skillList.length > 0) {
              for (int i = 0; i < skillList.length; i++) {
                filterStatus[i] = false;
              }
              setState(() {
                filterStatus;
                skillList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Upload Acchievment Data ------------------

  bool validationCheck() {
    if (strCompetencyValue == "") {
      ToastWrap.showToast("Please select competency.");
      return false;
    } else if (appliedFilter == "") {
      ToastWrap.showToast("Please select skills");
      return false;
    } else if (strFromDate == "") {
      ToastWrap.showToast("Please select date");
      return false;
    } else if (strToDate == "") {
      ToastWrap.showToast("Please select date");
      return false;
    }
    return true;
  }

  Future apiCalling() async {
    try {
      CustomProgressLoader.showLoader(context);
      assestList.removeAt(0);
      Map map = {
        "userId": userIdPref,
        "competencyTypeId": widget.strCompetencyTypeId,
        "level2Competency": widget.strcompetencyTypeName,
        "level3Competency": strCompetencyValue,
        "badge": [],
        "certificate": [],
        "asset": assestList.map((item) => item.toJson()).toList(),
        "skills": skeelSelectedList.map((item) => item.toJson()).toList(),
        "title": strRecommendationTitle,
        "request": strRequest,
        "interactionStartDate": strFromDate,
        "interactionEndDate": strToDate,
        "firstName": strFirstName,
        "lastName": strLastName,
        "email": strEmail,
        "recommendation": "",
        "recommenderId": "",
        "stage": "Requested",
        "name": userName,
        "profileImage": profilePath,
        "requesterEmail": userEmail,
        "recommenderTitle": strTitle
      };

      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_ADD_RECOOMENDATION, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);

            CustomProgressLoader.cancelLoader(context);
            Navigator.pop(context, "push");
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    profilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    userName = prefs.getString(UserPreference.NAME);
    userEmail = prefs.getString(UserPreference.EMAIL);
    token = prefs.getString(UserPreference.USER_TOKEN);

    await apiCallSkill();
    await callApiForSaas();
    strPrefixPathforPhoto = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_MEDIA +
        "/";
  }

  @override
  void initState() {
    getSharedPreferences();
    assestList.add(new Assest("dammy", "dammy", "dammy",false));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMenuCompetency = level3Competencylist
        .map((Level3Competencies item) =>
            new DropdownMenuItem<Level3Competencies>(
                value: item, child: new Text(item.name)))
        .toList();

    //---------------------------------Skill Core Logic nd ui -----------------------
    void iterateFilters(key, value) {
      print('-------------$key:$value'); //string interpolation in action
      if (value) {
        if (key != 0) {
          if (filterData == "") {
            filterData = (key).toString();
            appliedFilter = skillList[key].title;
            skeelSelectedList
                .add(new Skill(skillList[key].title, skillList[key].skillId));
          } else {
            filterData = filterData + "," + (key).toString();
            appliedFilter = appliedFilter + ",\n" + skillList[key].title;
            skeelSelectedList
                .add(new Skill(skillList[key].title, skillList[key].skillId));
          }
        }
      }
    }
    Future<Null> _cropImage(File imageFile) async {
      imagePath = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        ratioX: 1.0,
        ratioY: 1.0,
        maxWidth: 512,
        maxHeight: 512,
      );
    }
    void onApplyClick() {
      filterData = "";
      appliedFilter = "";
      skeelSelectedList.clear();
      filterStatus.forEach(iterateFilters);
      setState(() {
        FocusScope.of(context).requestFocus(new FocusNode());
        appliedFilter;
      });
      Navigator.pop(context);
    }

    void onCancelTap() {
      filterData = "";
      appliedFilter = "";
      skeelSelectedList.clear();
      for (int i = 0; i < filterStatus.length; i++) {
        filterStatus[i] = false;
      }
      setState(() {
        FocusScope.of(context).requestFocus(new FocusNode());
        appliedFilter;
      });
      Navigator.pop(context);
    }

    void getFilters() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new AlertDialog(
              title: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text("Filters"),
                    flex: 4,
                  ),
                  new Expanded(
                    child: new InkWell(
                      child: new Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 30.0,
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.pop(context);
                      },
                    ),
                    flex: 1,
                  )
                ],
              ),
              content: new Container(
                  width: 300.0,
                  child: new ListView.builder(
                      // itemCount: myData.lenght(),
                      shrinkWrap: true,
                      itemCount: skillList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if ((skillList.length - 1) == index) {
                          return new Column(
                            children: <Widget>[
                              new Padding(
                                  padding: new EdgeInsets.all(5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                          child:
                                              new Text(skillList[index].title),
                                          flex: 2),
                                      new Expanded(
                                          child: new SizedBox(
                                              width: 20.0,
                                              height: 20.0,
                                              child: new Checkbox(
                                                value: filterStatus[index],
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    if (index == 0) {
                                                      for (int i = 0;
                                                          i <
                                                              filterStatus
                                                                  .length;
                                                          i++) {
                                                        if (!value)
                                                          filterStatus[i] =
                                                              false;
                                                        else
                                                          filterStatus[i] =
                                                              true;
                                                      }
                                                    } else {
                                                      filterStatus[0] = false;
                                                      filterStatus[index] =
                                                          value;
                                                    }
                                                    FocusScope.of(context).requestFocus(new FocusNode());
                                                    Navigator.pop(context);
                                                    getFilters();
                                                  });
                                                },
                                              )),
                                          flex: 0),
                                    ],
                                  )),
                              new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new Padding(
                                    padding: new EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 10.0),
                                    child: new Container(
                                      color: Colors.white,
                                      alignment: Alignment.bottomRight,
                                      child: new RaisedButton(
                                          color: Color(0Xff4cb050),
                                          elevation: 0.0,
                                          child: new Text(
                                            'Remove',
                                            style: new TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0Xffffffff)),
                                          ),
                                          onPressed: onCancelTap),
                                    ),
                                  )),
                                  new Expanded(
                                      child: new Padding(
                                    padding: new EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 10.0),
                                    child: new Container(
                                      color: Colors.white,
                                      alignment: Alignment.bottomRight,
                                      child: new RaisedButton(
                                          color: Color(0Xff4cb050),
                                          elevation: 0.0,
                                          child: new Text(
                                            'Apply',
                                            style: new TextStyle(
                                                fontSize: 18.0,
                                                color: Color(0Xffffffff)),
                                          ),
                                          onPressed: onApplyClick),
                                    ),
                                  ))
                                ],
                              )
                            ],
                          );
                        } else {
                          return new Padding(
                              padding: new EdgeInsets.all(5.0),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new Text(skillList[index].title),
                                      flex: 2),
                                  new Expanded(
                                      child: new SizedBox(
                                          width: 20.0,
                                          height: 20.0,
                                          child: new Checkbox(
                                            value: filterStatus[index],
                                            onChanged: (bool value) {
                                              setState(() {
                                                if (index == 0) {
                                                  for (int i = 0;
                                                      i < filterStatus.length;
                                                      i++) {
                                                    if (!value)
                                                      filterStatus[i] = false;
                                                    else
                                                      filterStatus[i] = true;
                                                  }
                                                } else {
                                                  filterStatus[0] = false;
                                                  filterStatus[index] = value;
                                                }
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                Navigator.pop(context);
                                                getFilters();
                                              });
                                            },
                                          )),
                                      flex: 0),
                                ],
                              ));
                        }
                      }))));
    }

    final skillUi = new Container(

        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        child: new InkWell(
          child: new TextFormField(
            enabled: false,
            maxLines: null,
            controller: new TextEditingController(text: appliedFilter),
            keyboardType: TextInputType.multiline,
            decoration: new InputDecoration(
              filled: true,
              hintText: "Select skills",
              fillColor: Colors.transparent,
              border: InputBorder.none,
            ),
          ),
          onTap: () {
            setState(() {
              FocusScope.of(context).requestFocus(new FocusNode());
            });
            getFilters();
          },
        ));
//======================================================================================

    final competencyDropDownUi = new Container(
        padding: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        width: double.infinity,
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton<Level3Competencies>(
                hint: new Text(
                  " Select Competency",
                  style: new TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                value: competencySelected,
                items: dropdownMenuCompetency,
                onChanged: (Level3Competencies item) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    competencySelected = item;
                    strCompetencyValue = item.key;
                  });
                })));

    final titleUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(
            filled: true,
            hintText: "Recommender Title",
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => val.trim().isEmpty ? 'Please enter recommender title.' : null,
          onSaved: (val) => strTitle = val.trim(),
        ));

    final firstName = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 20,
          decoration: new InputDecoration(
            filled: true,   hintText: "First Name",
            fillColor: Colors.transparent,counterText: "",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => val.trim().isEmpty ? 'Please enter first name.' : null,
          onSaved: (val) => strFirstName = val.trim(),
        ));
    final lastName = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 20,
          decoration: new InputDecoration(
            filled: true,   hintText: "Last Name",
            fillColor: Colors.transparent,counterText: "",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => val.trim().isEmpty ? 'Please enter last name.' : null,
          onSaved: (val) => strLastName = val.trim(),
        ));

    final email = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: new InputDecoration(
            filled: true,   hintText: "Email",
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => !isEmail(val) ? 'Please enter your email address.' : null,
          onSaved: (val) => strEmail = val,
        ));

    final recommendationTitle = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(
            filled: true,   hintText: "Enter Title",
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => val.trim().isEmpty ? 'Please enter title.' : null,
          onSaved: (val) => strRecommendationTitle = val,
        ));

    final descriptrionUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,
          maxLines: 4,
          decoration: new InputDecoration(
            filled: true,   hintText: "Enter Here",
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300])
              )
          ),
          validator: (val) => val.trim().isEmpty ? 'Please enter request.' : null,
          onSaved: (val) => strRequest = val.trim(),
        ));
    Text getTextLabel(txt, size, color, fontWeight) {
      return new Text(
        txt,
        style:
            new TextStyle(fontSize: size, color: color, fontWeight: fontWeight),
      );
    }

    Future<Null> selectFromDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.parse("1800-01-01"),
        lastDate: new DateTime.now(),
      );

      if (picked != null) {
        fromDate=picked;
        String date = new DateFormat("MM-dd-yyyy").format(picked);
        String date2 = new DateFormat("yyyy-MM-dd").format(picked);
        print(date);
        setState(() {
          strFromDate = (picked.millisecondsSinceEpoch).toString();
          fromDateController = new TextEditingController(text: date);
          toDateController = new TextEditingController(text: "");
        });
      }
    }

    final fromDateUi = new InkWell(
        child: new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.grey[300])),
            child: new TextField(
              keyboardType: TextInputType.text,
              enabled: false,
              controller: fromDateController,
              decoration: new InputDecoration(
                  border: InputBorder.none,hintText: "Date",
                  labelStyle: new TextStyle(
                      fontSize: 12.0, color: const Color(0xFF757575)),
                  suffixIcon: new GestureDetector(
                    child: new Icon(
                      Icons.calendar_today,
                    ),
                  )),
            )),
        onTap: () {
          setState(() {
            FocusScope.of(context).requestFocus(new FocusNode());
            selectFromDate(context);
          });
        });

    Future<Null> selectToDate(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.parse("1800-01-01"),
        lastDate: new DateTime.now(),
      );

      if (picked != null) {
        String date = new DateFormat("MM-dd-yyyy").format(picked);
        String date2 = new DateFormat("yyyy-MM-dd").format(picked);
        print(date);
        var differenceStartDate = picked.difference(fromDate);
        if (differenceStartDate.inDays >= 0) {
          setState(() {
            strToDate = (picked.millisecondsSinceEpoch).toString();
            toDateController = new TextEditingController(text: date);
          });
        }else{
          ToastWrap.showToast("Not a valid date.");
        }
      }
    }

    final toDateUi = new InkWell(
        child: new Container(
            padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            decoration: new BoxDecoration(
                border: new Border.all(color: new Color(0XFFDADBDD))),
            child: new TextField(
              keyboardType: TextInputType.text,
              enabled: false,
              controller: toDateController,
              decoration: new InputDecoration(
                  border: InputBorder.none,hintText: "To",
                  labelStyle: new TextStyle(
                      fontSize: 12.0, color: const Color(0xFF757575)),
                  suffixIcon: new GestureDetector(
                    child: new Icon(
                      Icons.calendar_today,
                    ),
                  )),
            )),
        onTap: () {
          setState(() {
            FocusScope.of(context).requestFocus(new FocusNode());
            if(fromDate!=null){
              selectToDate(context);
            }
            else {
              ToastWrap.showToast("Please select from date.");
            }
          });
        });
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
              if (validationCheck()) {
                apiCalling();
              }
            }
          },
        ));

    //---------------------Add Media View and core logics  ---------------------
    ontapApply() async {
      if (imagePath != null) {
        strAzureImageUploadPath = await uploadImgOnAzure(
            imagePath
                .toString()
                .replaceAll("File: ", "")
                .replaceAll("'", "")
                .trim(),
            strPrefixPathforPhoto);
        setState(() {
          strAzureImageUploadPath;
        });
        CustomProgressLoader.cancelLoader(context);
        print("azureimagepath   :-" + strAzureImageUploadPath);
        if (strAzureImageUploadPath != "" &&
            strAzureImageUploadPath != "false") {
          assestList.add(new Assest("image", selectedImageType,
              strPrefixPathforPhoto + strAzureImageUploadPath,false));

          selectedImageType = "media";
          strAzureImageUploadPath = "";
          imagePath = null;
          Navigator.pop(context);
          setState(() {
            assestList;
            selectedImageType;
            strAzureImageUploadPath;
            imagePath;
          });

          for (int i = 0; i < assestList.length; i++) {
            print("assest$i" + assestList[i].tag + "..." + assestList[i].file);
          }
        }
      }
    }

    //--------------------------------Image Selectedview -------------------------
    Padding isImageSelectedView() {
      return PaddingWrap.paddingfromLTRB(
          15.0,
          25.0,
          15.0,
          20.0,
          new Container(
              width: double.infinity,
              child:
                  new Image.file(imagePath, fit: BoxFit.cover, height: 200.0)));
    }

    final applyButton = Padding(
        padding:
            new EdgeInsets.only(left: 5.0, top: 30.0, right: 5.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed:(){
                CustomProgressLoader.showLoader(context);
                Timer _timer = new Timer(const Duration(milliseconds: 400), () {
                  ontapApply();
                });
              },
              color: new Color(ColorValues.BLUE_COLOR),
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Apply ',
                      style: TextStyle(fontSize: 13.0,
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));

    // Build a Form widget using the _formKey we created above

    void addMediaDialog() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new AlertDialog(
              title: new Container(
                  color: Colors.blue,
                  height: 60.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text(
                          "ADD MEDIA",
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.white),
                        ),
                        flex: 6,
                      ),
                      new Expanded(
                        child: new InkWell(
                          child: new Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 30.0,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        flex: 1,
                      )
                    ],
                  )),
              contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              titlePadding: new EdgeInsets.all(0.0),
              content: new Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      isImageSelectedView(),
                      PaddingWrap.paddingAll(
                          5.0,
                          TextViewWrap.textView(
                              "Select Tag for the image.",
                              TextAlign.start,
                              Colors.black54,
                              16.0,
                              FontWeight.bold)),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Expanded(
                              child: selectedImageType == "media"
                                  ? PaddingWrap.paddingfromLTRB(
                                      5.0,
                                      0.0,
                                      5.0,
                                      0.0,
                                      new InkWell(
                                        child: new Container(
                                            height: 50.0,
                                            color: Colors.blue,
                                            child: new Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Image.asset(
                                                  "assets/profile/media/general.png",
                                                  height: 20.0,
                                                  width: 20.0,
                                                ),
                                                TextViewWrap.textView(
                                                    " General",
                                                    TextAlign.center,
                                                    Colors.white,
                                                    10.0,
                                                    FontWeight.bold),
                                              ],
                                            )),
                                        onTap: () {
                                          selectedImageType = "media";
                                          Navigator.pop(context);
                                          addMediaDialog();
                                        },
                                      ),
                                    )
                                  : PaddingWrap.paddingfromLTRB(
                                      5.0,
                                      0.0,
                                      5.0,
                                      0.0,
                                      new InkWell(
                                        child: new Container(
                                            height: 50.0,
                                            decoration: new BoxDecoration(
                                                border: new Border.all(
                                              color: Colors.grey[300],
                                            )),
                                            child: new Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Image.asset(
                                                  "assets/profile/media/general.png",
                                                  height: 20.0,
                                                  width: 20.0,
                                                ),
                                                TextViewWrap.textView(
                                                    " General",
                                                    TextAlign.center,
                                                    Colors.black,
                                                    10.0,
                                                    FontWeight.bold),
                                              ],
                                            )),
                                        onTap: () {
                                          selectedImageType = "media";
                                          Navigator.pop(context);
                                          addMediaDialog();
                                        },
                                      )),
                              flex: 1),
                          new Expanded(
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  0.0,
                                  5.0,
                                  0.0,
                                  selectedImageType == "certificates"
                                      ? new InkWell(
                                          child: new Container(
                                              height: 50.0,
                                              color: Colors.blue,
                                              child: new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/media/certifigate1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  TextViewWrap.textView(
                                                      " Certificate",
                                                      TextAlign.center,
                                                      Colors.white,
                                                      10.0,
                                                      FontWeight.bold),
                                                ],
                                              )),
                                          onTap: () {
                                            selectedImageType = "certificates";
                                            Navigator.pop(context);
                                            addMediaDialog();
                                          },
                                        )
                                      : new InkWell(
                                          child: new Container(
                                              height: 50.0,
                                              decoration: new BoxDecoration(
                                                  border: new Border.all(
                                                      color: Colors.grey[300])),
                                              child: new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/media/certifigate1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  TextViewWrap.textView(
                                                      " certificates",
                                                      TextAlign.center,
                                                      Colors.black,
                                                      10.0,
                                                      FontWeight.bold),
                                                ],
                                              )),
                                          onTap: () {
                                            selectedImageType = "certificates";
                                            Navigator.pop(context);
                                            addMediaDialog();
                                          },
                                        )),
                              flex: 1),
                          new Expanded(
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  0.0,
                                  5.0,
                                  0.0,
                                  selectedImageType == "badges"
                                      ? new InkWell(
                                          child: new Container(
                                              height: 50.0,
                                              color: Colors.blue,
                                              child: new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/media/badges1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  TextViewWrap.textView(
                                                      " Badges",
                                                      TextAlign.center,
                                                      Colors.white,
                                                      10.0,
                                                      FontWeight.bold),
                                                ],
                                              )),
                                          onTap: () {
                                            selectedImageType = "badges";
                                            Navigator.pop(context);
                                            addMediaDialog();
                                          },
                                        )
                                      : new InkWell(
                                          child: new Container(
                                              height: 50.0,
                                              decoration: new BoxDecoration(
                                                  border: new Border.all(
                                                      color: Colors.grey[300])),
                                              child: new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/media/badges1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  TextViewWrap.textView(
                                                      " Badges",
                                                      TextAlign.center,
                                                      Colors.black,
                                                      10.0,
                                                      FontWeight.bold),
                                                ],
                                              )),
                                          onTap: () {
                                            selectedImageType = "badges";
                                            Navigator.pop(context);
                                            addMediaDialog();
                                          },
                                        )),
                              flex: 1)
                        ],
                      ),
                      PaddingWrap.paddingfromLTRB(
                          5.0,
                          20.0,
                          5.0,
                          20.0,
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: Padding(
                                    padding: new EdgeInsets.only(
                                        left: 5.0,
                                        top: 30.0,
                                        right: 5.0,
                                        bottom: 0.0),
                                    child: new Container(
                                        height: 50.0,
                                        child: FlatButton(
                                          onPressed: () async {
                                            File imagepath2=
                                            await ImagePicker.pickImage(source: ImageSource.gallery);


                                            if (imagepath2 != null) {
                                              imagePath=imagepath2;
                                              Navigator.pop(context);
                                              addMediaDialog();
                                            }
                                          },
                                          color: Colors.black54,
                                          child: Row(
                                            // Replace with a Row for horizontal icon + text
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Change Photo ',
                                                  style: TextStyle(fontSize: 13.0,
                                                      fontFamily: 'customBold',
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ))),
                                flex: 1,
                              ),
                              new Expanded(
                                child: applyButton,
                                flex: 1,
                              ),
                            ],
                          ))
                    ],
                  )
                ],
              ))));
    }
    //------------------------Image Sewlection ---------------------------

    Future getImage(type) async {
      imagePath = await ImagePicker.pickImage(source: ImageSource.gallery);



      if (imagePath != null) {
        await  _cropImage(imagePath);
        if (imagePath != null) {
          addMediaDialog();
          setState(() {
            imagePath;
          });
        }
      }
    }

//==========================Grid View horizontal for Selected Images====================================

    Padding gridSelectedImages() {
      return assestList != null && assestList.length > 0
          ? PaddingWrap.paddingfromLTRB(
          5.0,
          5.0,
          5.0,
          5.0,
          new Container(
              height: 130.0,
              child: new GridView.count(
                primary: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(5.0),
                crossAxisCount: 1,
                childAspectRatio: .90,
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 2.0,
                children: new List.generate(assestList.length, (int index) {
                  return index == 0
                      ? new InkWell(
                      child: PaddingWrap.paddingAll(
                          0.0,
                          new Image.asset(
                            "assets/profile/add_image.png",
                            width: 100.0,
                            height: 100.0,
                          )),
                      onTap: () {
                        getImage(ImageSource.gallery);
                      })
                      : new Stack(
                    children: <Widget>[
                      new InkWell(
                          child: new Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              new Image.network(
                                Constant.IMAGE_PATH+
                                    assestList[index].file,
                                fit: BoxFit.cover,
                                height: 100.0,
                                width: 100.0,
                              ),
                              new Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  new Expanded(
                                    child: TextViewWrap.textView(
                                        assestList[index].tag,
                                        TextAlign.start,
                                        Colors.black,
                                        12.0,
                                        FontWeight.bold),
                                    flex: 1,
                                  ),
                                  new Expanded(
                                    child: assestList[index].tag ==
                                        "media"
                                        ? PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        0.0,
                                        10.0,
                                        0.0,
                                        new Image.asset(
                                          "assets/profile/media/general.png",
                                          height: 20.0,
                                          width: 20.0,
                                        ))
                                        : assestList[index].tag ==
                                        "badges"
                                        ? PaddingWrap
                                        .paddingfromLTRB(
                                        0.0,
                                        0.0,
                                        10.0,
                                        0.0,
                                        new Image.asset(
                                          "assets/profile/media/badges1.png",
                                          height: 20.0,
                                          width: 20.0,
                                        ))
                                        : PaddingWrap
                                        .paddingfromLTRB(
                                        0.0,
                                        0.0,
                                        10.0,
                                        0.0,
                                        new Image.asset(
                                          "assets/profile/media/certifigate1.png",
                                          height: 20.0,
                                          width: 20.0,
                                        )),
                                    flex: 1,
                                  ),
                                ],
                              )
                            ],
                          ),
                          onLongPress: () {
                            assestList.removeAt(index);
                            setState(() {
                              assestList;
                            });
                          }),
                      new Container(
                        height: 100.0,
                        width: 100.0,
                        color: Colors.black54,
                      ),
                      new Align(
                          alignment: Alignment.topRight,
                          child: new InkWell(
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  5.0,
                                  40.0,
                                  0.0,
                                  assestList[index].isSelected
                                      ? new Image.asset(
                                    "assets/profile/achiv/check.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                      : new Image.asset(
                                    "assets/profile/achiv/uncheck.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
                              onTap: () {
                                if (assestList[index].isSelected) {
                                  assestList[index].isSelected =
                                  false;
                                } else {
                                  assestList[index].isSelected = true;
                                }
                                setState(() {
                                  assestList[index].isSelected;
                                });
                              })),
                    ],
                  );
                }).toList(),
              )))
          : PaddingWrap.paddingfromLTRB(
          5.0,
          10.0,
          5.0,
          10.0,
          new Container(
            height: 1.0,
          ));
    }

    // Build a Form widget using the _formKey we created above
    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            appBar:


          new AppBar(      titleSpacing: 2.0,
            brightness: Brightness.light,
        title:




              new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text("REQUEST RECOMMENDATION",style: new TextStyle(color: new Color(0XFF617082)),)
              ],
            )

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
                child: ListView(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child:new Column(children: <Widget>[
                        PaddingWrap.paddingAll(
                            10.0,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("Recommender Title", 16.0,
                                        new Color(0XFFA8B3B9), FontWeight.normal)),
                                titleUi,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("First Name", 16.0, new Color(0XFFA8B3B9),
                                        FontWeight.normal)),
                                firstName,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("Last Name", 16.0, new Color(0XFFA8B3B9),
                                        FontWeight.normal)),
                                lastName,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("Email", 16.0, new Color(0XFFA8B3B9),
                                        FontWeight.normal)),
                                email,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("Recommendation Title", 16.0,
                                        new Color(0XFFA8B3B9), FontWeight.normal)),
                                recommendationTitle,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    getTextLabel("Request", 16.0, Colors.grey,
                                        FontWeight.normal)),
                                descriptrionUi,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    10.0,
                                    10.0,
                                    0.0,
                                    getTextLabel("Competency", 16.0,new Color(0XFFA8B3B9),
                                        FontWeight.normal)),
                                competencyDropDownUi,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    10.0,
                                    10.0,
                                    0.0,
                                    getTextLabel("Skills", 16.0, new Color(0XFFA8B3B9),
                                        FontWeight.normal)),
                                skillUi,
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    15.0,
                                    0.0,
                                    0.0,
                                    new Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        new Expanded(
                                          child: new Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              getTextLabel("Date(From)", 16.0,
                                                  new Color(0XFFA8B3B9), FontWeight.normal),
                                              fromDateUi
                                            ],
                                          ),
                                          flex: 1,
                                        ),
                                        new Expanded(
                                          child: new Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              getTextLabel("Date(To)", 16.0,
                                                  new Color(0XFFA8B3B9), FontWeight.normal),
                                              toDateUi
                                            ],
                                          ),
                                          flex: 1,
                                        ),
                                      ],
                                    )),
                                PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    10.0,
                                    0.0,
                                    10.0,
                                    new Container(
                                        child: new Row(
                                          children: <Widget>[
                                            new Expanded(
                                              child: PaddingWrap.paddingAll(
                                                  10.0,
                                                  TextViewWrap.textView(
                                                      "Upload Media  ( Optional )",
                                                      TextAlign.start,
                                                      Colors.black,
                                                      14.0,
                                                      FontWeight.bold)),
                                              flex: 5,
                                            ),
                                            new Expanded(
                                              child: new Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  new InkWell(
                                                    child: PaddingWrap.paddingAll(
                                                        5.0,
                                                        new Image.asset(
                                                          "assets/profile/delete_black.png",
                                                          width: 25.0,
                                                          height: 25.0,
                                                        )),
                                                    onTap: () {
                                                      for(int i=0;i<assestList.length;i++){
                                                        if(assestList[i].isSelected)
                                                          assestList.removeAt(i);
                                                      }
                                                      setState(() {
                                                        assestList;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),flex: 1,)
                                          ],
                                        ))),

                                /* new Row(
                            children: <Widget>[

                              imageSelectionView(),
                            ],
                          ),*/
                                gridSelectedImages(),

                              ],
                            )), submitButton
                      ],)
                    )
                  ],
                ))));
  }
}
