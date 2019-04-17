import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
class TextViewWrap {

 static Text textView(text,txtAlign,txtColour,txtSize,txtFontWeight){
   return new Text(
     text,overflow: TextOverflow.ellipsis,maxLines: 1,
     textAlign: txtAlign,
     style: new TextStyle(
         color: txtColour,
         fontSize: txtSize,
         fontWeight: txtFontWeight),
   );
  }

 static Text textViewSingleLine(text,txtAlign,txtColour,txtSize,txtFontWeight){
   return new Text(
     text,overflow: TextOverflow.ellipsis,maxLines:1 ,
     textAlign: txtAlign,
     style: new TextStyle(
         color: txtColour,
         fontSize: txtSize,
         fontWeight: txtFontWeight),
   );
 }

 static Text textViewMultiLine(text,txtAlign,txtColour,txtSize,txtFontWeight){
   return new Text(
     text,overflow: TextOverflow.ellipsis,maxLines:2,
     textAlign: txtAlign,
     style: new TextStyle(
         color: txtColour,
         fontSize: txtSize,
         fontWeight: txtFontWeight),
   );
 }
}
