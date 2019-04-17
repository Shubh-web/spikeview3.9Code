import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/chat/modal/ChatRoomModel.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'dart:io';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/parser/ParseJson.dart';
class ChatRoomHome extends StatefulWidget {
  String link,shareId;

  ChatRoomHome(this.connectionListModel, this.link,this.shareId);

  final connectionListModel;

  @override
  _ChatRoomHomeState createState() => _ChatRoomHomeState(connectionListModel);
}

class _ChatRoomHomeState extends State<ChatRoomHome> {
  ConnectionListModel model;
  List<ChatRoomModel> dataList = new List();
  TextEditingController chatMessageEditTextController;
  String previousDateStamp = "", token;
  SharedPreferences prefs;
  TextEditingController txtController;
  ScrollController _controller = ScrollController();

  _ChatRoomHomeState(ConnectionListModel model) {
    this.model = model;
  }

  String userIdPref, profile_image_path;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    userIdPref = prefs.getString(UserPreference.USER_ID);
    token = prefs.getString(UserPreference.USER_TOKEN);
    profile_image_path = prefs.getString(UserPreference.PROFILE_IMAGE_PATH);
  }


  Future apiCallingForUpdateStudentStatus() async {
    try {
      Response response;

      Map map = {
        "sharedId":int.parse(widget.shareId),"shareTo":int.parse( model.receiverId)
      };

      response = await new ApiCalling()
          .apiCallPutWithMapData(context, Constant.ENDPOINT_SHARE_UPDATE, map);
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
  @override
  void initState() {
    getSharedPreferences();
    // TODO: implement initState
    super.initState();
    chatMessageEditTextController =
    new TextEditingController(text: widget.link);
    fetchMessages();

    _onReceiveChatMessage();
    _leaveOrEnterChatRoom(true);
  }

/* View creation here*/
  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 200),
            () => _controller.jumpTo(_controller.position.maxScrollExtent));

    return new WillPopScope(
        onWillPop: () {
          print("----------ON BACK PROCESS");
          _leaveOrEnterChatRoom(false);
          GlobalSocketConnection.socket.off('updatechat');
          Navigator.pop(context);
        },
        child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child:new Scaffold(

                appBar: new AppBar(
                  automaticallyImplyLeading: false,  titleSpacing: 2.0,
                  brightness: Brightness.light,
                  leading: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new InkWell(
                        child: new Image.asset(
                          "assets/profile/post/back_arrow_blue.png",
                          height: 25.0,
                          width: 25.0,
                        ),
                        onTap: () {
                          _leaveOrEnterChatRoom(false);
                          GlobalSocketConnection.socket.off('updatechat');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  title: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      PaddingWrap.paddingfromLTRB(
                          0.0,
                          10.0,
                          5.0,
                          5.0,
                          new SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: new ClipOval(
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fill,
                                    placeholder: 'assets/profile/user_on_user.png',
                                    image: Constant.IMAGE_PATH_SMALL +
                                        ParseJson.getMediumImage(
                                            model.partnerProfilePicture),
                                    width: 40.0,
                                    height: 40.0,
                                  )))),
                      new Text(
                        model.partnerLastName == null ||
                            model.partnerLastName == "" ||
                            model.partnerLastName == "null"
                            ? model.partnerFirstName
                            : "   " +
                            model.partnerFirstName +
                            " " +
                            model.partnerLastName,
                        textAlign: TextAlign.start,
                        style: new TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                      )
                    ],
                  ),
                  backgroundColor: Colors.white,
                ),
                body: new Column(
                  children: <Widget>[
                    new Expanded(
                      child: new ListView.builder(
                          controller: _controller,
                          itemCount: dataList.length,
                          itemBuilder: (BuildContext ctxt, int Index) {
                            return model.userId == dataList[Index].sender
                                ? getSenderCellItem(dataList[Index])
                                : getReceiverCellItem(dataList[Index]);
                          }),
                      flex: 1,
                    ),
                    new Container(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Flexible(
                              child: new Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, top: 5.0, bottom: 20.0),
                                child: new TextField(
                                  maxLines: 3,maxLength: 1000,
                                  keyboardType: TextInputType.multiline,
                                  decoration: new InputDecoration.collapsed(

                                    hintText: "Type a message",),
                                  controller: chatMessageEditTextController,
                                  // onSubmitted: _handleSubmit,*/
                                ),
                              )),
                          new Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: new InkWell(
                              child: new Padding(
                                  padding:
                                  new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                  child: new Image.asset(
                                    "assets/home/send.png",
                                    width: 30.0,
                                    height: 30.0,
                                  )),
                              onTap: () {
                                if (chatMessageEditTextController.text.trim() != "")


                                  _sendChatMessage(
                                      chatMessageEditTextController.text);

                                if(widget.link!=""){

                                  apiCallingForUpdateStudentStatus();
                                }
                                /*        Timer(
                                Duration(milliseconds: 200),
                                () => _controller.jumpTo(
                                    _controller.position.maxScrollExtent));*/
                              },
                            ),
                          )
                        ],
                      ),
                      color: Colors.white,
                    ),
                  ],
                ))));
  }

  Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  onTapText(text) {
    if (text.toString().contains("http") || text.toString().contains("HTTP")) {
      _launchInWebViewOrVC("http://103.76.253.131:3000/student/previewprofile/551");
    }
  }

  Padding getReceiverCellItem(ChatRoomModel model1) {
    return new Padding(
        padding: new EdgeInsets.all(10.0),
        child: new Center(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Text(
                      getConvertedDateStamp(model1.time),
                      style: new TextStyle(color: Colors.grey),
                    )),
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                          height: 40.0,
                          width: 40.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/profile/user_on_user.png',
                            image:
                            model.partnerProfilePicture==null|| model.partnerProfilePicture=="null"?"": Constant.IMAGE_PATH + model.partnerProfilePicture          ,
                          )),
                      flex: 0,
                    ),
                    new Expanded(
                      child: new Card(
                          elevation: 5.0,
                          child: new Container(
                              color: Colors.white,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new GestureDetector(
                                    child: new Padding(
                                        padding: new EdgeInsets.all(10.0),
                                        child: new Text(
                                          model1.text,
                                          maxLines: null,
                                          style: new TextStyle(color: Colors.black),
                                        )),
                                    onTap: () {
                                      onTapText( model1.text);
                                    },
                                  ),
                                  new Align(
                                    alignment: Alignment.bottomRight,
                                    child: new Padding(
                                      padding: new EdgeInsets.all(5.0),
                                      child: new Text(getConvertedTime(model1.time),
                                          style: new TextStyle(
                                              color: Colors.black, fontSize: 8.0)),
                                    ),
                                  )
                                ],
                              ))),
                      flex: 1,
                    ),
                  ],
                ),
              ],
            )));
  }

  Padding getSenderCellItem(ChatRoomModel model) {
    return new Padding(
        padding: new EdgeInsets.all(10.0),
        child: new Center(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Text(
                      getConvertedDateStamp(model.time),
                      style: new TextStyle(color: Colors.grey),
                    )),
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: new Card(
                          elevation: 5.0,
                          child: new Container(
                              color: new Color(ColorValues.BLUE_COLOR),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new GestureDetector(
                                    child: new Padding(
                                        padding: new EdgeInsets.all(10.0),
                                        child: new Text(
                                          model.text,
                                          maxLines: null,
                                          style: new TextStyle(
                                              color: Colors.white),
                                        )),
                                    onTap: () {
                                      onTapText( model.text);
                                    },
                                  ),
                                  new Align(
                                    alignment: Alignment.bottomLeft,
                                    child: new Padding(
                                      padding: new EdgeInsets.all(5.0),
                                      child: new Text(
                                          getConvertedTime(model.time),
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0)),
                                    ),
                                  )
                                ],
                              ))),
                      flex: 1,
                    ),
                    new Expanded(
                      child: new Container(
                          height: 40.0,
                          width: 40.0,
                          child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: 'assets/profile/user_on_user.png',
                            image: Constant.IMAGE_PATH_SMALL +
                                ParseJson.getMediumImage(profile_image_path),
                          )),
                      flex: 0,
                    ),
                  ],
                )
              ]),
        ));
  }

  //=============================SOCKET CREATION =============================================

  void _sendChatMessage(String msg) async {
    if (GlobalSocketConnection.socket != null) {
      if (msg != null && msg.isNotEmpty) {
        int dateAndTimeMil = DateTime.now().millisecondsSinceEpoch;

        Map map = {
          "connectorId": model.connectId,
          "sender": model.userId,
          "receiver": model.receiverId,
          "time": dateAndTimeMil,
          "text": msg,
          "type": 1,
        };
        print("con:-"+model.connectId+" sender:-"+model.userId+" rec:-"+model.receiverId+" time:-"+dateAndTimeMil.toString());
        GlobalSocketConnection.socket.emit("sendchat", [map]);

        // Add message in model

        dataList.add(new ChatRoomModel("0", model.connectId, model.userId,
            model.receiverId, dateAndTimeMil.toString(), msg, "1", "0"));
        chatMessageEditTextController.clear();

        setState(() {
          dataList;
        });
      }
    }
  }

  void _leaveOrEnterChatRoom(bool flag) async {
    if (GlobalSocketConnection.socket != null) {
      int screenId;
      screenId = flag ? 1 : 0;

      Map map = {
        "userId": model.userId,
        "partnerId": model.receiverId,
        "screenId": screenId,
      };

      GlobalSocketConnection.socket.emit("setConnectionList", [map]);

      // Add message in model

    }
  }

