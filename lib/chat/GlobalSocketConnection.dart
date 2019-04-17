import 'package:adhara_socket_io/adhara_socket_io.dart';

class GlobalSocketConnection {
  //static SocketIO socketIO;




 static String ip = "https://spikeview.com:3002/";
 //static String ip = "https://socket-io-chat.now.sh/";
 //static String ip = "http://103.76.253.131:3002";
  //static String ip = "http://104.42.51.157:3002";

  static SocketIOManager manager = SocketIOManager();
  static SocketIO socket;
//103.76.253.131:3002
}