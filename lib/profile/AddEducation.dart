import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
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
import 'package:spike_view_project/modal/OrganizationModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class AddEducation extends StatefulWidget {
  String dob, isActive;

  AddEducation(this.dob, this.isActive);

  @override
  AddEducationState createState() {
    return new AddEducationState(dob, isActive);
  }
}

class AddEducationState extends State<AddEducation> {
  final _formKey = GlobalKey<FormState>();
  String dob, isActive;

  AddEducationState(this.dob, this.isActive);

  String strAchievement,
      strFromDate,
      strToDate,
      strName,
      strEmail,
      strCity,
      strDeascription,
      grade1,
      strGrade1 = "",
      grade2,
      strGrade2 = "",
      year1,
      stryear1 = "",
      year2,
      stryear2 = "";
  SharedPreferences prefs;
  String strAzureUploadPath = "";
  List<OrganizationModal> organizationLst = List<OrganizationModal>();
  TextEditingController fromDateController, toDateController;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  String userIdPref, token;
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> yearList = new List();
  String sasToken, containerName;
  bool _IsSearching;
  File imagePath;
  String _searchText = "",
      strOrganizationId = "",
      strInstiute = "",
      strOrganizationType = "School",
      strPrefixPathOrganization;
  final List<String> _items = [
    'Select Grade',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th',
  ].toList();

//------------------------------------Retrive data ( Userid nd token ) ---------------------
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);

    recommendationApi();
    callApiForSaas();
    strPrefixPathOrganization = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_ORGANIZATION +
        "/";
  }

  //=========================================================Api Calling =======================================
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

  //--------------------------Recommendation Info api ------------------
  Future recommendationApi() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_ORGANIZATION_LIST, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            organizationLst.clear();
            organizationLst =
                ParseJson.parseMapOrganization(response.data['result']);
            if (organizationLst.length > 0) {
              setState(() {
                organizationLst;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //-------------------------------------Upload image on Azure --------------------------
  Future<String> uploadImgOnAzure(imagePath) async {
    try {
      if (sasToken != "" && containerName != "") {
        final String result = await platform.invokeMethod('getBatteryLevel', {
          "sasToken": sasToken,
          "imagePath": imagePath,
          "uploadPath": Constant.IMAGE_PATH + strPrefixPathOrganization
        });

        print("image_path" + result);
        return result;
      }
      return "";
    } on Exception catch (e) {
      CustomProgressLoader.cancelLoader(context);
      return "";
    }
  }

  //--------------------------Upload Organization Data ------------------
  Future organizationApi() async {
    try {
      CustomProgressLoader.showLoader(context);
      if (strAzureUploadPath != "") {
        strAzureUploadPath = strPrefixPathOrganization + strAzureUploadPath;
      }
      Map map = {
        "userId": userIdPref,
        "organizationId": strOrganizationId,
        "logo": strAzureUploadPath,
        "institute": strInstiute,
        "city": strCity,
        "fromYear": year1,
        "toYear": year2,
        "fromGrade": grade1,
        "toGrade": grade2,
        "description": strDeascription,
        "isActive": isActive,
        "type": strOrganizationType
      };
      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_ADD_ORGANIZATION, map);

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

  @override
  void initState() {
    // TODO: implement initState
    getSharedPreferences();

    DateTime date = new DateTime.fromMillisecondsSinceEpoch(int.tryParse(dob));
    yearList.add("Select Year");
    for (int i = date.year; i <= new DateTime.now().year; i++) {
      yearList.add(i.toString());
    }
    setState(() {
      yearList;
    });
    _IsSearching = false;
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });

    super.initState();
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
  @override
  Widget build(BuildContext context) {
    //-----------------------------------Image Selectio Ui nd core logic-------------------------------

    Future getImage(type) async {
      imagePath = await ImagePicker.pickImage(source: ImageSource.gallery);

      print("img   :-" +
          imagePath.toString().replaceAll("File: ", "").replaceAll("'", "").trim());
      if (imagePath != null) {
      await  _cropImage(imagePath);
        setState(() {
          imagePath = imagePath;
        });
      }
    }

    InkWell imageSelectionView() {
      return new InkWell(
        child: new Container(
          width: 150.0,
          height: 180.0,
          child: new Stack(
            children: <Widget>[
              new Center(
                  child: new Container(
                child: new Image.asset(
                  "assets/profile/education_form_default.png",
                  fit: BoxFit.fill,
                ),
                width: 150.0,
                height: 180.0,
                padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              )),
              new Align(
                alignment: Alignment.bottomCenter,
                child: new Container(
                  padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                  child: new Image.asset("assets/profile/circle_camera.png"),
                  height: 40.0,
                ),
              )
            ],
          ),
        ),
        onTap: () {
          getImage(ImageSource.gallery);
        },
      );
    }

    InkWell isImageSelectedView() {
      return new InkWell(
        child: new Container(
          width: 150.0,
          height: 180.0,
          child: new Stack(
            children: <Widget>[
              new Center(
                  child: new Container(
                child: new Image.file(
                  imagePath,
                  fit: BoxFit.fill,
                ),
                width: 150.0,
                height: 180.0,
                padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              )),
              new Align(
                alignment: Alignment.bottomCenter,
                child: new Container(
                  padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                  child: new Image.asset("assets/profile/circle_camera.png"),
                  height: 40.0,
                ),
              )
            ],
          ),
        ),
        onTap: () {
          getImage(ImageSource.gallery);
        },
      );
    }

    //------------------------------------- Dropdown List for Grade & Year Spinner -------------------------
    final dropdownMenuGrade = _items
        .map((String item) =>
            new DropdownMenuItem<String>(value: item, child: new Text(item)))
        .toList();
    final dropdownMenuYear = yearList
        .map((String item) => new DropdownMenuItem<String>(
            value: item,
            child: PaddingWrap.paddingfromLTRB(
                5.0, 0.0, 0.0, 0.0, new Text(item))))
        .toList();

    //------------------------------------------- Search LIst Ui  and Logic implementation ----------------------------
    List<InkWell> _buildSearchList() {
      if (_searchText.isEmpty) {
        return new List.generate(organizationLst.length, (int index) {
          return new InkWell(
              child: new ListTile(title: new Text(organizationLst[index].name)),
              onTap: () {
                print(organizationLst[index].name);
                setState(() {
                  print("list");
                  _IsSearching = false;
                });
              });
        });
      } else {
        List<OrganizationModal> _searchList = List();
        for (int i = 0; i < organizationLst.length; i++) {
          String name = organizationLst[i].name;
          if (name.toLowerCase().contains(_searchText.toLowerCase())) {
            _searchList.add(organizationLst[i]);
          }
        }
        return new List.generate(_searchList.length, (int index) {
          return new InkWell(
              child: new ListTile(title: new Text(_searchList[index].name)),
              onTap: () {
                print(_searchList[index]);
                setState(() {
                  _searchQuery.text = _searchList[index].name;
                  strOrganizationId = _searchList[index].organizationId;
                  strOrganizationType = _searchList[index].type;

                  _IsSearching = false;
                });
              });
        });
      }
    }

    Container getOrganizationUi() {
      return new Container(
          decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey[300])),
          child: new Column(
            children: <Widget>[
              PaddingWrap.paddingfromLTRB(
                  5.0,
                  0.0,
                  0.0,
                  0.0,
                  new TextFormField(
                      controller: _searchQuery,maxLength: 50,
                      maxLines: 1,
                      decoration: new InputDecoration(
                          hintText: 'Search Institute',
                          border: InputBorder.none,counterText: "",
                          fillColor: Colors.transparent,
                          labelStyle: new TextStyle(
                              fontSize: 12.0, color: const Color(0xFF757575)),
                          suffixIcon: new GestureDetector(
                            child: new Icon(
                              Icons.arrow_drop_down,
                            ),
                          )))),
              _IsSearching
                  ? new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildSearchList())
                  : new Text("")
            ],
          ));
    }

//-----------------------------------------------Spinner Ui Grade nd Year --------------------------------
    final gradeUi1 = new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        width: double.infinity,
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
                hint: new Text(
                  " Select Grade",
                  style: new TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                value: grade1,
                items: dropdownMenuGrade,
                onChanged: (s) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    grade1 = s;
                    strGrade1 = s;
                  });
                })));

    final gradeUi2 = new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        width: double.infinity,
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
                hint: new Text(
                  " Select Grade",
                  style: new TextStyle(fontSize: 15.0),
                ),
                value: grade2,
                items: dropdownMenuGrade,
                onChanged: (s) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    grade2 = s;
                    strGrade2 = s;
                  });
                })));

    final yearUi1 = new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        width: double.infinity,
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
                hint: new Text(
                  " Select Year",
                  style: new TextStyle(fontSize: 15.0),
                ),
                value: year1,
                items: dropdownMenuYear,
                onChanged: (s) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    year1 = s;
                    stryear1 = s;
                  });
                })));

    final yearUi2 = new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        decoration:
            new BoxDecoration(border: new Border.all(color: Colors.grey[300])),
        width: double.infinity,
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
                hint: new Text(
                  " Select Year",
                  style: new TextStyle(fontSize: 15.0),
                ),
                value: year2,
                items: dropdownMenuYear,
                onChanged: (s) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    year2 = s;
                    stryear2 = s;
                  });
                })));

