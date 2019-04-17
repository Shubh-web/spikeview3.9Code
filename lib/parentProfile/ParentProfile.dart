import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
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
import 'package:flutter/material.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget_Parent.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileEducationModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/StudentDataModel.dart';
import 'package:spike_view_project/parentProfile/AddParent.dart';
import 'package:spike_view_project/parentProfile/AddStudent.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/ProfileSharingLog.dart';
import 'package:spike_view_project/profile/UserProfile.dart';

import 'package:spike_view_project/values/ColorValues.dart';

class ParentProfilePage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  ParentProfilePageState createState() => new ParentProfilePageState();
}

final formKey = GlobalKey<FormState>();

class ParentProfilePageState extends State<ParentProfilePage> {
  Color borderColor = Colors.amber;
  bool isRememberMe = false;
  bool isDataRember = false;
  File imagePath, imagePathCover;
  String strNetworkImage = "";
  String userIdPref, token;
  TextEditingController passwordCtrl, emailCtrl;
  ProfileInfoModal profileInfoModal;
  List<StudentDataModel> listStudent = new List();
  List<ProfileEducationModal> userEducationList =
      new List<ProfileEducationModal>();
  List<NarrativeModel> narrativeList = new List<NarrativeModel>();
  List<Recomdation> recommendationtList = new List<Recomdation>();
  BuildContext context;
  SharedPreferences prefs;
  bool isNarativeShow = false;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  String sasToken, containerName;
  String strPrefixPathforCoverPhoto,
      strPrefixPathforProfilePhoto,
      strAzureCoverImageUploadPath = "",
      strAzureProfileImageUploadPath = "";
  String strSummary;
  String strAccCount = "", strRecCount = "";
  bool isActive = false;
  StreamSubscription<dynamic> _streamSubscription;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  //----------------------------------------- api calling and data parse ----------------------------

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
              strNetworkImage = profileInfoModal.profilePicture;
              setState(() {
                strNetworkImage;
                profileInfoModal;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Students BY Parent api ------------------
  Future studentByParentApi() async {
    try {
      Response response = await new ApiCalling().apiCall(context,
          Constant.ENDPOINT_PARENT_STUDENTSBYPARENT + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            listStudent.clear();
            listStudent =
                ParseJson.parseMapStudentByParent(response.data['result']);
            if (listStudent != null) {
              setState(() {
                listStudent;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
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

  //--------------------------Upload Cover Image Data ------------------
  Future uploadCoverIMage(type) async {
    try {
      Response response;
      if (type == "cover") {
        Map map = {
          "coverImage":
              strPrefixPathforCoverPhoto + strAzureCoverImageUploadPath,
          "userId": userIdPref
        };
        response = await new ApiCalling().apiCallPutWithMapData(
            context, Constant.ENDPOINT_USER_COVER_PHOTO_UPDATE, map);
      } else {
        Map map = {
          "profilePicture":
              strPrefixPathforProfilePhoto + strAzureProfileImageUploadPath,
          "userId": userIdPref
        };

        response = await new ApiCalling().apiCallPutWithMapData(
            context, Constant.ENDPOINT_USER_COVER_PHOTO_UPDATE, map);
      }
      CustomProgressLoader.cancelLoader(context);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            if (type != "cover") {
              prefs.setString(
                  UserPreference.PROFILE_IMAGE_PATH,
                  strPrefixPathforProfilePhoto +
                      strAzureProfileImageUploadPath);
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Api Calling for update user Status ------------------
  Future apiCallingForUpdateStudentStatus(userId, isActive) async {
    try {
      Response response;

      Map map = {"userId": userId, "isActive": isActive};

      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_PARENT_PERSONAL_UPDATEUSER_STATUS, map);
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

//***************************************************************************************************************

//------------------------------------Retrive data ( Userid nd token ) ---------------------
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);

    await profileApi();
    await studentByParentApi();
    await callApiForSaas();

    strPrefixPathforCoverPhoto = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_COVER +
        "/";

    strPrefixPathforProfilePhoto = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_PROFILE +
        "/";
  }

//*********************************************************************************************

  @override
  void initState() {
    print("changes");
    getSharedPreferences();

    //-------------listener for refresh profile info -------------------------
    _streamSubscription =
        DashBoardStateParent.syncDoneController.stream.listen((value) {
      apiUpdated(value);
    });
    super.initState();
  }

  //-------------listener for refresh profile info -------------------------
  void apiUpdated(String result) async {
    profileApi();
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
    // Main View for return final Output
    this.context = context;

    Future getImage(type) async {
      imagePath = await ImagePicker.pickImage(source: ImageSource.gallery);
      print("img   :-" +
          imagePath
              .toString()
              .replaceAll("File: ", "")
              .replaceAll("'", "")
              .trim());
      if (imagePath != null) {
        await _cropImage(imagePath);

        CustomProgressLoader.showLoader(context);
        Timer _timer = new Timer(const Duration(milliseconds: 400), () async {
          strAzureProfileImageUploadPath = await uploadImgOnAzure(
              imagePath
                  .toString()
                  .replaceAll("File: ", "")
                  .replaceAll("'", "")
                  .trim(),
              strPrefixPathforProfilePhoto);
          if (strAzureProfileImageUploadPath != "" &&
              strAzureProfileImageUploadPath != "false") {
            setState(() {
              strNetworkImage = "";
              imagePath = imagePath;
            });
            uploadCoverIMage("profile");
          } else {
            CustomProgressLoader.cancelLoader(context);
          }
        });
      }
    }

    Future getImageCover() async {
      imagePathCover = await ImagePicker.pickImage(source: ImageSource.gallery);
      print("img   :-" +
          imagePathCover
              .toString()
              .replaceAll("File: ", "")
              .replaceAll("'", "")
              .trim());
      if (imagePathCover != null) {
        await _cropImage(imagePathCover);
        CustomProgressLoader.showLoader(context);
        Timer _timer = new Timer(const Duration(milliseconds: 400), () async {
          strAzureCoverImageUploadPath = await uploadImgOnAzure(
              imagePathCover
                  .toString()
                  .replaceAll("File: ", "")
                  .replaceAll("'", "")
                  .trim(),
              strPrefixPathforCoverPhoto);
          print("azureimagepath   :-" + strAzureCoverImageUploadPath);
          if (strAzureCoverImageUploadPath != "" &&
              strAzureCoverImageUploadPath != "false") {
            setState(() {
              imagePathCover = imagePathCover;
            });
            uploadCoverIMage("cover");
          } else {
            CustomProgressLoader.cancelLoader(context);
          }
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
                  "assets/profile/user_on_user.png",
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
                child: strNetworkImage == "" || strNetworkImage == "null"
                    ? new Image.file(
                        imagePath,
                        fit: BoxFit.fill,
                      )
                    : FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        placeholder: 'assets/profile/user_on_user.png',
                        image: Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(
                                profileInfoModal.profilePicture),
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

//-----------------------------------------Header Design ----------------------------------------
    Container headerUiDesign() {
      return new Container(
        height: 220.0,
        child: new Stack(
          children: <Widget>[
            new Positioned(
              top: 0.0,
              bottom: 80.0,
              left: 0.0,
              right: 0.0,
              child: imagePathCover == null
                  ? profileInfoModal != null &&
                          profileInfoModal.coverImage != ""
                      ? new Stack(
                          children: <Widget>[
                            new Positioned(
                              child: new Image.network(
                                Constant.IMAGE_PATH_SMALL +
                                    ParseJson.getMediumImage(
                                        profileInfoModal.coverImage),
                                fit: BoxFit.cover,
                              ),
                              top: 0.0,
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                            ),
                            new Positioned(
                              child: new Image.asset(
                                "assets/home/cover.png",
                                fit: BoxFit.fill,
                              ),
                              top: 0.0,
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                            )
                          ],
                        )
                      : new Image.asset(
                          "assets/profile/background.png",
                          fit: BoxFit.fill,
                        )
                  : new Stack(
                      children: <Widget>[
                        new Positioned(
                          child: new Image.file(
                            imagePathCover,
                            fit: BoxFit.fitWidth,
                          ),
                          top: 0.0,
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                        ),
                        new Positioned(
                          child: new Image.asset(
                            "assets/home/cover.png",
                            fit: BoxFit.fill,
                          ),
                          top: 0.0,
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                        )
                      ],
                    ),
            ),
            new Align(
                alignment: Alignment.center,
                child: PaddingWrap.paddingfromLTRB(
                    0.0,
                    20.0,
                    0.0,
                    0.0,
                    new Container(
                        height: 180.0,
                        child: (imagePath == null && strNetworkImage == "" ||
                                strNetworkImage == "null")
                            ? imageSelectionView()
                            : isImageSelectedView()))),
            new Positioned(
                right: 20.0,
                top: 100.0,
                child: new InkWell(
                  child: new Container(
                    padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                    child: new Image.asset("assets/profile/cover_edit.png"),
                    height: 30.0,
                  ),
                  onTap: () {
                    getImageCover();
                  },
                )),
          ],
        ),
      );
    }

//-----------------------------------------Button Desin Design ----------------------------------------
    onTapAddParent() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new AddParent("ADD NEW PARENT")));
      if (result == "push") {
        studentByParentApi();
      }
    }

    onTapAddStudent() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new AddStudent("ADD NEW STUDENT")));

      if (result == "push") {
        studentByParentApi();
      }
    }

    Container getBtnUi() {
      return new Container(
        padding: new EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              child: PaddingWrap.paddingAll(
                  10.0,
                  new Center(
                      child: new InkWell(
                    child: new Container(
                        decoration: new BoxDecoration(
                            border: new Border.all(
                                color: Colors.grey[300], width: 2.0)),
                        child: PaddingWrap.paddingAll(
                          10.0,
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Image.asset(
                                "assets/profile/parent/plus_black.png",
                                height: 12.0,
                                width: 12.0,
                              ),
                              TextViewWrap.textView(
                                  "Add Parent",
                                  TextAlign.center,
                                  Colors.black,
                                  14.0,
                                  FontWeight.bold),
                            ],
                          ),
                        )),
                    onTap: () {
                      onTapAddParent();
                    },
                  ))),
              flex: 1,
            ),
            new Expanded(
              child: new InkWell(
                child: PaddingWrap.paddingAll(
                    10.0,
                    new Container(
                        decoration: new BoxDecoration(
                            border: new Border.all(
                                color: Colors.grey[300], width: 2.0)),
                        child: PaddingWrap.paddingAll(
                            10.0,
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Image.asset(
                                  "assets/profile/parent/plus_black.png",
                                  height: 12.0,
                                  width: 12.0,
                                ),
                                TextViewWrap.textView(
                                    "Add Student",
                                    TextAlign.center,
                                    Colors.black,
                                    14.0,
                                    FontWeight.bold),
                              ],
                            )))),
                onTap: () {
                  onTapAddStudent();
                },
              ),
              flex: 1,
            )
          ],
        ),
      );
    }

//-----------------------------------------Student List Design ----------------------------------------
    onTapStudentItem(index) {
      prefs.setString(UserPreference.USER_ID, listStudent[index].userId);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new UserProfilePage("", true,"")));
    }

