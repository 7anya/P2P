import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Msg.dart';
class Conversation{
  static List <Msg> ListOfMsgs=[];
  static  String deviceId;
  Conversation();
}
// class Message {
//   String deviceId;
//   String message;
//   String msgtype;
//   Message(this.deviceId,this.message,this.msgtype);
//
// }
class Global {

  static List<Device> devices = [];
  static List<Device> connectedDevices = [];
  static NearbyService nearbyService;
  static StreamSubscription subscription;
  static StreamSubscription receivedDataSubscription;
  static List<Msg> messages =[Msg("1","test","sent"),Msg("2","test2","sent")];
  static Map <String,Conversation> conversations;
}


// In another file:
//
// import <path-to-global>
// Global.messages = bla;