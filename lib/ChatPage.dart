// TapboxA manages its own state.

//------------------------- TapboxA ----------------------------------
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'Msg.dart';
import 'Global.dart';

class ChatPage extends StatefulWidget {
ChatPage(this.device);
final Device device;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _active = false;



  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('chat Screen'),
      ),
      body:Column(
        children: [
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount:Global.messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 15,
                  // color: Colors.amber[colorCodes[index]],
                  child: Center(child: Text(Global.messages[index].msgtype+":" +Global.messages[index].deviceId + " "+Global.messages[index].message )),
                );
              },
          )
          ,
          TextField(controller: myController),
          ElevatedButton(
              onPressed: () {
                Global.nearbyService.sendMessage(
                    widget.device.deviceId, myController.text);
      setState(() {
        Global.messages.add(new Msg(widget.device.deviceId,myController.text,"sent"));
        // conversations[device.deviceId].ListOfMsgs.add(new Message(device.deviceId,myController.text,"sent"));
      });},
              child:Text("send")
          ),

        ],
      )  ,


    )
      ;
  }
}

//------------------------- MyApp ----------------------------------