//======================================================= END SOCKET =================================================================
  void _onReceiveChatMessage() {
    GlobalSocketConnection.socket.on("updatechat", (data) {
      //sample event
      print("Chat Room clAS");
      print(data);

      String msg = data["text"].toString();
      String connectorId = data["connectorId"].toString();
      String sender = data["sender"].toString();
      String receiver = data["receiver"].toString();
      String time = data["time"].toString();
      String type = data["type"].toString();
      String status = data["status"].toString();

      print(msg);

      if (sender.toString() != model.userId) {
        dataList.add(new ChatRoomModel(
            "0",
            connectorId.toString(),
            sender.toString(),
            receiver.toString(),
            time.toString(),
            msg,
            type.toString(),
            status.toString()));

        chatMessageEditTextController.clear();
        //GlobalSocketConnection.socketIO.unSubscribesAll();
        setState(() {
          dataList;
        });
      }
    });
  }

  /*===================================================== Fetch Chat History =======================================================*/

  // get Contacts list for chat
  void fetchMessages() async {
    try {
      // CustomProgressLoader.showLoader(context);
      var isConnect = await ConectionDetecter.isConnected();
      print(isConnect);
      if (isConnect) {
        var dio = new Dio();
        dio.onHttpClientCreate = (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            return true;
          };
        };

        //dio.options.baseUrl = "http://103.76.253.131:3002/ui/connect/";
        dio.options.connectTimeout = 60000; //5s
        dio.options.receiveTimeout = 60000;
        dio.options.headers = {'user-agent': 'dio'};
        dio.options.headers = {'Accept': 'application/json'};
        dio.options.headers = {'Content-Type': 'application/json'};
        dio.options.headers = {'Authorization': token}; // Prepare Data

        // Make API call
        Response response = await dio.get(
            Constant.BASE_URL + "ui/message?connectorId=" + model.connectId);

        String status = response.data["status"];

        //  CustomProgressLoader.cancelLoader(context);

        if (status == "Success") {
          // get Accepted array from data

          parseMap(response.data["result"]);
        } else {}
      } else {
        //  CustomProgressLoader.cancelLoader(context);

      }
    } catch (e) {
      print("================");
      return print(e);

      //CustomProgressLoader.cancelLoader(context);
//      Fluttertoast.showToast(
//          msg: "Please check your internet connection....!",
//          toastLength: Toast.LENGTH_SHORT,
//          timeInSecForIos: 1,
//          textColor: Colors.white);
    }
  }

  void parseMap(map) {
    for (int i = 0; i < map.length; i++) {
      print(map.length);

      int messageId, connectorId, sender, receiver, time, type, status;
      String text;

      messageId = map[i]["messageId"];
      connectorId = map[i]["connectorId"];
      sender = map[i]["sender"];
      receiver = map[i]["receiver"];
      time = map[i]["time"];
      type = map[i]["type"];
      status = map[i]["status"];
      text = map[i]["text"];

      dataList.add(new ChatRoomModel(
          messageId.toString(),
          connectorId.toString(),
          sender.toString(),
          receiver.toString(),
          time.toString(),
          text,
          type.toString(),
          status.toString()));
    }
    print("datalist length:" + dataList.length.toString());
    setState(() {
      dataList;
    });
  }

//====================================================== END PARSING============================================================

//====================================================== Update Date and time =================================================
  String getConvertedTime(String time) {
    int millis = int.tryParse(time);
    var now = new DateTime.fromMillisecondsSinceEpoch(millis);
    var formatter = new DateFormat('hh:mm aa');
    String formatted = formatter.format(now);
    return formatted;
  }

  String getConvertedDateStamp(String time) {
    int millis = int.tryParse(time);
    var now = new DateTime.fromMillisecondsSinceEpoch(millis);
    var formatter = new DateFormat('MMM dd yyyy');
    String formatted = formatter.format(now);

    if (formatted != previousDateStamp) {
      previousDateStamp = formatted;
      return formatted;
    } else {
      return "";
    }
  }

//=======================================
}
