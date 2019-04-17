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
import 'package:spike_view_project/activity/FullImageViewPager.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';

import 'package:intl/intl.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/group/EditGroupWidget.dart';
import 'package:spike_view_project/group/GroupMemberDetail.dart';
import 'package:spike_view_project/group/InviteByEmailWidget.dart';
import 'package:spike_view_project/group/InviteMemberWidget.dart';
import 'package:spike_view_project/group/model/GroupDetailModel.dart';
import 'package:spike_view_project/home/AddPost.dart';
import 'package:spike_view_project/home/AddTagWidget.dart';
import 'package:spike_view_project/home/CommentListWidget.dart';
import 'package:spike_view_project/home/LikeDetailWidget.dart';
import 'package:spike_view_project/home/SharePostWidget.dart';
import 'package:spike_view_project/home/TagDetailWidget.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:video_player/video_player.dart';

// Create a Form Widget
class GroupDetailWidget extends StatefulWidget {
  String groupId;

  GroupDetailWidget(this.groupId);

  @override
  GroupDetailWidgetState createState() {
    return new GroupDetailWidgetState();
  }
}

class GroupDetailWidgetState extends State<GroupDetailWidget> {
  SharedPreferences prefs;
  String userIdPref, profile_image_path, token;
  int offset = 0;
  bool isLoadMore = true;
  final _formKey = GlobalKey<FormState>();
  List<GroupDetailModel> groupList = new List();
  List<UserPostModal> userPostList = new List<UserPostModal>();
  bool isFeed = true;
  File imagePathCover;
  String strAzureCoverImageUploadPath, strPrefixPathforCoverPhoto;
  String sasToken, containerName;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  String status = "pop";
  ProfileInfoModal profileInfoModal;
  bool isJoin = false;

  Future apiCallingForDeleteFeed(userPostModal, index) async {
    try {
      Map map = {"feedId": userPostModal.feedId};
      Response response = await new ApiCalling().apiCallDeleteWithMapData(
          context, Constant.ENDPOINT_FEED_DELETE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            userPostList.removeAt(index);
            setState(() {
              userPostList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUpdateFeed(userPostModal, visibility, scopeList) async {
    try {
      Map map = {
        "feedId": userPostModal.feedId,
        "visibility": visibility,
        "scope": scopeList.map((item) => item).toList()
      };
      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_FEED_UPDATE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            userPostModal.visibility = visibility;
            setState(() {
              userPostModal;
            });
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

  Future apiCallingForAddLike(feedId, userpostModal) async {
    try {
      bool isLike = false;
      if (userpostModal.isLike) {
        isLike = false;
      } else {
        isLike = true;
      }
      Map map = {
        "feedId": feedId,
        "userId": int.parse(userIdPref),
        "isLike": isLike,
        "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
        "lastActivityType": "LikeFeed"
      };

      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_ADD_LIKE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            if (userpostModal.isLike) {
              userpostModal.isLike = false;
              userpostModal.likeList.removeLast();
            } else {
              userpostModal.isLike = true;
              userpostModal.likeList.add(new Likes(
                  userIdPref,
                  profileInfoModal.lastName == "null"
                      ? profileInfoModal.firstName
                      : profileInfoModal.firstName +
                          " " +
                          profileInfoModal.lastName,
                  profile_image_path,
                  "student"));
            }
            setState(() {
              userpostModal;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAddComment(feedId, comment, userpostModal) async {
    try {
      Map map = {
        "feedId": feedId,
        "userId": int.parse(userIdPref),
        "comment": comment,
        "dateTime": new DateTime.now().millisecondsSinceEpoch,
        "name": "",
        "title": "",
        "profilePicture": "",
        "lastActivityTime": new DateTime.now().millisecondsSinceEpoch,
        "lastActivityType": "CommentOnFeed"
      };

      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_ADD_FEED_COMMENT, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            userpostModal.isCommented = true;
            List<Likes> likesList = new List();
            userpostModal.commentList.add(new CommentData(
                response.data["result"]["commentId"].toString(),
                comment,
                userIdPref,
                "a few seconds ago",
                profile_image_path,
                profileInfoModal.lastName == "" ||
                        profileInfoModal.lastName == "null"
                    ? profileInfoModal.firstName
                    : profileInfoModal.firstName +
                        " " +
                        profileInfoModal.lastName,
                "",
                userIdPref,
                likesList,
                false));
            setState(() {
              userPostList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallForGet() async {
    try {
      Response response;
      response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_GROUPS_MEMBERS + widget.groupId, "get");

      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            groupList.clear();
            groupList = ParseJson.parseGroupDetailMap(
                response.data['result'], userIdPref);
            if (groupList.length > 0) {
              setState(() {
                groupList;
                print("shubh" + groupList[0].groupImage.toString());
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUserPost() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context,
          "ui/feed/postListByGroupId?groupId=" + widget.groupId + "&skip=0",
          "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            userPostList.clear();
            userPostList =
                ParseJson.parseHomeData(response.data['result'], userIdPref);
            if (userPostList.length > 0) {
              setState(() {
                userPostList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAccept(groupId, index, type) async {
    try {
      Map map = {
        "groupId": int.parse(groupId),
        "userId": int.parse(userIdPref),
        "status": type
      };
      Response response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_UPDATE_GROUP_REQUEST, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            apiCallForGet();
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForUserPostLoadMore() async {
    try {
      Response response = await new ApiCalling().apiCall(
          context,
          "ui/feed/postListByGroupId?groupId=" +
              widget.groupId +
              "&skip=" +
              offset.toString(),
          "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            List<UserPostModal> userPostListNew =
                ParseJson.parseHomeData(response.data['result'], userIdPref);
            if (userPostListNew.length > 0) {
              userPostList.addAll(userPostListNew);
              setState(() {
                userPostList;
              });
            } else {
              isLoadMore = false;
            }
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
      print("groupid" + widget.groupId);
      Map map = {
        "groupImage": strPrefixPathforCoverPhoto + strAzureCoverImageUploadPath,
        "groupId": int.parse(widget.groupId)
      };

      response = await new ApiCalling().apiCallPutWithMapData(
          context, Constant.ENDPOINT_GROUP_PHOTO_UPDATE, map);

      CustomProgressLoader.cancelLoader(context);
      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            //  ToastWrap.showToast(msg);
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Upload Cover Image Data ------------------
  Future apiCallJoin() async {
    try {
      Response response;

      Map map = {
        "groupId": int.parse(widget.groupId),
        "userId": int.parse(userIdPref)
      };

      response = await new ApiCalling()
          .apiCallPostWithMapData(context, Constant.ENDPOINT_JOIN_GROUP, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            apiCallForGet();
          }
        }
      }
    } catch (e) {
      e.toString();
    }
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
              setState(() {
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

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.PARENT_ID);
    profile_image_path = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
    token = prefs.getString(UserPreference.USER_TOKEN);
    await apiCallForGet();
    await apiCallingForUserPost();
    await callApiForSaas();
    await profileApi();

    strPrefixPathforCoverPhoto = Constant.CONTAINER_PREFIX +
        userIdPref +
        "/" +
        Constant.CONTAINER_FEED +
        "/";
  }

  @override
  void initState() {
    getSharedPreferences();

    // TODO: implement initState
    super.initState();
  }
  Future<Null> _cropImage(File imageFile) async {
    imagePathCover = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
  }
  @override
  Widget build(BuildContext context) {
    Future getImageCover() async {
      imagePathCover= await ImagePicker.pickImage(source: ImageSource.gallery);
      print("img   :-" +
          imagePathCover.toString().replaceAll("File: ", "").replaceAll("'", "").trim());
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

    void onTapLike(userPostModal) {
      apiCallingForAddLike(userPostModal.feedId, userPostModal);
    }

    onTapLikeText(userPostModal) {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new LikeDetailWidget(userPostModal.likeList)));
    }

    void onTapShare(userPostModel) async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new SharePostWidget(profileInfoModal, userPostModel)));

      if (result == "push") {
        apiCallingForUserPost();
      }
    }

    void onTapViewAllComments(commentList, feedId, userPostModel) async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new CommentListWidget(
              commentList,
              profile_image_path,
              feedId,
              profileInfoModal.lastName == "" ||
                      profileInfoModal.lastName == "null"
                  ? profileInfoModal.firstName
                  : profileInfoModal.firstName +
                      " " +
                      profileInfoModal.lastName,
              userPostModel,
              userIdPref)));

      if (result == "push") {
        // apiCallingForUserPost();
      }
    }

    onAddComment(feedId, comment, userPostModal) {
      apiCallingForAddComment(feedId, comment, userPostModal);
      print("Comments : " + comment + "feedid:- $feedId");
    }

    onTapEditGroup() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new EditGroupWidget(groupList[0])));
      status = result;
      if (result == "push") {
        apiCallForGet();
      }
    }

    isCount1(imageurl) {
      return Image.network(
        Constant.IMAGE_PATH_SMALL + ParseJson.getMediumImage(imageurl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      );
    }

    isCount2(imageurl1, imageurl2) {
      return new Row(
        children: <Widget>[
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl1),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          ),
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl2),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          )
        ],
      );
    }

    isCount3(imageurl1, imageurl2, imageurl3) {
      return new Column(
        children: <Widget>[
          new Expanded(
            child: PaddingWrap.paddingAll(
                2.0,
                Image.network(
                  Constant.IMAGE_PATH_SMALL +
                      ParseJson.getMediumImage(imageurl1),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                )),
            flex: 1,
          ),
          new Expanded(
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl2),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                ),
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl3),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                )
              ],
            ),
            flex: 1,
          ),
        ],
      );
    }

    isCount4(imageurl1, imageurl2, imageurl3, imageurl4, imageCount) {
      return new Column(
        children: <Widget>[
          new Expanded(
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl1),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                ),
                new Expanded(
                  child: PaddingWrap.paddingAll(
                      2.0,
                      Image.network(
                        Constant.IMAGE_PATH_SMALL +
                            ParseJson.getMediumImage(imageurl2),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                      )),
                  flex: 1,
                )
              ],
            ),
            flex: 1,
          ),
          new Expanded(
            child: new Stack(children: <Widget>[
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                        2.0,
                        Image.network(
                          Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(imageurl3),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                        )),
                    flex: 1,
                  ),
                  new Expanded(
                    child: PaddingWrap.paddingAll(
                        2.0,
                        Image.network(
                          Constant.IMAGE_PATH_SMALL +
                              ParseJson.getMediumImage(imageurl4),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                        )),
                    flex: 1,
                  )
                ],
              ),
              imageCount > 4
                  ? new Positioned(
                      child: new Container(
                          color: Colors.black12,
                          child: new Text(
                            (imageCount - 4).toString() + "+ more",
                            style: new TextStyle(color: Colors.white),
                          )),
                      bottom: 20.0,
                      right: 10.0,
                    )
                  : new Container(
                      height: 1.0,
                    )
            ]),
            flex: 1,
          ),
        ],
      );
    }

