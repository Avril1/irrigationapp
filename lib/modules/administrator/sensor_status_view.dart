import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorStatusView extends TbPageWidget {
  SensorStatusView(TbContext tbContext, {Key? key})
      : super(tbContext, key: key);

  @override
  _SensorStatusViewState createState() => _SensorStatusViewState();
}

class _SensorStatusViewState extends TbPageState<SensorStatusView> {
  String? active;
  late Future<List<Widget>> futureWidgets;

  @override
  void initState() {
    super.initState();
    futureWidgets = getSensors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Status'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                ),
              ),
            ],
            onSelected: (dynamic menu){
              if(menu == 1){
                setState(() {
                  futureWidgets = getSensors();
                });
              }
            },
          ),
        ],
      ),
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

  Future<List<Widget>> getSensors() async {
    final pageLink = PageLink(20);
    PageData<Device> pageData = await tbClient.getDeviceService().getTenantDevices(pageLink);
    List<Device> devices = pageData.data;
    List<Device> sensors = [];
    for(final device in devices){
      if(device.type == 'sensor'){
        sensors.add(device);
      }
    }

    List<Widget> widgets = [];
    for(final sensor in sensors){
      var deviceId = sensor.id.toString();
      deviceId = deviceId.substring(14,50);
      var deviceCredential = await tbClient.getDeviceService().getDeviceCredentialsByDeviceId(deviceId);
      var deviceToken = deviceCredential?.credentialsId;
      await getSensorStatus(deviceToken!);
      widgets.add(sensorStatus('images/sensor1_icon.png', sensor.name, active!));
    }

    return widgets;
  }

  Widget sensorStatus(String image, String text, String status) {
    return Container(
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                    'Active:  $status',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> getSensorStatus(String deviceToken) async {
    var sensorStatus = await getDeviceAttributes(deviceToken);
    active = sensorStatus!.client.active;
  }

  Future<DeviceAttributes?> getDeviceAttributes(String deviceToken,
      {RequestConfig? requestConfig}) async {
    return nullIfNotFound(
      (RequestConfig requestConfig) async {
        var response = await tbClient.get<Map<String, dynamic>>(
            '/api/v1/$deviceToken/attributes?clientKeys=active',
            options: defaultHttpOptionsFromConfig(requestConfig));
        return response.data != null
            ? DeviceAttributes.fromJson(response.data!)
            : null;
      },
      requestConfig: requestConfig,
    );
  }
}

class DeviceAttributes {
  DeviceStatus client;

  DeviceAttributes.fromJson(Map<String, dynamic> json)
      : client = DeviceStatus.fromJson(json['client']);
}

class DeviceStatus {
  String? active;

  DeviceStatus() : active = '';

  DeviceStatus.fromJson(Map<String, dynamic> json) : active = json['active'];
}
