import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:adhara_socket_io/manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:spike_view_project/chat/ChatListWithHeader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/api_interface/ApiCallingWithoutProgressIndicator.dart';
import 'package:spike_view_project/chat/ChatRoom.dart';
import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/common/Connectivity.dart';

//import 'package:spike_view_project/chat/ChatListWithHeader.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/modal/ConnectionModel.dart';
import 'package:spike_view_project/modal/SpiderChartModel.dart';
import 'package:spike_view_project/profile/EditEducationWidget.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/profile/AllRecommendationList.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileEducationModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/AddEducation.dart';
import 'package:spike_view_project/profile/AddSummary.dart';
import 'package:spike_view_project/profile/AllRecommendationList.dart';
import 'package:spike_view_project/profile/CompetenciesWidget.dart';
import 'package:spike_view_project/profile/EditUserProfile.dart';
import 'package:spike_view_project/profile/EmailShareWidget.dart';
import 'package:spike_view_project/profile/RecommendationDetail.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:spike_view_project/values/StringValues.dart';

//
class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  // TODO: implement barrierLabel
  @override
  String get barrierLabel => null;
}

class ModalBottomSheet extends StatefulWidget {
  List<NarrativeModel> narrativeList;

  ModalBottomSheet(this.narrativeList);

  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet>
    with SingleTickerProviderStateMixin {
  var heightOfModalBottomSheet = 100.0;
  double _discreteValue = 0.0;

  String getImportanceType(imoportanceValue) {
    switch (imoportanceValue) {
      case 0:
        {
          return "Private";
        }
      case 1:
        {
          return "Parent";
        }
      case 2:
        {
          return "Family & Friends";
        }
      case 3:
        {
          return "Individual";
        }
      case 4:
        {
          return "Team";
        }
      case 5:
        {
          return "Class";
        }
      case 6:
        {
          return "School";
        }
      case 7:
        {
          return "School District";
        }
      case 8:
        {
          return "Regional";
        }
      case 9:
        {
          return "State";
        }
      case 10:
        {
          return "National";
        }
      case 11:
        {
          return "International";
        }
      case 12:
        {
          return "Hide";
        }
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: new List.generate(widget.narrativeList.length, (int index) {
            return new Column(
              children: <Widget>[
                PaddingWrap.paddingAll(
                    10.0,
                    new Row(
                      children: <Widget>[
                        TextViewWrap.textView(
                            widget.narrativeList[index].name + " : ",
                            TextAlign.center,
                            Colors.black,
                            15.0,
                            FontWeight.bold),
                        TextViewWrap.textView(
                            " " +
                                getImportanceType(widget
                                    .narrativeList[index].imoportanceValue
                                    .toInt()),
                            TextAlign.center,
                            new Color(ColorValues.BLUE_COLOR),
                            15.0,
                            FontWeight.bold),
                      ],
                    )),
                new Slider(
                  value: widget.narrativeList[index].imoportanceValue,
                  min: 0.0,
                  max: 12.0,
                  activeColor:Colors.green,
                  inactiveColor:Colors.red,
                  divisions: 12,
                  label:
                      '${widget.narrativeList[index].imoportanceValue.round()}',
                  onChanged: (double value) {
                    setState(() {
                      widget.narrativeList[index].imoportanceValue = value;
                    });
                  },
                )
              ],
            );
          })),
    );
    ;
  }
}

class UserProfilePage extends StatefulWidget {
  static String tag = 'login-page';
  String userId,pageRedirect="";
  bool isEditable = true;

  UserProfilePage(this.userId, this.isEditable,this.pageRedirect);

  @override
  UserProfilePageState createState() => new UserProfilePageState();
}

final formKey = GlobalKey<FormState>();
String _email = "", _password = "";
bool _isLoading = false;

class UserProfilePageState extends State<UserProfilePage> {
  Color borderColor = Colors.amber;
  bool isRememberMe = false;
  bool isDataRember = false;
  bool isAccepetd = false;
  bool isSubscribe = false;
  bool isShare = false;
  String shareName = "", shareEmail = "", shareLastName = "";
  int subsCriberId = 0;
  bool isParent = false;
  File imagePath, imagePathCover;
  String strNetworkImage = "";
  String userIdPref, token;
  TextEditingController passwordCtrl, emailCtrl;
  ProfileInfoModal profileInfoModal;
  List<ProfileEducationModal> userEducationList =
      new List<ProfileEducationModal>();
  List<NarrativeModel> narrativeList = new List<NarrativeModel>();
  List<int> indexRemoveList = new List<int>();
  List<NarrativeModel> mainNarrativeList = new List<NarrativeModel>();
  ConnectionModel connectionModel;
  List<Recomdation> recommendationtList = new List<Recomdation>();
  List<double> spiderChartList = new List<double>();
  List<String> spiderChartName = new List<String>();
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
  bool isEditTagline = false;
  TextEditingController addTagline;
  bool isConnected = false;
  double _discreteValue = 0.0;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  //----------------------------------------- api calling and data parse ----------------------------

