import 'package:flutter/material.dart';
import 'package:spike_view_project/activity/ConnectedWidget.dart';
import 'package:spike_view_project/activity/Connection_Requests.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class ConnectionsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ConnectionsWidgetState();
  }
}

class ConnectionsWidgetState extends State<ConnectionsWidget> {
  void floationOnClick() {
    print("clicked");
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: new Container(
            color: Colors.white,
            child: new SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(child: new Container()),
                  new TabBar(
                    indicatorColor: new Color(ColorValues.BLUE_COLOR),
                    labelColor: new Color(ColorValues.BLUE_COLOR),
                    indicatorWeight: 4.0,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: [

                      PaddingWrap.paddingAll(
                          10.0,
                          new Text("Your Connection",
                              textAlign: TextAlign.center,
                              style:
                                  new TextStyle(fontWeight: FontWeight.bold))),
                      PaddingWrap.paddingAll(
                          10.0,
                          new Text(
                            "Connection Requests",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: new TabBarView(
          children: <Widget>[

            new ConnectedWidget() ,  new ConnectionRequests()
            ,
          ],
        ),
      ),
    );
  }
}
