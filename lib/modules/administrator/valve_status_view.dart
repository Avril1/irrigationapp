import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class ValveStatusView extends TbPageWidget{

  ValveStatusView(TbContext tbContext, {Key? key}) : super(tbContext, key: key);

  @override
  _ValveStatusViewState createState() => _ValveStatusViewState();
}

class _ValveStatusViewState extends TbPageState<ValveStatusView> {
  String? status;
  late Future<List<Widget>> futureWidgets;

  @override
  void initState() {
    super.initState();
    futureWidgets = getValves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve Status'),
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
                  futureWidgets = getValves();
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

  Future<List<Widget>> getValves() async {
    final pageLink = PageLink(20);
    PageData<Device> pageData = await tbClient.getDeviceService().getTenantDevices(pageLink);
    List<Device> devices = pageData.data;
    List<Device> valves = [];
    for(final device in devices){
      if(device.type == 'valve'){
        valves.add(device);
      }
    }

    List<Widget> widgets = [];
    for(final valve in valves){
      var deviceId = valve.id.toString();
      deviceId = deviceId.substring(14,50);
      var deviceCredential = await tbClient.getDeviceService().getDeviceCredentialsByDeviceId(deviceId);
      var deviceToken = deviceCredential?.credentialsId;
      await getSensorStatus(deviceToken!);
      widgets.add(valveStatus('images/valve_icon.png', valve.name, status!));
    }

    return widgets;
  }


  Widget valveStatus(String image, String text, String status){
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:<Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Image(image: AssetImage(image), height: 150, width: 150,),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children:<Widget>[
                Text(text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                Text('Status:  '+ status,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> getSensorStatus(String deviceToken) async {
    var sensorStatus = await getDeviceAttributes(deviceToken);
    status = sensorStatus!.client.status;
  }

  Future<DeviceAttributes?> getDeviceAttributes(String deviceToken,
      {RequestConfig? requestConfig}) async {
    return nullIfNotFound(
          (RequestConfig requestConfig) async {
        var response = await tbClient.get<Map<String, dynamic>>(
            '/api/v1/$deviceToken/attributes?clientKeys=status',
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
  String? status;

  DeviceStatus() : status = '';

  DeviceStatus.fromJson(Map<String, dynamic> json) : status = json['status'];
}