  //--------------------------Profile Info api ------------------
  Future profileApi(isShowLaoder) async {
    try {
      if (isShowLaoder) CustomProgressLoader.showLoader(context);

      Response response = await new ApiCalling2().apiCall(
          context, Constant.ENDPOINT_PERSONAL_INFO + userIdPref, "get");

      if (isShowLaoder) CustomProgressLoader.cancelLoader(context);

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            profileInfoModal =
                ParseJson.parseMapUserProfile(response.data['result']);
            if (profileInfoModal != null) {
              strNetworkImage = profileInfoModal.profilePicture;
              addTagline = new TextEditingController(
                  text: profileInfoModal.tagline == "" ||
                          profileInfoModal.tagline == "null"
                      ? "Enter tagline"
                      : profileInfoModal.tagline);
              setState(() {
                strNetworkImage;
                profileInfoModal;
                addTagline;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Profile Info api ------------------
  Future eductionApi(isShowLoader) async {
    try {
      if (isShowLoader) CustomProgressLoader.showLoader(context);

      Response response = await new ApiCalling2()
          .apiCall(context, Constant.ENDPOINT_EDUCATION + userIdPref, "get");

      if (isShowLoader) CustomProgressLoader.cancelLoader(context);

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            userEducationList.clear();
            userEducationList =
                ParseJson.parseMapEducation(response.data['result']);
            if (userEducationList.length > 0) {
              setState(() {
                userEducationList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------My Narratives Info api ------------------
  Future narrativeApi(isShowLoader) async {
    try {
      if (isShowLoader) CustomProgressLoader.showLoader(context);

      Response response = await new ApiCalling2()
          .apiCall(context, Constant.ENDPOINT_NARRATIVE + userIdPref, "get");

      if (isShowLoader) CustomProgressLoader.cancelLoader(context);

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            narrativeList.clear();
            mainNarrativeList.clear();

            narrativeList =
                ParseJson.parseMapNarrative(response.data['result']);
            if (narrativeList.length > 0) {
              try {
                mainNarrativeList = await narrativeList
                    .map((item) => new NarrativeModel.clone(item))
                    .toList();
              } catch (e) {
                e.toString();
              }
              setState(() {
                narrativeList;
                mainNarrativeList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Recommendation Info api ------------------
  Future recommendationApi(isShowLoader) async {
    try {
      if (isShowLoader) CustomProgressLoader.showLoader(context);

      Response response = await new ApiCalling2().apiCall(
          context, Constant.ENDPOINT_RECOMMENDATION + userIdPref, "get");

      if (isShowLoader) CustomProgressLoader.cancelLoader(context);

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            recommendationtList.clear();
            recommendationtList =
                ParseJson.parseMapRecommdation(response.data['result']);
            if (recommendationtList.length > 0) {
              setState(() {
                recommendationtList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }
  //--------------------------spider chart api ------------------
  Future spiderChart(isShowLoader) async {
    try {
      if (isShowLoader) CustomProgressLoader.showLoader(context);

      Response response = await new ApiCalling2().apiCall(
          context, Constant.ENDPOINT_SPIDER_CHART+userIdPref+"/0", "get");

      if (isShowLoader) CustomProgressLoader.cancelLoader(context);

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            spiderChartList.clear();
            spiderChartList =
                parseSpiderChart(response.data['result']);
            if (spiderChartList.length > 0) {
              setState(() {
                spiderChartList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

   List<double> parseSpiderChart(map) {
    List<double> dataList = new List();
    for (int i = 0; i < map.length; i++) {

      String  _id = map[i]["_id"].toString();
      String  importance = map[i]["importance"].toString();
      String  name = map[i]["name"].toString();
      String  importanceTitle = map[i]["importanceTitle"].toString();

      spiderChartName.add(name);
      // dataList.add(new SpiderChartModel(_id, importance, name, importanceTitle));
      dataList.add(double.parse(importance));
    }

    return dataList;
  }
  //--------------------------Recommendation Info api ------------------
  Future countAccRec(isShowLaoder) async {
    try {
      Response response = await new ApiCalling2().apiCall(
          context, Constant.ENDPOINT_ACC_REC_COUNT + userIdPref + "/0", "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          var map = response.data['result'];
          if (status == "Success") {
            strAccCount = response.data['result']['achievement'].toString();
            strRecCount = response.data['result']['recommendation'].toString();
            setState(() {
              strAccCount;
              strRecCount;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Recommendation Info api ------------------
  Future apiCallForCheckIsFriend() async {
    try {
      Response response;
      String uri;

      if (prefs.getBool(UserPreference.IS_PARENT)) {
        uri = Constant.ENDPOINT_CHECK_IS_FRIEND +
            prefs.getString(UserPreference.PARENT_ID) +
            "&partnerId=" +
            widget.userId;
      } else {
        uri = Constant.ENDPOINT_CHECK_IS_FRIEND +
            prefs.getString(UserPreference.USER_ID) +
            "&partnerId=" +
            widget.userId;
      }
      print(uri);
      response = await new ApiCalling().apiCall(context, uri, "get");
      print(response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          var map = response.data['result'];
          if (map.length > 0) {
            isConnected = true;

            String status = map[map.length - 1]['status'];
            if (status == "Accepted") {
              isAccepetd = true;
            } else if (status == "Requested") {
              isAccepetd = false;
            } else {
              isConnected = false;
            }

            String connectId = map[map.length - 1]['connectId'].toString();
            String userId = map[map.length - 1]['userId'].toString();
            String partnerId = map[map.length - 1]['partnerId'].toString();
            String dateTime = map[map.length - 1]['dateTime'].toString();
            connectionModel = new ConnectionModel(
                connectId, userId, partnerId, dateTime, status);
            setState(() {
              isConnected;
              connectionModel;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //-------------------------- api ------------------
  Future apiCallForCheckSubscribe() async {
    try {
      Response response;
      String uri;

      if (prefs.getBool(UserPreference.IS_PARENT)) {
        uri = Constant.ENDPOINT_CHECK_IS_SUBSCRIBE +
            prefs.getString(UserPreference.PARENT_ID) +
            "&followerId=" +
            widget.userId;
      } else {
        uri = Constant.ENDPOINT_CHECK_IS_SUBSCRIBE +
            prefs.getString(UserPreference.USER_ID) +
            "&followerId=" +
            widget.userId;
      }
      print(uri);
      response = await new ApiCalling().apiCall(context, uri, "get");
      print(response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          var map = response.data['result'];
          if (map.length > 0) {
            String status = map[map.length - 1]['status'];
            subsCriberId = map[map.length - 1]['subscribeId'];
            if (status == "Un-Subscribe") {
              isSubscribe = false;
            } else {
              isSubscribe = true;
            }
            setState(() {
              isSubscribe;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //-------------------------- api ------------------
  Future apiCallForAddRecommendation(recommendation) async {
    try {
      Map map = {
        "recommendationId": int.parse(recommendation.recommendationId),
        "stage": "Added"
      };
      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_ADD_RECOMMENDATION, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            // recommendation.stag = "Added";
            //setState(() {
            spiderChart(true);
            narrativeApi(true);
            recommendationApi(true);
            // });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------  api ------------------
  Future apiCallForConnect() async {
    try {
      Map map = {
        "userId": prefs.getString(UserPreference.USER_ID),
        "partnerId": int.parse(widget.userId),
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "status": "Requested",
        "isActive": profileInfoModal.isActive
      };
      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_CONNECTION_UPDATE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            setState(() {
              isConnected = true;
              isAccepetd = false;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  refresh() async {
    narrativeList = await mainNarrativeList
        .map((item) => new NarrativeModel.clone(item))
        .toList();
    setState(() {
      narrativeList;
    });
  }

  //--------------------------  api ------------------
  Future apiCallForShare(type) async {
    try {
      Map map = {
        "sharedType": type,
        "profileOwner": int.parse(userIdPref),
        "firstName": shareName,
        "lastName": shareLastName,
        "email": shareEmail.toLowerCase(),
        "shareTime": new DateTime.now().millisecondsSinceEpoch,
        "shareConfiguration":
            narrativeList.map((item) => item.toJson()).toList(),
        "sharedView": "linear",
        "isActive": profileInfoModal.isActive,
        "theme": ""
      };

      print(map.toString());
      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_SHARE_PROFILE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            String sharedId = response.data['result']['sharedId'].toString();
            String link = response.data['result']['link'].toString();
            print(link);

            if (type == "Email") {
              refresh();
              setState(() {
                isShare = false;
              });
            } else {
              refresh();
              setState(() {
                isShare = false;
              });

              //chatlistRemove
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ChatListWithHeader(link, sharedId)));
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------  api ------------------
  Future apiCallForSubscribe() async {
    try {
      Map map = {
        "userId": prefs.getString(UserPreference.USER_ID),
        "followerId": widget.userId,
        "followerName":
            profileInfoModal.lastName == null || profileInfoModal.lastName == ""
                ? profileInfoModal.firstName
                : profileInfoModal.firstName + " " + profileInfoModal.lastName,
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "isActive": true,
        "status": "Subscribe"
      };

      Response response = await new ApiCalling()
          .apiCallPostWithMapData(context, Constant.ENDPOINT_SUBSCRIBE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            setState(() {
              isSubscribe = true;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------  api ------------------
  Future apiCallForUnSubscribe() async {
    try {
      Map map = {
        "subscribeId": subsCriberId,
        "userId": prefs.getString(UserPreference.USER_ID),
        "followerId": widget.userId,
        "followerName":
            profileInfoModal.lastName == null || profileInfoModal.lastName == ""
                ? profileInfoModal.firstName
                : profileInfoModal.firstName + " " + profileInfoModal.lastName,
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "isActive": true,
        "status": "Un-Subscribe"
      };
      Response response = await new ApiCalling()
          .apiCallPostWithMapData(context, Constant.ENDPOINT_SUBSCRIBE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast("Un-Subscribe Successfully");
            setState(() {
              isSubscribe = false;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------SaasToken  api ------------------
  Future callApiForSaas(isShowLoader) async {
    try {
      Response response = await new ApiCalling2().apiCall(
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
            if (type != "cover") {
              prefs.setString(
                  UserPreference.PROFILE_IMAGE_PATH,
                  strPrefixPathforProfilePhoto +
                      strAzureProfileImageUploadPath);
            }
            //  ToastWrap.showToast(msg);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

//***************************************************************************************************************
  void initSocket() async {
    // modify with your true address/port
    GlobalSocketConnection.socket = await SocketIOManager().createInstance(
        GlobalSocketConnection.ip); //TODO change the port  accordingly
    GlobalSocketConnection.socket.onConnect((data) {
      print("connected...");
      print(data);
    });

    GlobalSocketConnection.socket.on("updatechat", (data) {
      //sample event
      print("==========================MAin Chat Room Call back ");
      print(data);
    });

    GlobalSocketConnection.socket.connect();
  }

//------------------------------------Retrive data ( Userid nd token ) ---------------------
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    isParent = prefs.getBool("isParent");
    if (isParent == null) {
      isParent = false;
    }
    if (widget.userId != "") {
      await apiCallForCheckIsFriend();
      await apiCallForCheckSubscribe();
    }
    if (widget.userId != "") userIdPref = widget.userId;

    CustomProgressLoader.showLoader(context);
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      await spiderChart(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await callApiForSaas(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await countAccRec(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await profileApi(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await eductionApi(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await narrativeApi(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }
    if (isConnect) {
      await recommendationApi(false);
    } else {
      ToastWrap.showToast("Please check your internet connection....!");
    }


    CustomProgressLoader.cancelLoader(context);
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

  //--------------------------Delete Education Data ------------------
  Future deleteEducation(educationId, index) async {
    try {
      Map map = {
        "educationId": educationId,
      };
      Response response = await new ApiCalling().apiCallDeleteWithMapData(
          context, Constant.ENDPOINT_ADD_ORGANIZATION, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            userEducationList.removeAt(index);
            setState(() {
              userEducationList;
            });
            ToastWrap.showToast(msg);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Api Calling ------------------
  Future apiCallingforTagline() async {
    try {
      Response response;

      Map map = {"tagline": addTagline.text, "userId": userIdPref};
      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_USER_COVER_PHOTO_UPDATE, map);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            setState(() {
              profileInfoModal.tagline = addTagline.text;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

//*********************************************************************************************
  @override
  void initState() {
    addTagline = new TextEditingController(text: "");
//initSocket();
    getSharedPreferences();
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
    // Main View for return final Output
    this.context = context;

    Future getImage(type) async {
      imagePath = await ImagePicker.pickImage(source: ImageSource.gallery);

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
              widget.isEditable && (!isShare)
                  ? new Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                        padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                        child:
                            new Image.asset("assets/profile/circle_camera.png"),
                        height: 40.0,
                      ),
                    )
                  : new Container(
                      height: 0.0,
                    )
            ],
          ),
        ),
        onTap: () {
          widget.isEditable && (!isShare)
              ? getImage(ImageSource.gallery)
              : null;
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
              widget.isEditable && (!isShare)
                  ? new Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                        padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                        child:
                            new Image.asset("assets/profile/circle_camera.png"),
                        height: 40.0,
                      ))
                  : new Container(
                      height: 0.0,
                    ),
            ],
          ),
        ),
        onTap: () {
          widget.isEditable && (!isShare)
              ? getImage(ImageSource.gallery)
              : null;
        },
      );
    }
    //*****************************************************************************************************

    Padding getShareButton() {
      return PaddingWrap.paddingfromLTRB(
          0.0,
          0.0,
          0.0,
          10.0,
          new Row(
            children: <Widget>[
              new Expanded(
                child: new InkWell(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        "assets/profile/share_profile.png",
                        width: 25.0,
                        height: 25.0,
                      ),
                      PaddingWrap.paddingAll(
                        5.0,
                        TextViewWrap.textView("Share", TextAlign.center,
                            Colors.grey, 13.0, FontWeight.normal),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      isShare = true;
                    });
                  },
                ),
                flex: 1,
              ),
            ],
          ));
    }

    Padding getUiButtonsIfStudentLoggedIn() {
      return PaddingWrap.paddingfromLTRB(
          10.0,
          10.0,
          10.0,
          10.0,
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    isConnected
                        ? new Column(
                            children: <Widget>[
                              isAccepetd
                                  ? new Image.asset(
                                      "assets/profile/connected.png",
                                      width: 25.0,
                                      height: 25.0,
                                    )
                                  : new Image.asset(
                                      "assets/profile/user/pending.png",
                                      width: 25.0,
                                      height: 25.0,
                                    ),
                              PaddingWrap.paddingAll(
                                5.0,
                                TextViewWrap.textView(
                                    isAccepetd ? "Connected" : "Pending",
                                    TextAlign.center,
                                    new Color(ColorValues.BLUE_COLOR),
                                    13.0,
                                    FontWeight.normal),
                              )
                            ],
                          )
                        : new InkWell(
                            child: new Column(
                              children: <Widget>[
                                new Image.asset(
                                  "assets/profile/connect.png",
                                  width: 25.0,
                                  height: 25.0,
                                ),
                                PaddingWrap.paddingAll(
                                  5.0,
                                  TextViewWrap.textView(
                                      "Connect",
                                      TextAlign.center,
                                      Colors.grey,
                                      13.0,
                                      FontWeight.normal),
                                )
                              ],
                            ),
                            onTap: () {
                              apiCallForConnect();
                            },
                          )
                  ],
                ),
                flex: 1,
              ),
              isSubscribe
                  ? new Expanded(
                      child: new InkWell(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Image.asset(
                              "assets/profile/user/unsubscribe.png",
                              width: 25.0,
                              height: 25.0,
                            ),
                            PaddingWrap.paddingAll(
                              5.0,
                              TextViewWrap.textView(
                                  "Unsubscribe",
                                  TextAlign.center,
                                  new Color(ColorValues.BLUE_COLOR),
                                  13.0,
                                  FontWeight.normal),
                            )
                          ],
                        ),
                        onTap: () {
                          apiCallForUnSubscribe();
                        },
                      ),
                      flex: 1,
                    )
                  : new Expanded(
                      child: new InkWell(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Image.asset(
                              "assets/profile/subscribe.png",
                              width: 25.0,
                              height: 25.0,
                            ),
                            PaddingWrap.paddingAll(
                              5.0,
                              TextViewWrap.textView(
                                  "Subscribe",
                                  TextAlign.center,
                                  Colors.grey,
                                  13.0,
                                  FontWeight.normal),
                            )
                          ],
                        ),
                        onTap: () {
                          apiCallForSubscribe();
                        },
                      ),
                      flex: 1,
                    ),
              isConnected && isAccepetd
                  ? new Expanded(
                      child: new InkWell(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Image.asset(
                              "assets/profile/message_profile.png",
                              width: 25.0,
                              height: 25.0,
                            ),
                            PaddingWrap.paddingAll(
                              5.0,
                              TextViewWrap.textView("Message", TextAlign.center,
                                  Colors.grey, 13.0, FontWeight.normal),
                            )
                          ],
                        ),
                        onTap: () {
                          print("userId" +
                              prefs.getString(UserPreference.USER_ID));
                          print("partenrid" + connectionModel.userId);
                          print("connectId" + connectionModel.connectId);
                          ConnectionListModel model = new ConnectionListModel(
                              prefs.getString(UserPreference.USER_ID),
                              profileInfoModal.firstName,
                              profileInfoModal.lastName,
                              profileInfoModal.email,
                              profileInfoModal.profilePicture,
                              new DateTime.now().millisecondsSinceEpoch,
                              connectionModel.userId,
                              connectionModel.connectId,
                              "",
                              "",
                              profileInfoModal.firstName,
                              profileInfoModal.lastName,
                              profileInfoModal.profilePicture);

                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ChatRoomHome(model, "", "")));
                        },
                      ),
                      flex: 1,
                    )
                  : new Expanded(
                      child: new Container(
                        height: 0.0,
                        width: 0.0,
                      ),
                      flex: 0,
                    ),
            ],
          ));
    }

    Padding getUiButtonsIfParentLoggedIn() {
      return PaddingWrap.paddingfromLTRB(
          0.0,
          10.0,
          0.0,
          10.0,
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    isConnected
                        ? new Column(
                            children: <Widget>[
                              isAccepetd
                                  ? new Image.asset(
                                      "assets/profile/connected.png",
                                      width: 25.0,
                                      height: 25.0,
                                    )
                                  : new Image.asset(
                                      "assets/profile/user/pending.png",
                                      width: 25.0,
                                      height: 25.0,
                                    ),
                              PaddingWrap.paddingAll(
                                5.0,
                                TextViewWrap.textView(
                                    isAccepetd ? "Connected" : "Pending",
                                    TextAlign.center,
                                    new Color(ColorValues.BLUE_COLOR),
                                    13.0,
                                    FontWeight.normal),
                              )
                            ],
                          )
                        : new InkWell(
                            child: new Column(
                              children: <Widget>[
                                new Image.asset(
                                  "assets/profile/connect.png",
                                  width: 25.0,
                                  height: 25.0,
                                ),
                                PaddingWrap.paddingAll(
                                  5.0,
                                  TextViewWrap.textView(
                                      "Connect",
                                      TextAlign.center,
                                      Colors.grey,
                                      13.0,
                                      FontWeight.normal),
                                )
                              ],
                            ),
                            onTap: () {
                              apiCallForConnect();
                            },
                          )
                  ],
                ),
                flex: 1,
              ),
              new Expanded(
                child: new InkWell(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        "assets/profile/message_profile.png",
                        width: 25.0,
                        height: 25.0,
                      ),
                      PaddingWrap.paddingAll(
                        5.0,
                        TextViewWrap.textView("Message", TextAlign.center,
                            Colors.grey, 13.0, FontWeight.normal),
                      )
                    ],
                  ),
                  onTap: () {
                    ToastWrap.showToast("In progress ..");
                  },
                ),
                flex: 1,
              ),
              new Expanded(
                child: new InkWell(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        "assets/profile/share_profile.png",
                        width: 25.0,
                        height: 25.0,
                      ),
                      PaddingWrap.paddingAll(
                        5.0,
                        TextViewWrap.textView("Share", TextAlign.center,
                            Colors.grey, 13.0, FontWeight.normal),
                      )
                    ],
                  ),
                  onTap: () {
                    ToastWrap.showToast("In progress ..");
                  },
                ),
                flex: 1,
              ),
              isSubscribe
                  ? new Expanded(
                      child: new InkWell(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Image.asset(
                              "assets/profile/user/unsubscribe.png",
                              width: 25.0,
                              height: 25.0,
                            ),
                            PaddingWrap.paddingAll(
                              5.0,
                              TextViewWrap.textView(
                                  "Unsubscribe",
                                  TextAlign.center,
                                  new Color(ColorValues.BLUE_COLOR),
                                  13.0,
                                  FontWeight.normal),
                            )
                          ],
                        ),
                        onTap: () {
                          apiCallForUnSubscribe();
                        },
                      ),
                      flex: 1,
                    )
                  : new Expanded(
                      child: new InkWell(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Image.asset(
                              "assets/profile/subscribe.png",
                              width: 25.0,
                              height: 25.0,
                            ),
                            PaddingWrap.paddingAll(
                              5.0,
                              TextViewWrap.textView(
                                  "Subscribe",
                                  TextAlign.center,
                                  Colors.grey,
                                  13.0,
                                  FontWeight.normal),
                            )
                          ],
                        ),
                        onTap: () {
                          apiCallForSubscribe();
                        },
                      ),
                      flex: 1,
                    )
            ],
          ));
    }

    //----------------------------Add Summary Button click and ui view ----------------
    onTapAddSummaryBtn() async {
      if (widget.isEditable) {
        String result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new AddSummary(" Add Summary", profileInfoModal.summary)));
        if (result != null && result != "") profileInfoModal.summary = result;
      }
    }

    onTapEditSummaryBtn() async {
      if (widget.isEditable && (!isShare)) {
        String result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new AddSummary(" Edit Summary", profileInfoModal.summary)));
        if (result != null && result != "") profileInfoModal.summary = result;
      }
    }

    Container getAddSummaryButtonUi() {
      return new Container(
          color: Colors.white,
          child: Padding(
              padding: new EdgeInsets.only(
                  left: 40.0, top: 40.0, right: 40.0, bottom: 40.0),
              child: new Container(
                  height: 50.0,
                  child: FlatButton(
                    onPressed: onTapAddSummaryBtn,
                    color: new Color(ColorValues.BLUE_COLOR),
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Add Summary ',
                            style: TextStyle(
                                fontFamily: 'customBold', color: Colors.white)),
                      ],
                    ),
                  ))));
    }
    //----------------------------Add Education Button click and ui view ----------------

    onTapAddEducationBtn() async {
      if (widget.isEditable) {
        final result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new AddEducation(
                profileInfoModal.dob, profileInfoModal.isActive)));
        print(result);
        if (result == "push") {
          eductionApi(true);
        }
      }
    }

    Container getAddEductionButtonUi() {
      return new Container(
          color: Colors.white,
          child: Padding(
              padding: new EdgeInsets.only(
                  left: 40.0, top: 40.0, right: 40.0, bottom: 40.0),
              child: new Container(
                  height: 50.0,
                  child: FlatButton(
                    onPressed: onTapAddEducationBtn,
                    color: new Color(ColorValues.BLUE_COLOR),
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Add Education ',
                            style: TextStyle(
                                fontFamily: 'customBold', color: Colors.white)),
                      ],
                    ),
                  ))));
    }

    //=====================================On Tap =============================
    onTapNarative(index) async {
      if (widget.isEditable) {
        final result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new CompetenciesWidget(index, "")));
        print(result);
        if (result == "push") {
          spiderChart(true);
          narrativeApi(true);
        }
      }
    }

    onTapEditNarative(index, name) async {
      if (widget.isEditable) {
        final result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new CompetenciesWidget(index, name)));
        print(result);
        if (result == "push") {
          spiderChart(true);
          narrativeApi(true);
          recommendationApi(true);
        }
      }
    }

    onTapViewAll() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new AllRecommendationList(profileInfoModal)));
      if (result == "push") {
        spiderChart(true);
        narrativeApi(true);
        recommendationApi(true);
      }
    }

    //--------------------------------My Narrative UI View --------------------------------
    Container getNarrativeUi() {
      return new Container(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          height: 120.0,
          color: Colors.white,
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new InkWell(
                  child: new Container(
                      decoration: const BoxDecoration(
                        border: const Border(
                          right: const BorderSide(
                              width: 0.8, color: const Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: PaddingWrap.paddingAll(
                        10.0,
                        new Column(
                          children: <Widget>[
                            new Center(
                                child: new Container(
                              child: new Image.asset("assets/profile/arts.png"),
                              width: 30.0,
                              height: 30.0,
                            )),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                8.0,
                                0.0,
                                0.0,
                                new Text(
                                  "Arts Competency",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      )),
                  onTap: () {
                    onTapNarative(0);
                  },
                ),
                flex: 1,
              ),
              new Expanded(
                child: new InkWell(
                  child: new Container(
                      decoration: const BoxDecoration(
                        border: const Border(
                          right: const BorderSide(
                              width: 0.8, color: const Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: PaddingWrap.paddingAll(
                        10.0,
                        new Column(
                          children: <Widget>[
                            new Center(
                                child: new Container(
                              child: new Image.asset(
                                  "assets/profile/Vocational.png"),
                              width: 30.0,
                              height: 30.0,
                            )),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                8.0,
                                0.0,
                                0.0,
                                new Text(
                                  "Vocational Competency",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      )),
                  onTap: () {
                    onTapNarative(1);
                  },
                ),
                flex: 1,
              ),
              new Expanded(
                child: new InkWell(
                  child: new Container(
                      decoration: const BoxDecoration(
                        border: const Border(
                          right: const BorderSide(
                              width: 0.8, color: const Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: PaddingWrap.paddingAll(
                        10.0,
                        new Column(
                          children: <Widget>[
                            new Center(
                                child: new Container(
                              child: new Image.asset(
                                  "assets/profile/acadamic.png"),
                              width: 30.0,
                              height: 30.0,
                            )),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                8.0,
                                0.0,
                                0.0,
                                new Text(
                                  "Academic Competency",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      )),
                  onTap: () {
                    onTapNarative(2);
                  },
                ),
                flex: 1,
              ),
              new Expanded(
                child: new InkWell(
                  child: new Container(
                      decoration: const BoxDecoration(
                        border: const Border(
                          right: const BorderSide(
                              width: 0.8, color: const Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: PaddingWrap.paddingAll(
                        10.0,
                        new Column(
                          children: <Widget>[
                            new Center(
                                child: new Container(
                              child:
                                  new Image.asset("assets/profile/sports.png"),
                              width: 30.0,
                              height: 30.0,
                            )),
                            PaddingWrap.paddingfromLTRB(
                                0.0,
                                8.0,
                                0.0,
                                0.0,
                                new Text(
                                  "Sports Competency",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      )),
                  onTap: () {
                    onTapNarative(3);
                  },
                ),
                flex: 1,
              ),
            ],
          ));
    }

//---------------------------------------------- Label text UI -----------------------
    Container label(text) {
      return new Container(
        color: new Color(0XFFF7F7F9),
        padding: new EdgeInsets.all(20.0),
        child: new Center(
            child: new Stack(
          children: <Widget>[
            new Positioned.fill(
              left: 0.0,
              right: 0.0,
              child: new Divider(color: Colors.grey[300]),
            ),
            new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  color: new Color(0XFFF7F7F9),
                  child: new Text(
                    text,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                )
              ],
            ),
          ],
        )),
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
            widget.isEditable && (!isShare)
                ? new Positioned(
                    right: 20.0,
                    top: 100.0,
                    child: new InkWell(
                      child: new Container(
                        padding: new EdgeInsets.fromLTRB(80.0, 0.0, 0.0, 0.0),
                        child: new Image.asset("assets/profile/cover_edit.png"),
                        height: 25.0,
                      ),
                      onTap: () {
                        widget.isEditable && (!isShare)
                            ? getImageCover()
                            : null;
                      },
                    ))
                : new Container(
                    height: 0.0,
                  ),
          ],
        ),
      );
    }

    //---------------------------------- Eduction List item Ui -----------------------------
    onTapEducationItemEditBtn(profileEducationModal) async {
      if (widget.isEditable) {
        print("clicked edit");
        final result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new EditEducationWidget(
                profileInfoModal.dob,
                profileInfoModal.isActive,
                profileEducationModal)));
        print(result);
        if (result == "push") {
          eductionApi(true);
        }
      }
    }

    showDialogDeleteAchievment(educationId, orgName, index) {
      showDialog(
        context: context,
        barrierDismissible: false,
        child: new Dialog(
          child: new Container(
              height: 180.0,
              color: Colors.white,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                            child: new Text(
                              "Are you sure ?",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.grey),
                            )),
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                            child: new Text(
                              "You want to delete $orgName  instiute ?",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Colors.grey),
                            )),
                        new Container(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                PaddingWrap.paddingfromLTRB(
                                    5.0,
                                    0.0,
                                    5.0,
                                    0.0,
                                    new Container(
                                      decoration: new BoxDecoration(
                                          border: new Border.all(
                                              color: Colors.white)),
                                      height: 40.0,
                                      width: 100.0,
                                      child: new FlatButton(
                                          color: new Color(0XFFC74647),
                                          onPressed: () {
                                            deleteEducation(educationId, index);
                                            Navigator.pop(context);
                                          },
                                          child: new Text("Delete",
                                              style: new TextStyle(
                                                  color: Colors.white))),
                                    )),
                                PaddingWrap.paddingfromLTRB(
                                    5.0,
                                    0.0,
                                    5.0,
                                    0.0,
                                    new Container(
                                      decoration: new BoxDecoration(
                                          border: new Border.all(
                                              color: Colors.white)),
                                      height: 40.0,
                                      width: 100.0,
                                      child: new FlatButton(
                                          color: Colors.black54,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: new Text("Cancel",
                                              style: new TextStyle(
                                                  color: Colors.white))),
                                    )),
                              ],
                            )),
                      ],
                    ),
                    flex: 4,
                  ),
                ],
              )),
        ),
      );
    }

    onTapEmailShare() async {
      List<String> dataList = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new EmailShareWidget("SHARE WITH")));
      if (dataList != null && dataList.length > 0) {
        shareName = dataList[0];
        shareLastName = dataList[1];
        shareEmail = dataList[2];
        apiCallForShare("Email");
      }
    }

    showDialogForShareType() {
      showDialog(
        context: context,
        barrierDismissible: true,
        child: new Dialog(
          child: new Container(
              height: 150.0,
              color: Colors.white,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new InkWell(
                    child: PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        8.0,
                        15.0,
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: new Image.asset(
                                "assets/profile/user/share_profile1.png",
                                width: 30.0,
                                height: 30.0,
                              ),
                              flex: 1,
                            ),
                            new Expanded(
                              child: TextViewWrap.textView(
                                  " Share As Message",
                                  TextAlign.start,
                                  Colors.black,
                                  20.0,
                                  FontWeight.w500),
                              flex: 4,
                            )
                          ],
                        )),
                    onTap: () {
                      Navigator.pop(context);
                      apiCallForShare("Message");
                    },
                  ),
                  new InkWell(
                    child: PaddingWrap.paddingfromLTRB(
                        10.0,
                        8.0,
                        10.0,
                        15.0,
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: new Image.asset(
                                "assets/profile/user/share_profile1.png",
                                width: 30.0,
                                height: 30.0,
                              ),
                              flex: 1,
                            ),
                            new Expanded(
                              child: TextViewWrap.textView(
                                  " Share As Email",
                                  TextAlign.start,
                                  Colors.black,
                                  20.0,
                                  FontWeight.w500),
                              flex: 4,
                            )
                          ],
                        )),
                    onTap: () {
                      Navigator.pop(context);
                      onTapEmailShare();
                      //apiCallForShare("Email");
                    },
                  )
                ],
              )),
        ),
      );
    }

    Container getEducationListItem(index) {
      return new Container(
          color: Colors.white,
          child: new InkWell(
            child: PaddingWrap.paddingfromLTRB(
                0.0,
                10.0,
                0.0,
                0.0,
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: PaddingWrap.paddingfromLTRB(
                          10.0,
                          0.0,
                          10.0,
                          10.0,
                          userEducationList[index].logo == "" ||
                                  userEducationList[index].logo == "null"
                              ? Image.asset(
                                  "assets/profile/img_default.png",
                                  height: 60.0,
                                  width: 60.0,
                                )
                              : new Container(
                                  height: 60.0,
                                  width: 60.0,
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    placeholder:
                                        'assets/profile/img_default.png',
                                    image: Constant.IMAGE_PATH +
                                        userEducationList[index].logo,
                                  ))),
                      flex: 0,
                    ),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          PaddingWrap.paddingAll(
                              5.0,
                              new Text(
                                userEducationList[index].institute,
                                maxLines: 1,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0),
                              )),
                          new Row(
                            children: <Widget>[
                              PaddingWrap.paddingAll(
                                  5.0,
                                  new Text(
                                    userEducationList[index].fromGrade +
                                        " - " +
                                        userEducationList[index].toGrade +
                                        " Grade",
                                    style: new TextStyle(
                                        color: new Color(
                                          ColorValues.BLUE_COLOR,
                                        ),
                                        fontSize: 15.0),
                                  )),
                              PaddingWrap.paddingAll(
                                  5.0,
                                  new Text(
                                    userEducationList[index].fromYear +
                                        " to " +
                                        userEducationList[index].toYear,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 15.0),
                                  ))
                            ],
                          )
                        ],
                      ),
                      flex: 5,
                    ),
                  ],
                )),
            onTap: () {
              if (widget.isEditable) {
                onTapEducationItemEditBtn(userEducationList[index]);
              }
            },
            onLongPress: () {
              if (widget.isEditable) {
                showDialogDeleteAchievment(userEducationList[index].educationId,
                    userEducationList[index].institute, index);
              }
            },
          ));
    }
