import 'package:connectivity/connectivity.dart';



import 'dart:async';


class ConectionDetecter {
  static final Connectivity conectivity = new Connectivity();

  static Future<bool> isConnected() async {
    var connectivityResult = await (conectivity.checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return true;
    }
    return false;
  }
}