    void onTapTagSelectedConnection(userPostModel) async {
      List<String> result = await Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new AddTagWidget("MY CONNECTIONS")));

      if (result != null) {
        List<String> scopeList = new List();
        scopeList = result;
        if (scopeList.length > 0)
          apiCallingForUpdateFeed(
              userPostModel, "SelectedConnections", scopeList);
      }
    }

    Padding getMemberImages() {
      return groupList != null && groupList.length > 0
          ? PaddingWrap.paddingfromLTRB(
              5.0,
              0.0,
              5.0,
              5.0,
              new Container(
                  height: 40.0,
                  child: new GridView.count(
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(5.0),
                    crossAxisCount: 1,
                    childAspectRatio: .95,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 2.0,
                    children: new List.generate(
                        groupList[0].memberList.length > 6
                            ? 6
                            : groupList[0].memberList.length, (int index) {
                      return new Stack(
                        children: <Widget>[
                          new InkWell(
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FadeInImage.assetNetwork(
                                  fit: BoxFit.fill,
                                  height: 30.0,
                                  width: double.infinity,
                                  placeholder:
                                      'assets/profile/user_on_user.png',
                                  image: Constant.IMAGE_PATH_SMALL +
                                      ParseJson.getSmallImage(groupList[0]
                                          .memberList[index]
                                          .profilePicture),
                                )
                              ],
                            ),
                          ),
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

    void onTapAddPost(groupId) async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new AddPost(profileInfoModal, groupId)));

      if (result == "push") {
        apiCallingForUserPost();
      }
    }

    onTapMemberDetail() async {
      String result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new GroupMemberDetail(groupList[0])));
    }

    Column getHeaderUi() {
      return new Column(
        children: <Widget>[
          PaddingWrap.paddingAll(
              10.0,
              TextViewWrap.textView(groupList[0].groupName, TextAlign.center,
                  Colors.black, 22.0, FontWeight.bold)),
          groupList[0].status == "Invited"
              ? new Row(
                  children: <Widget>[
                    new Expanded(
                      child: PaddingWrap.paddingfromLTRB(
                          10.0,
                          5.0,
                          0.0,
                          5.0,
                          new InkWell(
                            child: new Container(
                                height: 40.0,
                                decoration: new BoxDecoration(
                                    border: new Border.all(
                                        color: Colors.grey[400], width: 1.0)),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Image.asset(
                                      "assets/login/check.png",
                                      height: 20.0,
                                      width: 20.0,
                                    ),
                                    new Text(
                                      "  Accept",
                                      style: new TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                            onTap: () {
                              apiCallingForAccept(
                                  groupList[0].groupId, 0, "Accepted");
                            },
                          )),
                      flex: 1,
                    ),
                    new Expanded(
                      child: PaddingWrap.paddingfromLTRB(
                          0.0,
                          5.0,
                          10.0,
                          5.0,
                          new InkWell(
                            child: new Container(
                                height: 40.0,
                                decoration: new BoxDecoration(
                                    border: new Border.all(
                                        color: Colors.grey[400], width: 1.0)),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Image.asset(
                                      "assets/login/delete.png",
                                      height: 20.0,
                                      width: 20.0,
                                    ),
                                    new Text(
                                      "  Decline",
                                      style: new TextStyle(color: Colors.black),
                                    )
                                  ],
                                )),
                            onTap: () {
                              apiCallingForAccept(
                                  groupList[0].groupId, 0, "Rejected");
                            },
                          )),
                      flex: 1,
                    ),
                  ],
                )
              : groupList[0].status == ""||groupList[0].status == "Requested"
                  ? new Container(
                      child: new InkWell(
                        child: new Container(
                            height: 40.0,
                            width: 140.0,
                            color: new Color(ColorValues.BLUE_COLOR),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Image.asset(
                                  "assets/group/join_group.png",
                                  width: 25.0,
                                  height: 25.0,
                                ),
                                new Text(
                                  groupList[0].status=="Requested"? " Requested" : "  Join Group",
                                  style: new TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                )
                              ],
                            )),
                        onTap: () {
                          if (!(groupList[0].status=="Requested")) {
                            apiCallJoin();
                          }
                        },
                      ),
                    )
                  :groupList[0].type=="private"? groupList[0].isAdmin?new Row(
                      children: <Widget>[
                        new Expanded(
                          child: PaddingWrap.paddingfromLTRB(
                              5.0,
                              5.0,
                              10.0,
                              5.0,
                              new InkWell(
                                child: new Container(
                                    height: 40.0,
                                    color: new Color(ColorValues.BLUE_COLOR),
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Image.asset(
                                          "assets/group/invite_email.png",
                                          width: 25.0,
                                          height: 25.0,
                                        ),
                                        new Text(
                                          "  Invite By Email",
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0),
                                        )
                                      ],
                                    )),
                                onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              new InviteByEmailWidget(
                                                  groupList[0])));
                                },
                              )),
                          flex: 1,
                        ),
                        new Expanded(
                          child: PaddingWrap.paddingfromLTRB(
                              10.0,
                              5.0,
                              5.0,
                              5.0,
                              new InkWell(
                                child: new Container(
                                    height: 40.0,
                                    color: new Color(ColorValues.BLUE_COLOR),
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Image.asset(
                                          "assets/group/invite.png",
                                          width: 25.0,
                                          height: 25.0,
                                        ),
                                        new Text(
                                          "  Invite By Name",
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0),
                                        )
                                      ],
                                    )),
                                onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              new InviteMemberWidget(
                                                  groupList[0],
                                                  profileInfoModal)));
                                },
                              )),
                          flex: 1,
                        ),
                      ],
                    ):new Container(height: 0.0,):new Row(
            children: <Widget>[
              new Expanded(
                child: PaddingWrap.paddingfromLTRB(
                    5.0,
                    5.0,
                    10.0,
                    5.0,
                    new InkWell(
                      child: new Container(
                          height: 40.0,
                          color: new Color(ColorValues.BLUE_COLOR),
                          child: new Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              new Image.asset(
                                "assets/group/invite_email.png",
                                width: 25.0,
                                height: 25.0,
                              ),
                              new Text(
                                "  Invite By Email",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0),
                              )
                            ],
                          )),
                      onTap: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new InviteByEmailWidget(
                                    groupList[0])));
                      },
                    )),
                flex: 1,
              ),
              new Expanded(
                child: PaddingWrap.paddingfromLTRB(
                    10.0,
                    5.0,
                    5.0,
                    5.0,
                    new InkWell(
                      child: new Container(
                          height: 40.0,
                          color: new Color(ColorValues.BLUE_COLOR),
                          child: new Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              new Image.asset(
                                "assets/group/invite.png",
                                width: 25.0,
                                height: 25.0,
                              ),
                              new Text(
                                "  Invite By Name",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0),
                              )
                            ],
                          )),
                      onTap: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new InviteMemberWidget(
                                    groupList[0],
                                    profileInfoModal)));
                      },
                    )),
                flex: 1,
              ),
            ],
          ),
          groupList[0].memberList.length > 0
              ? PaddingWrap.paddingfromLTRB(
                  10.0,
                  20.0,
                  10.0,
                  0.0,
                  new Card(
                      elevation: 5.0,
                      color: Colors.white,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Container(
                                decoration: new BoxDecoration(
                                    border: new Border(
                                  right: new BorderSide(
                                      color: Colors.grey, width: 1.0),
                                )),
                                child: PaddingWrap.paddingfromLTRB(
                                    0.0,
                                    0.0,
                                    5.0,
                                    0.0,
                                    TextViewWrap.textView(
                                        "  Members     ",
                                        TextAlign.start,
                                        Colors.black,
                                        16.0,
                                        FontWeight.normal))),
                            flex: 0,
                          ),
                          new Expanded(
                            child: new InkWell(
                              child: getMemberImages(),
                              onTap: () {
                                onTapMemberDetail();
                              },
                            ),
                            flex: 1,
                          ),
                          groupList[0].memberList.length > 4
                              ? new Expanded(
                                  child: new InkWell(
                                    child: TextViewWrap.textView(
                                        " + More",
                                        TextAlign.start,
                                        Colors.black,
                                        16.0,
                                        FontWeight.normal),
                                    onTap: () {
                                      onTapMemberDetail();
                                    },
                                  ),
                                  flex: 0,
                                )
                              : new Container(
                                  height: 0.0,
                                ),
                        ],
                      )))
              : new Container(
                  height: 0.0,
                )
        ],
      );
    }

    Container getInfoUi() {
      return new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextViewWrap.textView("About Group", TextAlign.start, Colors.black,
                18.0, FontWeight.bold),
            PaddingWrap.paddingfromLTRB(
                0.0,
                10.0,
                0.0,
                0.0,
                new Text(
                  groupList[0].aboutGroup,
                  style: new TextStyle(
                      color: new Color(0XFF525252), fontSize: 16.0),
                )),
            groupList[0].type == "public"
                ? PaddingWrap.paddingfromLTRB(
                    0.0,
                    20.0,
                    0.0,
                    0.0,
                    new Row(
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
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.bold))
                      ],
                    ))
                : PaddingWrap.paddingfromLTRB(
                    0.0,
                    20.0,
                    0.0,
                    0.0,
                    new Row(
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
                                new Color(ColorValues.BLUE_COLOR),
                                16.0,
                                FontWeight.bold)),
                      ],
                    )),
            PaddingWrap.paddingfromLTRB(
                0.0,
                20.0,
                0.0,
                0.0,
                new Row(
                  children: <Widget>[
                    TextViewWrap.textView("Admin :   ", TextAlign.start,
                        Colors.black, 16.0, FontWeight.normal),
                    TextViewWrap.textView(
                        "  " + groupList[0].adminName,
                        TextAlign.start,
                        new Color(ColorValues.BLUE_COLOR),
                        16.0,
                        FontWeight.normal)
                  ],
                )),
            PaddingWrap.paddingfromLTRB(
                0.0,
                20.0,
                0.0,
                0.0,
                new Row(
                  children: <Widget>[
                    TextViewWrap.textView("Created On :   ", TextAlign.start,
                        Colors.black, 16.0, FontWeight.normal),
                    TextViewWrap.textView(
                        "  " + groupList[0].creationDate,
                        TextAlign.start,
                        new Color(ColorValues.BLUE_COLOR),
                        16.0,
                        FontWeight.normal)
                  ],
                )),
            groupList[0].memberList.length > 0
                ? PaddingWrap.paddingfromLTRB(
                    0.0,
                    20.0,
                    0.0,
                    0.0,
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: TextViewWrap.textView(
                              "Members :   ",
                              TextAlign.start,
                              Colors.black,
                              16.0,
                              FontWeight.normal),
                          flex: 0,
                        ),
                        new Expanded(
                          child: getMemberImages(),
                          flex: 1,
                        ),
                        groupList[0].memberList.length > 6
                            ? new Expanded(
                                child: TextViewWrap.textView(
                                    "+ " +
                                        (groupList[0].memberList.length - 6)
                                            .toString() +
                                        " More",
                                    TextAlign.start,
                                    Colors.black,
                                    16.0,
                                    FontWeight.normal),
                                flex: 0,
                              )
                            : new Container(
                                height: 0.0,
                              ),
                      ],
                    ))
                : new Container(
                    height: 0.0,
                  )
          ],
        ),
      );
    }

    Widget getMoreDropDown(userPostModal, index) {
      return new PopupMenuButton<String>(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Image.asset(
              "assets/profile/post/user_more.png",
              width: 25.0,
              height: 25.0,
            )
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem(
                child: new InkWell(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      PaddingWrap.paddingfromLTRB(
                          5.0,
                          10.0,
                          5.0,
                          10.0,
                          new Image.asset(
                            "assets/profile/post/delete_fill.png",
                            width: 30.0,
                            height: 30.0,
                          )),
                      PaddingWrap.paddingfromLTRB(
                          5.0,
                          15.0,
                          5.0,
                          10.0,
                          TextViewWrap.textView(
                              "Delete",
                              TextAlign.center,
                              new Color(ColorValues.BLUE_COLOR),
                              16.0,
                              FontWeight.normal))
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    apiCallingForDeleteFeed(userPostModal, index);
                  },
                ),
                value: "0",
              ),
              userPostModal.visibility == "Public"
                  ? new PopupMenuItem(
                      height: 0.0,
                      child: new Container(
                        height: 0.0,
                      ),
                    )
                  : PopupMenuItem(
                      child: new InkWell(
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
                          List<String> scopeList = new List();
                          apiCallingForUpdateFeed(
                              userPostModal, "Public", scopeList);
                        },
                      ),
                      value: "1",
                    ),
              userPostModal.visibility == "Private"
                  ? new PopupMenuItem(
                      height: 0.0,
                      child: new Container(
                        height: 0.0,
                      ),
                    )
                  : PopupMenuItem(
                      child: new InkWell(
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
                          List<String> scopeList = new List();
                          apiCallingForUpdateFeed(
                              userPostModal, "Private", scopeList);
                        },
                      ),
                      value: "2",
                    ),
              userPostModal.visibility == "SelectedConnections"
                  ? new PopupMenuItem(
                      height: 0.0,
                      child: new Container(
                        height: 0.0,
                      ),
                    )
                  : PopupMenuItem(
                      child: new InkWell(
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
                          onTapTagSelectedConnection(userPostModal);
                        },
                      ),
                      value: "3",
                    ),
              userPostModal.visibility == "AllConnections"
                  ? new PopupMenuItem(
                      height: 0.0,
                      child: new Container(
                        height: 0.0,
                      ),
                    )
                  : PopupMenuItem(
                      child: new InkWell(
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
                          List<String> scopeList = new List();
                          apiCallingForUpdateFeed(
                              userPostModal, "AllConnections", scopeList);
                        },
                      ),
                      value: "4",
                    ),
            ],
      );
    }

    InkWell shareView(userPostModel, feedtype) {
      return new InkWell(
        child: PaddingWrap.paddingAll(
            10.0,
            new Image.asset(
              "assets/home/share_inactive.png",
              height: 30.0,
              width: 30.0,
            )),
        onTap: () {
          feedtype ? onTapShare(userPostModel) : null;
        },
      );
    }

    getEvent(userPostModal) {
      return new Column(
        children: <Widget>[
          userPostModal.lastActivityType == "CreateFeed" &&
                  userPostModal.tagList.length > 0
              ? new Column(
                  children: <Widget>[
                    PaddingWrap.paddingAll(
                      10.0,
                      new InkWell(
                        child: new Row(
                          children: <Widget>[
                            TextViewWrap.textView(
                                userPostModal.lastName == null ||
                                        userPostModal.lastName == "null"
                                    ? userPostModal.firstName
                                    : userPostModal.firstName +
                                        " " +
                                        userPostModal.lastName,
                                TextAlign.start,
                                new Color(ColorValues.BLUE_COLOR),
                                15.0,
                                FontWeight.normal),
                            TextViewWrap.textView(" is with  ", TextAlign.start,
                                Colors.black, 15.0, FontWeight.normal),
                            TextViewWrap.textView(
                                " " +
                                    userPostModal.tagList.length.toString() +
                                    " others",
                                TextAlign.start,
                                new Color(ColorValues.BLUE_COLOR),
                                15.0,
                                FontWeight.normal)
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new TagDetailWidget(userPostModal.tagList)));
                        },
                      ),
                    ),
                    new Divider(color: Colors.grey[300]),
                  ],
                )
              : userPostModal.lastActivityType == "LikeFeed" &&
                      userPostModal.likeList.length > 0
                  ? new Column(
                      children: <Widget>[
                        PaddingWrap.paddingAll(
                          10.0,
                          new Row(
                            children: <Widget>[
                              TextViewWrap.textView(
                                  userPostModal
                                      .likeList[
                                          userPostModal.likeList.length - 1]
                                      .name,
                                  TextAlign.start,
                                  new Color(ColorValues.BLUE_COLOR),
                                  15.0,
                                  FontWeight.normal),
                              TextViewWrap.textView(
                                  " likes this  ",
                                  TextAlign.start,
                                  Colors.black,
                                  15.0,
                                  FontWeight.normal),
                            ],
                          ),
                        ),
                        new Divider(color: Colors.grey[300]),
                      ],
                    )
                  : userPostModal.lastActivityType == "CommentOnFeed" &&
                          userPostModal.commentList.length > 0
                      ? new Column(
                          children: <Widget>[
                            PaddingWrap.paddingAll(
                              10.0,
                              new Row(
                                children: <Widget>[
                                  TextViewWrap.textView(
                                      userPostModal
                                          .commentList[
                                              userPostModal.commentList.length -
                                                  1]
                                          .name,
                                      TextAlign.start,
                                      new Color(ColorValues.BLUE_COLOR),
                                      15.0,
                                      FontWeight.normal),
                                  TextViewWrap.textView(
                                      " commented on this  ",
                                      TextAlign.start,
                                      Colors.black,
                                      15.0,
                                      FontWeight.normal),
                                ],
                              ),
                            ),
                            new Divider(color: Colors.grey[300]),
                          ],
                        )
                      : userPostModal.tagList.length > 0
                          ? new Column(
                              children: <Widget>[
                                PaddingWrap.paddingAll(
                                  10.0,
                                  new InkWell(
                                    child: new Row(
                                      children: <Widget>[
                                        TextViewWrap.textView(
                                            userPostModal.lastName == null ||
                                                    userPostModal.lastName ==
                                                        "null"
                                                ? userPostModal.firstName
                                                : userPostModal.firstName +
                                                    " " +
                                                    userPostModal.lastName,
                                            TextAlign.start,
                                            new Color(ColorValues.BLUE_COLOR),
                                            15.0,
                                            FontWeight.normal),
                                        TextViewWrap.textView(
                                            " is with  ",
                                            TextAlign.start,
                                            Colors.black,
                                            15.0,
                                            FontWeight.normal),
                                        TextViewWrap.textView(
                                            " " +
                                                userPostModal.tagList.length
                                                    .toString() +
                                                " others",
                                            TextAlign.start,
                                            new Color(ColorValues.BLUE_COLOR),
                                            15.0,
                                            FontWeight.normal)
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new TagDetailWidget(
                                                      userPostModal.tagList)));
                                    },
                                  ),
                                ),
                                new Divider(color: Colors.grey[300]),
                              ],
                            )
                          : new Container(
                              height: 0.0,
                            )
        ],
      );
    }

    Padding getListView(userPostModal, index, feedType) {
      return PaddingWrap.paddingAll(
          3.0,
          new Card(
              child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              getEvent(userPostModal),
              PaddingWrap.paddingAll(
                  10.0,
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: userPostModal.profilePicture != "null"
                              ? new Container(
                                  width: 60.0,
                                  height: 60.0,
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    placeholder:
                                        'assets/profile/user_on_user.png',
                                    image: Constant.IMAGE_PATH_SMALL +
                                        ParseJson.getSmallImage(
                                            userPostModal.profilePicture),
                                  ))
                              : new Image.asset(
                                  "assets/profile/user_on_user.png",
                                  height: 60.0,
                                  width: 60.0,
                                ),
                        ),
                        flex: 1,
                      ),
                      new Expanded(
                        child: PaddingWrap.paddingAll(
                            5.0,
                            new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                TextViewWrap.textView(
                                    userPostModal.lastName == "null"
                                        ? userPostModal.firstName
                                        : userPostModal.firstName +
                                            " " +
                                            userPostModal.lastName,
                                    TextAlign.right,
                                    Colors.black,
                                    16.0,
                                    FontWeight.bold),
                                userPostModal.title == "null"
                                    ? new Container(
                                        height: 1.0,
                                      )
                                    : TextViewWrap.textView(
                                        userPostModal.title,
                                        TextAlign.center,
                                        Colors.grey,
                                        14.0,
                                        FontWeight.normal),
                              ],
                            )),
                        flex: 4,
                      ),
                      new Expanded(
                        child: userIdPref == userPostModal.postedBy
                            ? feedType
                                ? getMoreDropDown(userPostModal, index)
                                : new Container(
                                    height: 0.0,
                                  )
                            : new Container(
                                height: 1.0,
                              ),
                        flex: 0,
                      )
                    ],
                  )),
              userPostModal.postdata.imageList.length == 0
                  ? new Container(
                      height: 1.0,
                    )
                  : new InkWell(
                      child: new Container(
                        height: 200.0,
                        child: userPostModal.postdata.imageList.length == 1
                            ? isCount1(userPostModal.postdata.imageList[0])
                            : userPostModal.postdata.imageList.length == 2
                                ? isCount2(userPostModal.postdata.imageList[0],
                                    userPostModal.postdata.imageList[1])
                                : userPostModal.postdata.imageList.length == 3
                                    ? isCount3(
                                        userPostModal.postdata.imageList[0],
                                        userPostModal.postdata.imageList[1],
                                        userPostModal.postdata.imageList[2])
                                    : isCount4(
                                        userPostModal.postdata.imageList[0],
                                        userPostModal.postdata.imageList[1],
                                        userPostModal.postdata.imageList[2],
                                        userPostModal.postdata.imageList[3],
                                        userPostModal
                                            .postdata.imageList.length),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new FullIMageView(
                                    userPostModal.postdata.imageList)));
                      },
                    ),
              userPostModal.postdata.imageList.length > 0 ||
                      userPostModal.postdata.media == null ||
                      userPostModal.postdata.media == "" ||
                      userPostModal.postdata.media == "null"
                  ? new Container(
                      height: 1.0,
                    )
                  : new Container(
                      height: 200.0,
                      child: new Center(
                        child: new Center(
                            child: new AspectRatio(
                          aspectRatio: 3 / 2,
                          child: new PlayerLifeCycle(
                              Constant.IMAGE_PATH +
                                  userPostModal.postdata.media,
                              (BuildContext context,
                                      VideoPlayerController controller) =>
                                  new VideoPlayPause(controller)),
                        )),
                      ),
                    ),
              userPostModal.postdata.imageList.length == 0
                  ? PaddingWrap.paddingfromLTRB(
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      userPostModal.postdata.text == "" ||
                              userPostModal.postdata.text == "null" ||
                              userPostModal.postdata.text == "\n"
                          ? new Container(
                              height: 1.0,
                            )
                          : PaddingWrap.paddingfromLTRB(
                              10.0,
                              0.0,
                              0.0,
                              5.0,
                              TextViewWrap.textView(
                                  userPostModal.postdata.text,
                                  TextAlign.left,
                                  Colors.black,
                                  16.0,
                                  FontWeight.normal)),
                    )
                  : new Container(
                      height: 1.0,
                    ),
              new Row(
                children: <Widget>[
                  new Expanded(
                      child: new Row(
                    children: <Widget>[
                      userPostModal.isLike
                          ? new InkWell(
                              child: PaddingWrap.paddingAll(
                                  10.0,
                                  new Image.asset(
                                    "assets/home/like.png",
                                    height: 30.0,
                                    width: 30.0,
                                  )),
                              onTap: () {
                                feedType ? onTapLike(userPostModal) : null;
                              },
                            )
                          : new InkWell(
                              child: PaddingWrap.paddingAll(
                                  10.0,
                                  new Image.asset(
                                    "assets/home/like_inactive.png",
                                    height: 30.0,
                                    width: 30.0,
                                  )),
                              onTap: () {
                                feedType ? onTapLike(userPostModal) : null;
                              },
                            ),
                      userPostModal.isCommented
                          ? new InkWell(
                              child: PaddingWrap.paddingAll(
                                  10.0,
                                  new Image.asset(
                                    "assets/home/comment.png",
                                    height: 30.0,
                                    width: 30.0,
                                  )),
                              onTap: () {
                                //  onTapComment(userPostModal);
                              },
                            )
                          : new InkWell(
                              child: PaddingWrap.paddingAll(
                                  10.0,
                                  new Image.asset(
                                    "assets/home/comment_inactive.png",
                                    height: 30.0,
                                    width: 30.0,
                                  )),
                              onTap: () {
                                //onTapComment(userPostModal);
                              },
                            ),
                      shareView(userPostModal, feedType),
                    ],
                  )),
                  new Expanded(
                      child: PaddingWrap.paddingfromLTRB(
                          0.0,
                          0.0,
                          10.0,
                          0.0,
                          new Text(
                            userPostModal.dateTime,
                            textAlign: TextAlign.right,
                          ))),
                ],
              ),
              PaddingWrap.paddingAll(
                  10.0,
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      userPostModal.likeList.length > 0
                          ? new InkWell(
                              child: TextViewWrap.textView(
                                  userPostModal.likeList.length == 1
                                      ? "1 Like"
                                      : userPostModal.likeList.length
                                              .toString() +
                                          " Likes",
                                  TextAlign.left,
                                  Colors.black,
                                  18.0,
                                  FontWeight.bold),
                              onTap: () {
                                feedType ? onTapLikeText(userPostModal) : null;
                              },
                            )
                          : new Container(
                              height: 1.0,
                            ),
                      userPostModal.postdata.imageList.length > 0
                          ? PaddingWrap.paddingfromLTRB(
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                              userPostModal.postdata.text == "" ||
                                      userPostModal.postdata.text == "null" ||
                                      userPostModal.postdata.text == "\n"
                                  ? new Container(
                                      height: 1.0,
                                    )
                                  : PaddingWrap.paddingfromLTRB(
                                      10.0,
                                      0.0,
                                      0.0,
                                      5.0,
                                      TextViewWrap.textView(
                                          userPostModal.postdata.text,
                                          TextAlign.left,
                                          Colors.black,
                                          16.0,
                                          FontWeight.normal)),
                            )
                          : new Container(
                              height: 1.0,
                            ),
                      userPostModal.commentList.length > 1
                          ? new InkWell(
                              child: PaddingWrap.paddingfromLTRB(
                                0.0,
                                10.0,
                                0.0,
                                0.0,
                                TextViewWrap.textView(
                                    "View all " +
                                        userPostModal.commentList.length
                                            .toString() +
                                        " comments",
                                    TextAlign.left,
                                    Colors.grey,
                                    16.0,
                                    FontWeight.bold),
                              ),
                              onTap: () {
                                feedType
                                    ? onTapViewAllComments(
                                        userPostModal.commentList,
                                        userPostModal.feedId,
                                        userPostModal)
                                    : null;
                              },
                            )
                          : new Container(
                              height: 1.0,
                            ),
                      new Padding(
                          padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: new List.generate(
                                  userPostModal.commentList.length > 1
                                      ? 1
                                      : userPostModal.commentList.length,
                                  (int index) {
                                return PaddingWrap.paddingAll(
                                    5.0,
                                    new Column(
                                      children: <Widget>[
                                        new Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Expanded(
                                              child: new Center(
                                                child: new Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      fit: BoxFit.fill,
                                                      width: double.infinity,
                                                      placeholder:
                                                          'assets/profile/user_on_user.png',
                                                      image: Constant
                                                              .IMAGE_PATH_SMALL +
                                                          ParseJson.getSmallImage(userPostModal
                                                              .commentList[
                                                                  userPostModal
                                                                          .commentList
                                                                          .length -
                                                                      1]
                                                              .profilePicture),
                                                    )),
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
                                                  TextViewWrap.textView(
                                                      userPostModal
                                                          .commentList[
                                                              userPostModal
                                                                      .commentList
                                                                      .length -
                                                                  1]
                                                          .comment,
                                                      TextAlign.left,
                                                      new Color(ColorValues
                                                          .HOME_TEXT_COLOUR),
                                                      16.0,
                                                      FontWeight.bold),
                                                  new Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      new Text(
                                                        userPostModal
                                                            .commentList[
                                                                userPostModal
                                                                        .commentList
                                                                        .length -
                                                                    1]
                                                            .dateTime,
                                                        textAlign:
                                                            TextAlign.left,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              flex: 4,
                                            )
                                          ],
                                        ),
                                        new Divider(color: Colors.grey[300]),
                                      ],
                                    ));
                              }))),
                      PaddingWrap.paddingAll(
                          5.0,
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: profile_image_path != null &&
                                        profile_image_path != "" &&
                                        profile_image_path != "null"
                                    ? new Center(
                                        child: new Container(
                                            width: 50.0,
                                            height: 50.0,
                                            child: FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              placeholder:
                                                  'assets/profile/user_on_user.png',
                                              image: Constant.IMAGE_PATH_SMALL +
                                                  ParseJson.getSmallImage(
                                                      profile_image_path),
                                            )),
                                      )
                                    : new Image.asset(
                                        "assets/profile/user_on_user.png",
                                        height: 50.0,
                                        width: 50.0,
                                      ),
                                flex: 1,
                              ),
                              new Expanded(
                                child: new TextField(
                                  controller: userPostModal.txtController,
                                  keyboardType: TextInputType.text,
                                  enabled: feedType,
                                  onChanged: (s) {
                                    if (s.length > 0) {
                                      userPostModal.isCommentIconVisible = true;
                                    } else {
                                      userPostModal.isCommentIconVisible =
                                          false;
                                    }
                                    setState(() {
                                      userPostModal.isCommentIconVisible;
                                    });
                                  },
                                  decoration: userPostModal.isCommentIconVisible
                                      ? new InputDecoration(
                                          border: InputBorder.none,
                                          filled: true,
                                          hintText: "Add Comment..",
                                          fillColor: Colors.transparent,
                                          suffixIcon: new InkWell(
                                            child: new Image.asset(
                                              "assets/home/send.png",
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            onTap: () {
                                              userPostModal
                                                  .isCommentIconVisible = false;
                                              onAddComment(
                                                  userPostModal.feedId,
                                                  userPostModal
                                                      .txtController.text,
                                                  userPostModal);
                                              userPostModal.txtController.text =
                                                  "";
                                              setState(() {
                                                userPostModal.txtController;
                                                userPostModal
                                                    .isCommentIconVisible;
                                              });
                                            },
                                          ))
                                      : new InputDecoration(
                                          border: InputBorder.none,
                                          filled: true,
                                          hintText: "Add Comment..",
                                          fillColor: Colors.transparent,
                                        ),
                                ),
                                flex: 4,
                              )
                            ],
                          )),
                    ],
                  ))
            ],
          )));
    }

    Padding getListViewPost(userPostModal, index, feedType) {
      return PaddingWrap.paddingAll(
          3.0,
          new Card(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                getEvent(userPostModal),
                PaddingWrap.paddingAll(
                    10.0,
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Center(
                              child: userPostModal.profilePicture != "null"
                                  ? new Container(
                                      width: 60.0,
                                      height: 60.0,
                                      child: FadeInImage.assetNetwork(
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        placeholder:
                                            'assets/profile/user_on_user.png',
                                        image: Constant.IMAGE_PATH_SMALL +
                                            ParseJson.getSmallImage(
                                                userPostModal.profilePicture),
                                      ))
                                  : new Image.asset(
                                      "assets/profile/user_on_user.png",
                                      height: 60.0,
                                      width: 60.0,
                                    )),
                          flex: 1,
                        ),
                        new Expanded(
                          child: PaddingWrap.paddingAll(
                              5.0,
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  TextViewWrap.textView(
                                      userPostModal.lastName == "null"
                                          ? userPostModal.firstName
                                          : userPostModal.firstName +
                                              " " +
                                              userPostModal.lastName,
                                      TextAlign.right,
                                      Colors.black,
                                      16.0,
                                      FontWeight.bold),
                                  userPostModal.title == "null"
                                      ? new Container(
                                          height: 1.0,
                                        )
                                      : TextViewWrap.textView(
                                          userPostModal.title,
                                          TextAlign.center,
                                          Colors.grey,
                                          14.0,
                                          FontWeight.normal),
                                  TextViewWrap.textView(
                                      userPostModal.dateTime,
                                      TextAlign.center,
                                      Colors.black,
                                      14.0,
                                      FontWeight.normal)
                                ],
                              )),
                          flex: 4,
                        ),
                        new Expanded(
                          child: userIdPref == userPostModal.postedBy
                              ? getMoreDropDown(userPostModal, index)
                              : new Container(
                                  height: 1.0,
                                ),
                          flex: 0,
                        )
                      ],
                    )),
                userPostModal.shareText == "null" ||
                        userPostModal.shareText == ""
                    ? new Container(
                        height: 1.0,
                      )
                    : PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        0.0,
                        0.0,
                        TextViewWrap.textView(
                            userPostModal.shareText,
                            TextAlign.left,
                            Colors.black,
                            16.0,
                            FontWeight.normal)),
                PaddingWrap.paddingAll(
                    3.0,
                    new Card(
                        elevation: 5.0,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            PaddingWrap.paddingAll(
                                10.0,
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: userPostModal
                                                  .postOwnerProfilePicture !=
                                              "null"
                                          ? new Center(
                                              child: new Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    fit: BoxFit.fill,
                                                    width: double.infinity,
                                                    placeholder:
                                                        'assets/profile/user_on_user.png',
                                                    image: Constant
                                                            .IMAGE_PATH_SMALL +
                                                        ParseJson.getSmallImage(
                                                            userPostModal
                                                                .postOwnerProfilePicture),
                                                  )))
                                          : new Image.asset(
                                              "assets/profile/user_on_user.png",
                                              height: 40.0,
                                              width: 40.0,
                                            ),
                                      flex: 1,
                                    ),
                                    new Expanded(
                                      child: PaddingWrap.paddingAll(
                                          5.0,
                                          new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              TextViewWrap.textView(
                                                  userPostModal
                                                              .postOwnerLastName ==
                                                          "null"
                                                      ? userPostModal
                                                          .postOwnerFirstName
                                                      : userPostModal
                                                              .postOwnerFirstName +
                                                          " " +
                                                          userPostModal
                                                              .postOwnerLastName,
                                                  TextAlign.right,
                                                  Colors.black,
                                                  16.0,
                                                  FontWeight.bold),
                                              userPostModal.postOwnerTitle ==
                                                      "null"
                                                  ? new Container(
                                                      height: 1.0,
                                                    )
                                                  : TextViewWrap.textView(
                                                      userPostModal
                                                          .postOwnerTitle,
                                                      TextAlign.center,
                                                      Colors.grey,
                                                      14.0,
                                                      FontWeight.normal),
                                            ],
                                          )),
                                      flex: 4,
                                    )
                                  ],
                                )),
                            userPostModal.postdata.text == "" ||
                                    userPostModal.postdata.text == "null" ||
                                    userPostModal.postdata.text == "\n"
                                ? new Container(
                                    height: 1.0,
                                  )
                                : PaddingWrap.paddingfromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    5.0,
                                    TextViewWrap.textView(
                                        userPostModal.postdata.text,
                                        TextAlign.left,
                                        Colors.black,
                                        16.0,
                                        FontWeight.normal)),
                            userPostModal.postdata.imageList.length == 0
                                ? new Container(
                                    height: 1.0,
                                  )
                                : new InkWell(
                                    child: new Container(
                                      padding: new EdgeInsets.all(5.0),
                                      height: 200.0,
                                      child: userPostModal.postdata.imageList.length == 1
                                          ? isCount1(userPostModal
                                              .postdata.imageList[0])
                                          : userPostModal.postdata.imageList.length == 2
                                              ? isCount2(
                                                  userPostModal
                                                      .postdata.imageList[0],
                                                  userPostModal
                                                      .postdata.imageList[1])
                                              : userPostModal.postdata.imageList.length == 3
                                                  ? isCount3(
                                                      userPostModal.postdata
                                                          .imageList[0],
                                                      userPostModal.postdata
                                                          .imageList[1],
                                                      userPostModal.postdata
                                                          .imageList[2])
                                                  : isCount4(
                                                      userPostModal.postdata
                                                          .imageList[0],
                                                      userPostModal.postdata.imageList[1],
                                                      userPostModal.postdata.imageList[2],
                                                      userPostModal.postdata.imageList[3],
                                                      userPostModal.postdata.imageList.length),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new FullIMageView(
                                                      userPostModal.postdata
                                                          .imageList)));
                                    },
                                  ),
                            userPostModal.postdata.imageList.length > 0 ||
                                    userPostModal.postdata.media == null ||
                                    userPostModal.postdata.media == "" ||
                                    userPostModal.postdata.media == "null"
                                ? new Container(
                                    height: 1.0,
                                  )
                                : new Container(
                                    height: 200.0,
                                    child: new Center(
                                        child: new AspectRatio(
                                      aspectRatio: 3 / 2,
                                      child: new PlayerLifeCycle(
                                          Constant.IMAGE_PATH +
                                              userPostModal.postdata.media,
                                          (BuildContext context,
                                                  VideoPlayerController
                                                      controller) =>
                                              new VideoPlayPause(controller)),
                                    ))),
                          ],
                        ))),
                new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Row(
                      children: <Widget>[
                        userPostModal.isLike
                            ? new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/like.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  onTapLike(userPostModal);
                                },
                              )
                            : new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/like_inactive.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  onTapLike(userPostModal);
                                },
                              ),
                        userPostModal.isCommented
                            ? new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/comment.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  //  onTapComment(userPostModal);
                                },
                              )
                            : new InkWell(
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Image.asset(
                                      "assets/home/comment_inactive.png",
                                      height: 30.0,
                                      width: 30.0,
                                    )),
                                onTap: () {
                                  //   onTapComment(userPostModal);
                                },
                              ),
                        shareView(userPostModal, feedType),
                      ],
                    )),
                    new Expanded(
                        child: PaddingWrap.paddingfromLTRB(
                            0.0,
                            0.0,
                            10.0,
                            0.0,
                            new Text(
                              userPostModal.shareTime,
                              textAlign: TextAlign.right,
                            ))),
                  ],
                ),
                PaddingWrap.paddingAll(
                    10.0,
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        userPostModal.likeList.length > 0
                            ? new InkWell(
                                child: TextViewWrap.textView(
                                    userPostModal.likeList.length == 1
                                        ? "1 Like"
                                        : userPostModal.likeList.length
                                                .toString() +
                                            " Likes",
                                    TextAlign.left,
                                    Colors.black,
                                    18.0,
                                    FontWeight.bold),
                                onTap: () {
                                  onTapLikeText(userPostModal);
                                },
                              )
                            : new Container(
                                height: 1.0,
                              ),
                        userPostModal.commentList.length > 1
                            ? new InkWell(
                                child: PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  10.0,
                                  0.0,
                                  0.0,
                                  TextViewWrap.textView(
                                      "View all " +
                                          userPostModal.commentList.length
                                              .toString() +
                                          " comments",
                                      TextAlign.left,
                                      Colors.grey,
                                      16.0,
                                      FontWeight.bold),
                                ),
                                onTap: () {
                                  onTapViewAllComments(
                                      userPostModal.commentList,
                                      userPostModal.feedId,
                                      userPostModal);
                                })
                            : new Container(
                                height: 1.0,
                              ),
                        new Padding(
                            padding:
                                new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                            child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: new List.generate(
                                    userPostModal.commentList.length > 1
                                        ? 1
                                        : userPostModal.commentList.length,
                                    (int index) {
                                  return PaddingWrap.paddingAll(
                                      5.0,
                                      new Column(
                                        children: <Widget>[
                                          new Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Center(
                                                  child: new Container(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        fit: BoxFit.fill,
                                                        width: double.infinity,
                                                        placeholder:
                                                            'assets/profile/user_on_user.png',
                                                        image: Constant
                                                                .IMAGE_PATH_SMALL +
                                                            ParseJson.getSmallImage(userPostModal
                                                                .commentList[
                                                                    userPostModal
                                                                            .commentList
                                                                            .length -
                                                                        1]
                                                                .profilePicture),
                                                      )),
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
                                                    TextViewWrap.textView(
                                                        userPostModal
                                                            .commentList[
                                                                userPostModal
                                                                        .commentList
                                                                        .length -
                                                                    1]
                                                            .comment,
                                                        TextAlign.left,
                                                        new Color(ColorValues
                                                            .HOME_TEXT_COLOUR),
                                                        16.0,
                                                        FontWeight.bold),
                                                    new Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        new Text(
                                                          userPostModal
                                                              .commentList[
                                                                  userPostModal
                                                                          .commentList
                                                                          .length -
                                                                      1]
                                                              .dateTime,
                                                          textAlign:
                                                              TextAlign.left,
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                flex: 4,
                                              )
                                            ],
                                          ),
                                          new Divider(color: Colors.grey[300]),
                                        ],
                                      ));
                                }))),
                        PaddingWrap.paddingAll(
                            5.0,
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: profile_image_path != null &&
                                          profile_image_path != "" &&
                                          profile_image_path != "null"
                                      ? new Center(
                                          child: new Container(
                                              width: 50.0,
                                              height: 50.0,
                                              child: FadeInImage.assetNetwork(
                                                fit: BoxFit.fill,
                                                width: double.infinity,
                                                placeholder:
                                                    'assets/profile/user_on_user.png',
                                                image:
                                                    Constant.IMAGE_PATH_SMALL +
                                                        ParseJson.getSmallImage(
                                                            profile_image_path),
                                              )),
                                        )
                                      : new Image.asset(
                                          "assets/profile/user_on_user.png",
                                          height: 50.0,
                                          width: 50.0,
                                        ),
                                  flex: 1,
                                ),
                                new Expanded(
                                  child: new TextField(
                                    controller: userPostModal.txtController,
                                    keyboardType: TextInputType.text,
                                    onChanged: (s) {
                                      if (s.length > 0) {
                                        userPostModal.isCommentIconVisible =
                                            true;
                                      } else {
                                        userPostModal.isCommentIconVisible =
                                            false;
                                      }
                                      setState(() {
                                        userPostModal.isCommentIconVisible;
                                      });
                                    },
                                    decoration: userPostModal
                                            .isCommentIconVisible
                                        ? new InputDecoration(
                                            border: InputBorder.none,
                                            filled: true,
                                            hintText: "Add Comment..",
                                            fillColor: Colors.transparent,
                                            suffixIcon: new InkWell(
                                              child: new Image.asset(
                                                "assets/home/send.png",
                                                width: 30.0,
                                                height: 30.0,
                                              ),
                                              onTap: () {
                                                userPostModal
                                                        .isCommentIconVisible =
                                                    false;
                                                onAddComment(
                                                    userPostModal.feedId,
                                                    userPostModal
                                                        .txtController.text,
                                                    userPostModal);
                                                userPostModal
                                                    .txtController.text = "";
                                                setState(() {
                                                  userPostModal.txtController;
                                                  userPostModal
                                                      .isCommentIconVisible;
                                                });
                                              },
                                            ))
                                        : new InputDecoration(
                                            border: InputBorder.none,
                                            filled: true,
                                            hintText: "Add Comment..",
                                            fillColor: Colors.transparent,
                                          ),
                                  ),
                                  flex: 4,
                                )
                              ],
                            )),
                      ],
                    ))
              ])));
    }

    Column getFeedUi(feedType) {
      return new Column(
        children: <Widget>[
          isFeed
              ? PaddingWrap.paddingAll(
                  5.0,
                  new Card(
                      color: Colors.white,
                      elevation: 5.0,
                      child: new Container(
                        padding: new EdgeInsets.all(5.0),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new InkWell(
                                child: new Container(
                                    decoration: new BoxDecoration(
                                        border: new Border(
                                      right: new BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    )),
                                    child: PaddingWrap.paddingAll(
                                        5.0,
                                        new Center(
                                          child: new Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                new Image.asset(
                                                  "assets/group/write_post.png",
                                                  width: 30.0,
                                                  height: 30.0,
                                                ),
                                                TextViewWrap.textView(
                                                    "   Write a post",
                                                    TextAlign.center,
                                                    new Color(
                                                        ColorValues.BLUE_COLOR),
                                                    16.0,
                                                    FontWeight.normal)
                                              ]),
                                        ))),
                                onTap: () {
                                  onTapAddPost(groupList[0].groupId);
                                },
                              ),
                              flex: 1,
                            ),
                            new Expanded(
                              child: new InkWell(
                                child: PaddingWrap.paddingAll(
                                  5.0,
                                  new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Image.asset(
                                          "assets/group/upload_media.png",
                                          width: 30.0,
                                          height: 30.0,
                                        ),
                                        TextViewWrap.textView(
                                            "  Upload Media",
                                            TextAlign.center,
                                            new Color(ColorValues.BLUE_COLOR),
                                            16.0,
                                            FontWeight.normal)
                                      ]),
                                ),
                                onTap: () {
                                  onTapAddPost(groupList[0].groupId);
                                },
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                      )))
              : new Container(
                  height: 0.0,
                ),
          !isFeed
              ? getInfoUi()
              : userPostList.length > 0
                  ? new Column(
                      children: new List.generate(userPostList.length,
                          (int position) {
                      if (userPostList.length - 1 == position) {
                        ++offset;
                        if (isLoadMore) apiCallingForUserPostLoadMore();
                      }
                      if (userPostList[position].postOwner == "null")
                        return getListView(
                            userPostList[position], position, feedType);
                      else
                        return getListViewPost(
                            userPostList[position], position, feedType);
                    }))
                  : new Center(
                      child: new Text(
                        "",
                      ),
                    )
        ],
      );
    }

    Container getPrivateRequest() {
      return !isFeed
          ? getInfoUi()
          : new Container(
              padding: new EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
              child: new Center(
                  child: new Column(
                children: <Widget>[
                  new Image.asset(
                    "assets/group/no_feed.png",
                    width: 150.0,
                    height: 150.0,
                  ),
                  PaddingWrap.paddingAll(
                      10.0,
                      new Text(
                        "You can not see the post of private group.",
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              )),
            );
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context, status);
        },
        child: new Scaffold(
            backgroundColor: new Color(0XFFF7F7F9),
            body: new Container(
                color: new Color(0XFFF7F7F9),
                child: new ListView(
                  children: <Widget>[
                    new Container(
                        height: 180.0,
                        child: new Stack(
                          children: <Widget>[
                            imagePathCover == null
                                ? FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    placeholder:
                                        'assets/group/group_default.png',
                                    image: groupList.length > 0
                                        ? Constant.IMAGE_PATH +
                                            groupList[0].groupImage
                                        : "",
                                  )
                                : new Image.file(
                                    imagePathCover,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                  ),
                            new Container(
                              color: Colors.black38,
                              height: 180.0,
                              width: double.infinity,
                            ),
                            new Align(
                              alignment: Alignment.topLeft,
                              child: PaddingWrap.paddingfromLTRB(
                                  5.0,
                                  10.0,
                                  0.0,
                                  0.0,
                                  new InkWell(
                                    child: new Image.asset(
                                      "assets/group/back_arrow.png",
                                      width: 30.0,
                                      height: 30.0,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, status);
                                    },
                                  )),
                            ),
                            groupList.length > 0
                                ?groupList[0].type=="private"? groupList[0].isAdmin
                                    ? new Align(
                                        alignment: Alignment.topRight,
                                        child: PaddingWrap.paddingfromLTRB(
                                            5.0,
                                            10.0,
                                            0.0,
                                            0.0,
                                            new InkWell(
                                              child: new Image.asset(
                                                "assets/profile/user/edit_profile.png",
                                                width: 30.0,
                                                height: 30.0,
                                              ),
                                              onTap: () {
                                                onTapEditGroup();
                                              },
                                            )),
                                      )
                                    : new Container(
                                        height: 0.0,
                                      ):new Align(
                              alignment: Alignment.topRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  5.0,
                                  10.0,
                                  0.0,
                                  0.0,
                                  new InkWell(
                                    child: new Image.asset(
                                      "assets/profile/user/edit_profile.png",
                                      width: 30.0,
                                      height: 30.0,
                                    ),
                                    onTap: () {
                                      onTapEditGroup();
                                    },
                                  )),
                            )
                                : new Container(
                                    height: 0.0,
                                  ),
                            groupList.length > 0
                                ?groupList[0].type=="private"? groupList[0].isAdmin
                                    ? new Align(
                                        alignment: Alignment.bottomRight,
                                        child: PaddingWrap.paddingfromLTRB(
                                            5.0,
                                            10.0,
                                            10.0,
                                            10.0,
                                            new InkWell(
                                              child: new Image.asset(
                                                "assets/profile/cover_edit.png",
                                                width: 30.0,
                                                height: 30.0,
                                              ),
                                              onTap: () {
                                                getImageCover();
                                              },
                                            )),
                                      )
                                    : new Container(
                                        height: 0.0,
                                      ):new Align(
                              alignment: Alignment.bottomRight,
                              child: PaddingWrap.paddingfromLTRB(
                                  5.0,
                                  10.0,
                                  10.0,
                                  10.0,
                                  new InkWell(
                                    child: new Image.asset(
                                      "assets/profile/cover_edit.png",
                                      width: 30.0,
                                      height: 30.0,
                                    ),
                                    onTap: () {
                                      getImageCover();
                                    },
                                  )),
                            )
                                : new Container(
                                    height: 0.0,
                                  ),
                          ],
                        )),
                    groupList.length > 0
                        ? new Column(
                            children: <Widget>[
                              getHeaderUi(),
                              PaddingWrap.paddingfromLTRB(
                                  0.0,
                                  20.0,
                                  0.0,
                                  0.0,
                                  new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Column(
                                            children: <Widget>[
                                              PaddingWrap.paddingAll(
                                                  5.0,
                                                  TextViewWrap.textView(
                                                      "Feed",
                                                      TextAlign.center,
                                                      isFeed
                                                          ? new Color(
                                                              ColorValues
                                                                  .BLUE_COLOR)
                                                          : Colors.grey,
                                                      16.0,
                                                      FontWeight.bold)),
                                              new Container(
                                                height: 2.0,
                                                color: isFeed
                                                    ? new Color(
                                                        ColorValues.BLUE_COLOR)
                                                    : Colors.grey[300],
                                              )
                                            ],
                                          ),
                                          onTap: () {
                                            isFeed = true;
                                            setState(() {
                                              isFeed;
                                            });
                                          },
                                        ),
                                        flex: 1,
                                      ),
                                      new Expanded(
                                        child: new InkWell(
                                          child: new Column(
                                            children: <Widget>[
                                              PaddingWrap.paddingAll(
                                                  5.0,
                                                  TextViewWrap.textView(
                                                      "Info",
                                                      TextAlign.center,
                                                      isFeed
                                                          ? Colors.grey
                                                          : new Color(
                                                              ColorValues
                                                                  .BLUE_COLOR),
                                                      16.0,
                                                      FontWeight.bold)),
                                              new Container(
                                                height: 2.0,
                                                color: isFeed
                                                    ? Colors.grey[300]
                                                    : new Color(
                                                        ColorValues.BLUE_COLOR),
                                              )
                                            ],
                                          ),
                                          onTap: () {
                                            isFeed = false;
                                            setState(() {
                                              isFeed;
                                            });
                                          },
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  )),
                              groupList[0].type == "public"
                                  ? getFeedUi(groupList[0].status == "Accepted"
                                      ? true
                                      : false)
                                  : groupList[0].status == "Accepted"
                                      ? getFeedUi(true)
                                      : getPrivateRequest()
                            ],
                          )
                        : new Container(
                            height: 0.0,
                          )
                  ],
                ))));
  }
}
