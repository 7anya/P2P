import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:p2p/ChatPage.dart';
import './Msg.dart';
import 'Global.dart';
import 'Conversation.dart';

void main() {
  runApp(MyApp());
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
      builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
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

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
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
          title: Text("Available Devices"),
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              final device = Global.devices[index];
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChatPage(device);
                                },
                              ),
                            );
                          },
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
                            child: Center(
                                child: Text(Global.messages[index].msgtype +
                                    ":" +
                                    Global.messages[index].deviceId +
                                    " " +
                                    Global.messages[index].message)),
                          );
                        }),
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

  int getItemCount() {
    return Global.devices.length;
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

  void startBrowsing() async {
    await Global.nearbyService.stopBrowsingForPeers();
    await Global.nearbyService.startBrowsingForPeers();
  }

  void startAdvertising() async {
    await Global.nearbyService.stopAdvertisingPeer();
    await Global.nearbyService.startAdvertisingPeer();
  }

  void init() async {
    Global.nearbyService = NearbyService();
    await Global.nearbyService.init(
        serviceType: 'mp-connection',
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            startAdvertising();
            startBrowsing();
          }
        });
    Global.subscription =
        Global.nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList?.forEach((element) {
        print(
            "deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");
        if (element.state == 'SessionState.connected')
          Global.conversations[element.deviceId] = new Conversation();
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
      setState(() {
        Global.messages
            .add(new Msg(data["deviceId"], data["message"], "received"));
        Global.conversations[data["deviceId"]].ListOfMsgs
            .add(new Msg(data["deviceId"], data["message"], "received"));
      });
    });
  }
}
