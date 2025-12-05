import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast({String message = "Something went wrong!"}){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
      fontSize: 16.0
  );

}