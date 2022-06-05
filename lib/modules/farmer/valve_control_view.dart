import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class ValveControlView extends TbPageWidget {
  final String customerId;
  final String farmType;

  ValveControlView(TbContext tbContext,
      {Key? key, required this.customerId, required this.farmType})
      : super(tbContext, key: key);

  @override
  _ValveControlViewState createState() =>
      _ValveControlViewState(customerId, farmType);
}

class _ValveControlViewState extends TbPageState<ValveControlView> {
  final String customerId;
  final String farmType;
  bool flag1 = false;
  int time = 0;
  late Future<List<Widget>> futureWidgets;

  _ValveControlViewState(this.customerId, this.farmType);

  @override
  void initState() {
    super.initState();
    futureWidgets = getValves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Widget>>(
        future: futureWidgets,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            List<Widget> widgets = snapshot.data;
            children = <Widget>[
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widgets.length,
                  itemBuilder: (context, index) {
                    return widgets[index];
                  }),
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Loading...'),
                    )
                  ],
                ),
              )
            ];
          }
          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  Future<List<Widget>> getValves() async {
    PageLink pageLink = PageLink(20);
    var pageData = await tbClient
        .getDeviceService()
        .getCustomerDevices(customerId, pageLink);
    var devices = pageData.data;
    List<Device> valves = [];
    for (final device in devices) {
      if (device.type == 'valve' && device.label == farmType) {
        valves.add(device);
      }
    }

    List<Widget> widgets = [];
    for (final valve in valves) {
      widgets.add(valveControl(
          'images/valve_control2_icon.png', valve.name, time, valve.id));
    }

    return widgets;
  }

  Future<void> sendData(DeviceId? deviceId, int time) async {
    var telemetryRequest = {'valve': 'on', 'time': time};
    var res = await tbClient
        .getAttributeService()
        .saveEntityTelemetry(deviceId!, 'TELEMETRY', telemetryRequest);
    print("res: $res");
  }

  Widget valveControl(String image, String text, int time, DeviceId? deviceId) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/valve_graph');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              child: Image(image: AssetImage(image)),
            ),
            Column(
              children: <Widget>[
                Text(
                  text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "Time: $time min",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Row(
                  children: <Widget>[
                    const Text(
                      'OFF',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Switch(
                        value: flag1,
                        onChanged: (bool? value) {
                          setState(() {
                            flag1 = value!;
                            if (flag1) {
                              sendData(deviceId, time);
                            }
                          });
                        }),
                    const Text(
                      'ON',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Valve control',
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
              ),
            ),
            const PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh'),
              ),
            ),
          ],
          onSelected: (dynamic menu) {
            if (menu == 1) {
              Navigator.pushNamed(context, '/notification');
            } else {
              setState(() {
                futureWidgets = getValves();
              });
            }
          },
        ),
      ],
    );
  }
}
