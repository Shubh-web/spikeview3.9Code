// Updated COde

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/home/home.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/gateway/Login_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Student_Widget.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:http/http.dart' as http;
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';

class SignupParentPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  SignupPageState createState() => new SignupPageState();
}

final formKey = GlobalKey<FormState>();
String strFirstName = "",
    strLastName = "",
    strEmail = "",
    strStudentyEmail = "",
    strStudentFirstName = "";
bool _isLoading = false;

class SignupPageState extends State<SignupParentPage> {
  Color borderColor = Colors.amber;
BuildContext context;
  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }




  bool isName(String em) {

    return RegExp(r"\s+\b|\b\s|^[a-zA-Z]+$").hasMatch(em);
  }





  loginServiceCall() async {

    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {

        var dio = new Dio();
        dio.onHttpClientCreate = (HttpClient client) {
          client.badCertificateCallback=(X509Certificate cert, String host, int port){
            return true;

          };
        };
        dio.options.baseUrl = Constant.BASE_URL;
        dio.options.connectTimeout = Constant.CONNECTION_TIME_OUT; //5s
        dio.options.receiveTimeout = Constant.SERVICE_TIME_OUT;
        dio.options.headers = {'user-agent': 'dio'};
        dio.options.headers = {'Accept': 'application/json'};
        dio.options.headers = {'Content-Type': 'application/json'};
        // Prepare Data
        Map map = {
          "firstName": strFirstName,
          "lastName": strLastName,
          "email": strEmail.toLowerCase(),
          "roleId": 2,
          "students": [
            {"email": strStudentyEmail.toLowerCase(), "firstName": strStudentFirstName}
          ]
        };

        // Make API call
        Response response = await dio.post(Constant.ENDPOINT_PARENT_SIGNUP, data: json.encode(map));
        //   CustomProgressLoader.cancelLoader(context);
        setState(() => _isLoading = false);
        print(response.toString());
        if (response.statusCode == 200) {

          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data[LoginResponseConstant.MESSAGE];

          if (status == "Success") {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => new LoginPage()),
            );



            ToastWrap.showToast(message);
          } else {
            ToastWrap.showToast(message);

          }
        } else {
          setState(() => _isLoading = false);
          // If that call was not successful, throw an error.
          throw Exception('Something went wrong!!');
        }
      } catch (e) {
        print(e);
        ToastWrap.showToast(e.toString());
      }
    } else {
      setState(() => _isLoading = false);
      ToastWrap.showToast("Please check your internet connection....!");

    }
  }

  void _checkValidation() {

    final form = formKey.currentState;
    setState(() => _isLoading = true);
    form.save();
    if (form.validate()) {
      print("SUCCESS 00");
      loginServiceCall();
    } else {
      setState(() => _isLoading = false);
      print("Failure 00");
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context=context;



    final upperLogo = new Image(
      image: new AssetImage("assets/logo.png"),
      color: null,
      width: 130.0,
      height: 70.0,
      fit: BoxFit.contain,
    );

    final userFirstNameUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 10.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,
        validator: (val) => !isName(val.trim()) ? 'Please enter first name.':null,
        onSaved: (val) => strFirstName = val.trim(),
        style: new TextStyle(color: Colors.white),maxLength: 20,
        decoration: new InputDecoration(
            prefixIcon: new GestureDetector(
                child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: new Image.asset(
                "assets/login/user.png",
                width: 25.0,
                height: 25.0,
              ),
            )),
            hintText: "First Name",
            labelStyle: new TextStyle(color: Colors.white),counterText: "",
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );

    final lastNameUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 10.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,maxLength: 15,
        validator: (val) => !isName(val.trim()) ? 'Please enter last name.':null,
        onSaved: (val) => strLastName = val.trim(),
        style: new TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            prefixIcon: new GestureDetector(
                child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: new Image.asset(
                "assets/login/user.png",
                width: 25.0,
                height: 25.0,
              ),
            )),
            hintText: "Last Name",counterText: "",
            labelStyle: new TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );

    final emailUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val) => !isEmail(val) ? 'Please enter email.' : null,
        onSaved: (val) => strEmail = val,
        style: new TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            prefixIcon: new GestureDetector(
                child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: new Image.asset(
                "assets/login/email.png",
                width: 25.0,
                height: 25.0,
              ),
            )),
            hintText: "Email",
            labelStyle: new TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );

    final studentEmailUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val) => !isEmail(val) ? 'Please enter email.' : null,
        onSaved: (val) => strStudentyEmail = val,
        style: new TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            prefixIcon: new GestureDetector(
                child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: new Image.asset(
                "assets/login/email.png",
                width: 25.0,
                height: 25.0,
              ),
            )),
            hintText: "Student Email",
            labelStyle: new TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );

    final studentNameUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,maxLength: 35,
        validator: (val) => !isName(val.trim()) ? 'Please enter student name.':null,
        onSaved: (val) => strStudentFirstName = val.trim(),
        style: new TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            prefixIcon: new GestureDetector(
                child: new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: new Image.asset(
                "assets/login/user.png",
                width: 25.0,
                height: 25.0,
              ),
            )),
            hintText: "Student First Name",counterText: "",
            labelStyle: new TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );
    final loginButton = Padding(
        padding: new EdgeInsets.only(
            left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: _checkValidation,
              color: Color(ColorValues.BUTTON_LOGIN_BG),
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('SIGN UP ',
                      style: TextStyle(
                          fontFamily: 'customBold',
                          color: Color(ColorValues.BUTTON_TEXT_BLUE))),
                ],
              ),
            )));

    final _SignUpAsParentBtnBottom = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: new Text(
            'SIGN UP',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(ColorValues.BUTTON_TEXT_BLUE),
              fontSize: 16.0,
              fontFamily: 'customBold',
            ),
          ),
          onPressed: () {
            /*Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage()),
            );*/
          },
        ),
        new Text(
          'AS PARENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(ColorValues.BUTTON_TEXT_BLUE),
            fontSize: 10.0,
          ),
        ),
      ],
    );

    final _SignUpAsStudentBtnBottom = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new FlatButton(
          onPressed: () {
          /*  Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupStudentPage()),
            );*/


            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) {
                  return SignupStudentPage();
                },
                transitionsBuilder: (context, animation1, animation2, child) {
                  return FadeTransition(
                    opacity: animation1,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 200),
              ),
            );

          },
          child: new Text(
            'SIGN UP',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(ColorValues.BUTTON_TEXT_GRAY),
              fontSize: 16.0,
              fontFamily: 'customBold',
            ),
          ),
        ),
        new Text(
          'AS STUDENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(ColorValues.BUTTON_TEXT_GRAY),
            fontSize: 10.0,
          ),
        ),
      ],
    );

    final _SignInBtnBottom = FlatButton(
      child: new Text(
        'SIGN IN',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Color(ColorValues.BUTTON_TEXT_GRAY),
          fontSize: 16.0,
          fontFamily: 'customBold',
        ),
      ),
      onPressed: () {
      /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );*/

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) {
              return LoginPage();
            },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      },
    );

    // Main View for return final Output
    return new Theme(
        data: ThemeData(
            backgroundColor: Colors.white,
            brightness: Brightness.dark,
            indicatorColor: Colors.white,
            primaryColor: Colors.white,
            accentColor: Colors.white),
        child: new Scaffold(
            resizeToAvoidBottomPadding: false,
            body: new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage("assets/login/signup_p_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child:new Column(children: <Widget>[
                  new Expanded(child: new Stack(
                    children: <Widget>[
                      new Container(
                        child: new Container(
                            child: new Center(
                              child: Form(
                                  key: formKey,
                                  child: new ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      userFirstNameUi,
                                      lastNameUi,
                                      emailUi,
                                      studentEmailUi,
                                      studentNameUi,
                                      _isLoading
                                          ? new Center(
                                          child: new Padding(
                                            padding: new EdgeInsets.fromLTRB(
                                                0.0, 60.0, 0.0, 0.0),
                                            child: new Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                new CircularProgressIndicator(),
                                              ],
                                            ),
                                          ))
                                          : loginButton,
                                      new Text(""),
                                      new Text("")
                                    ],
                                  )),
                            )),
                      ),

                    ],
                  ),flex: 8,),
                  new Expanded(child: new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Padding(
                              padding: new EdgeInsets.fromLTRB(
                                  0.0, 0.0, 0.0, 40.0),
                              child: new Align(
                                  alignment: Alignment.bottomLeft,
                                  child: _SignInBtnBottom)),
                          flex: 1),
                      new Expanded(
                          child: new Padding(
                              padding: new EdgeInsets.fromLTRB(
                                  0.0, 0.0, 0.0, 25.0),
                              child: new Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _SignUpAsParentBtnBottom)),
                          flex: 1),
                      new Expanded(
                          child: new Padding(
                              padding: new EdgeInsets.fromLTRB(
                                  0.0, 0.0, 0.0, 25.0),
                              child: new Align(
                                  alignment: Alignment.bottomRight,
                                  child: _SignUpAsStudentBtnBottom)),
                          flex: 1),
                    ],
                  ),flex: 2,),
                ],) )));
  }
}
