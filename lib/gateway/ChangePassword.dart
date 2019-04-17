// Updated COde

import 'package:flutter/services.dart';
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
import 'package:spike_view_project/drawer/Dash_Board_Widget_Parent.dart';
import 'package:spike_view_project/gateway/Signup_As_Parent_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Student_Widget.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/values/ColorValues.dart';


class ChangePassword extends StatefulWidget {
  static String tag = 'login-page';
  String activity;
  bool isParent;
  ChangePassword(this.activity,this.isParent);
  @override
  ChangePasswordState createState() => new ChangePasswordState(activity);
}

final formKey = GlobalKey<FormState>();
String strNewPassword = "", strConformPassword = "", strOldPassword = "";
bool _isLoading = false;

class ChangePasswordState extends State<ChangePassword> {
  Color borderColor = Colors.amber;
  String activity;
  static const platform = const MethodChannel('samples.flutter.io/battery');
  ChangePasswordState(this.activity);
  void _checkValidation() async {
    final form = formKey.currentState;
    setState(() => _isLoading = true);
    form.save();
    if (form.validate()) {
      print("SUCCESS 00");
      if(strNewPassword==strConformPassword) {
        changePasswordApiCall();
      }else{
        ToastWrap.showToast("Confirm passsword not matched....!");

      }
    } else {
      setState(() => _isLoading = false);
      print("Failure 00");
    }
  }




