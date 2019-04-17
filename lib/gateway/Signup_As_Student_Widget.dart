// Updated COde

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/home/home.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/gateway/Login_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Parent_Widget.dart';
import 'package:spike_view_project/values/ColorValues.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';

class SignupStudentPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  SignupStudentPageState createState() => new SignupStudentPageState();
}

final formKey = GlobalKey<FormState>();
String strFirstName = "",
    strLastName = "",
    strEmail = "",
    strParentEmail = "",
    strParentFirstName = "";
int strDateOfBirth;

bool _isLoading = false;
TextEditingController dobController;

class SignupStudentPageState extends State<SignupStudentPage> {
  Color borderColor = Colors.amber;

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  @override
  void initState() {
    dobController = new TextEditingController(text: '');
  }

  void _checkValidation() {
    final form = formKey.currentState;
    setState(() => _isLoading = true);
    form.save();
    if (form.validate()) {
      print("SUCCESS 00");
      if (strDateOfBirth != null || strDateOfBirth != 0) {
        loginServiceCall();
      } else {
        ToastWrap.showToast("Please select date of birth..!");
      }
    } else {
      setState(() => _isLoading = false);
      print("Failure 00");
    }
  }

  loginServiceCall() async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        var dio = new Dio();
        dio.onHttpClientCreate = (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
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
          "parentEmail": strParentEmail.toLowerCase(),
          "parentFirstName": strParentFirstName,
          "roleId": 1,
          "dob": strDateOfBirth
        };

        // Make API call
        Response response = await dio.post(Constant.ENDPOINT_PARENT_SIGNUP,
            data: json.encode(map));
        //   CustomProgressLoader.cancelLoader(context);
        setState(() => _isLoading = false);
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data[LoginResponseConstant.MESSAGE];

          if (status == "Success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => new LoginPage()),
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
  bool isName(String em) {

    return RegExp(r"\s+\b|\b\s|^[a-zA-Z]+$").hasMatch(em);
  }
  @override
  Widget build(BuildContext context) {
    final upperLogo = new Image(
      image: new AssetImage("assets/logo.png"),
      color: null,
      width: 130.0,
      height: 70.0,
      fit: BoxFit.contain,
    );

    final userFirstNameUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 25.0, right: 30.0, bottom: 10.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,maxLength: 20,
        validator: (val) => !isName(val.trim()) ? 'Please enter first name.':null,
        onSaved: (val) => strFirstName = val.trim(),
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
            hintText: "First Name",counterText: "",
            labelStyle: new TextStyle(color: Colors.white),
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

    Future<Null> selectDob(BuildContext context) async {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.parse("1800-01-01"),
        lastDate: new DateTime.now(),
      );
      if (picked != null) {
        strDateOfBirth = picked.millisecondsSinceEpoch;
        String date = new DateFormat("MM-dd-yyyy").format(picked);
        String date2 = new DateFormat("yyyy-MM-dd").format(picked);
        print(date);
        setState(() {
          dobController = new TextEditingController(text: date);
        });
      }
    }

    final dateOBUI = new InkWell(
        child: new Container(
            padding: new EdgeInsets.only(
                left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
            child: new TextField(
              keyboardType: TextInputType.text,
              controller: dobController,
              decoration: new InputDecoration(
                  enabled: false,
                  hintText: "Date Of Birth",
                  labelStyle: new TextStyle(
                      fontSize: 12.0, color: const Color(0xFF757575)),
                  prefixIcon: new GestureDetector(
                      child: new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: new Image.asset(
                      "assets/login/calander_singup.png",
                      width: 25.0,
                      height: 25.0,
                    ),
                  ))),
            )),
        onTap: () {
          setState(() {
            selectDob(context);
          });
        });

    final parentEmailUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (val) => !isEmail(val) ? 'Please enter email.' : null,
        onSaved: (val) => strParentEmail = val,
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
            hintText: "Parent Email",
            labelStyle: new TextStyle(color: Colors.white),
            border: new UnderlineInputBorder(
                borderSide: new BorderSide(color: Colors.white))),
      ),
    );

    final parentNameUi = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 20.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,maxLength: 35,
        validator: (val) => !isName(val) ? 'Please enter parent name.':null,
        onSaved: (val) => strParentFirstName = val.trim(),
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
            hintText: "Parent First Name",counterText: "",
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
        new FlatButton(
          onPressed: () {
           /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupParentPage()),
            );*/

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) {
                  return SignupParentPage();
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
          'AS PARENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(ColorValues.BUTTON_TEXT_GRAY),
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
          onPressed: () {},
        ),
        new Text(
          'AS STUDENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(ColorValues.BUTTON_TEXT_BLUE),
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
       /* Navigator.pushReplacement(
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

    /*  return new Theme(
        data: ThemeData(
            backgroundColor: Colors.white,
            brightness: Brightness.dark,
            indicatorColor: Colors.white,
            primaryColor: Colors.white,
            accentColor: Colors.white),
        child: new Scaffold(
            body: new Container(

                height: double.infinity,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage("assets/login/signup_p_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: new Column(children: <Widget>[

                  new SingleChildScrollView(
                      child:  Form(
                      key: formKey,
                      child: new Column(
                        children: <Widget>[
                          userFirstNameUi,
                          lastNameUi,
                          emailUi,
                          dateOBUI,
                          parentEmailUi,
                          parentNameUi,
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
                      )))

              ],)
                )));*/
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
                child: new Column(children: <Widget>[
                  new Expanded(child: new Stack(
                      children: <Widget>[
                        new Container(

                          child: new Container(
                              child: new Center(
                                child: Form(
                                  key: formKey,
                                  child: new ListView(
                                    children: <Widget>[
                                      userFirstNameUi,
                                      lastNameUi,
                                      emailUi,
                                      dateOBUI,
                                      parentEmailUi,
                                      parentNameUi,
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
                          )]),
                      flex: 8,
                    ),
                    new Expanded(
                      child: new Row(
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
                      ),
                      flex: 2,
                    )
                  ],
                ))));
  }
}
