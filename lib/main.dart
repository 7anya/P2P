import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './Msg.dart';
import 'Global.dart';
void main() {
  runApp(MyApp());
}
// class Conversation{
//   List <Msg> ListOfMsgs=[];
//   String deviceId;
//   Conversation();
// }
// class Msg {
//   String deviceId;
//   String message;
//   String msgtype;
//   Msg(this.deviceId,this.message,this.msgtype);
//
// }
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
    case 'advertiser':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(deviceType: DeviceType.advertiser));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'browser');
              },
              child: Container(
                color: Colors.red,
                child: Center(
                    child: Text(
                      'BROWSER',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'advertiser');
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                      'ADVERTISER',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  // List<Device> devices = [];
  // List<Device> connectedDevices = [];
  // NearbyService nearbyService;
  // StreamSubscription subscription;
  // StreamSubscription receivedDataSubscription;
  // List<Msg> messages =[Msg("1","test","sent"),Msg("2","test2","sent")];
 Map <String,Conversation> conversations;
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    Global.subscription?.cancel();
    Global.receivedDataSubscription?.cancel();
    Global.nearbyService.stopBrowsingForPeers();
    Global.nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.deviceType.toString().substring(11).toUpperCase()),
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              final device = widget.deviceType == DeviceType.advertiser
                  ? Global.connectedDevices[index]
                  : Global.devices[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabItemListener(device,Global.messages),
                              child: Column(
                                children: [
                                  Text(device.deviceName),
                                  Text(
                                    getStateName(device.state),
                                    style: TextStyle(
                                        color: getStateColor(device.state)),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            )),
                        // Request connect
                        GestureDetector(
                          onTap: () => _onButtonClicked(device),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    Text("hello"),

                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: Global.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 15,
                              // color: Colors.amber[colorCodes[index]],
                              child: Center(child: Text(Global.messages[index].msgtype+":" +Global.messages[index].deviceId + " "+Global.messages[index].message )),
                            );
                          }) ,



                  ],
                ),
              );
            }));
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  _onTabItemListener(Device device,List<Msg> messages) {
    if (device.state == SessionState.connected) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return AlertDialog(
              title: Text("Send message"),
              content: TextField(controller: myController),
              actions: [
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Send"),
                  onPressed: () {
                    Global.nearbyService.sendMessage(
                        device.deviceId, myController.text);
                    setState(() {
                      messages.add(new Msg(device.deviceId,myController.text,"sent"));
                      // conversations[device.deviceId].ListOfMsgs.add(new Msg(device.deviceId,myController.text,"sent"));
                    });

                    myController.text = '';
                  },
                )
              ],
            );
          });
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {
      return Global.connectedDevices.length;
    } else {
      return Global.devices.length;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        Global.nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );

        break;
      case SessionState.connected:
        Global.nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
    Global.nearbyService = NearbyService();
    await Global.nearbyService.init(
        serviceType: 'mp-connection',
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            if (widget.deviceType == DeviceType.browser) {
              await Global.nearbyService.stopBrowsingForPeers();
              await Global.nearbyService.startBrowsingForPeers();
            } else {
              await Global.nearbyService.stopAdvertisingPeer();
              await Global.nearbyService.startAdvertisingPeer();

              await Global.nearbyService.stopBrowsingForPeers();
              await Global.nearbyService.startBrowsingForPeers();
            }
          }
        });
    Global.subscription =
        Global.nearbyService.stateChangedSubscription(callback: (devicesList) {
          devicesList?.forEach((element) {
            print(
                " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

            if (Platform.isAndroid) {
              if (element.state == SessionState.connected) {
                Global.nearbyService.stopBrowsingForPeers();
              } else {
                Global.nearbyService.startBrowsingForPeers();
              }
            }
          });

          setState(() {
            Global.devices.clear();
            Global.devices.addAll(devicesList);
            Global.connectedDevices.clear();
            Global.connectedDevices.addAll(devicesList
                .where((d) => d.state == SessionState.connected)
                .toList());
          });
        });

    Global.receivedDataSubscription =
        Global.nearbyService.dataReceivedSubscription(callback: (data) {
          print("dataReceivedSubscription: ${jsonEncode(data)}");
          Fluttertoast.showToast(msg: jsonEncode(data));
          var temp= jsonEncode(data);
          setState(() {
            Global.messages.add(new Msg(data["deviceId"],data["message"],"received"));
            // conversations[data["deviceId"]].ListOfMsgs.add(new Msg(data["deviceId"],data["message"],"received"));
          });
          print(data["deviceId"]+" herrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
        });
  }
}
