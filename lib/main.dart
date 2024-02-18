import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:iot_switch/models/switch_btn.dart';
import 'package:provider/provider.dart';
// import 'package:alert/alert.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'components/slidable_Time_List_Item.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("uriBox");
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => SwitchProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'wantedSans',
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF62C500),
            onPrimary: Color(0xFF1C8B00),
            secondary: Color(0xFFE5E5E5),
            onSecondary: Color(0xFF868686),
            error: Color(0xFFD60000),
            onError: Color(0xFF690000),
            background: Color(0xFFFFFFFF),
            onBackground: Color(0xFF000000),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF000000),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStatePropertyAll(
                Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStatePropertyAll(
                Colors.black.withOpacity(0.1),
              ),
            ),
          ),
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box box = Hive.box("uriBox");
  late WebSocketChannel channel;
  late bool connected;
  late bool status;

  // connect to WebSocket
  void connectSocket({String strUri = "192.168.0.1:81"}) async {
    try {
      channel = WebSocketChannel.connect(Uri.parse("ws://$strUri"));
      channel.stream.listen(
        (message) {
          // Alert(message: message).show();
          // ignore: void_checks
          if (message == "connected") {
            connected = true;
            setState(() {
              if (message == "connected") {
                // channel.sink.add("poweron");
                connected = true; //message is "connected" from NodeMCU
              } else if (message == "poweron") {
                status = true;
              } else if (message == "poweroff") {
                status = false;
              }
            });
          }
        },
        onDone: () {
          //if WebSocket is disconnected
          // Alert(message: "Web socket is closed").show();
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          // Alert(message: error.toString()).show();
        },
      );
    } catch (error) {
      // Alert(message: error.toString()).show();
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected) {
      if (cmd != "poweron" && cmd != "poweroff") {
        // Alert(message: "Send the valid command").show();
      } else {
        // Alert(message: cmd).show();
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      connectSocket();
      // Alert(message: "Websocket is not connected.").show();
    }
  }

  @override
  void initState() {
    status = false;
    connected = false;
    if (status == false && box.get("uri") != null && box.get("uri") == "") {
      // uriController.text = box.get("uri");
      Future.delayed(Duration.zero, () async {
        connectSocket(
            strUri: box.get("uri")); //connect to WebSocket wth NodeMCU
      });
    }
    // uriController.text = "192.168.0.1:81";
    connectSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer(
            builder: (context, SwitchProvider provider, child) {
              Timer.periodic(const Duration(seconds: 1), (Timer t) {
                DateTime now = DateTime.now();
                DateTime useNow =
                    DateTime(0, 0, 0, now.hour, now.minute, now.second, 0, 0);
                if (provider.nextTime.hour == useNow.hour &&
                    provider.nextTime.minute == useNow.minute &&
                    provider.nextTime.second == useNow.second) {
                  setState(() {
                    if (status) {
                      //if ledStatus is true, then turn off the led
                      //if led is on, turn off
                      sendcmd("poweroff");
                      provider.statusSet(false);
                      status = false;
                      print("off");
                    } else {
                      //if ledStatus is false, then turn on the led
                      //if led is off, turn on
                      sendcmd("poweron");
                      provider.statusSet(true);
                      status = true;
                      print("on");
                    }
                  });
                  provider.statusNextTime();
                }
              });
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (status) {
                      //if ledStatus is true, then turn off the led
                      //if led is on, turn off
                      sendcmd("poweroff");
                      provider.statusSet(false);
                      status = false;
                    } else {
                      //if ledStatus is false, then turn on the led
                      //if led is off, turn on
                      sendcmd("poweron");
                      provider.statusSet(true);
                      status = true;
                    }
                  });
                },
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: status ? color.primary : color.secondary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () => _showDialog(context),
                        style: ButtonStyle(
                          shape: const MaterialStatePropertyAll<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                            ),
                          ),
                          overlayColor: MaterialStatePropertyAll(
                            Colors.black.withOpacity(0.1),
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            children: [
                              Text(
                                'Next Switching'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: status
                                      ? color.onPrimary
                                      : color.onSecondary,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                alignment: Alignment.center,
                                // width: 144.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: color.background,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40.0,
                                      child: Center(
                                        child: Text(
                                          '${(provider.nextTime.hour < 10) ? '0' : ''}${provider.nextTime.hour}',
                                          style: const TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ':',
                                      style: TextStyle(
                                        color: Color(0xFF4D4D4D),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40.0,
                                      child: Center(
                                        child: Text(
                                          '${(provider.nextTime.minute < 10) ? '0' : ''}${provider.nextTime.minute}',
                                          style: const TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        status ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: color.background,
                          fontSize: 64.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: color.background,
              ),
              height: size.height / 2,
              width: 400.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer(
                  builder: (context, SwitchProvider provider, Widget? child) =>
                      Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Switching Time'.toUpperCase(),
                            style: TextStyle(
                                color: color.onBackground,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              style: const ButtonStyle(
                                  padding:
                                      MaterialStatePropertyAll(EdgeInsets.zero),
                                  overlayColor: MaterialStatePropertyAll(
                                      Colors.transparent),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: color.onBackground,
                              )),
                        ],
                      ),
                      Expanded(
                        child: (provider.timeHistory.isNotEmpty)
                            ? ListView.builder(
                                itemCount: provider.timeHistory.length,
                                itemBuilder: (context, index) {
                                  return SlidableTimeListItem(
                                      provider: provider, index: index);
                                },
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add a New Switching Time",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: color.onSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.more_time_outlined,
                                    size: 32.0,
                                    color: color.onSecondary,
                                  )
                                ],
                              ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                  color.secondary,
                                ),
                                shape: MaterialStatePropertyAll<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                iconSize: const MaterialStatePropertyAll(24.0),
                                iconColor:
                                    MaterialStatePropertyAll(color.onSecondary),
                              ),
                              onPressed: () =>
                                  _showDialogSetting(context, provider),
                              icon: const Icon(
                                Icons.settings,
                                // color: color.onSecondary,
                              ),
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Expanded(
                              child: TextButton(
                                style: ButtonStyle(
                                  shape:
                                      MaterialStatePropertyAll<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStatePropertyAll(
                                      color.onBackground),
                                  overlayColor: MaterialStatePropertyAll(
                                    Colors.black.withOpacity(0.1),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    _openTimePicker(context, provider),
                                child: Text(
                                  'Add Switching Time',
                                  style: TextStyle(
                                    color: color.background,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  void _showDialogSetting(BuildContext context, SwitchProvider provider) {
    final color = Theme.of(context).colorScheme;
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: color.background,
                ),
                height: size.height / 2,
                width: 400.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Setting'.toUpperCase(),
                              style: TextStyle(
                                  color: color.onBackground,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  size: 28,
                                  color: color.onBackground,
                                )),
                          ],
                        ),
                      ),
                      const Expanded(
                          child: Center(
                        child: Icon(Icons.settings),
                      )),
                      TextButton(
                        style: ButtonStyle(
                          minimumSize:
                              const MaterialStatePropertyAll(Size(318.0, 48.0)),
                          shape: MaterialStatePropertyAll<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStatePropertyAll(color.onBackground),
                          overlayColor: MaterialStatePropertyAll(
                            Colors.black.withOpacity(0.1),
                          ),
                        ),
                        onPressed: null,
                        child: Text(
                          'Add Switching Time',
                          style: TextStyle(
                            color: color.background,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  void _openTimePicker(BuildContext context, SwitchProvider provider) {
    Size size = MediaQuery.of(context).size;
    BottomPicker.time(
      title: 'Switching Time',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
        color: Color(0xFF000000),
      ),
      titlePadding: const EdgeInsets.only(top: 12),
      titleAlignment: CrossAxisAlignment.start,
      // description: 'Pick up your switching time',
      // descriptionStyle: const TextStyle(
      //   fontSize: 14.0,
      //   color: Color(0xFF868686),
      // ),
      pickerTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black),
      onSubmit: (index) {
        provider.addTimeHistory(index);
        // print(index);
      },
      onClose: null,
      use24hFormat: true,
      initialTime: Time(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
      ),
      buttonContent: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Submit",
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 14.0),
          ),
        ],
      ),
      buttonWidth: size.width - 48,
      buttonPadding: 8,
      buttonStyle: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Color(0xFF000000),
      ),
    ).show(context);
  }
}