  bool isPass(String em) {
    String emailRegexp =
        r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[?!@#$%^&*()_+])(?=.*[a-zA-Z].*)[a-zA-Z\d\!?@#\$%&\*]{7,}$';
    //r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[?!@#$%^&*()_+])[A-Za-z\d][A-Za-z\d!?@#$%^&*()_+]{7,19}$';

    RegExp regExp = RegExp(emailRegexp);
    bool isPasw=regExp.hasMatch(em);
    if(!isPasw){
      ToastWrap.showToast("Pssword should contain one capital letter One special character , one number and not be of less than 8 characters.");
    }
    return isPasw;
  }
  ontapCancel() {
    Navigator.pop(context);
  }

  changePasswordApiCall() async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        final String encryptedstrOldPassword = await platform.invokeMethod('encryption', {
          "password": strOldPassword,
        });

        final String encryptedstrNewPassword = await platform.invokeMethod('encryption', {
          "password": strNewPassword,
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString(UserPreference.USER_TOKEN);
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
        dio.options.headers = {'Authorization': token};
        // Prepare Data
        Map map = {
          "oldPassword": encryptedstrOldPassword,
          "newPassword": encryptedstrNewPassword
        };

        // Make API call
        Response response = await dio.post(Constant.ENDPOINT_CHANGE_PASSWORD,
            data: json.encode(map));
        CustomProgressLoader.cancelLoader(context);
        setState(() => _isLoading = false);
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data[LoginResponseConstant.MESSAGE];

          if (status == "Success") {
            prefs.setBool(UserPreference.IS_PASSWORD_CHANGED, true);
            if(activity=="login"){


              if(widget.isParent){
                Navigator.pushReplacement(context,
                    new MaterialPageRoute(
                        builder: (context) => new DashBoardWidgetParent()));
              }else {
             /*   Navigator.pushReplacement(context,
                    new MaterialPageRoute(
                        builder: (context) => new DashBoardWidget()));*/

                Navigator.pushReplacement(context,
                    new MaterialPageRoute(
                      //   builder: (context) => new DashBoardWidget()));
                        builder: (context) =>  new UserProfilePage("", true,"login")));
              }

            }else{
              Navigator.pop(context);
            }


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
      CustomProgressLoader.cancelLoader(context);
      setState(() => _isLoading = false);
      ToastWrap.showToast("Please check your internet connection....!");
    }
  }


  @override
  Widget build(BuildContext context) {
    final oldPassUi = new Padding(
      padding:
      new EdgeInsets.only(left: 30.0, top: 15.0, right: 30.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.grey,
            textSelectionColor: Colors.black,
            accentColor: Colors.black,
            hintColor: Colors.grey),
        child: new TextFormField(
          validator: (val) => !isPass(val) ? 'Please enter valid old password.' : null,
          onSaved: (val) => strOldPassword = val,
          obscureText: true,
          style: new TextStyle(color: Colors.black),
          autofocus: false,
          decoration: new InputDecoration(
              prefixIcon: new GestureDetector(
                  child: new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: new Image.asset(
                      "assets/navigation/change_password.png",
                      width: 25.0,
                      height: 25.0,
                    ),
                  )),
              hintText: "  Old password",
              labelStyle: new TextStyle(color: Colors.grey),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                      color: Colors.grey, style: BorderStyle.none))),
        ),
      ),
    );

    final newPassUi = new Padding(
      padding:
      new EdgeInsets.only(left: 30.0, top: 15.0, right: 30.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.grey,
            textSelectionColor: Colors.black,
            accentColor: Colors.black,
            hintColor: Colors.grey),
        child: new TextFormField(
          validator: (val) => !isPass(val) ? 'Please enter valid new password.' : null,
          onSaved: (val) => strNewPassword = val,
          obscureText: true,
          style: new TextStyle(color: Colors.black),
          autofocus: false,
          decoration: new InputDecoration(
              prefixIcon: new GestureDetector(
                  child: new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: new Image.asset(
                      "assets/navigation/change_password.png",
                      width: 25.0,
                      height: 25.0,
                    ),
                  )),
              hintText: "  New password",
              labelStyle: new TextStyle(color: Colors.grey),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                      color: Colors.grey, style: BorderStyle.none))),
        ),
      ),
    );

    final conformPasUi = new Padding(
      padding:
      new EdgeInsets.only(left: 30.0, top: 15.0, right: 30.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.grey,
            textSelectionColor: Colors.black,
            accentColor: Colors.black,
            hintColor: Colors.grey),
        child: new TextFormField(
          validator: (val) => !isPass(val) ? 'Please enter valid confirm password.' : null,
          onSaved: (val) => strConformPassword = val,
          obscureText: true,
          style: new TextStyle(color: Colors.black),
          autofocus: false,
          decoration: new InputDecoration(
              prefixIcon: new GestureDetector(
                  child: new Padding(
                    padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: new Image.asset(
                      "assets/navigation/change_password.png",
                      width: 25.0,
                      height: 25.0,
                    ),
                  )),
              hintText: "  Confirm password",
              labelStyle: new TextStyle(color: Colors.grey),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                      color: Colors.grey, style: BorderStyle.none))),
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
              color: new Color(ColorValues.BLUE_COLOR),
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('SAVE ',
                      style: TextStyle(
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));

    final cancelButton = Padding(
        padding: new EdgeInsets.only(
            left: 10.0, top: 30.0, right: 15.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: ontapCancel,
              color: Colors.black54,
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('CANCEL ',
                      style: TextStyle(
                          fontFamily: 'customBold', color: Colors.white)),
                ],
              ),
            )));
    // Main View for return final Output
    return new Scaffold(
        appBar: new AppBar(    brightness: Brightness.light,
          title: new Text(" "),  titleSpacing: 2.0,
          backgroundColor: new Color(ColorValues.BLUE_COLOR),
        ),
        body: new Container(
            color: Colors.white,
            height: double.infinity,
            child: new Theme(
                data: new ThemeData(hintColor: Colors.white),
                child: new Stack(
                  children: <Widget>[
                    new Container(
                        color: Colors.white,
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
                                            "assets/login/change_password.png",
                                            width: 60.0,
                                            height: 60.0,
                                          ),
                                          PaddingWrap.paddingAll(
                                              10.0,
                                              TextViewWrap.textView(
                                                  "Change Password",
                                                  TextAlign.center,
                                                  new Color(ColorValues.BLUE_COLOR),
                                                  22.0,
                                                  FontWeight.bold)),
                                        ],
                                      )),
                                  oldPassUi,
                                  newPassUi,
                                  conformPasUi,
                                  PaddingWrap.paddingAll(
                                      10.0,
                                      new Row(
                                        children: <Widget>[
                                          new Expanded(
                                            child: loginButton,
                                            flex: 1,
                                          ),
                                          /*new Expanded(
                                            child: cancelButton,
                                            flex: 1,
                                          )*/
                                        ],
                                      ))
                                ],
                              )),
                        )),
                  ],
                ))));
  }
}