    Container getStudentsUi() {
      return new Container(
          child: Column(
        children: <Widget>[
          PaddingWrap.paddingfromLTRB(
              5.0,
              10.0,
              5.0,
              10.0,
              new Container(
                  height: 300.0,
                  child: new GridView.count(
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(5.0),
                    crossAxisCount: 1,
                    childAspectRatio: 0.97,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 2.0,
                    children:
                        new List.generate(listStudent.length, (int index) {
                      return PaddingWrap.paddingAll(
                        10.0,
                        new Container(
                          child: new Stack(
                            children: <Widget>[
                              new Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                left: 0.0,
                                top: 50.0,
                                child: new Container(
                                    child: new Card(
                                        elevation: 2.0,
                                        child: new Column(
                                          children: <Widget>[
                                            new InkWell(
                                              child:
                                                  PaddingWrap.paddingfromLTRB(
                                                      5.0,
                                                      90.0,
                                                      5.0,
                                                      0.0,
                                                      new Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          PaddingWrap
                                                              .paddingAll(
                                                            2.0,
                                                            TextViewWrap.textView(
                                                                listStudent[index]
                                                                            .lastName ==
                                                                        "null"
                                                                    ? listStudent[
                                                                            index]
                                                                        .firstName
                                                                    : listStudent[index]
                                                                            .firstName +
                                                                        " " +
                                                                        listStudent[index]
                                                                            .lastName,
                                                                TextAlign
                                                                    .center,
                                                                Colors.black,
                                                                18.0,
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                          PaddingWrap
                                                              .paddingfromLTRB(
                                                                  0.0,
                                                                  3.0,
                                                                  0.0,
                                                                  0.0,
                                                                  PaddingWrap
                                                                      .paddingAll(
                                                                    2.0,
                                                                    TextViewWrap.textView(
                                                                        listStudent[index]
                                                                            .email,
                                                                        TextAlign
                                                                            .center,
                                                                        Colors
                                                                            .grey,
                                                                        12.0,
                                                                        FontWeight
                                                                            .normal),
                                                                  )),
                                                        ],
                                                      )),
                                              onTap: () {
                                                onTapStudentItem(index);
                                              },
                                            ),
                                            PaddingWrap.paddingfromLTRB(
                                                0.0,
                                                0.0,
                                                0.0,
                                                0.0,
                                                new Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    new Expanded(
                                                      child: PaddingWrap
                                                          .paddingfromLTRB(
                                                              10.0,
                                                              10.0,
                                                              10.0,
                                                              0.0,
                                                              new Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  listStudent[index]
                                                                              .isActive ==
                                                                          "true"
                                                                      ? new GestureDetector(
                                                                          onHorizontalDragEnd:
                                                                              (DragEndDetails details) {
                                                                            setState(() {
                                                                              listStudent[index].isActive = "false";

                                                                              apiCallingForUpdateStudentStatus(listStudent[index].userId, false);
                                                                            });
                                                                          },
                                                                          child: new Center(
                                                                              child: new Padding(
                                                                                  padding: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                                                                  child: new Image.asset(
                                                                                    "assets/profile/parent/active.png",
                                                                                    width: 50.0,
                                                                                    height: 50.0,
                                                                                  ))))
                                                                      : new GestureDetector(
                                                                          onHorizontalDragEnd: (DragEndDetails details) {
                                                                            setState(() {
                                                                              listStudent[index].isActive = "true";
                                                                              apiCallingForUpdateStudentStatus(listStudent[index].userId, true);
                                                                            });
                                                                          },
                                                                          child: new Center(
                                                                              child: new Padding(
                                                                                  padding: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                                                                  child: new Image.asset(
                                                                                    "assets/profile/parent/inactive.png",
                                                                                    width: 50.0,
                                                                                    height: 50.0,
                                                                                  )))),
                                                                  TextViewWrap.textView(
                                                                      listStudent[index].isActive ==
                                                                              "true"
                                                                          ? "           ACTIVE"
                                                                          : "           INACTIVE",
                                                                      TextAlign
                                                                          .start,
                                                                      new Color(
                                                                          0XFF9DA9B6),
                                                                      12.0,
                                                                      FontWeight
                                                                          .normal),
                                                                ],
                                                              )
                                                              /*new FlatButton(
                                                        onPressed: () {
                                                          prefs.setString(
                                                              UserPreference
                                                                  .USER_ID,
                                                              listStudent[index]
                                                                  .userId);
                                                          Navigator.of(context).push(
                                                              new MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      new UserProfilePage()));
                                                        },
                                                        color: new Color(
                                                            ColorValues
                                                                .BLUE_COLOR),
                                                        child: new Text(
                                                          "GO TO PROFILE",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: new TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10.0),
                                                        ))*/
                                                              ),
                                                    ),
                                                  ],
                                                ))
                                          ],
                                        ))),
                              ),
                              new Positioned(
                                top: 0.0,
                                right: 0.0,
                                left: 0.0,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    new InkWell(
                                      child: new Container(
                                        child:
                                            listStudent[index].profilePicture !=
                                                        "" &&
                                                    listStudent[index]
                                                            .profilePicture !=
                                                        "null"
                                                ? Image.network(
                                                    Constant.IMAGE_PATH_SMALL +
                                                        ParseJson.getMediumImage(
                                                            listStudent[index]
                                                                .profilePicture),
                                                    fit: BoxFit.cover,
                                                  )
                                                : new Image.asset(
                                                    "assets/profile/user_on_user.png",
                                                    fit: BoxFit.fill,
                                                  ),
                                        width: 120.0,
                                        height: 150.0,
                                        padding: new EdgeInsets.fromLTRB(
                                            10.0, 20.0, 0.0, 20.0),
                                      ),
                                      onTap: () {
                                        onTapStudentItem(index);
                                      },
                                    )
                                  ],
                                ),
                              ),
                              new Align(
                                alignment: Alignment.topRight,
                                child: PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    60.0,
                                    8.0,
                                    0.0,
                                    new InkWell(
                                      child: new Image.asset(
                                        "assets/profile/parent/profile_sharing_log.png",
                                        height: 30.0,
                                        width: 30.0,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        new ProfileSharingLog(
                                                            listStudent[index]
                                                                .userId)));
                                      },
                                    )),
                              ),
                            ],
                          ),
                          height: 200.0,
                        ),
                      );
                    }).toList(),
                  ))),
        ],
      ));
    }

    return new Container(
        color: new Color(0XFFF7F7F9),
        child: new Stack(
          children: <Widget>[
            new ListView(
              children: <Widget>[
                headerUiDesign(),
                PaddingWrap.paddingfromLTRB(
                    0.0,
                    0.0,
                    0.0,
                    8.0,
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        PaddingWrap.paddingAll(
                          2.0,
                          TextViewWrap.textView(
                              profileInfoModal == null
                                  ? ""
                                  : profileInfoModal.lastName == "null"
                                      ? profileInfoModal.firstName!="null"?profileInfoModal.firstName:""
                                      : profileInfoModal.firstName +
                                          " " +
                                          profileInfoModal.lastName,
                              TextAlign.center,
                              Colors.black,
                              20.0,
                              FontWeight.bold),
                        ),
                      ],
                    )),
                new Column(
                  children: <Widget>[
                    PaddingWrap.paddingAll(
                      10.0,
                      TextViewWrap.textView(
                          "Welcome to spikeview! ",
                          TextAlign.center,
                          Colors.blueAccent,
                          20.0,
                          FontWeight.bold),
                    ),
                    PaddingWrap.paddingfromLTRB(
                      10.0,
                      0.0,
                      10.0,
                      0.0,
                      new Text(
                        "Please click Go To Profile to add information to your childs’ profile. We suggest you add as many relevant pictures and videos as possible to create a rich, compelling narrative.",
                        style: new TextStyle(
                            color: new Color(0XFF7A8B9B), fontSize: 15.0),
                      ),
                    ),
                    getBtnUi(),
                    getStudentsUi()
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
