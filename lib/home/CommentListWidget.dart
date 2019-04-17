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
import 'package:spike_view_project/home/LikeDetailWidget.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class CommentListWidget extends StatefulWidget {
  List<CommentData> commentList;
  String profile_image_path, feedId, name;
  UserPostModal userPostModel;
  String userIdPref;

  CommentListWidget(this.commentList, this.profile_image_path, this.feedId,
      this.name, this.userPostModel, this.userIdPref);

  @override
  CommentListWidgetState createState() {
    return new CommentListWidgetState(commentList, userIdPref);
  }
}

class CommentListWidgetState extends State<CommentListWidget> {
  SharedPreferences prefs;
  String userIdPref, token, summary = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController addComment;
  bool isCommentIconVisible = false;

  CommentListWidgetState(this.commentList, this.userIdPref);

  List<CommentData> commentList;

  @override
  void initState() {
    //getSharedPreferences();
    addComment = new TextEditingController(text: '');

    super.initState();
  }

  Future apiCallingForAddLike(index) async {
    try {
      bool isLike = false;
      if (commentList[index].isLike) {
        isLike = false;
      } else {
        isLike = true;
      }
      Map map = {
        "feedId": int.parse(widget.feedId),
        "userId": int.parse(userIdPref),
        "isLike": isLike,
        "commentId": commentList[index].commentId
      };

      Response response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_ADD_LIKE, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            if (commentList[index].isLike) {
              commentList[index].isLike = false;
              commentList[index].likesList.removeLast();
              for (int i = 0; i < commentList[index].likesList.length; i++) {
                if (commentList[index].likesList[i].userId == userIdPref) {
                  commentList[index].likesList.removeAt(i);
                  break;
                }
              }
            } else {
              commentList[index].isLike = true;
              commentList[index].likesList.add(new Likes(userIdPref,
                  widget.name, widget.profile_image_path, "student"));
            }
            setState(() {
              commentList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallingForAddComment() async {
    try {
      Map map = {
        "feedId": widget.feedId,
        "userId": int.parse(userIdPref),
        "comment": addComment.text,
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
            widget.userPostModel.isCommented = true;
            List<Likes> likesList = new List();
            commentList.add(new CommentData(
                response.data["result"]["commentId"].toString(),
                addComment.text,
                userIdPref,
                "a few seconds ago",
                widget.profile_image_path,
                widget.name,
                "",
                userIdPref,
                likesList,
                false));
            setState(() {
              addComment.text = "";
              widget.userPostModel;
              commentList;
            });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  Future apiCallForRemoveComment(index) async {
    try {
      Map map = {
        "feedId": int.parse(widget.feedId),
        "commentId": commentList[index].commentId,
        "dateTime": new DateTime.now().millisecondsSinceEpoch
      };

      Response response = await new ApiCalling().apiCallPostWithMapData(
          context, Constant.ENDPOINT_REMOVE_COMMENT, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            commentList.removeAt(index);
            if (commentList.length == 0)
              widget.userPostModel.isCommented = false;
            setState(() {
              commentList;
              widget.userPostModel;
            });
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

    Widget getMoreDropDown(index) {
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
                    apiCallForRemoveComment(index);
                  },
                ),
                value: "1",
              ),
            ],
      );
    }

    Widget getListItem(index) {
      return index == commentList.length - 1
          ? PaddingWrap.paddingAll(
              5.0,
              new Column(
                children: <Widget>[

                  new Divider(color: Colors.grey[300]),
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Container(
                              width: 50.0,
                              height: 50.0,
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.fill,
                                placeholder: 'assets/profile/user_on_user.png',
                                image: Constant.IMAGE_PATH_SMALL +
                                    ParseJson.getSmallImage(
                                        commentList[index].profilePicture),
                              )),
                        ),
                        flex: 1,
                      ),
                      new Expanded(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Row(
                              children: <Widget>[
                                new Expanded(
                                    child: PaddingWrap.paddingfromLTRB(
                                        5.0,
                                        5.0,
                                        0.0,
                                        0.0,
                                        TextViewWrap.textView(
                                            commentList[index].name,
                                            TextAlign.start,
                                            Colors.black,
                                            17.0,
                                            FontWeight.bold))),
                                new Expanded(
                                  child: userIdPref ==
                                          commentList[index].commentedBy
                                      ? PaddingWrap.paddingfromLTRB(5.0, 0.0,
                                          10.0, 0.0, getMoreDropDown(index))
                                      : new Container(
                                          height: 1.0,
                                        ),
                                  flex: 0,
                                )
                              ],
                            ),
                            PaddingWrap.paddingfromLTRB(
                                5.0,
                                0.0,
                                0.0,
                                5.0,
                                new Text(
                                  commentList[index].comment,
                                  textAlign: TextAlign.left,
                                  style: new TextStyle(
                                      color: Colors.black, fontSize: 16.0),
                                )),
                            new Row(

                              children: <Widget>[
                                new Expanded(
                                    child: new Row(
                                  children: <Widget>[
                                    commentList[index].isLike
                                        ? new InkWell(
                                            child: PaddingWrap.paddingAll(
                                                5.0,
                                                new Image.asset(
                                                  "assets/home/like.png",
                                                  height: 30.0,
                                                  width: 30.0,
                                                )),
                                            onTap: () {
                                              apiCallingForAddLike(index);
                                            },
                                          )
                                        : new InkWell(
                                            child: PaddingWrap.paddingAll(
                                                5.0,
                                                new Image.asset(
                                                  "assets/home/like_inactive.png",
                                                  height: 30.0,
                                                  width: 30.0,
                                                )),
                                            onTap: () {
                                              apiCallingForAddLike(index);
                                            },
                                          ),
                                    commentList[index].likesList != null &&
                                            commentList[index]
                                                    .likesList
                                                    .length >
                                                0
                                        ? new InkWell(
                                            child: TextViewWrap.textView(
                                                commentList[index]
                                                        .likesList
                                                        .length
                                                        .toString() +
                                                    " Likes",
                                                TextAlign.left,
                                                Colors.black,
                                                18.0,
                                                FontWeight.bold),
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  new MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          new LikeDetailWidget(
                                                              commentList[index]
                                                                  .likesList)));
                                            },
                                          )
                                        : new Container(
                                            height: 1.0,
                                          ),
                                  ],
                                )),
                                new Expanded(
                                  child: new Row(

                                    children: <Widget>[
                                      new Text(
                                        commentList[index].dateTime,
                                        textAlign: TextAlign.right,
                                      )
                                    ],
                                  ),
                                  flex: 0,
                                )
                              ],
                            )
                          ],
                        ),
                        flex: 4,
                      ),
                    ],
                  ),
                  new Divider(color: Colors.grey[300]),
                  PaddingWrap.paddingAll(
                      5.0,
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                            child: new Center(
                              child: new Container(
                                  width: 50.0,
                                  height: 50.0,
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    placeholder:
                                        'assets/profile/user_on_user.png',
                                    image: Constant.IMAGE_PATH_SMALL +
                                        ParseJson.getSmallImage(
                                            widget.profile_image_path),
                                  )),
                            ),
                            flex: 1,
                          ),
                          new Expanded(
                            child: new TextField(
                              maxLines: null,
                              controller: addComment,
                              keyboardType: TextInputType.text,
                              onChanged: (s) {
                                if (s.length > 0) {
                                  isCommentIconVisible = true;
                                } else {
                                  isCommentIconVisible = false;
                                }
                                setState(() {
                                  isCommentIconVisible;
                                });
                              },
                              decoration: isCommentIconVisible
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
                                          isCommentIconVisible = false;
                                          apiCallingForAddComment();
                                          setState(() {
                                            isCommentIconVisible;
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
                      ))
                ],
              ))
          : PaddingWrap.paddingAll(
              5.0,
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: new Center(
                          child: new Container(
                              width: 50.0,
                              height: 50.0,
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.fill,
                                placeholder: 'assets/profile/user_on_user.png',
                                image: Constant.IMAGE_PATH_SMALL +
                                    ParseJson.getSmallImage(
                                        commentList[index].profilePicture),
                              )),
                        ),
                        flex: 1,
                      ),
                      new Expanded(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Row(
                              children: <Widget>[
                                new Expanded(
                                    child: PaddingWrap.paddingfromLTRB(
                                        5.0,
                                        5.0,
                                        0.0,
                                        0.0,
                                        TextViewWrap.textView(
                                            commentList[index].name,
                                            TextAlign.start,
                                            Colors.black,
                                            17.0,
                                            FontWeight.bold))),
                                new Expanded(
                                  child: userIdPref ==
                                      commentList[index].commentedBy
                                      ? PaddingWrap.paddingfromLTRB(5.0, 0.0,
                                      10.0, 0.0, getMoreDropDown(index))
                                      : new Container(
                                    height: 1.0,
                                  ),
                                  flex: 0,
                                )
                              ],
                            ),
                            PaddingWrap.paddingfromLTRB(
                                5.0,
                                0.0,
                                0.0,
                                5.0,
                                new Text(
                                  commentList[index].comment,
                                  textAlign: TextAlign.left,
                                  style: new TextStyle(
                                      color: Colors.black, fontSize: 16.0),
                                )),
                            new Row(

                              children: <Widget>[
                                new Expanded(
                                    child: new Row(
                                      children: <Widget>[
                                        commentList[index].isLike
                                            ? new InkWell(
                                          child: PaddingWrap.paddingAll(
                                              5.0,
                                              new Image.asset(
                                                "assets/home/like.png",
                                                height: 30.0,
                                                width: 30.0,
                                              )),
                                          onTap: () {
                                            apiCallingForAddLike(index);
                                          },
                                        )
                                            : new InkWell(
                                          child: PaddingWrap.paddingAll(
                                              5.0,
                                              new Image.asset(
                                                "assets/home/like_inactive.png",
                                                height: 30.0,
                                                width: 30.0,
                                              )),
                                          onTap: () {
                                            apiCallingForAddLike(index);
                                          },
                                        ),
                                        commentList[index].likesList != null &&
                                            commentList[index]
                                                .likesList
                                                .length >
                                                0
                                            ? new InkWell(
                                          child: TextViewWrap.textView(
                                              commentList[index]
                                                  .likesList
                                                  .length
                                                  .toString() +
                                                  " Likes",
                                              TextAlign.left,
                                              Colors.black,
                                              18.0,
                                              FontWeight.bold),
                                          onTap: () {
                                            Navigator.of(context).push(
                                                new MaterialPageRoute(
                                                    builder: (BuildContext
                                                    context) =>
                                                    new LikeDetailWidget(
                                                        commentList[index]
                                                            .likesList)));
                                          },
                                        )
                                            : new Container(
                                          height: 1.0,
                                        ),
                                      ],
                                    )),
                                new Expanded(
                                  child: new Row(

                                    children: <Widget>[
                                      new Text(
                                        commentList[index].dateTime,
                                        textAlign: TextAlign.right,
                                      )
                                    ],
                                  ),
                                  flex: 0,
                                )
                              ],
                            )
                          ],
                        ),
                        flex: 4,
                      ),
                    ],
                  ),
                  new Divider(color: Colors.grey[300])
                ],
              ));
    }

    return new Scaffold(
        backgroundColor: new Color(0XFFF7F7F9),
        appBar: new AppBar(
          titleSpacing: 2.0,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          leading: new Container(
              height: 20.0,
              width: 20.0,
              child: new InkWell(
                child: new Image.asset(
                  "assets/profile/post/back_arrow_blue.png",
                  height: 15.0,
                  width: 15.0,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
          backgroundColor: new Color(0XFFFAFAFA),
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text(
                "COMMENTS",
                style: new TextStyle(color: new Color(ColorValues.BLUE_COLOR)),
              )
            ],
          ),
        ),
        body: new Container(
            color: new Color(0XFFF7F7F9),
            child: new ListView(
              children: <Widget>[
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            new List.generate(commentList.length, (int index) {
                          return getListItem(index);
                        })))
              ],
            )));
  }
}
