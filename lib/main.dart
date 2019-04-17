import 'dart:io';

import 'package:adhara_socket_io/manager.dart';
import 'package:adhara_socket_io/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/chat/GlobalSocketConnection.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget_Parent.dart';
import 'package:spike_view_project/gateway/ChangePassword.dart';
import 'package:spike_view_project/gateway/Login_Widget.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/parentProfile/ParentProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spike_view_project/profile/UserProfile.dart';

void main() {

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(new MaterialApp(
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      //5
      '/dashboard': (BuildContext context) => new DashBoardWidget(),
      '/spike_view_project': (BuildContext context) => new LoginPage(),
      //7
    },
  ));
}

bool isAlreadyLoggedIn = false;
bool isPasswordChanged = false;
bool isParent = false;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _visible = true;
  SharedPreferences prefs;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void afterAnimation() {
    setState(() {
      _visible = false;
      startTime();
    });
  }
  void initSocket() async {
    // modify with your true address/port

  //TODO change the port  accordingly

    GlobalSocketConnection.socket = await SocketIOManager().createInstance(
        GlobalSocketConnection.ip);
    SecureSocket secureSocket = await SecureSocket.connect('104.42.51.157', 3002,
        onBadCertificate: (X509Certificate cert) => true);
    WebSocket.fromUpgradedSocket(secureSocket, serverSide: true);
    GlobalSocketConnection.socket.connect();


  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  startTimeForAnimation() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, afterAnimation);
  }

  void navigationPage() {
    // Navigator.pop(context);
    /*  _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure() ;
    _firebaseMessaging.getToken();*/


    if (!isAlreadyLoggedIn) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => new LoginPage()));



    } else {
      if(isPasswordChanged) {
        if(isParent){
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (context) => new DashBoardWidgetParent()));
        }else {
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
               //   builder: (context) => new DashBoardWidget()));
                  builder: (context) =>  new UserProfilePage("", true,"login")));
        }
      }else{
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => new ChangePassword("spike_view_project",isParent)));
      }
    }
  }
  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print("tokenm"+token);
      prefs.setString("deviceId",token);
    });

    Future _showNotificationWithDefaultSound(title,body) async {
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.Max, priority: Priority.High);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
     title,
       body,
        platformChannelSpecifics,
        payload: 'Default_Sound',
      );
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');


        _showNotificationWithDefaultSound(message['notification']['title'],message['notification']['body']);

      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');


      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }
  Future onSelectNotification(String payload) async {
    print('on tap notifiaction');
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) =>
        new  ChangePassword("spike_view_project",isParent)));

  }
  @override
  void initState() {
    super.initState();
    initSocket();
    getSharedPreferences();
    //startTime();
    startTimeForAnimation();
    firebaseCloudMessaging_Listeners();

    var initializationSettingsAndroid =
    new AndroidInitializationSettings('applogo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification:onSelectNotification
    );
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/splash_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            // If the Widget should be visible, animate to 1.0 (fully visible). If
            // the Widget should be hidden, animate to 0.0 (invisible).
            opacity: _visible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 1500),
            // The green box needs to be the child of the AnimatedOpacity
            child: new Container(
                margin: const EdgeInsets.all(30.0),
                child: new Image(
                  image: new AssetImage("assets/logo_white.png"),
                  color: null,
                  width: 300.0,
                  height: 100.0,
                  fit: BoxFit.contain,
                )),
          ),
        ),
      ),
    );
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    isAlreadyLoggedIn = prefs.getBool("loginStatus");
    isPasswordChanged = prefs.getBool("isPasswordChanged");
    isParent = prefs.getBool("isParent");
    prefs.setString("deviceId","");
    if (isAlreadyLoggedIn == null) {
      isAlreadyLoggedIn = false;
    }
    if (isPasswordChanged == null) {
      isPasswordChanged = false;
    }
    if (isParent == null) {
      isParent = false;
    }
  }
}
