import 'dart:async';

import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/material.dart';
import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/parser/ParseJson.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/chat/ChatRoom.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';

//import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

//import 'package:flutter_socket_io/flutter_socket_io.dart';
//import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/parser/ParseJson.dart';

class MessageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new MessageWidgetState();
  }
}

class MessageWidgetState extends State<MessageWidget> {
  List<ConnectionListModel> dataList = new List();
  StreamSubscription<dynamic> _streamSubscription;
  SharedPreferences prefs;
  String userIdPref;
  bool isParent;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    isParent = prefs.getBool("isParent");
    if (isParent == null) {
      isParent = false;
    }
    initSocket();
    fetchPost();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
    _streamSubscription =
        DashBoardState.syncDoneController.stream.listen((value) {
          refreshView();
        });
    print("==================== INIT STATE");
  }

  //============================ SOCKET IMPLEMENTATION===========================================
  void initSocket() async {
    /*  // modify with your true address/port
    GlobalSocketConnection.socket = await SocketIOManager().createInstance(
        GlobalSocketConnection.ip); //TODO change the port  accordingly*/
    GlobalSocketConnection.socket.onConnect((data) {
      print("connected...");
      print(data);
    });

    GlobalSocketConnection.socket.on("updatechat", (data) {
      //sample event
      print("==========================MAin Chat Room Call back ");
      print(data);

      dataList.clear();
      fetchPost();
    });

    /*  GlobalSocketConnection.socket.connect();*/
  }

  refreshView() {
    dataList.clear();
    fetchPost();
  }

  // Chatting Call backs
  void _onReceiveChatMessageForMain(dynamic data) {
    print("Chat Main Window: " + data);
    refreshView();
  }

//==========================================================

  //--------------------------Profile Info api ------------------
  Future fetchPost() async {
    try {
      Response response = await new ApiCalling()
          .apiCall(context, Constant.ENDPOINT_CHAT_LIST + userIdPref, "get");
      if (response != null) {
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          if (status == "Success") {
            dataList.clear();
            if (isParent)
              dataList =
                  ParseJson.parseChatData(response.data['result']);
            else
              dataList =
                  ParseJson.parseChatDataMainPage(response.data['result']);
            if (dataList != null) {
              setState(() {
                dataList;
              });
            }
          }
        }
      }
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Container getCellItem(ConnectionListModel model, int index1) {
      return new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                padding: new EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                height: 110.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                          height: 90.0,
                          width: 80.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: model.partnerProfilePicture == null
                                ? ""
                                : Constant.IMAGE_PATH +
                                model.partnerProfilePicture,
                          )),
                      flex: 0,
                    ),
                    new Expanded(
                      child: new Column(
                        children: <Widget>[
                          new Container(
                              height: 98.0,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new Padding(
                                      padding: new EdgeInsets.fromLTRB(
                                          5.0, 5.0, 5.0, 5.0),
                                      child: new Row(
                                        children: <Widget>[
                                          new Expanded(
                                            child: new Text(
                                              model.partnerLastName == null ||
                                                  model.partnerLastName ==
                                                      "null" ? model
                                                  .partnerFirstName :

                                              model.partnerFirstName +
                                                  " " +
                                                  model.partnerLastName,
                                              maxLines: 1,
                                              style: new TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            flex: 1,
                                          ),

                                          /*   new Expanded(child: new Row(
                    children: <Widget>[
                      new Icon(
                        Icons.watch_later,
                        size: 20.0,
                        color: new Color(0XFF87829C),
                      ),new Text(model.dateTime.toString(),style: new TextStyle(   color: new Color(0XFF87829C)),),
                    ],
                  ),flex: 0,)*/
                                        ],
                                      )),
                                  new Padding(
                                      padding: new EdgeInsets.fromLTRB(
                                          10.0, 0.0, 10.0, 5.0),
                                      child: new Row(
                                        children: <Widget>[
                                          new Expanded(
                                            child: new Text(
                                              model.lastMessage,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: new TextStyle(
                                                  color: new Color(0XFF87829C),
                                                  fontSize: 15.0),
                                            ),
                                            flex: 5,
                                          ),
                                          new Expanded(
                                            child: new Container(
                                              height: 30.0,
                                              width: 30.0,
                                              child: new Stack(
                                                children: <Widget>[
                                                  int.tryParse(model
                                                      .unreadMessageCount) >
                                                      0
                                                      ? new Positioned(
                                                    top: 1.0,
                                                    right: 5.0,
                                                    child: new Stack(
                                                      children: <Widget>[
                                                        new Icon(
                                                            Icons
                                                                .brightness_1,
                                                            size: 30.0,
                                                            color: Colors
                                                                .blue[300]),
                                                        new Positioned(
                                                            top: 10.0,
                                                            bottom: 10.0,
                                                            left: 10.0,
                                                            right: 10.0,
                                                            child: new Text(
                                                              model
                                                                  .unreadMessageCount,
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                  8.0),
                                                            ))
                                                      ],
                                                    ),
                                                  )
                                                      : new Text(
                                                    "",
                                                    textAlign:
                                                    TextAlign.center,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            flex: 1,
                                          )
                                        ],
                                      )),
                                ],
                              )),
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(
                                0.0, 0.0, 0.0, 5.0),
                            child: new Divider(
                              color: Colors.grey[300],
                              height: 1.0,
                            ),
                          )
                        ],
                      ),
                      flex: 4,
                    )
                  ],
                ),
              ),
            ],
          ));
    }

    void onItemClick(int index) async {
      print("==================== onItemClick");

      GlobalSocketConnection.socket.off('updatechat');

      await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) =>
          new ChatRoomHome(dataList[index], "", "")));
      fetchPost();
      GlobalSocketConnection.socket.on("updatechat", (data) {
        //sample event
        print("==========================MAin Chat Room Call back ");
        print(data);
        fetchPost();
      });
      //fetchPost();
    }

    return dataList.length > 0
        ? new ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (BuildContext ctxt, int Index) {
          return GestureDetector(
            child: getCellItem(dataList[Index], Index),
            onTap: () => onItemClick(Index),
          );
        })
        : new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
      PaddingWrap.paddingAll(15.0,  new Image.asset(
        "assets/no_message.png",

      )),
        TextViewWrap.textView(
            "No Messages Yet.",
            TextAlign.left,
            Colors.black,
            20.0,
            FontWeight.bold),
        PaddingWrap.paddingfromLTRB(
            30.0,
            15.0,
            30.0,
            5.0,
            new Text(
              "No Messages in your inbox, Yet!.Start chatting with people around you.",textAlign: TextAlign.center ,
              style: new TextStyle(color: Colors.grey[400],fontSize: 15.0,fontWeight: FontWeight.bold),)
)],
    )
    ,
    );
  }
}
