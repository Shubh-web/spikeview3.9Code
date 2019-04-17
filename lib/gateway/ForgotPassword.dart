// Updated COde

import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Parent_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Student_Widget.dart';
import 'package:spike_view_project/values/ColorValues.dart';


class ForgotPassword extends StatefulWidget {
  static String tag = 'login-page';

  @override
  ForgotPasswordState createState() => new ForgotPasswordState();
}

final formKey = GlobalKey<FormState>();
String _email = "";
bool _isLoading = false;

class ForgotPasswordState extends State<ForgotPassword> {
  Color borderColor = Colors.amber;

  void _checkValidation() {
    final form = formKey.currentState;
    setState(() => _isLoading = true);
    form.save();
    if (form.validate()) {
      forgotpassworApiCalling();
    } else {
      setState(() => _isLoading = false);
      print("Failure 00");
    }
  }

  ontapCancel() {
    Navigator.pop(context);
  }

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }

  forgotpassworApiCalling() async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        CustomProgressLoader.showLoader(context);
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

        // Make API call
        Response response = await dio.post(
          Constant.ENDPOINT_FORGOT_PASSWORD + _email,
        );
        CustomProgressLoader.cancelLoader(context);
        setState(() => _isLoading = false);
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data[LoginResponseConstant.MESSAGE];

          if (status == "Success") {
            Navigator.pop(context);

            ToastWrap.showToast(message);
          } else {
            ToastWrap.showToast(message);
          }
        } else {
          CustomProgressLoader.cancelLoader(context);
          setState(() => _isLoading = false);
          // If that call was not successful, throw an error.
          throw Exception('Something went wrong!!');
        }
      } catch (e) {
        CustomProgressLoader.cancelLoader(context);
        print(e);
        ToastWrap.showToast(e.toString());
      }
    } else {
      setState(() => _isLoading = false);
      CustomProgressLoader.cancelLoader(context);
      ToastWrap.showToast("Please check your internet connection....!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailUi = new Padding(
      padding:
          new EdgeInsets.only(left: 20.0, top: 15.0, right: 20.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.white,
            textSelectionColor: Colors.white,
            accentColor: Colors.white,
            hintColor: Colors.white),
        child: new TextFormField(
          keyboardType: TextInputType.emailAddress,
          validator: (val) => !isEmail(val) ? 'Please enter email.' : null,
          onSaved: (val) => _email = val,
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
              hintText: "  Email",
              labelStyle: new TextStyle(color: Colors.white),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white))),
        ),
      ),
    );

    final loginButton = Padding(
        padding: new EdgeInsets.only(
            left: 15.0, top: 30.0, right: 10.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: _checkValidation,
              color: Colors.white,
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('RESET PASSWORD ',
                      style: TextStyle(
                          fontFamily: 'customBold',
                          color:new Color(ColorValues.BLUE_COLOR),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )));

    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/splash_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                      padding: new EdgeInsets.fromLTRB(15.0, 30.0, 0.0, 0.0),
                      child: new InkWell(
                        child: new Image.asset(
                          "assets/login/back_arrow.png",
                          alignment: Alignment.bottomRight,
                          width: 32.0,
                          height: 32.0,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ))
                ],
              ),
              flex: 2,
            ),
            new Expanded(
              child: new Container(
                  child: new Container(
                padding: new EdgeInsets.all(10.0),
                child: Form(
                    key: formKey,
                    child: new ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        PaddingWrap.paddingfromLTRB(
                            0.0,
                            20.0,
                            0.0,
                            20.0,
                            new Column(
                              children: <Widget>[
                                new Image.asset(
                                  "assets/login/forgot_password.png",
                                  width: 60.0,
                                  height: 60.0,
                                ),
                                PaddingWrap.paddingAll(
                                    10.0,
                                    TextViewWrap.textView(
                                        "Forgot Password",
                                        TextAlign.center,
                                        Colors.white,
                                        22.0,
                                        FontWeight.bold)),

                                PaddingWrap.paddingAll(
                                    10.0,
                                  new Text("Reset your password by filling in your email address. you will then receive an email with new password.",
                                    textAlign: TextAlign.left,style: new TextStyle(color: Colors.white,fontSize: 16.0),)),
                              ],
                            )),
                        emailUi,
                        loginButton,
                      ],
                    )),
              )),
              flex: 23,
            )
          ],
        ),
      ),
    );
  }
}
