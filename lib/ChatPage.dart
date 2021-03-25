import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:p2p/Conversation.dart';
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

  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ' + widget.device.deviceName),
      ),
      body: Column(
        children: [
          Container(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              // reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: Global
                  .conversations[widget.device.deviceId]==null?0: Global
                  .conversations[widget.device.deviceId].ListOfMsgs.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 55,
                  // color: Colors.amber[colorCodes[index]],
                  child: Global.conversations[widget.device.deviceId]
                              .ListOfMsgs[index].msgtype ==
                          'sent'
                      ? Bubble(
                          margin: BubbleEdges.only(top: 10),
                          nip: BubbleNip.rightTop,
                          color: Color(0xffd1c4e9),
                          child: Text(
                              Global.conversations[widget.device.deviceId]
                                      .ListOfMsgs[index].msgtype +
                                  ": " +
                                  Global.conversations[widget.device.deviceId]
                                      .ListOfMsgs[index].message,
                              textAlign: TextAlign.right),
                        )
                      : Bubble(
                          nip: BubbleNip.leftTop,
                          color: Color(0xff80DEEA),
                          margin: BubbleEdges.only(top: 10),
                          child: Text(
                            Global.conversations[widget.device.deviceId]
                                    .ListOfMsgs[index].msgtype +
                                ": " +
                                Global.conversations[widget.device.deviceId]
                                    .ListOfMsgs[index].message,
                          ),
                        ),
                  // Text(Global.messages[index].msgtype+": "+Global.messages[index].message, ),
                );
              },
            ),
          ),
          TextFormField(
            controller: myController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'Send Message?',
              labelText: 'Send Message ',
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Global.nearbyService
                    .sendMessage(widget.device.deviceId, myController.text);
                setState(() {
                  if(Global.conversations[widget.device.deviceId]==null)
                    Global.conversations[widget.device.deviceId]= new Conversation();
                  Global.conversations[widget.device.deviceId].ListOfMsgs.add(
                      new Msg(
                          widget.device.deviceId, myController.text, "sent"));
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut);
                  // conversations[device.deviceId].ListOfMsgs.add(new Message(device.deviceId,myController.text,"sent"));
                });
              },
              child: Text("send")),
        ],
      ),
    );
  }
}