//==========================Grid View horizontal for Narrative====================================

    Padding getgridAchivement(index) {
      return narrativeList[index].achivmentList != null &&
              narrativeList[index].achivmentList.length > 0
          ? PaddingWrap.paddingfromLTRB(
              5.0,
              10.0,
              5.0,
              10.0,
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
                    children: narrativeList[index]
                        .achivmentList
                        .map((Achivment achiv) {
                      return new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          achiv.assestList.length > 0
                              ? new Image.network(
                                  Constant.IMAGE_PATH +
                                      achiv.assestList[0].file,
                                  fit: BoxFit.fill,
                                  height: 80.0,
                                  width: 100.0,
                                )
                              : new Image.asset(
                                  "assets/profile/default_achievement.jpg",
                                  fit: BoxFit.fill,
                                  height: 80.0,
                                  width: 100.0),
                          PaddingWrap.paddingfromLTRB(
                              2.0,
                              5.0,
                              2.0,
                              0.0,
                              new Text(
                                achiv.title,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                style: new TextStyle(color: Colors.grey),
                              )),
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

    Container getgridBadges(index) {
      return narrativeList[index].badgeListAll != null &&
              narrativeList[index].badgeListAll.length > 0
          ? new Container(
              child: Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Image.asset(
                      "assets/profile/badges.png",
                      width: 30.0,
                      height: 30.0,
                    ),
                    TextViewWrap.textView("  Badges", TextAlign.start,
                        Colors.black, 16.0, FontWeight.bold)
                  ],
                ),
                PaddingWrap.paddingfromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                    new Container(
                        height: 80.0,
                        child: new GridView.count(
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisCount: 1,
                          childAspectRatio: .90,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 2.0,
                          children: narrativeList[index]
                              .badgeListAll
                              .map((String uri) {
                            return new Container(
                                child: new InkWell(
                              child: new Material(
                                  shape: new CircleBorder(),
                                  child: new Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: new NetworkImage(
                                            Constant.IMAGE_PATH_SMALL +
                                                ParseJson.getMediumImage(uri),
                                          )),
                                    ),
                                  )),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new HeroDialogRoute(
                                    builder: (BuildContext context) {
                                      return new Center(
                                        child: new AlertDialog(
                                          content: new Container(
                                            child: new Hero(
                                              tag: 'developer-hero',
                                              child: new Container(
                                                height: 200.0,
                                                width: 200.0,
                                                child: Image.network(
                                                  Constant.IMAGE_PATH_SMALL +
                                                      ParseJson.getMediumImage(
                                                          uri),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('Close'),
                                              onPressed:
                                                  Navigator.of(context).pop,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ));
                          }).toList(),
                        ))),
              ],
            ))
          : new Container(
              height: 1.0,
            );
    }

    Container getgridCertificate(index) {
      return narrativeList[index].certificateListAll != null &&
              narrativeList[index].certificateListAll.length > 0
          ? new Container(
              child: Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Image.asset(
                      "assets/profile/certificate.png",
                      width: 30.0,
                      height: 30.0,
                    ),
                    TextViewWrap.textView("  Certificate", TextAlign.start,
                        Colors.black, 16.0, FontWeight.bold)
                  ],
                ),
                PaddingWrap.paddingfromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                    new Container(
                        height: 80.0,
                        child: new GridView.count(
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisCount: 1,
                          childAspectRatio: .90,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 2.0,
                          children: narrativeList[index]
                              .certificateListAll
                              .map((String uri) {
                            return new InkWell(
                              child: new Image.network(
                                Constant.IMAGE_PATH + uri,
                                fit: BoxFit.fill,
                                height: 80.0,
                                width: 80.0,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new HeroDialogRoute(
                                    builder: (BuildContext context) {
                                      return new Center(
                                        child: new AlertDialog(
                                          content: new Container(
                                            child: new Hero(
                                              tag: 'developer-hero',
                                              child: new Container(
                                                height: 200.0,
                                                width: 200.0,
                                                child: Image.network(
                                                  Constant.IMAGE_PATH_SMALL +
                                                      ParseJson.getMediumImage(
                                                          uri),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('Close'),
                                              onPressed:
                                                  Navigator.of(context).pop,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ))),
              ],
            ))
          : new Container(
              height: 1.0,
            );
    }

    Container getgridRecommendation(index) {
      return narrativeList[index].recommendationtList != null &&
              narrativeList[index].recommendationtList.length > 0
          ? new Container(
              child: Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Image.asset(
                      "assets/profile/recommendation.png",
                      width: 30.0,
                      height: 30.0,
                    ),
                    TextViewWrap.textView("  Recommendation", TextAlign.start,
                        Colors.black, 16.0, FontWeight.bold)
                  ],
                ),
                PaddingWrap.paddingfromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                    new Container(
                        height: 140.0,
                        child: new GridView.count(
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisCount: 1,
                          childAspectRatio: .90,
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 2.0,
                          children: narrativeList[index]
                              .recommendationtList
                              .map((Recomdation recommendation) {
                            return new Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Image.asset(
                                      "assets/profile/recommendation_default.png",
                                      width: 40.0,
                                      height: 40.0,
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        PaddingWrap.paddingAll(
                                            5.0,
                                            TextViewWrap.textView(
                                                recommendation
                                                    .recommender.firstName,
                                                TextAlign.start,
                                                Colors.black,
                                                16.0,
                                                FontWeight.bold)),
                                      ],
                                    ),
                                    /* PaddingWrap.paddingAll(
                                        5.0,
                                        TextViewWrap.textView(
                                            recommendation.title,
                                            TextAlign.start,
                                            Colors.black,
                                            15.0,
                                            FontWeight.normal)),*/
                                    /*    new InkWell(
                                      child: TextViewWrap.textView(
                                          recommendation.stage == "Requested"
                                              ? "Pending"
                                              : recommendation.stage ==
                                                      "Replied"
                                                  ? "Add to profile"
                                                  : "",
                                          TextAlign.right,
                                          Colors.orange,
                                          13.0,
                                          FontWeight.bold),
                                      onTap: () {
                                        if (recommendation.stage == "Replied") {
                                          apiCallForAddRecommendation(
                                              recommendation);
                                        }
                                      },
                                    ),*/

                                    recommendation.stage == "Replied"
                                        ? new Center(
                                            child: new InkWell(
                                            child: new Container(
                                                decoration: new BoxDecoration(
                                                    border: new Border.all(
                                                        color: const Color(
                                                            ColorValues
                                                                .BLUE_COLOR))),
                                                child: PaddingWrap.paddingAll(
                                                  5.0,
                                                  new Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new Image.asset(
                                                        "assets/profile/plus.png",
                                                        height: 10.0,
                                                        width: 10.0,
                                                      ),
                                                      TextViewWrap.textView(
                                                          "Add to profile",
                                                          TextAlign.center,
                                                          new Color(ColorValues
                                                              .BLUE_COLOR),
                                                          12.0,
                                                          FontWeight.bold),
                                                    ],
                                                  ),
                                                )),
                                            onTap: () {
                                              if (recommendation.stage ==
                                                  "Replied") {
                                                apiCallForAddRecommendation(
                                                    recommendation);
                                              }
                                            },
                                          ))
                                        : TextViewWrap.textView(
                                            recommendation.stage == "Requested"
                                                ? "Pending"
                                                : "",
                                            TextAlign.right,
                                            Colors.orange,
                                            13.0,
                                            FontWeight.bold),
                                  ],
                                )
                              ],
                            );
                          }).toList(),
                        ))),
              ],
            ))
          : new Container(
              height: 1.0,
            );
    }

    Container getRecommendation() {
      return recommendationtList != null && recommendationtList.length > 0
          ? new Container(
              child: Column(
              children: <Widget>[
                PaddingWrap.paddingfromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                    new Container(
                        height: 165.0,
                        child: new GridView.count(
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisCount: 1,
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 2.0,
                          children: new List.generate(
                              recommendationtList.length > 2
                                  ? 2
                                  : recommendationtList.length, (int index) {
                            return new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new InkWell(
                                    child: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Image.asset(
                                            "assets/profile/recommendation_default.png",
                                            width: 60.0,
                                            height: 60.0,
                                          ),
                                          PaddingWrap.paddingAll(
                                              5.0,
                                              TextViewWrap.textView(
                                                  recommendationtList[index]
                                                              .recommender
                                                              .lastName ==
                                                          "null"
                                                      ? recommendationtList[
                                                              index]
                                                          .recommender
                                                          .firstName
                                                      : recommendationtList[
                                                                  index]
                                                              .recommender
                                                              .firstName +
                                                          " " +
                                                          recommendationtList[
                                                                  index]
                                                              .recommender
                                                              .lastName,
                                                  TextAlign.start,
                                                  Colors.black,
                                                  16.0,
                                                  FontWeight.bold)),
                                          recommendationtList[index].stage ==
                                                  "Requested"
                                              ? TextViewWrap.textView(
                                                  "Pending",
                                                  TextAlign.right,
                                                  Colors.orange,
                                                  13.0,
                                                  FontWeight.bold)
                                              : recommendationtList[index]
                                                          .stage ==
                                                      "Added"
                                                  ? TextViewWrap.textView(
                                                      "Added",
                                                      TextAlign.right,
                                                      Colors.orange,
                                                      13.0,
                                                      FontWeight.bold)
                                                  : new Container(
                                                      height: 0.0,
                                                    ),
                                        ]),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new RecommendationDetail(
                                                      recommendationtList[
                                                          index],
                                                      profileInfoModal)));

                                      /*       Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new AllRecommendationList(
                                                recommendationtList,
                                                profileInfoModal)));*/
                                    }),

                                /* PaddingWrap.paddingAll(
                                      5.0,
                                      TextViewWrap.textView(
                                          recommendationtList[index].title,
                                          TextAlign.start,
                                          Colors.black,
                                          16.0,
                                          FontWeight.normal)),*/

                                recommendationtList[index].stage == "Replied"
                                    ? new Center(
                                        child: new InkWell(
                                        child: new Container(
                                            width: 100.0,
                                            decoration: new BoxDecoration(
                                                border: new Border.all(
                                                    color: const Color(
                                                        ColorValues
                                                            .BLUE_COLOR))),
                                            child: PaddingWrap.paddingAll(
                                              0.0,
                                              new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/plus.png",
                                                    height: 10.0,
                                                    width: 10.0,
                                                  ),
                                                  TextViewWrap.textView(
                                                      "Add to profile",
                                                      TextAlign.center,
                                                      new Color(ColorValues
                                                          .BLUE_COLOR),
                                                      12.0,
                                                      FontWeight.bold),
                                                ],
                                              ),
                                            )),
                                        onTap: () {
                                          if (recommendationtList[index]
                                                  .stage ==
                                              "Replied") {
                                            apiCallForAddRecommendation(
                                                recommendationtList[index]);
                                          }
                                        },
                                      ))
                                    : new Container(
                                        height: 0.0,
                                      )
                              ],
                            );
                          }).toList(),
                        ))),
              ],
            ))
          : new Container(
              height: 1.0,
            );
    }

