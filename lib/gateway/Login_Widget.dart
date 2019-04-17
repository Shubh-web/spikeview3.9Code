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
import 'package:spike_view_project/api_interface/ApiCalling.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget_Parent.dart';
import 'package:spike_view_project/gateway/ChangePassword.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:spike_view_project/drawer/Dash_Board_Widget.dart';
import 'package:spike_view_project/gateway/Signup_As_Parent_Widget.dart';
import 'package:spike_view_project/gateway/ForgotPassword.dart';
import 'package:spike_view_project/gateway/Signup_As_Student_Widget.dart';
import 'package:spike_view_project/modal/UserModel.dart';
import 'package:spike_view_project/parentProfile/ParentProfile.dart';
import 'package:spike_view_project/profile/UserProfile.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPageState createState() => new _LoginPageState();
}

final formKey = GlobalKey<FormState>();
String _email = "", _password = "";
bool _isLoading = false;
List<UserData> userList = new List();
List<UserData> userList2 = new List();

class _LoginPageState extends State<LoginPage> {
  Color borderColor = Colors.amber;
  static const platform = const MethodChannel('samples.flutter.io/battery');

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
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

  void _checkValidation() async {
    FocusScope.of(context).requestFocus(new FocusNode());
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

  loginServiceCall() async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String encryptedPassWord =
            await platform.invokeMethod('encryption', {
          "password": _password,
        });
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
        print("token genrated:-" + prefs.getString("deviceId"));
        Map map = {
          "email": _email.toLowerCase(),
          "password": encryptedPassWord,
          "deviceId": prefs.getString("deviceId"),
        };
        // Make API call
        Response response =
            await dio.post(Constant.ENDPOINT_LOGIN, data: json.encode(map));
        //   CustomProgressLoader.cancelLoader(context);
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];
          String message = response.data[LoginResponseConstant.MESSAGE];

          if (status == "Success") {
            String userId = response.data['result']['userId'].toString();
            String firstName = response.data['result']['firstName'].toString();
            String lastName = response.data['result']['lastName'].toString();
            String email = response.data['result']['email'].toString();
            String salt = response.data['result']['salt'].toString();
            String mobileNo = response.data['result']['mobileNo'].toString();
            String profilePicture =
                response.data['result']['profilePicture'].toString();
            String roleId = response.data['result']['roleId'].toString();
            String token = response.data['result']['token'].toString();
            bool isPasswordChanged =
                response.data['result']['isPasswordChanged'];
            userList.add(new UserData(userId, firstName, lastName, email, salt,
                mobileNo, profilePicture, roleId));

            prefs.setBool(UserPreference.LOGIN_STATUS, true);
            prefs.setBool(
                UserPreference.IS_PASSWORD_CHANGED, isPasswordChanged);
            prefs.setString(UserPreference.USER_ID, userId);
            prefs.setBool(
                UserPreference.IS_PARENT, roleId == "2" ? true : false);
            prefs.setString(UserPreference.PARENT_ID, userId);
            prefs.setString(UserPreference.NAME, firstName + " " + lastName);
            prefs.setString(UserPreference.EMAIL, email);
            prefs.setString(UserPreference.MOBILE, mobileNo);

            prefs.setString(UserPreference.PROFILE_IMAGE_PATH, profilePicture);
            prefs.setString(UserPreference.USER_TOKEN, "Spike " + token);

            if (isPasswordChanged) {
              if (roleId == "2") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new DashBoardWidgetParent()),
                );
              } else {
               /* Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new DashBoardWidget()),
                );*/

                Navigator.pushReplacement(context,
                    new MaterialPageRoute(
                      //   builder: (context) => new DashBoardWidget()));
                        builder: (context) =>  new UserProfilePage("", true,"login")));
              }
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => new ChangePassword("login",roleId == "2" ? true : false)),
              );
            }
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
        setState(() => _isLoading = false);
        ToastWrap.showToast(e.toString());
      }
    } else {
      setState(() => _isLoading = false);
      ToastWrap.showToast("Please check your internet connection....!");
    }
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

    final _userNameView = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 30.0, right: 30.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.white,
            textSelectionColor: Colors.white,
            accentColor: Colors.white,
            hintColor: Colors.white70),
        child: new TextFormField(
          keyboardType: TextInputType.emailAddress,
          validator: (val) => !isEmail(val) ? 'Please enter valid email.' : null,
          onSaved: (val) => _email = val,
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
              hintText: "Email",
              labelStyle: new TextStyle(color: Colors.grey),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white))),
        ),
      ),
    );

    final _userPassword = new Padding(
      padding:
          new EdgeInsets.only(left: 30.0, top: 15.0, right: 30.0, bottom: 10.0),
      child: new Theme(
        data: new ThemeData(
            primaryColor: Colors.white,
            textSelectionColor: Colors.white,
            accentColor: Colors.white,
            hintColor: Colors.white70),
        child: new TextFormField(
          validator: (val) =>
              !isPass(val) ? 'Please enter valid password.' : null,
          onSaved: (val) => _password = (val = val.trim()),
          obscureText: true,
          style: new TextStyle(color: Colors.white),
          autofocus: false,
          decoration: new InputDecoration(
              prefixIcon: new GestureDetector(
                  child: new Padding(
                padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: new Image.asset(
                  "assets/login/password.png",
                  width: 25.0,
                  height: 25.0,
                ),
              )),
              hintText: "Password",
              labelStyle: new TextStyle(color: Colors.grey),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                      color: Colors.white, style: BorderStyle.none))),
        ),
      ),
    );

    final loginButton = Padding(
        padding: new EdgeInsets.only(
            left: 30.0, top: 30.0, right: 30.0, bottom: 0.0),
        child: new Container(
            height: 50.0,
            child: FlatButton(
              onPressed: _checkValidation,
              color: Color(ColorValues.BUTTON_LOGIN_BG),
              child: Row(
                // Replace with a Row for horizontal icon + text
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('SIGN IN ',
                      style: TextStyle(
                          fontFamily: 'customBold',
                          color: Color(ColorValues.BUTTON_TEXT_BLUE))),
                ],
              ),
            )));

    final _forgotLabel = new Padding(
        padding: new EdgeInsets.all(5.0),
        child: FlatButton(
          child: Text(
            'Forgot Password?',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'customRegular',
                fontSize: 15.0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPassword()),
            );
          },
        ));

    final _SignUpAsParentBtnBottom = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new FlatButton(
          onPressed: () {
            /*Navigator.pushReplacement(
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
        new FlatButton(
          onPressed: () {
            /* Navigator.pushReplacement(
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
          color: Color(ColorValues.BUTTON_TEXT_BLUE),
          fontSize: 16.0,
          fontFamily: 'customBold',
        ),
      ),
      onPressed: () {
        /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );*/
      },
    );

    // Main View for return final Output
    return new Theme(
        data: ThemeData(
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            indicatorColor: Colors.white,
            primaryColor: Colors.white,
            accentColor: Colors.white),
        child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Scaffold(
                resizeToAvoidBottomPadding: false,
                body: new Stack(
                  children: <Widget>[
                    new Container(
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: new AssetImage("assets/login/login_bg.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: new Container(
                          child: new Center(
                        child: Form(
                            key: formKey,
                            child: new ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                _userNameView,
                                _userPassword,
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
                                new Center(
                                  child: _forgotLabel,
                                ),
                                new Text(""),
                                new Text("")
                              ],
                            )),
                      )),
                    ),
                    new Row(
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
                  ],
                ))));
  }
}
