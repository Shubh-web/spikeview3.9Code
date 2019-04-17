import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
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
// Create a Form Widget
class RecommendationDetail extends StatefulWidget {
  ProfileInfoModal profileInfoModal;
  Recomdation recomdation;

  RecommendationDetail(this.recomdation, this.profileInfoModal);

  @override
  RecommendationDetailState createState() {
    return new RecommendationDetailState(recomdation, profileInfoModal);
  }
}

class RecommendationDetailState extends State<RecommendationDetail> {
  Recomdation recomdation;
  ProfileInfoModal profileInfoModal;

  RecommendationDetailState(this.recomdation, this.profileInfoModal);

  SharedPreferences prefs;
  String userIdPref, token;
  String strSkills = "", strYear = "";
  DateTime date;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
  }

  @override
  void initState() {
    try {
      if (recomdation.skillList == null) {
      } else {
        for (int i = 0; i < recomdation.skillList.length; i++) {
          strSkills = strSkills + recomdation.skillList[i].label + ",";
        }
        setState(() {
          strSkills;
        });
      }

      if (recomdation.interactionStartDate != "null") {
        int d = int.tryParse(recomdation.interactionStartDate);
        date = new DateTime.fromMillisecondsSinceEpoch(d);
        strYear = date.year.toString();
      }
      setState(() {
        strYear;
      });
      getSharedPreferences();
      // TODO: implement initState

    } catch (e) {
      e.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above

    Container getgridBadges() {
      return recomdation.assestList != null && recomdation.assestList.length > 0
          ? new Container(
              child: Column(
              children: <Widget>[
                PaddingWrap.paddingfromLTRB(
                    5.0,
                    10.0,
                    5.0,
                    10.0,
                    new Container(
                        height: 170.0,
                        child: new GridView.count(
                          primary: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(5.0),
                          crossAxisCount: 1,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 2.0,
                          children: recomdation.assestList.map((Assest assest) {
                            return new Column(
                              children: <Widget>[
                                new Container(
                                  child: new InkWell(child: new Material(
                                    child: new Container(
                                      child: new Image.network(
                                        Constant.IMAGE_PATH + assest.file,
                                        fit: BoxFit.fill,
                                        height: 120.0,
                                        width: 100.0,
                                      ),
                                    ),
                                  ),onTap: (){
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
                                                      Constant.IMAGE_PATH +
                                                          ParseJson.getMediumImage(assest.file),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  child: new Text('Close'),
                                                  onPressed: Navigator.of(context).pop,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },),
                                ),
                        PaddingWrap.paddingfromLTRB(10.0, 0.0, 0.0, 0.0,        new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Expanded(
                                      child: TextViewWrap.textView(
                                          assest.tag,
                                          TextAlign.start,
                                          Colors.black,
                                          10.0,
                                          FontWeight.bold),
                                      flex: 2,
                                    ),
                                    new Expanded(
                                      child: assest.tag == "media"
                                          ? PaddingWrap.paddingfromLTRB(
                                              0.0,
                                              0.0,
                                              0.0,
                                              0.0,
                                              new Image.asset(
                                                "assets/profile/media/general.png",
                                                height: 20.0,
                                                width: 20.0,
                                              ))
                                          : assest.tag == "badges"
                                              ? PaddingWrap.paddingfromLTRB(
                                                  0.0,
                                                  0.0,
                                                  0.0,
                                                  0.0,
                                                  new Image.asset(
                                                    "assets/profile/media/badges1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ))
                                              : PaddingWrap.paddingfromLTRB(
                                                  0.0,
                                                  0.0,
                                                  0.0,
                                                  0.0,
                                                  new Image.asset(
                                                    "assets/profile/media/certifigate1.png",
                                                    height: 20.0,
                                                    width: 20.0,
                                                  )),
                                      flex: 1,
                                    ),
                                  ],
                                ))
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

    return new Scaffold(
        appBar: new AppBar(
          titleSpacing: 2.0,
          brightness: Brightness.light,
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text("Recommendation Detail"),
            ],
          ),
          backgroundColor: new Color(ColorValues.BLUE_COLOR),
        ),
        body: new Theme(
            data: new ThemeData(hintColor: Colors.grey[300]),
            child: ListView(
              children: <Widget>[
                PaddingWrap.paddingAll(
                    10.0,
                    new Card(
                        elevation: 2.0,
                        child: new Container(
                          color: new Color(0XFFF2F6FF),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Center(
                                      child: new Container(
                                    child: profileInfoModal.profilePicture !=
                                                "" &&
                                            profileInfoModal.profilePicture !=
                                                "null"
                                        ? FadeInImage.assetNetwork(
                                            fit: BoxFit.cover,
                                            placeholder:
                                                'assets/profile/user_on_user.png',
                                            image: Constant.IMAGE_PATH +
                                                profileInfoModal.profilePicture,
                                          )
                                        : new Image.asset(
                                            "assets/profile/user_on_user.png",
                                            fit: BoxFit.fill,
                                          ),
                                    width: 100.0,
                                    height: 120.0,
                                    padding: new EdgeInsets.fromLTRB(
                                        10.0, 5.0, 0.0, 20.0),
                                  )),
                                  PaddingWrap.paddingAll(
                                    2.0,
                                    TextViewWrap.textView(
                                        profileInfoModal == null
                                            ? ""
                                            : profileInfoModal.firstName +
                                                " " +
                                                profileInfoModal.lastName,
                                        TextAlign.center,
                                        Colors.black,
                                        18.0,
                                        FontWeight.bold),
                                  ),
                                  PaddingWrap.paddingAll(
                                      10.0,
                                      TextViewWrap.textView(
                                          profileInfoModal == null
                                              ? ""
                                              : profileInfoModal.summary,
                                          TextAlign.center,
                                          Colors.black,
                                          15.0,
                                          FontWeight.normal)),
                                ],
                              ),
                            ],
                          ),
                          height: 210.0,
                        ))),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        5.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView("Title", TextAlign.center,
                            new Color(0XFF9DA9B6), 17.0, FontWeight.bold)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            recomdation.title,
                            TextAlign.center,
                            Colors.black,
                            17.0,
                            FontWeight.normal)),

                    recomdation.recommendation==""?new Container(height: 0.0,):     PaddingWrap.paddingfromLTRB(
                        10.0,
                        5.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            "Recommendations",
                            TextAlign.center,
                            new Color(0XFF9DA9B6),
                            17.0,
                            FontWeight.bold)),
                    recomdation.recommendation==""?new Container(height: 0.0,):   PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            recomdation.recommendation,
                            TextAlign.center,
                            Colors.black,
                            17.0,
                            FontWeight.normal)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView("Competency", TextAlign.center,
                            new Color(0XFF9DA9B6), 17.0, FontWeight.bold)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            recomdation.level2Competency,
                            TextAlign.center,
                            Colors.black,
                            17.0,
                            FontWeight.normal)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView("Skills", TextAlign.center,
                            new Color(0XFF9DA9B6), 17.0, FontWeight.bold)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        new Text(
                          strSkills,
                          style: new TextStyle(
                              color: Colors.black, fontSize: 17.0),
                        )),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            "Interaction Date",
                            TextAlign.center,
                            new Color(0XFF9DA9B6),
                            17.0,
                            FontWeight.bold)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(strYear, TextAlign.center,
                            Colors.black, 17.0, FontWeight.normal)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        5.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            "Recommendation",
                            TextAlign.center,
                            new Color(0XFF9DA9B6),
                            17.0,
                            FontWeight.bold)),
                    PaddingWrap.paddingfromLTRB(
                        10.0,
                        0.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView(
                            recomdation.request,
                            TextAlign.center,
                            Colors.black,
                            17.0,
                            FontWeight.normal)),
                    recomdation.assestList.length > 0?      PaddingWrap.paddingfromLTRB(
                        10.0,
                        10.0,
                        10.0,
                        5.0,
                        TextViewWrap.textView("Media", TextAlign.center,
                            new Color(0XFF9DA9B6), 17.0, FontWeight.bold)):new Container(height: 0.0,),
                    recomdation.assestList != null &&
                            recomdation.assestList.length > 0
                        ? getgridBadges()
                        : new Container(
                            height: 1.0,
                          ),
                  ],
                )
              ],
            )));
  }
}