//================================================OnTap ======================
    final summaryUI = PaddingWrap.paddingAll(
        10.0,
        new Container(
            padding: new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 20.0),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.grey[300])),
            child: new TextFormField(
              enabled: false,
              maxLines: null,
              keyboardType: TextInputType.text,
              controller: new TextEditingController(
                  text:
                      profileInfoModal != null ? profileInfoModal.summary : ""),
              decoration: new InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
              ),
              validator: (val) => val.isEmpty ? 'can\'t be empty.' : null,
              onSaved: (val) => strSummary = val,
            )));

    onTapEdit() async {
      if (profileInfoModal != null) {
        String result = await Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                new EditUserProfile(profileInfoModal)));
        if (result == "push") {
          profileApi(true);
        }
      }
    }

    void importanceBottomSheet(context) async {
      await showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return new Stack(
              children: <Widget>[
                PaddingWrap.paddingfromLTRB(
                    0.0,
                    20.0,
                    0.0,
                    0.0,
                    ListView(
                        children: <Widget>[ModalBottomSheet(narrativeList)])),
                new Align(
                  alignment: Alignment.topRight,
                  child: new InkWell(
                    child: PaddingWrap.paddingAll(
                        10.0,
                        TextViewWrap.textView("Done", TextAlign.right,
                            Colors.black, 16.0, FontWeight.normal)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          });

      for (int i = 0; i < narrativeList.length; i++) {
        try {
          narrativeList[i].achivmentList.clear();
          narrativeList[i].achivmentList = await mainNarrativeList[i]
              .achivmentList
              .map((item) => new Achivment.clone(item))
              .toList();
          indexRemoveList.clear();
          for (int j = 0; j < narrativeList[i].achivmentList.length; j++) {
            if (int.parse(narrativeList[i].achivmentList[j].importance) >=
                narrativeList[i].imoportanceValue.toInt()) {
              String s = "";
            } else {
              indexRemoveList.add(j);
            }
          }

          for (int k = 0; k < indexRemoveList.length; k++) {
            if (k == 0)
              narrativeList[i].achivmentList.removeAt(indexRemoveList[k]);
            else
              narrativeList[i].achivmentList.removeAt(indexRemoveList[k] - 1);
          }
        } catch (e) {
          e.toString();
        }

        if (i == narrativeList.length - 1) {
          setState(() {
            narrativeList;
          });
        }
      }
    }

    Container summaryView() {
      return new Container(
          color: Colors.white,
          child: new InkWell(
            child: new Container(
              child: new TextFormField(
                enabled: false,
                maxLines: null,
                controller: new TextEditingController(
                    text: profileInfoModal == null &&
                            profileInfoModal.summary == "null"
                        ? "No Summary"
                        : profileInfoModal.summary),
                keyboardType: TextInputType.multiline,
                decoration: new InputDecoration(
                  filled: true,
                  labelText: "",
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            onTap: onTapEditSummaryBtn,
          ));
    }

    return new WillPopScope(
        onWillPop: () {


          if (!isShare) {
            if(widget.pageRedirect!=""){
              CustomProgressLoader.showDialogBackDialog(context);
            }else {
              Navigator.pop(context);
            }
          } else {
            refresh();
            setState(() {
              isShare = false;
            });
          }

        },
        child: new Scaffold(
          appBar: isShare
              ? new AppBar(
                  automaticallyImplyLeading: false,
            titleSpacing: 2.0,
            brightness: Brightness.light,
                  leading: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new InkWell(
                        child: new Image.asset(
                          "assets/profile/post/back_arrow_blue.png",
                          height: 25.0,
                          width: 25.0,
                        ),
                        onTap: () {
                          refresh();
                          setState(() {
                            isShare = false;
                          });
                        },
                      )
                    ],
                  ),
                 /* title: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      PaddingWrap.paddingfromLTRB(
                          0.0,
                          0.0,
                          10.0,
                          0.0,
                          new Image.asset(
                            "assets/share/linear_view.png",
                            height: 25.0,
                            width: 25.0,
                          )),
                      PaddingWrap.paddingfromLTRB(
                          10.0,
                          0.0,
                          0.0,
                          0.0,
                          new Image.asset(
                            "assets/share/aerial_view.png",
                            height: 25.0,
                            width: 25.0,
                          ))
                    ],
                  ),*/
                  actions: <Widget>[
                    PaddingWrap.paddingAll(
                        10.0,
                        new InkWell(
                          child: new Container(
                              width: 70.0,
                              child: new Image.asset(
                                "assets/view.png",
                              )),
                          onTap: () {

                          },
                        )),
                    PaddingWrap.paddingAll(
                        10.0,
                        new InkWell(
                          child: new Container(
                              width: 70.0,
                              child: new Image.asset(
                                "assets/filter.png",
                              )),
                          onTap: () {
                            if (narrativeList.length > 0) {
                              importanceBottomSheet(context);
                            }
                          },
                        )),
                    PaddingWrap.paddingAll(
                        10.0,
                        new InkWell(
                          child: new Container(
                              width: 70.0,
                              child: new Image.asset(
                                "assets/share/share_button.png",
                              )),
                          onTap: () {
                            showDialogForShareType();
                          },
                        ))
                  ],
                  backgroundColor: Colors.white,
                )
              : new AppBar(
                  automaticallyImplyLeading: false,
                  leading: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new InkWell(
                        child: PaddingWrap.paddingfromLTRB(5.0, 0.0, 0.0, 0.0,new Image.asset(
                          "assets/home/homei.png",
                          height: 32.0,
                          width: 32.0,
                        )),
                        onTap: () {
                         if(widget.pageRedirect=="")
                          Navigator.pop(context);
                         else
                           Navigator.of(context).pushReplacement(new MaterialPageRoute(
                               builder: (BuildContext context) =>
                               new DashBoardWidget()));
                        },
                      )
                    ],
                  ),
                  title: new Text(""),
                  actions: <Widget>[
                    widget.isEditable
                        ? isParent
                            ? new Container(
                                height: 0.0,
                              )
                            : new InkWell(
                                child: new Image.asset(
                                  "assets/profile/user/edit_profile.png",
                                  height: 25.0,
                                  width: 25.0,
                                ),
                                onTap: () {
                                  onTapEdit();
                                },
                              )
                        : new Container(
                            height: 0.0,
                          )
                  ],
                  backgroundColor: new Color(ColorValues.BLUE_COLOR),
                ),
          body: new Stack(
            children: <Widget>[
              new Positioned(
                  bottom: isShare ? 60.0 : 0.0,
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  child: new Container(
                      color: new Color(0XFFF7F7F9),
                      child: new Stack(
                        children: <Widget>[
                          new ListView(
                            children: <Widget>[
                              new Column(
                                children: <Widget>[
                                  headerUiDesign(),
                                  PaddingWrap.paddingfromLTRB(
                                      0.0,
                                      0.0,
                                      0.0,
                                      8.0,
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          PaddingWrap.paddingAll(
                                            2.0,
                                            TextViewWrap.textView(
                                                profileInfoModal == null
                                                    ? ""
                                                    : profileInfoModal
                                                                    .lastName ==
                                                                "" ||
                                                            profileInfoModal
                                                                    .lastName ==
                                                                "null"
                                                        ? profileInfoModal
                                                            .firstName
                                                        : profileInfoModal
                                                                .firstName +
                                                            " " +
                                                            profileInfoModal
                                                                .lastName,
                                                TextAlign.center,
                                                Colors.black,
                                                20.0,
                                                FontWeight.bold),
                                          ),
                                          isEditTagline
                                              ? new Container(
                                                  height: 1.0,
                                                )
                                              : new Container(

                                                  //   width: 200.0,
                                                  child: new Stack(
                                                  children: <Widget>[
                                                    new Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: PaddingWrap.paddingfromLTRB(
                                                            10.0,
                                                            5.0,
                                                            10.0,
                                                            5.0,
                                                            TextViewWrap.textView(
                                                                profileInfoModal ==
                                                                            null ||
                                                                        profileInfoModal.tagline ==
                                                                            "null"
                                                                    ? ""
                                                                    : profileInfoModal
                                                                        .tagline,
                                                                TextAlign
                                                                    .center,
                                                                Colors.grey,
                                                                15.0,
                                                                FontWeight
                                                                    .normal))),
                                                    /*  new Align(
                                          alignment: Alignment.topRight,
                                          child: new InkWell(
                                            child: PaddingWrap.paddingAll(
                                                5.0,
                                                new Image.asset(
                                                  "assets/profile/edit.png",
                                                  width: 20.0,
                                                  height: 20.0,
                                                )),
                                            onTap: () {
                                              if (isEditTagline) {
                                                isEditTagline = false;
                                              } else {
                                                isEditTagline = true;
                                              }
                                              setState(() {
                                                isEditTagline;
                                              });
                                            },
                                          )),*/
                                                  ],
                                                )),
                                          isEditTagline
                                              ? PaddingWrap.paddingAll(
                                                  5.0,
                                                  new TextFormField(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    controller: addTagline,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    decoration: new InputDecoration(
                                                        filled: true,
                                                        border: InputBorder.none,
                                                        fillColor: Colors.transparent,
                                                        suffixIcon: new InkWell(
                                                            child: PaddingWrap.paddingfromLTRB(
                                                                5.0,
                                                                0.0,
                                                                5.0,
                                                                5.0,
                                                                new Image.asset(
                                                                  "assets/profile/tick_save.png",
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                )),
                                                            onTap: () {
                                                              if (widget
                                                                  .isEditable) {
                                                                if (isEditTagline) {
                                                                  isEditTagline =
                                                                      false;
                                                                } else {
                                                                  isEditTagline =
                                                                      true;
                                                                }
                                                                setState(() {
                                                                  isEditTagline;
                                                                });
                                                                if (addTagline
                                                                        .text !=
                                                                    "") {
                                                                  apiCallingforTagline();
                                                                }
                                                              }
                                                            })),
                                                  ),
                                                )
                                              : new Container(
                                                  height: 1.0,
                                                )
                                        ],
                                      )),
                                  widget.userId == ""
                                      ? profileInfoModal != null &&
                                              profileInfoModal.isActive ==
                                                  "true"
                                          ? isShare
                                              ? new Container(
                                                  height: 0.0,
                                                )
                                              : getShareButton()
                                          : PaddingWrap.paddingAll(
                                              10.0,
                                              TextViewWrap.textView(
                                                  "Your Profile is Inactive, Until Your Parent Approves",
                                                  TextAlign.center,
                                                  Colors.black,
                                                  14.0,
                                                  FontWeight.normal))
                                      : getUiButtonsIfStudentLoggedIn(),
                                  new Container(
                                    padding: new EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 10.0),
                                    height: 80.0,
                                    color: Colors.white,
                                    child: new Row(
                                      children: <Widget>[
                                        new Expanded(
                                          child: new Container(
                                              decoration: const BoxDecoration(
                                                border: const Border(
                                                  right: const BorderSide(
                                                      width: 0.8,
                                                      color: const Color(
                                                          0xFFEEEEEE)),
                                                ),
                                              ),
                                              child: PaddingWrap.paddingAll(
                                                10.0,
                                                new Column(
                                                  children: <Widget>[
                                                    TextViewWrap.textView(
                                                        "Accomplishments",
                                                        TextAlign.center,
                                                        Colors.black,
                                                        12.0,
                                                        FontWeight.bold),
                                                    PaddingWrap.paddingAll(
                                                        5.0,
                                                        TextViewWrap.textView(
                                                            strAccCount ==
                                                                        null &&
                                                                    strAccCount ==
                                                                        ""
                                                                ? "0"
                                                                : strAccCount,
                                                            TextAlign.center,
                                                            new Color(ColorValues
                                                                .BLUE_COLOR),
                                                            12.0,
                                                            FontWeight.bold)),
                                                  ],
                                                ),
                                              )),
                                          flex: 1,
                                        ),
                                        new Expanded(
                                          child: new Container(
                                              decoration: const BoxDecoration(
                                                border: const Border(
                                                  right: const BorderSide(
                                                      width: 0.8,
                                                      color: const Color(
                                                          0xFFEEEEEE)),
                                                ),
                                              ),
                                              child: PaddingWrap.paddingAll(
                                                  10.0,
                                                  new Column(
                                                    children: <Widget>[
                                                      TextViewWrap.textView(
                                                          "Recommendations",
                                                          TextAlign.center,
                                                          Colors.black,
                                                          12.0,
                                                          FontWeight.bold),
                                                      PaddingWrap.paddingAll(
                                                          5.0,
                                                          TextViewWrap.textView(
                                                              strRecCount ==
                                                                          null &&
                                                                      strRecCount ==
                                                                          ""
                                                                  ? "0"
                                                                  : strRecCount,
                                                              TextAlign.center,
                                                              new Color(ColorValues
                                                                  .BLUE_COLOR),
                                                              12.0,
                                                              FontWeight.bold)),
                                                    ],
                                                  ))),
                                          flex: 1,
                                        )
                                      ],
                                    ),
                                  ),

                                  spiderChartList.length>0? PaddingWrap.paddingAll(10.0,   new Center(child:Center(
                                    child: Container(

                                      child:new Center(child: SpiderChart(
                                        data:spiderChartList, name: spiderChartName,
                                        maxValue: 12, // the maximum value that you want to represent (essentially sets the data scale of the chart)

                                      )),
                                    ),
                                  ))):new Container(height: 0.0,),

                                  widget.isEditable
                                      ? narrativeList != null &&
                                              narrativeList.length > 0
                                          ? new Container(
                                              height: 1.0,
                                            )
                                          : new Column(
                                              children: <Widget>[
                                                PaddingWrap.paddingAll(
                                                  10.0,
                                                  TextViewWrap.textView(
                                                      "Welcome to Spikeview! ",
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
                                                      "To build out your narrative, start by adding some achievements. Follow the two steps below",
                                                      textAlign: TextAlign.left,
                                                      style: new TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                          fontSize: 15.0),
                                                    )),
                                                PaddingWrap.paddingfromLTRB(
                                                    15.0,
                                                    0.0,
                                                    15.0,
                                                    0.0,
                                                    new Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        PaddingWrap
                                                            .paddingfromLTRB(
                                                                0.0,
                                                                10.0,
                                                                0.0,
                                                                0.0,
                                                                new Text(
                                                                  "- Select your focus area or Competency from the options below",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: new TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12.0),
                                                                )),
                                                        PaddingWrap
                                                            .paddingfromLTRB(
                                                                0.0,
                                                                10.0,
                                                                0.0,
                                                                0.0,
                                                                new Text(
                                                                  "- In the selected Competency, click on the Add Achievement button and provide the details. Wherever possible, add images and videos to enrich your profile.",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: new TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12.0),
                                                                )),
                                                      ],
                                                    )),
                                              ],
                                            )
                                      : new Container(
                                          height: 0.0,
                                        ),
                                ],
                              ),
                              narrativeList.length > 0
                                  ? new Column(
                                      children: <Widget>[
                                        label("Summary"),
                                        (!isShare)
                                            ? profileInfoModal == null &&
                                                        profileInfoModal
                                                                .summary ==
                                                            "" ||
                                                    profileInfoModal.summary ==
                                                        "null"
                                                ? getAddSummaryButtonUi()
                                                : summaryView()
                                            : summaryView(),
                                        new Container(
                                          color: new Color(0XFFF7F7F9),
                                          padding: new EdgeInsets.all(20.0),
                                          child: new Center(
                                              child: new Stack(
                                            children: <Widget>[
                                              new Positioned.fill(
                                                left: 0.0,
                                                right: 0.0,
                                                child: new Divider(
                                                    color: Colors.grey[300]),
                                              ),
                                              new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Container(
                                                      color:
                                                          new Color(0XFFF7F7F9),
                                                      child: PaddingWrap
                                                          .paddingfromLTRB(
                                                        0.0,
                                                        10.0,
                                                        0.0,
                                                        0.0,
                                                        new Text(
                                                          "Education",
                                                          style: new TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18.0),
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              isShare || (!widget.isEditable)
                                                  ? new Container(
                                                      height: 0.0,
                                                    )
                                                  : new Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: new InkWell(
                                                          child:
                                                              new Image.asset(
                                                            "assets/profile/add.png",
                                                            height: 35.0,
                                                            width: 35.0,
                                                            alignment: Alignment
                                                                .centerLeft,
                                                          ),
                                                          onTap: () {
                                                            onTapAddEducationBtn();
                                                          }),
                                                    )
                                            ],
                                          )),
                                        ),
                                        widget.isEditable
                                            ? userEducationList.length == 0
                                                ? (isShare)
                                                    ? new Container(
                                                        height: 50.0,
                                                        width: double.infinity,
                                                        color: Colors.white,
                                                        child: new Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            new Text(
                                                                "   No Data Available")
                                                          ],
                                                        ),
                                                      )
                                                    : getAddEductionButtonUi()
                                                : new Column(
                                                    children: new List.generate(
                                                        userEducationList
                                                            .length,
                                                        (int index) {
                                                    return getEducationListItem(
                                                        index);
                                                  }))
                                            : new Container(
                                                height: 50.0,
                                                width: double.infinity,
                                                color: Colors.white,
                                                child: new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    new Text(
                                                        "   No Data Available")
                                                  ],
                                                ),
                                              )
                                      ],
                                    )
                                  : new Container(
                                      height: 1.0,
                                    ),
                              narrativeList.length > 0
                                  ? label("My Narrative")
                                  : new Container(
                                      height: 0.0,
                                    ),
                              isShare || (!widget.isEditable)
                                  ? new Container(
                                      height: 0.0,
                                    )
                                  : getNarrativeUi(),
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: new List.generate(
                                      narrativeList.length, (int index) {
                                    return new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        isShare
                                            ? narrativeList[index]
                                                        .achivmentList
                                                        .length >
                                                    0
                                                ? new Container(
                                                    height: 40.0,
                                                    child: new Row(
                                                      children: <Widget>[
                                                        new Expanded(
                                                          child: new ListTile(
                                                            leading: Icon(
                                                              IconData(
                                                                  getConstant(
                                                                      narrativeList[
                                                                              index]
                                                                          .name),
                                                                  fontFamily:
                                                                      'Boxicons'),
                                                              size: 30.0,
                                                              color: new Color(
                                                                  ColorValues
                                                                      .BLUE_COLOR),
                                                            ),
                                                            title: TextViewWrap.textView(
                                                                narrativeList[
                                                                        index]
                                                                    .name,
                                                                TextAlign.start,
                                                                new Color(
                                                                    ColorValues
                                                                        .BLUE_COLOR),
                                                                14.0,
                                                                FontWeight
                                                                    .bold),
                                                            trailing:
                                                                new InkWell(
                                                              child: PaddingWrap
                                                                  .paddingAll(
                                                                      5.0,
                                                                      new Image
                                                                          .asset(
                                                                        narrativeList[index].isVisible
                                                                            ? "assets/profile/less_1.png"
                                                                            : "assets/profile/add_1.png",
                                                                        width:
                                                                            25.0,
                                                                        height:
                                                                            25.0,
                                                                      )),
                                                              onTap: () {
                                                                if (narrativeList[
                                                                        index]
                                                                    .isVisible)
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible = false;
                                                                else
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible = true;
                                                                setState(() {
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          flex: 3,
                                                        ),
                                                      ],
                                                    ))
                                                : new Container(
                                                    height: 0.0,
                                                  )
                                            : new InkWell(
                                                child: new Container(
                                                    height: 40.0,
                                                    child: new Row(
                                                      children: <Widget>[
                                                        new Expanded(
                                                          child: new ListTile(
                                                            leading: Icon(
                                                              IconData(
                                                                  getConstant(
                                                                      narrativeList[
                                                                              index]
                                                                          .name),
                                                                  fontFamily:
                                                                      'Boxicons'),
                                                              size: 30.0,
                                                              color: new Color(
                                                                  ColorValues
                                                                      .BLUE_COLOR),
                                                            ),
                                                            title: TextViewWrap.textView(
                                                                narrativeList[
                                                                        index]
                                                                    .name,
                                                                TextAlign.start,
                                                                new Color(
                                                                    ColorValues
                                                                        .BLUE_COLOR),
                                                                14.0,
                                                                FontWeight
                                                                    .bold),
                                                            trailing:
                                                                new InkWell(
                                                              child: PaddingWrap
                                                                  .paddingAll(
                                                                      5.0,
                                                                      new Image
                                                                          .asset(
                                                                        narrativeList[index].isVisible
                                                                            ? "assets/profile/less_1.png"
                                                                            : "assets/profile/add_1.png",
                                                                        width:
                                                                            25.0,
                                                                        height:
                                                                            25.0,
                                                                      )),
                                                              onTap: () {
                                                                if (narrativeList[
                                                                        index]
                                                                    .isVisible)
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible = false;
                                                                else
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible = true;
                                                                setState(() {
                                                                  narrativeList[
                                                                          index]
                                                                      .isVisible;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          flex: 3,
                                                        ),
                                                      ],
                                                    )),
                                                onTap: () {
                                                  if (widget.isEditable) {
                                                    if (narrativeList[index]
                                                            .level1 ==
                                                        "Arts Competency") {
                                                      onTapEditNarative(
                                                          0,
                                                          narrativeList[index]
                                                              .name);
                                                    } else if (narrativeList[
                                                                index]
                                                            .level1 ==
                                                        "Vocational Competency") {
                                                      onTapEditNarative(
                                                          1,
                                                          narrativeList[index]
                                                              .name);
                                                    } else if (narrativeList[
                                                                index]
                                                            .level1 ==
                                                        "Academic Competency") {
                                                      onTapEditNarative(
                                                          2,
                                                          narrativeList[index]
                                                              .name);
                                                    } else if (narrativeList[
                                                                index]
                                                            .level1 ==
                                                        "Sports Competency") {
                                                      onTapEditNarative(
                                                          3,
                                                          narrativeList[index]
                                                              .name);
                                                    }
                                                  }
                                                },
                                              ),
                                        narrativeList[index].isVisible
                                            ? new Column(
                                                children: <Widget>[
                                                  new InkWell(
                                                    child: getgridAchivement(
                                                        index),
                                                    onTap: () {
                                                      if (widget.isEditable &&
                                                          (!isShare)) {
                                                        if (narrativeList[index]
                                                                .level1 ==
                                                            "Arts Competency") {
                                                          onTapEditNarative(
                                                              0,
                                                              narrativeList[
                                                                      index]
                                                                  .name);
                                                        } else if (narrativeList[
                                                                    index]
                                                                .level1 ==
                                                            "Vocational Competency") {
                                                          onTapEditNarative(
                                                              1,
                                                              narrativeList[
                                                                      index]
                                                                  .name);
                                                        } else if (narrativeList[
                                                                    index]
                                                                .level1 ==
                                                            "Academic Competency") {
                                                          onTapEditNarative(
                                                              2,
                                                              narrativeList[
                                                                      index]
                                                                  .name);
                                                        } else if (narrativeList[
                                                                    index]
                                                                .level1 ==
                                                            "Sports Competency") {
                                                          onTapEditNarative(
                                                              3,
                                                              narrativeList[
                                                                      index]
                                                                  .name);
                                                        }
                                                      }
                                                    },
                                                  ),
                                                  isShare
                                                      ? new Container(
                                                          height: 0.0,
                                                        )
                                                      : getgridRecommendation(
                                                          index),
                                                  isShare
                                                      ? new Container(
                                                          height: 0.0,
                                                        )
                                                      : getgridBadges(index),
                                                  isShare
                                                      ? new Container(
                                                          height: 0.0,
                                                        )
                                                      : getgridCertificate(
                                                          index),
                                                ],
                                              )
                                            : new Container(
                                                height: 1.0,
                                              ),
                                        PaddingWrap.paddingfromLTRB(
                                            0.0,
                                            5.0,
                                            0.0,
                                            0.0,
                                            new Divider(
                                                color: Colors.grey[300]))
                                      ],
                                    );
                                  })),
                              recommendationtList.length > 0 && (!isShare)
                                  ? new Column(
                                      children: <Widget>[
                                        label("Recommendation"),
                                        recommendationtList.length > 2
                                            ? new Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: new InkWell(
                                                  child: PaddingWrap.paddingAll(
                                                    5.0,
                                                    TextViewWrap.textView(
                                                        "View All",
                                                        TextAlign.end,
                                                        new Color(ColorValues
                                                            .BLUE_COLOR),
                                                        14.0,
                                                        FontWeight.normal),
                                                  ),
                                                  onTap: () {
                                                    onTapViewAll();
                                                  },
                                                ),
                                              )
                                            : new Container(
                                                height: 0.0,
                                              ),
                                        getRecommendation(),
                                      ],
                                    )
                                  : new Container(
                                      height: 1.0,
                                    )
                            ],
                          ),
                        ],
                      ))),
            /*  new Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: isShare
                      ? new Container(
                          height: 60.0,
                          child: new FlatButton(
                              onPressed: () {
                                if (narrativeList.length > 0) {
                                  importanceBottomSheet(context);
                                }
                              },
                              color: new Color(ColorValues.BLUE_COLOR),
                              child: TextViewWrap.textView(
                                  "Select Importance",
                                  TextAlign.center,
                                  Colors.white,
                                  17.0,
                                  FontWeight.bold)))
                      : new Container(
                          height: 0.0,
                        ))*/
            ],
          )
        ));
  }

  static int getConstant(name) {
    switch (name) {
      case 'Performing Arts':
        {
          return StringValues.PerformingArts;
        }
      case 'Visual Arts':
        {
          return StringValues.VisualArts;
        }

      case 'Robotics':
        {
          return StringValues.Robotics;
        }
      case 'Visual Arts':
        {
          return StringValues.VisualArts;
        }
      case 'Refrigeration Fundamentals':
        {
          return StringValues.RefrigerationFundamentals;
        }
      case 'Plumbing':
        {
          return StringValues.Plumbing;
        }
      case 'Networking':
        {
          return StringValues.Networking;
        }
      case 'Metalworking':
        {
          return StringValues.Metalworking;
        }
      case 'Woodworking':
        {
          return StringValues.Woodworking;
        }
      case 'Heating and Cooling Systems':
        {
          return StringValues.HeatingandCoolingSystems;
        }
      case 'JROTC':
        {
          return StringValues.JROTC;
        }
      case 'Driver Education':
        {
          return StringValues.DriverEducation;
        }
      case 'Criminal Justice':
        {
          return StringValues.CriminalJustice;
        }
      case 'Computer-Aided Drafting':
        {
          return StringValues.ComputerAidedDrafting;
        }
      case 'Auto Mechanics':
        {
          return StringValues.AutoMechanics;
        }
      case 'Auto Body Repair':
        {
          return StringValues.AutoBodyRepair;
        }
      case 'Electronics':
        {
          return StringValues.Electronics;
        }
      case 'Production Technology':
        {
          return StringValues.ProductionTechnology;
        }
      case 'FFA':
        {
          return StringValues.FFA;
        }
      case 'Fire Science':
        {
          return StringValues.FireScience;
        }
      case 'Building Construction':
        {
          return StringValues.BuildingConstruction;
        }
      case 'Hospitality and Tourism':
        {
          return StringValues.HospitalityandTourism;
        }
      case 'Cosmetology':
        {
          return StringValues.Cosmetology;
        }

      case 'General':
        {
          return StringValues.General;
        }
      case 'Journalism':
        {
          return StringValues.Journalism;
        }
      case 'Social Studies':
        {
          return StringValues.SocialStudies;
        }
      case 'Mathematics':
        {
          return StringValues.Mathematics;
        }
      case 'Foreign Language':
        {
          return StringValues.ForeignLanguage;
        }
      case 'English':
        {
          return StringValues.English;
        }

      case 'Physical Education':
        {
          return StringValues.PhysicalEducation;
        }
      case 'Family and Consumer Science':
        {
          return StringValues.FamilyandConsumerScience;
        }
      case 'Business':
        {
          return StringValues.Business;
        }
      case 'Science':
        {
          return StringValues.Science;
        }

      case 'Computer Science/IT':
        {
          return StringValues.ComputerScienceIT;
        }

      case 'Ultimate Frisbee':
        {
          return StringValues.UltimateFrisbee;
        }
      case 'Chess':
        {
          return StringValues.Chess;
        }
      case 'Hockey':
        {
          return StringValues.Hockey;
        }
      case 'Wrestling':
        {
          return StringValues.Wrestling;
        }
      case 'Lacrosse':
        {
          return StringValues.Lacrosse;
        }
      case 'Gymnastics':
        {
          return StringValues.Gymnastics;
        }

      case 'Track/Field':
        {
          return StringValues.TrackField;
        }
      case 'Swimming':
        {
          return StringValues.Swimming;
        }

      case 'Fencing':
        {
          return StringValues.Fencing;
        }

      case 'Soccer':
        {
          return StringValues.Soccer;
        }

      case 'Golf':
        {
          return StringValues.Golf;
        }
      case 'Tennis':
        {
          return StringValues.Tennis;
        }
      case 'Cricket':
        {
          return StringValues.Cricket;
        }
      case 'Badminton':
        {
          return StringValues.Badminton;
        }
      case 'Baseball':
        {
          return StringValues.Baseball;
        }
      case 'Volleyball':
        {
          return StringValues.Volleyball;
        }
      case 'Football':
        {
          return StringValues.Football;
        }
      default:
        {
          return StringValues.PerformingArts;
        }
    }
  }
}
