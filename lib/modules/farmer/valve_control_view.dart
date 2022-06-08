import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/utils/device_attribute.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import 'home_farmer_view.dart';

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
  bool switched = false;
  String time = '0';
  late Future<List<Widget>> futureWidgets;
  DeviceAttribute? deviceAttribute;
  late DeviceId deviceID;
  late TelemetrySubscriber subscriber;

  _ValveControlViewState(this.customerId, this.farmType);

  @override
  void initState() {
    super.initState();
    futureWidgets = getValves();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
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
        ),
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeFarmerView(tbContext, customerId: customerId, farmType: farmType,)
        ));
        return false;
      },
    );
  }

  Future<void> getValveData(String deviceName) async{
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: deviceName);

    // Prepare list of queried device fields
    var deviceFields = <EntityKey>[
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime')
    ];

    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'valve'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'time'),
    ];

    var devicesQuery = EntityDataQuery(
        entityFilter: entityFilter,
        entityFields: deviceFields,
        latestValues: deviceTelemetry,
        pageLink: EntityDataPageLink(
            pageSize: 10,
            sortOrder: EntityDataSortOrder(
                key: EntityKey(
                    type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
                direction: EntityDataSortOrderDirection.DESC)));

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['valve','time'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService =  tbClient.getTelemetryService();

    subscriber = TelemetrySubscriber(telemetryService, [cmd]);

    subscriber.subscribe();


    subscriber.entityDataStream.listen((entityDataUpdate) {
      var data = entityDataUpdate.toString();
      if(data.contains('Page',17)){
        var index = data.indexOf('time');
        var index2 = data.indexOf('valve');
        var status = data.substring(index2 + 41, index2 + 43);
        if(status == 'on'){
          flag1 = true;
          time = data.substring(index + 40, index + 42);
          if(time.contains('}')){
            time = data.substring(index + 40, index + 41);
          }
        }else{
          flag1 = false;
          time = '0';
        }
      }else{}
    });
    await Future.delayed(const Duration(milliseconds: 300));
    subscriber.unsubscribe();
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
      if(!switched){
        await getValveData(valve.name);
      }

      deviceID = valve.id!;
      widgets.add(valveControl(
          'images/valve_control2_icon.png', valve.name, time, valve.id));
    }

    return widgets;
  }

  Future<void> sendData(DeviceId? deviceId, String status, String time) async {
    var telemetryRequest = {'valve': status, 'time': time};
    var res = await tbClient
        .getAttributeService()
        .saveEntityTelemetry(deviceId!, 'TELEMETRY', telemetryRequest);
  }

  Widget valveControl(
      String image, String text, String time, DeviceId? deviceId) {
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
                      onChanged: _changeState,
                    ),
                    const Text(
                      'ON',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    onPressed: _onPressed,
                    child: const Text('Add time')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onPressed() {
    TextEditingController _vc = TextEditingController();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AddTimeDialog(
            contentWidget: AddTimeDialogContent(
              okBtnTap: () {
                if(_vc.text.isNotEmpty){
                  time = _vc.text;
                }
                setState(() {
                  switched = true;
                  futureWidgets = getValves();
                });
              },
              cancelBtnTap: () {},
              vc: _vc,
              title: 'Please input time (< 100 minutes)',
            ),
          );
        });
  }

  void _changeState(bool value) {
    setState(() {
      flag1 = value;
      switched = true;
      if (flag1) {
        sendData(deviceID, 'on', time);
      }else{
        time = '0';
        sendData(deviceID, 'off', time);
      }
      futureWidgets = getValves();
    });
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
                switched = false;
                futureWidgets = getValves();
              });
            }
          },
        ),
      ],
    );
  }
}

class AddTimeDialog extends AlertDialog {
  AddTimeDialog({required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.blue, width: 3)),
        );
}

double btnHeight = 60;
double borderWidth = 2;

class AddTimeDialogContent extends StatefulWidget {
  String title;
  String cancelBtnTitle;
  String okBtnTitle;
  VoidCallback cancelBtnTap;
  VoidCallback okBtnTap;
  TextEditingController vc;

  AddTimeDialogContent(
      {required this.title,
      this.cancelBtnTitle = "Cancel",
      this.okBtnTitle = "Ok",
      required this.cancelBtnTap,
      required this.okBtnTap,
      required this.vc});

  @override
  _RenameDialogContentState createState() => _RenameDialogContentState();
}

class _RenameDialogContentState extends State<AddTimeDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        height: 200,
        width: 10000,
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  style: const TextStyle(color: Colors.grey),
                )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                style: const TextStyle(color: Colors.black87),
                controller: widget.vc,
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    )),
              ),
            ),
            Container(
              // color: Colors.red,
              height: btnHeight,
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Column(
                children: [
                  Container(
                    // 按钮上面的横线
                    width: double.infinity,
                    color: Colors.blue,
                    height: borderWidth,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                        onPressed: () {
                          widget.vc.text = "";
                          widget.cancelBtnTap();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.cancelBtnTitle,
                          style:
                              const TextStyle(fontSize: 22, color: Colors.blue),
                        ),
                      ),
                      Container(
                        // 按钮中间的竖线
                        width: borderWidth,
                        color: Colors.blue,
                        height: btnHeight - borderWidth - borderWidth,
                      ),
                      FlatButton(
                          onPressed: () {
                            widget.okBtnTap();
                            Navigator.of(context).pop();
                            widget.vc.text = "";
                          },
                          child: Text(
                            widget.okBtnTitle,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.blue),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
