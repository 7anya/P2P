// TapboxA manages its own state.

//------------------------- TapboxA ----------------------------------
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bubble/bubble.dart';
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
        title: Text('Chat with'+widget.device.deviceName),
      ),
      body:Column(
        children: [
          Container(
            height:350,
            child:   ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount:Global.messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height:55,
                  // color: Colors.amber[colorCodes[index]],
                  child: Global.messages[index].msgtype=='sent'?Bubble(
                    margin: BubbleEdges.only(top: 10),
                    nip: BubbleNip.rightTop,
                    color: Color(0xffd1c4e9),
                    child: Text(Global.messages[index].msgtype+": "+Global.messages[index].message, textAlign: TextAlign.right),
                  ):
                  Bubble(
                    nip: BubbleNip.leftTop,
                    color: Color(0xff80DEEA),
                    margin: BubbleEdges.only(top: 10),
                    child:  Text(Global.messages[index].msgtype+": "+Global.messages[index].message, ),
                  ),
                  // Text(Global.messages[index].msgtype+": "+Global.messages[index].message, ),
                );
              },
            ),
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
