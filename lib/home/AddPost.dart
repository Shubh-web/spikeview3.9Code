import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spike_view_project/home/AddMyConnectionSharePost.dart';
import 'package:spike_view_project/home/AddTagWidget.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/TagModel.dart';
import 'package:video_player/video_player.dart';
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
class AddPost extends StatefulWidget {
  ProfileInfoModal profileInfoModal;
  String groupId;

  AddPost(this.profileInfoModal, this.groupId);

  @override
  AddPostState createState() {
    return new AddPostState();
  }
}

class AddPostState extends State<AddPost> {
  SharedPreferences prefs;
  String userIdPref, token, userProfilePath;
  final _formKey = GlobalKey<FormState>();
  String isType = "Public";
  List<AssestForPost> assestList = new List();
  VoidCallback listener;
  File videoPath;
  String strVideo;
  TextEditingController edtController;

  String sasToken, containerName, strPrefixPathforFeed;
  String strFirstName, strLastName, strEmail;
  List<dynamic> images;

  Future<File> videoFile;
  List<String> azureImageUploadList = new List();
  VideoPlayerController _controller;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  List<TagsPost> selectedUerTagLIst = new List();
  List<String> selectedtScopeList = new List();

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    userProfilePath = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    token = prefs.getString(UserPreference.USER_TOKEN);
    setState(() {
      userProfilePath;
    });
    strPrefixPathforFeed = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_FEED +
        "/";
    callApiForSaas();
  }

  @override
  void initState() {
    getSharedPreferences();
    edtController = new TextEditingController(text: '');
    // TODO: implement initState
    listener = () {
      setState(() {});
    };

    super.initState();
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.removeListener(listener);
    }
    super.deactivate();
  }

  //--------------------------SaasToken  api ------------------
  Future callApiForSaas() async {
    try {
      Response response = await new ApiCalling().apiCall2(
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

  //-------------------------------------Api Calling for feed--------------------------

  Future apiCalling() async {
    try {
      Map map;

      print("edtControllr shubh " + edtController.text);
      if (edtController.text != "" ||
          assestList.length > 0 ||
          videoPath != null) {
        if (assestList.length > 0) {
          map = {
            "post": {
              "text": edtController.text,
              "images": azureImageUploadList.map((item) => item).toList(),
              "media": ""
            },
            "postedBy": int.parse(userIdPref),
            "dateTime": new DateTime.now().millisecondsSinceEpoch,
            "status": "",
            "visibility": isType,
            "scope": selectedtScopeList.map((item) => item).toList(),
            "isActive": widget.profileInfoModal.isActive,
            "tags": selectedUerTagLIst.map((item) => item.toJson()).toList(),
            "groupId": widget.groupId == "" ? "" : int.parse(widget.groupId),
            "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
            "lastActivityType": "CreateFeed"
          };
        } else if (videoPath != null) {
          map = {
            "post": {
              "text": edtController.text,
              "images": [],
              "media": strPrefixPathforFeed + strVideo
            },
            "postedBy": int.parse(userIdPref),
            "dateTime": new DateTime.now().millisecondsSinceEpoch,
            "status": "",
            "visibility": isType,
            "scope": selectedtScopeList.map((item) => item).toList(),
            "isActive": false,
            "tags": selectedUerTagLIst.map((item) => item.toJson()).toList(),
            "groupId": widget.groupId == "" ? "" : int.parse(widget.groupId),
            "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
            "lastActivityType": "CreateFeed"
          };
        } else {
          map = {
            "post": {"text": edtController.text, "images": [], "media": ""},
            "postedBy": int.parse(userIdPref),
            "dateTime": new DateTime.now().millisecondsSinceEpoch,
            "status": "",
            "visibility": isType,
            "scope": selectedtScopeList.map((item) => item).toList(),
            "isActive": false,
            "tags": selectedUerTagLIst.map((item) => item.toJson()).toList(),
            "groupId": widget.groupId == "" ? "" : int.parse(widget.groupId),
            "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
            "lastActivityType": "CreateFeed"
          };
        }

        Response response = await new ApiCalling()
            .apiCallPostWithMapData(context, Constant.ENDPOINT_ADD_FEED, map);

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
      } else {
        CustomProgressLoader.cancelLoader(context);
        ToastWrap.showToast("Please wtite something..");
      }
    } catch (e) {
      CustomProgressLoader.cancelLoader(context);
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTapTagBtn() async {
      List<TagsPost> result = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) => new AddTagWidget("TAGGING")));

      if (result != null) {
        selectedUerTagLIst = result;
      }
    }

    void onTapTagSelectedConnection() async {
      List<String> result = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new AddMyConnectionSharePost("MY CONNECTIONS")));

      if (result != null) {
        selectedtScopeList = result;
      }
    }

    onTapPostButton() async {
      if (assestList.length > 0 ||
          edtController.text.trim() != "" ||
          videoPath != null) {
        if (assestList.length > 0) {
          for (int i = 0; i < assestList.length; i++) {
            String azureUploadPath = await uploadImgOnAzure(
                assestList[i].imagePath, strPrefixPathforFeed);
            azureImageUploadList.add(strPrefixPathforFeed + azureUploadPath);
          }

          String s = "ss";
        } else if (videoPath != null) {
          strVideo = await uploadImgOnAzure(
              videoPath
                  .toString()
                  .replaceAll("File: ", "")
                  .replaceAll("'", "")
                  .trim(),
              strPrefixPathforFeed);

          String s = "";
        }

        apiCalling();
      } else {
        ToastWrap.showToast("Please wtite something..");
      }
    }

    getVideo() {
      videoPath = null;
      setState(() {
        videoPath;
      });
      if (_controller != null) {
        _controller.setVolume(0.0);
        _controller.removeListener(listener);
      }
      ImagePicker.pickVideo(source: ImageSource.gallery).then((File file) {
        if (file != null && mounted) {
          setState(() {
            _controller = VideoPlayerController.file(file)
              ..addListener(listener)
              ..setVolume(1.0)
              ..initialize()
              ..setLooping(true)
              ..play();
            videoPath = file;
          });
        }
      });
    }

    getImage(type) async {
      if (assestList.length < 8) {
        int numberOfItems = 8 - assestList.length;
        // if (numberOfItems == 1) {
        File imagePath =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        if (imagePath != null) {
          assestList.add(new AssestForPost(
              imagePath
                  .toString()
                  .replaceAll("File: ", "")
                  .replaceAll("'", "")
                  .trim(),
              "image",
              "",
              false));
          setState(() {
            assestList;
          });
          // }
        }
        /*else {
          images = await ImagePicker.pickImagesCustom(
              source: ImageSource.gallery, numberOfItems: numberOfItems);

          if (images != null) {
            for (int i = 0; i < images.length; i++) {
              try {
                assestList
                    .add(new AssestForPost(images[i], "image", "", false));
                setState(() {
                  assestList;
                });
                if (assestList.length == 8) break;
              } catch (e) {
                e.toString();
              }
            }
          }
        }*/
      } else {
        ToastWrap.showToast("Maximum eight images selected..!");
      }
    }

    void _settingModalBottomSheet(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  new Container(
                      height: 40.0,
                      color: new Color(0XFF3B79E0),
                      child: new TextFormField(
                        textAlign: TextAlign.center,
                        enabled: false,
                        controller: new TextEditingController(text: 'STATUS'),
                        keyboardType: TextInputType.text,
                        style:
                            new TextStyle(color: Colors.white, fontSize: 17.0),
                        decoration: new InputDecoration(
                            filled: true,
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            suffixIcon: new InkWell(
                              child: PaddingWrap.paddingfromLTRB(
                                  5.0,
                                  5.0,
                                  5.0,
                                  5.0,
                                  new Image.asset(
                                    "assets/profile/post/cross_white.png",
                                    width: 20.0,
                                    height: 20.0,
                                  )),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )),
                      )),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "Public"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            10.0,
                            5.0,
                            10.0,
                            new Image.asset(
                              "assets/profile/post/public.png",
                              width: 30.0,
                              height: 30.0,
                            )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            15.0,
                            5.0,
                            10.0,
                            TextViewWrap.textView(
                                "Public",
                                TextAlign.center,
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.normal))
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      isType = "Public";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "Private"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            10.0,
                            5.0,
                            10.0,
                            new Image.asset(
                              "assets/profile/post/private.png",
                              width: 30.0,
                              height: 30.0,
                            )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            15.0,
                            5.0,
                            10.0,
                            TextViewWrap.textView(
                                "Private",
                                TextAlign.center,
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.normal))
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      isType = "Private";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "AllConnections"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            10.0,
                            5.0,
                            10.0,
                            new Image.asset(
                              "assets/profile/post/all_connections.png",
                              width: 30.0,
                              height: 30.0,
                            )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            15.0,
                            5.0,
                            10.0,
                            TextViewWrap.textView(
                                "All Connections",
                                TextAlign.center,
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.normal))
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      isType = "AllConnections";
                      setState(() {
                        isType;
                      });
                    },
                  ),
                  new InkWell(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            10.0,
                            15.0,
                            10.0,
                            10.0,
                            isType == "SelectedConnections"
                                ? new Image.asset(
                                    "assets/profile/post/radio_selected.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )
                                : new Image.asset(
                                    "assets/profile/post/radio_inactive.png",
                                    width: 25.0,
                                    height: 25.0,
                                  )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            10.0,
                            5.0,
                            10.0,
                            new Image.asset(
                              "assets/profile/post/selected_connections.png",
                              width: 30.0,
                              height: 30.0,
                            )),
                        PaddingWrap.paddingfromLTRB(
                            5.0,
                            15.0,
                            5.0,
                            10.0,
                            TextViewWrap.textView(
                                "Selected Connections",
                                TextAlign.center,
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.normal))
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onTapTagSelectedConnection();
                      isType = "SelectedConnections";
                      setState(() {
                        isType;
                      });
                    },
                  ),

                  /* PaddingWrap.paddingfromLTRB(
                      0.0,
                      40.0,
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
                        onPressed: () {},
                      ))*/
                ],
              ),
            );
          });
    }

    Padding gridSelectedImages() {
      return assestList != null && assestList.length > 0
          ? PaddingWrap.paddingfromLTRB(
              5.0,
              0.0,
              5.0,
              10.0,
              new Container(
                  height: 130.0,
                  child: new GridView.count(
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(5.0),
                    crossAxisCount: 1,
                    childAspectRatio: .95,
                    mainAxisSpacing: 0.0,
                    crossAxisSpacing: 2.0,
                    children: new List.generate(assestList.length, (int index) {
                      return new Stack(
                        children: <Widget>[
                          new InkWell(
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Image.file(
                                    new File(assestList[index].imagePath),
                                    fit: BoxFit.cover,
                                    height: 100.0,
                                    width: 100.0,
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                assestList.removeAt(index);

                                setState(() {
                                  assestList;
                                });
                              }),
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

    Widget _previewVideo(VideoPlayerController controller) {
      if (controller == null) {
        return const Text(
          'You have not yet picked a video',
          textAlign: TextAlign.center,
        );
      } else if (controller.value.initialized) {
        return new Container(
            height: 120.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ));
      } else {
        return const Text(
          'Error Loading Video',
          textAlign: TextAlign.center,
        );
      }
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: new Scaffold(
            backgroundColor: new Color(0XFFF7F7F9),
            appBar: new AppBar(
              titleSpacing: 2.0,
              brightness: Brightness.light,
              title: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    "POST",
                    textAlign: TextAlign.start,
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
            body: new ListView(
              children: <Widget>[
                new Container(
                  height: assestList.length > 0 || videoPath != null
                      ? 355.0
                      : 255.0,
                  child: new Stack(
                    children: <Widget>[
                      new Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        left: 0.0,
                        top: 70.0,
                        child: new Container(
                            child: new Card(
                                elevation: 2.0,
                                child: new Column(
                                  children: <Widget>[
                                    PaddingWrap.paddingfromLTRB(
                                        5.0,
                                        30.0,
                                        5.0,
                                        0.0,
                                        new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new TextField(
                                              maxLines: 3,
                                              maxLength: 2000,
                                              controller: edtController,autofocus: true,
                                              keyboardType: TextInputType.text,
                                              textAlign: TextAlign.start,
                                              decoration: new InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                hintText: "Write Here..",
                                                hintStyle: new TextStyle(
                                                    color: Colors.grey),
                                                fillColor: Colors.transparent,
                                              ),
                                            ),
                                            videoPath != null
                                                ? _previewVideo(_controller)
                                                : Container(
                                                    height: 1.0,
                                                  ),
                                            gridSelectedImages(),
                                          ],
                                        )),
                                  ],
                                ))),
                      ),
                      new Positioned(
                        top: 15.0,
                        left: 10.0,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              child: userProfilePath == null ||
                                      userProfilePath == "null" ||
                                      userProfilePath == ""
                                  ? new Image.asset(
                                      "assets/profile/user_on_user.png",
                                      fit: BoxFit.fill,
                                    )
                                  : FadeInImage.assetNetwork(
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      placeholder:
                                          'assets/profile/user_on_user.png',
                                      image: Constant.IMAGE_PATH_SMALL +
                                          ParseJson.getSmallImage(
                                            userProfilePath,
                                          ),
                                    ),
                              width: 80.0,
                              height: 100.0,
                              padding: new EdgeInsets.fromLTRB(
                                  10.0, 20.0, 0.0, 20.0),
                            ),
                            PaddingWrap.paddingfromLTRB(
                                5.0,
                                0.0,
                                5.0,
                                20.0,
                                new Text(
                                  widget.profileInfoModal.lastName == "null" || widget.profileInfoModal.lastName ==
                                              ""
                                      ? widget.profileInfoModal.firstName
                                      : widget.profileInfoModal.firstName +
                                          " " +
                                          widget.profileInfoModal.lastName,
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ))
                          ],
                        ),
                      ),
                      new Positioned(
                        top: 15.0,
                        right: 20.0,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new InkWell(
                              child: new Container(
                                child: new Image.asset(
                                  "assets/profile/post/post.png",
                                  fit: BoxFit.fill,
                                ),
                                width: 80.0,
                                height: 80.0,
                                padding: new EdgeInsets.fromLTRB(
                                    30.0, 40.0, 0.0, 0.0),
                              ),
                              onTap: () {
                                CustomProgressLoader.showLoader(context);
                                Timer _timer = new Timer(
                                    const Duration(milliseconds: 400), () {
                                  onTapPostButton();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      new Align(
                          alignment: Alignment.bottomLeft,
                          child: new Row(
                            children: <Widget>[
                              new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/profile/post/camera.png",
                                      fit: BoxFit.fill,
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  videoPath == null
                                      ? getImage(ImageSource.gallery)
                                      : null;
                                },
                              ),
                              new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/profile/post/video.png",
                                      fit: BoxFit.fill,
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  assestList.length == 0 ? getVideo() : null;
                                },
                              ),
                              new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/profile/post/tagging.png",
                                      fit: BoxFit.fill,
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  onTapTagBtn();
                                },
                              ),
                            ],
                          )),
                      new Align(
                          alignment: Alignment.bottomRight,
                          child: PaddingWrap.paddingAll(
                              10.0,
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  isType == "Public"
                                      ? new InkWell(
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              new Image.asset(
                                                "assets/profile/post/public.png",
                                                fit: BoxFit.fill,
                                                height: 30.0,
                                                width: 30.0,
                                              ),
                                              PaddingWrap.paddingAll(
                                                  5.0,
                                                  TextViewWrap.textView(
                                                      "Public",
                                                      TextAlign.center,
                                                      new Color(ColorValues
                                                          .BLUE_COLOR),
                                                      16.0,
                                                      FontWeight.bold))
                                            ],
                                          ),
                                          onTap: () {
                                            _settingModalBottomSheet(context);
                                          })
                                      : isType == "Private"
                                          ? new InkWell(
                                              child: new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  new Image.asset(
                                                    "assets/profile/post/private.png",
                                                    fit: BoxFit.fill,
                                                    height: 30.0,
                                                    width: 30.0,
                                                  ),
                                                  PaddingWrap.paddingAll(
                                                      5.0,
                                                      TextViewWrap.textView(
                                                          "Private",
                                                          TextAlign.center,
                                                          new Color(ColorValues
                                                              .BLUE_COLOR),
                                                          16.0,
                                                          FontWeight.bold))
                                                ],
                                              ),
                                              onTap: () {
                                                _settingModalBottomSheet(
                                                    context);
                                              })
                                          : isType == "AllConnections"
                                              ? new InkWell(
                                                  child: new Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      new Image.asset(
                                                        "assets/profile/post/all_connections.png",
                                                        fit: BoxFit.fill,
                                                        height: 30.0,
                                                        width: 30.0,
                                                      ),
                                                      PaddingWrap.paddingAll(
                                                          5.0,
                                                          TextViewWrap.textView(
                                                              "All Connections",
                                                              TextAlign.center,
                                                              new Color(ColorValues
                                                                  .BLUE_COLOR),
                                                              16.0,
                                                              FontWeight.bold))
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    _settingModalBottomSheet(
                                                        context);
                                                  })
                                              : new InkWell(
                                                  child: new Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      new Image.asset(
                                                        "assets/profile/post/selected_connections.png",
                                                        fit: BoxFit.fill,
                                                        height: 30.0,
                                                        width: 30.0,
                                                      ),
                                                      PaddingWrap.paddingAll(
                                                          5.0,
                                                          TextViewWrap.textView(
                                                              "Selected Connections",
                                                              TextAlign.center,
                                                              new Color(ColorValues
                                                                  .BLUE_COLOR),
                                                              16.0,
                                                              FontWeight.bold))
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    _settingModalBottomSheet(
                                                        context);
                                                  }),
                                ],
                              ))),
                    ],
                  ),
                )
              ],
            )));
  }
}