//-------------------------------------Text Input Fields Ui -----------------------------------
    final cityUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 25,
          decoration: new InputDecoration(
            filled: true,   hintText: "Ex: Newyork",
            fillColor: Colors.transparent,counterText: "",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )

          ),
          validator: (val) => val.isEmpty ? 'can\'t be empty.' : null,
          onSaved: (val) => strCity = val,
        ));

    final descriptrionUi = new Container(

        child: new TextFormField(
          keyboardType: TextInputType.text,maxLength: 500,
          maxLines: 4,
          decoration: new InputDecoration(
            filled: true,   hintText: "Enter Here",counterText: "",
            fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300],)
              )
          ),
          validator: (val) => val.isEmpty ? 'can\'t be empty.' : null,
          onSaved: (val) => strDeascription = val,
        ));

    Text getTextLabel(txt, size, color, fontWeight) {
      return new Text(
        txt,
        style:
            new TextStyle(fontSize: size, color: color, fontWeight: fontWeight),
      );
    }

    //------------------------------------Button Ui nd Logic Implementation-----------------------------
    bool validatioCheck() {
      if (strInstiute == "") {
        ToastWrap.showToast("Please Enter Instiute name..!");
        return false;
      } else if (strGrade1 == "" || strGrade1 == "Select Grade") {
        ToastWrap.showToast("Please Select grade..!");
        return false;
      } else if (strGrade2 == "" || strGrade2 == "Select Grade") {
        ToastWrap.showToast("Please Select grade..!");
        return false;
      } else if (stryear1 == "" || stryear1 == "Select Year") {
        ToastWrap.showToast("Please Select Year..!");
        return false;
      } else if (stryear2 == "" || stryear2 == "Select Year") {
        ToastWrap.showToast("Please Select Year..!");
        return false;
      }
      return true;
    }

    void _checkValidation() async {
      strInstiute = _searchQuery.text;
      final form = _formKey.currentState;
      form.save();
      if (form.validate()) {
        if (validatioCheck()) {
          try {

            if (imagePath != null) {
              strAzureUploadPath = await uploadImgOnAzure(imagePath
                  .toString()
                  .replaceAll("File: ", "")
                  .replaceAll("'", "")
                  .trim());
              organizationApi();
            } else {
              organizationApi();
            }
          } catch (e) {
          }
        }
      } else {
        print("Failure 00");
      }
    }

    final submitButton = Padding(
        padding:
            new EdgeInsets.only(left: 0.0, top: 30.0, right: 5.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: () {
                //CustomProgressLoader.showLoader(context);
                Timer _timer = new Timer(const Duration(milliseconds: 400), () {
                  _checkValidation();
                });
              },
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
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.black54,
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('CANCEL ',
                      style: TextStyle(
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));
    // Build a Form widget using the _formKey we created above

    //-------------------------------------Main Ui ------------------------------------------
    return new Scaffold(
        appBar: new AppBar(
          titleSpacing: 2.0,
          brightness: Brightness.light,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text(
                "EDUCATION INFO",
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
            child: ListView(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: PaddingWrap.paddingAll(
                      10.0,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Align(
                              alignment: Alignment.center,
                              child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  20.0,
                                  0.0,
                                  0.0,
                                  new Container(
                                      height: 180.0,
                                      child: imagePath == null
                                          ? imageSelectionView()
                                          : isImageSelectedView()))),
                          getTextLabel("Institute", 16.0, Colors.grey,
                              FontWeight.normal),
                          getOrganizationUi(),
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              getTextLabel("City", 16.0, Colors.grey,
                                  FontWeight.normal)),
                          cityUi,
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Expanded(
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        getTextLabel("Grade", 16.0, Colors.grey,
                                            FontWeight.normal),
                                        gradeUi1
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
                                        getTextLabel("Grade", 16.0, Colors.grey,
                                            FontWeight.normal),
                                        gradeUi2
                                      ],
                                    ),
                                    flex: 1,
                                  ),
                                ],
                              )),
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Expanded(
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        getTextLabel("Year", 16.0, Colors.grey,
                                            FontWeight.normal),
                                        yearUi1
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
                                        getTextLabel("Year", 16.0, Colors.grey,
                                            FontWeight.normal),
                                        yearUi2
                                      ],
                                    ),
                                    flex: 1,
                                  ),
                                ],
                              )),
                          PaddingWrap.paddingfromLTRB(
                              0.0,
                              15.0,
                              0.0,
                              0.0,
                              getTextLabel("Description", 16.0, Colors.grey,
                                  FontWeight.normal)),
                          descriptrionUi,
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: submitButton,
                                flex: 1,
                              ),
                              new Expanded(
                                child: cancelButton,
                                flex: 1,
                              ),
                            ],
                          )
                        ],
                      )),
                )
              ],
            )));
  }
}
