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
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/OrganizationModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/AddAchievment.dart';
import 'package:spike_view_project/profile/AddRecommendation.dart';
import 'package:spike_view_project/profile/EditAchievment.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class CompetenciesWidget extends StatefulWidget {
  int index;
  String name;

  CompetenciesWidget(this.index, this.name);

  @override
  CompetenciesWidgetState createState() {
    return new CompetenciesWidgetState(index);
  }
}

class CompetenciesWidgetState extends State<CompetenciesWidget> {
  final _formKey = GlobalKey<FormState>();
  String userIdPref, token;
  int index;

  CompetenciesWidgetState(this.index);

  List<NarrativeModel> narrativeList = new List<NarrativeModel>();
  String isPerformChanges = "pop";
  List<CompetencyModel> listCompetency = new List();
  SharedPreferences prefs;

//------------------------------------Retrive data ( Userid nd token ) ---------------------
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    competencyApiCall();
    narrativeApi();
  }

//------------------------------------Api Calling for get Commpetency -------------------------
  Future competencyApiCall() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_COMPENTENCY, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            listCompetency.clear();
            listCompetency =
                ParseJson.parseMapCompetency(response.data['result'][index]);
            if (listCompetency.length > 0) {
              setState(() {
                listCompetency;
                print("competency:-" + listCompetency.toString());
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
  Future narrativeApi() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_NARRATIVE + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            narrativeList.clear();
            narrativeList = ParseJson
                .parseMapNarrativeForCompetency(response.data['result']);
            if (narrativeList.length > 0) {
              setState(() {
                narrativeList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  //--------------------------Api Calling for delete achevement ------------------
  Future apiCallingForDeleteAchievment(achievementId, index) async {
    try {
      CustomProgressLoader.showLoader(context);
      Map map = {
        "achievementId": achievementId,
      };

      Response response = await new ApiCalling().apiCallDeleteWithMapData(
          context, Constant.ENDPOINT_ADD_ACHEVMENT, map);

      print("response:-" + response.toString());
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String msg = response.data[LoginResponseConstant.MESSAGE];
          if (status == "Success") {
            ToastWrap.showToast(msg);
            Navigator.pop(context, "push");
            isPerformChanges = "push";
            narrativeApi();
            CustomProgressLoader.cancelLoader(context);
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//============================================ grid view achevements nd core logic =====================================

    showDialogDeleteAchievment(achievementId, achievmentname) {
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
                              "You want to delete $achievmentname  achievement ?",
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
                                            apiCallingForDeleteAchievment(
                                                achievementId, index);
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

    onTapEditAchevment(level3Competencylist, id, name, achiv) async {
      final result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new EditAchievmentForm(level3Competencylist, id, name, achiv)));
      isPerformChanges = "push";

      narrativeApi();
    }

    Column getgridAchivement(index, name) {
      for (int i = 0; i < narrativeList.length; i++) {
        if (name == narrativeList[i].name) {
          return narrativeList[i].achivmentList != null &&
                  narrativeList[i].achivmentList.length > 0
              ? new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Image.asset(
                          "assets/profile/achievement.png",
                          width: 30.0,
                          height: 30.0,
                        ),
                        TextViewWrap.textView("  Achievements", TextAlign.start,
                            Colors.black, 16.0, FontWeight.bold)
                      ],
                    ),
                    PaddingWrap.paddingfromLTRB(
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
                              children: narrativeList[i]
                                  .achivmentList
                                  .map((Achivment achiv) {
                                return new Stack(
                                  children: <Widget>[
                                    new InkWell(
                                      child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          achiv.assestList.length > 0
                                              ? new Image.network(
                                                  Constant.IMAGE_PATH +
                                                      achiv.assestList[0].file,
                                                  fit: BoxFit.cover,
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
                                                achiv.title,maxLines: 2,
                                                textAlign: TextAlign.start,
                                              )),
                                        ],
                                      ),
                                      onTap: () {
                                        onTapEditAchevment(
                                            listCompetency[0]
                                                .level2Competencylist[index]
                                                .level3Competencylist,
                                            listCompetency[0]
                                                .level2Competencylist[index]
                                                .competencyTypeId,
                                            listCompetency[0]
                                                .level2Competencylist[index]
                                                .name,
                                            achiv);
                                      },
                                      onLongPress: () {
                                        showDialogDeleteAchievment(
                                            achiv.achievementId, achiv.title);
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            )))
                  ],
                )
              : new Column(
                  children: <Widget>[
                    PaddingWrap.paddingfromLTRB(
                        5.0,
                        10.0,
                        5.0,
                        10.0,
                        new Container(
                          height: 1.0,
                        ))
                  ],
                );
        }
      }

      return new Column(
        children: <Widget>[
          PaddingWrap.paddingfromLTRB(
              5.0,
              10.0,
              5.0,
              10.0,
              new Container(
                height: 1.0,
              ))
        ],
      );
    }

//=========================================On Tap Add Achievement =================================
    onTapAddAchievement(level3Competencylist, id, name) async {
      final result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new AddAchievmentForm(level3Competencylist, id, name)));
      print("shgubhresult :" + result.toString());
      isPerformChanges = "push";

      narrativeApi();
    }

    onTapAddRecommendation(level3Competencylist, id, name) async {
      final result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
              new AddRecommendationForm(level3Competencylist, id, name)));
      isPerformChanges = "push";

      narrativeApi();
    }

    Column getCompetencyItem(position) {
      if (widget.name != "")
        listCompetency[0].level2Competencylist[position].isSelected = true;
      return new Column(
        children: <Widget>[
          new Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  IconData(
                      UserProfilePageState. getConstant(
                          listCompetency[0].level2Competencylist[position].name),
                      fontFamily: 'Boxicons'),
                  size: 30.0,
                  color: new Color(
                      0XFF78818A),
                ),
                title: new Text(
                  listCompetency[0].level2Competencylist[position].name,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: new Color(0XFF78818A)),
                ),
                selected:
                    listCompetency[0].level2Competencylist[position].isSelected,
                onTap: () {
                  if (listCompetency[0]
                      .level2Competencylist[position]
                      .isSelected) {
                    listCompetency[0]
                        .level2Competencylist[position]
                        .isSelected = false;
                  } else {
                    listCompetency[0]
                        .level2Competencylist[position]
                        .isSelected = true;
                  }
                  setState(() {
                    listCompetency[0].level2Competencylist[position].isSelected;
                  });
                },
              )),
          listCompetency[0].level2Competencylist[position].isSelected
              ? new Column(children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                          child: new Center(
                              child: new InkWell(
                            child: new Container(
                                decoration: const BoxDecoration(
                                  border: const Border(
                                    right: const BorderSide(
                                        width: 0.8,
                                        color: const Color(0xFFEEEEEE)),
                                  ),
                                ),
                                child: PaddingWrap.paddingAll(
                                  10.0,
                                  new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Image.asset(
                                        "assets/profile/plus.png",
                                        height: 20.0,
                                        width: 20.0,
                                      ),
                                      TextViewWrap.textView(
                                          "Add Achievement",
                                          TextAlign.center,
                                          new Color(ColorValues.BLUE_COLOR),
                                          12.0,
                                          FontWeight.bold),
                                    ],
                                  ),
                                )),
                            onTap: () {
                              onTapAddAchievement(
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .level3Competencylist,
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .competencyTypeId,
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .name);
                            },
                          )),
                          flex: 1,
                        ),
                        new Expanded(
                          child: new InkWell(
                            child: new Container(
                                decoration: const BoxDecoration(
                                  border: const Border(
                                    right: const BorderSide(
                                        width: 0.8,
                                        color: const Color(0xFFEEEEEE)),
                                  ),
                                ),
                                child: PaddingWrap.paddingAll(
                                    10.0,
                                    new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Image.asset(
                                          "assets/profile/plus.png",
                                          height: 20.0,
                                          width: 20.0,
                                        ),
                                        TextViewWrap.textView(
                                            "Add Recommendation",
                                            TextAlign.center,
                                            new Color(ColorValues.BLUE_COLOR),
                                            12.0,
                                            FontWeight.bold),
                                      ],
                                    ))),
                            onTap: () {
                              onTapAddRecommendation(
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .level3Competencylist,
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .competencyTypeId,
                                  listCompetency[0]
                                      .level2Competencylist[position]
                                      .name);
                            },
                          ),
                          flex: 1,
                        )
                      ],
                    ),
                  ),
                  getgridAchivement(position,
                      listCompetency[0].level2Competencylist[position].name)
                ])
              : new Divider(
                  height: 1.0,
                  color: const Color(0xFFEEEEEE),
                ),
        ],
      );
    }

    return new WillPopScope(
        onWillPop: () {
          Navigator.pop(context, isPerformChanges);
        },
        child: new Scaffold(
            backgroundColor: new Color(0XFFF4F8FB),
            appBar: new AppBar(     titleSpacing: 2.0,
              brightness: Brightness.light,
              title:


              new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text("COMPETENCY")
              ],
            ),



              backgroundColor: new Color(ColorValues.BLUE_COLOR),
              actions: <Widget>[
                new InkWell(
                  child: new Image.asset(
                    "assets/profile/check.png",
                    height: 30.0,
                    width: 30.0,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            body: new Column(
              children: <Widget>[
                widget.name == ""
                    ? new Expanded(
                        child: new Container(
                            color: Colors.white,
                            child: PaddingWrap.paddingAll(
                                5.0,
                                new Column(
                                  children: <Widget>[
                                    new Text(
                                      "Select one from the list below from the ",
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        PaddingWrap.paddingAll(
                                            5.0,
                                            new Text(
                                              "compentencies in ",
                                              textAlign: TextAlign.center,
                                              style: new TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16.0,
                                              ),
                                            )),
                                        new Text(
                                          widget.index == 0
                                              ? " Arts Competency"
                                              : widget.index == 1
                                                  ? " Vocational Competency"
                                                  : widget.index == 2
                                                      ? " Academic Competency"
                                                      : " Sport Competency",
                                          textAlign: TextAlign.center,
                                          style: new TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16.0,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ))),
                        flex: 3,
                      )
                    : new Container(),
                new Expanded(
                  child: listCompetency.length > 0
                      ? new ListView.builder(
                          itemCount:
                              listCompetency[0].level2Competencylist.length,
                          itemBuilder: (BuildContext context, int position) {
                            return widget.name == ""
                                ? getCompetencyItem(position)
                                : listCompetency[0]
                                            .level2Competencylist[position]
                                            .name ==
                                        widget.name
                                    ? getCompetencyItem(position)
                                    : new Container();
                          })
                      : new Container(),
                  flex: 19,
                )
              ],
            )));
  }
}
