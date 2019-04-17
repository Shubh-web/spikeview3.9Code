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
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/OrganizationModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
import 'package:spike_view_project/profile/RecommendationDetail.dart';
import 'package:spike_view_project/values/ColorValues.dart';

// Create a Form Widget
class AllRecommendationList extends StatefulWidget {

  ProfileInfoModal profileInfoModal;
  AllRecommendationList(this.profileInfoModal);

  @override
  AllRecommendationListState createState() {
    return new AllRecommendationListState(profileInfoModal);
  }
}

class AllRecommendationListState extends State<AllRecommendationList> {
  List<Recomdation> recommendationtList=new List();
  ProfileInfoModal profileInfoModal;
  AllRecommendationListState(this.profileInfoModal);

  SharedPreferences prefs;
  String userIdPref, token;
  String isApiCall="";
  //--------------------------Recommendation Info api ------------------
  Future recommendationApi() async {
    try {

      Response response = await new ApiCalling().apiCall(
          context, Constant.ENDPOINT_RECOMMENDATION + userIdPref, "get");


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
            isApiCall="push";
            //setState(() {
            recommendationApi();
            // });
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

//------------------------------------Retrive data ( Userid nd token ) ---------------------
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    recommendationApi();
  }

  @override
  void initState() {
    // TODO: implement initState
    getSharedPreferences();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //-------------------------------------Main Ui ------------------------------------------
    return new WillPopScope( onWillPop: (){
      Navigator.pop(context,isApiCall);
    },child: new Scaffold(
        appBar: new AppBar(      titleSpacing: 2.0,
          brightness: Brightness.light,
          title:

          new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Text("Recommendation")
          ],
        ),
          backgroundColor: new Color(ColorValues.BLUE_COLOR),
          actions: <Widget>[],
        ),
        body:recommendationtList.length>0? new ListView(
          children: <Widget>[
            new Column(
                children:
                    new List.generate(recommendationtList.length, (int index) {



              return new Container(
                  padding: new EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
                  height: 165.0,
                  child: new Card(
                      elevation: 5.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child:new InkWell(child:new Container(
                                height: 165.0,
                                child: FadeInImage.assetNetwork(
                                  fit: BoxFit.fill,
                                  placeholder: 'assets/profile/user_on_user.png',
                                  image: "",
                                )),onTap: (){
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new RecommendationDetail(recommendationtList[index],profileInfoModal)));

              },),

                            flex: 3,
                          ),
                          new Expanded(
                            child: PaddingWrap.paddingfromLTRB(
                                10.0,
                                10.0,
                                0.0,
                                0.0,
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                            new InkWell(child:    new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    TextViewWrap.textView(
                                        recommendationtList[index]
                                            .recommender
                                            .firstName +
                                            " " +
                                            recommendationtList[index]
                                                .recommender
                                                .lastName,
                                        TextAlign.right,
                                        Colors.black,
                                        18.0,
                                        FontWeight.bold),
                                    recommendationtList[index]
                                        .recommender
                                        .title=="null"?new Container(height: 0.0,): PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        5.0,
                                        0.0,
                                        0.0,
                                        new Text( recommendationtList[index]
                                            .recommender
                                            .title,textAlign:TextAlign.right,maxLines:1,overflow: TextOverflow.ellipsis,style: new TextStyle(color: Colors.grey,fontSize: 15.0),)


                                    ),

                                    PaddingWrap.paddingfromLTRB(
                                        0.0,
                                        5.0,
                                        0.0,
                                        0.0,
                                        TextViewWrap.textView(
                                            recommendationtList[index]
                                                .level2Competency,
                                            TextAlign.right,
                                            Colors.black,
                                            15.0,
                                            FontWeight.normal)),


                                    new Align(
                                      alignment: Alignment.bottomRight,
                                      child:  recommendationtList[index].stage ==
                                        "Requested"
                                        ?PaddingWrap.paddingfromLTRB(
                                          10.0,recommendationtList[index]
                                          .recommender
                                          .title=="null"?35.0:25.0,10.0,10.0,  TextViewWrap.textView(
                                        "Pending",
                                        TextAlign.right,
                                        Colors.orange,
                                        13.0,
                                        FontWeight.bold))
                                        : recommendationtList[index]
                                        .stage ==
                                        "Added"
                                        ? PaddingWrap.paddingfromLTRB(
                                        10.0,recommendationtList[index]
                                          .recommender
                                          .title=="null"?35.0:25.0,10.0,10.0, TextViewWrap.textView(
                                        "Added",
                                        TextAlign.right,
                                        Colors.orange,
                                        13.0,
                                        FontWeight.bold))
                                        : new Container(
                                      height: 0.0,
                                    )
                                      ),

]),onTap: (){
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => new RecommendationDetail(recommendationtList[index],profileInfoModal)));

                            },),
                                    recommendationtList[index].stage == "Replied"
                                        ?  new Align(
                                        alignment: Alignment.bottomRight,child:PaddingWrap.paddingAll(
                                        10.0, new InkWell(
                                          child: new Container(
                                              width: 120.0,
                                              decoration: new BoxDecoration(
                                                  border: new Border.all(
                                                      color: const Color(
                                                          ColorValues
                                                              .BLUE_COLOR))),
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
                                        )))
                                        : new Container(
                                      height: 0.0,
                                    )

                                  ],
                                )),
                            flex: 7,
                          ),
                        ],
                      )));


            }))
          ],
        ):new Center(
          child: new Text(
            "",
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        )));

    }
}
