import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
class PaddingWrap {

 static Padding paddingAll(paddingValue,childValue){
  return  new Padding(padding: new EdgeInsets.all(paddingValue),
    child:childValue ,
    );
  }

 static Padding paddingfromLTRB(pL,pT,pR,pB,childValue){
   return  new Padding(padding: new EdgeInsets.fromLTRB(pL, pT, pR, pB),
     child:childValue ,
   );
 }
}
