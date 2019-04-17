import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';

class ApiCalling2 {
  String userIdPref, token;
  Response response;
  BuildContext context;
  String uri;
  String type;


  //========================================= Api Calling ============================
  Future<Response> apiCall2(context1,url,type) async {
    context = context1;
    response = await apiCallForUserProfile2(url,type);
    return response;
  }

  Future<Response> apiCallForUserProfile2(url,type) async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userIdPref = prefs.getString(UserPreference.USER_ID);
        token = prefs.getString(UserPreference.USER_TOKEN);
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
        dio.options.headers = {'Authorization': token}; // Prepare Data

        // Make API call
        if(type=='get') {
          response = await dio.get(url);
        }else{
          response = await dio.post(url);

        }
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];

          if (status == "Success") {

            return response;
          } else {
            return response;
          }
        } else {
          

          return response;
        }
      } catch (e) {
        
        print(e);
        return response;
      }
    } else {
      

      ToastWrap.showToast("Please check your internet connection....!");
      return response;
    }
  }



  //========================================= Api Calling ============================
  Future<Response> apiCall(context1,url,type) async {
    context = context1;
    response = await apiCallForUserProfile(url,type);
    return response;
  }

  Future<Response> apiCallForUserProfile(url,type) async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userIdPref = prefs.getString(UserPreference.USER_ID);
        token = prefs.getString(UserPreference.USER_TOKEN);
        
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
        dio.options.headers = {'Authorization': token}; // Prepare Data

        // Make API call
        if(type=='get') {
          response = await dio.get(url);
        }else{
          response = await dio.post(url);

        }
        
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];

          if (status == "Success") {

            return response;
          } else {
            return response;
          }
        } else {
          

          return response;
        }
      } catch (e) {
        
        print(e);
        return response;
      }
    } else {
      

      ToastWrap.showToast("Please check your internet connection....!");
      return response;
    }
  }


  //============================================Api Calling post with Param ===============================

  Future<Response> apiCallPostWithMapData(context1,url,map) async {
    context = context1;
    response = await apiCallPost(url,map);
    return response;
  }

  Future<Response> apiCallPost(url,map) async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userIdPref = prefs.getString(UserPreference.USER_ID);
        token = prefs.getString(UserPreference.USER_TOKEN);
        
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
        dio.options.headers = {'Authorization': token}; // Prepare Data


          response = await dio.post(url,data: json.encode(map));

print("response:-"+response.toString());
        
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];

          if (status == "Success") {

            return response;
          } else {
            return response;
          }
        } else {
          

          return response;
        }
      } catch (e) {
        
        print(e);
        return response;
      }
    } else {
      

      ToastWrap.showToast("Please check your internet connection....!");
      return response;
    }
  }


  //============================================Api Calling put with Param ===============================

  Future<Response> apiCallPutWithMapData(context1,url,map) async {
    context = context1;
    response = await apiCallPut(url,map);
    return response;
  }

  Future<Response> apiCallPut(url,map) async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userIdPref = prefs.getString(UserPreference.USER_ID);
        token = prefs.getString(UserPreference.USER_TOKEN);
        
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
        dio.options.headers = {'Authorization': token}; // Prepare Data


        response = await dio.put(url,data: json.encode(map));

        print("response:-"+response.toString());
        
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];

          if (status == "Success") {

            return response;
          } else {
            return response;
          }
        } else {
          

          return response;
        }
      } catch (e) {
        
        print(e);
        return response;
      }
    } else {
      

      ToastWrap.showToast("Please check your internet connection....!");
      return response;
    }
  }



  //============================================Api Calling Delete with Param ===============================

  Future<Response> apiCallDeleteWithMapData(context1,url,map) async {
    context = context1;
    response = await apiCallDelete(url,map);
    return response;
  }

  Future<Response> apiCallDelete(url,map) async {
    var isConnect = await ConectionDetecter.isConnected();
    if (isConnect) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userIdPref = prefs.getString(UserPreference.USER_ID);
        token = prefs.getString(UserPreference.USER_TOKEN);
        
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
        dio.options.headers = {'Authorization': token}; // Prepare Data


        response = await dio.delete(url,data: json.encode(map));

        print("response:-"+response.toString());
        
        print(response.toString());
        if (response.statusCode == 200) {
          String status = response.data[LoginResponseConstant.STATUS];

          if (status == "Success") {

            return response;
          } else {
            return response;
          }
        } else {
          

          return response;
        }
      } catch (e) {
        
        print(e);
        return response;
      }
    } else {
      

      ToastWrap.showToast("Please check your internet connection....!");
      return response;
    }
  }

}
