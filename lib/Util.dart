

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utility{
  static showMsg(String msg){
    Fluttertoast.showToast(
        msg: msg,
        fontSize: 15,
        timeInSecForIos: 20,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }
}