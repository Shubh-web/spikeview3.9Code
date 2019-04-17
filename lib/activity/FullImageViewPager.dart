import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
//import 'package:circle_indicator/circle_indicator.dart';
import 'package:spike_view_project/constant/Constant.dart';
class FullIMageView extends StatefulWidget {
  List<String> images;

  FullIMageView(this.images);

  @override
  FullIMageViewState createState() => new FullIMageViewState(images);
}

class FullIMageViewState extends State<FullIMageView> {
  FullIMageViewState(this.images);

  List<String> images = new List<String>();
  final PageController controller = new PageController();
int currentindex=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("View Images"),
          titleSpacing: 2.0,
          brightness: Brightness.light,
        ),
        body: new Container(
            padding: new EdgeInsets.only(
              top: 16.0,
            ),
            child: new Center(
              child: new Container(
                  height: 300.0,
                  child: new Stack(
                      alignment: FractionalOffset.bottomCenter,
                      children: <Widget>[
                        new PageView.builder(
                          itemCount: images.length,
                          controller: controller,
                          itemBuilder: (context, index) {
                            return new Image.network(
                              Constant.IMAGE_PATH + images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                            );
                          },onPageChanged:(index){
                          setState(() {
                            currentindex=index;
                          });
                        },
                        ),
                        new Container(
                            margin: new EdgeInsets.only(
                              top: 16.0,
                              bottom: 16.0,
                            ),
                            child:new DotsIndicator(
                                numberOfDot: images.length,
                                position: currentindex,
                                dotSize: const Size.square(9.0),
                                dotActiveSize: const Size(18.0, 9.0),
                                dotActiveShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                            )/*new CircleIndicator(
                        controller, images.length, 6.0, Colors.white70, Colors.white)*/
                            ),
                      ])),
            )));
  }
}
