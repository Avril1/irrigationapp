import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorManagementView extends TbPageWidget {
  // final String sensorType;
  // final String sensorName;
  SensorManagementView(TbContext tbContext, {Key? key})
      : super(tbContext, key: key);

  @override
  _SensorManagementViewState createState() => _SensorManagementViewState();
}

class _SensorManagementViewState extends TbPageState<SensorManagementView> {
  //final String sensorType;
  //final String sensorName;
  // _SensorManagementViewState(this.sensorType, this.sensorName);
  late Future<List<Widget>> sensorWidgets;

  @override
  void initState() {
    super.initState();
    sensorWidgets = loadSensors();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sensor management'),
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
                    sensorWidgets = loadSensors();
                  });
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Widget>>(
          future: sensorWidgets,
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
        floatingActionButton: addSensor(),
      ),
      onWillPop: () async {
        Navigator.pushNamed(context, '/home_admin');
        return false;
      },
    );
  }

  Widget sensorManagement(String name, String label, String deviceId) {
    return GestureDetector(
    onLongPress: (){
    showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => AlertDialog(
    title: const Text('Delete'),
    content: const Text("Do you want to delete this device?"),
    actions: <Widget>[
    TextButton(
    onPressed: (){
    deleteSensor(deviceId);
    setState(() {
    sensorWidgets = loadSensors();
    });
    Navigator.pop(context);
    },
    child: const Text('Delete'),
    ),
    TextButton(
    onPressed:(){
    Navigator.pop(context);
    },
    child: const Text('Cancel'),
    ),
    ],
    ),
    );
    },
    child:Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(fontSize: 18),
            maxLines: 2,
          ),
          Text(
            ' ($label)',
            style: const TextStyle(fontSize: 18),
            maxLines: 2,
          ),
        ],
      ),
    ),
    );
  }

  Widget addSensor() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/sensor_registration');
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add),
    );
  }

  Future<List<Widget>> loadSensors() async {
    final pageLink = PageLink(20);
    PageData<Device> pageData =
        await tbClient.getDeviceService().getTenantDevices(pageLink);
    List<Device> sensors = pageData.data;
    List<Widget> widgets = [];
    for (final sensor in sensors) {
       String sensorID = sensor.id.toString();
       sensorID = sensorID.substring(14,50);
      widgets.add(sensorManagement(sensor.name, sensor.label.toString(), sensorID));
    }
    return widgets;
  }

  Future<void> deleteSensor(String deviceId) async{
    await tbClient.getDeviceService().deleteDevice(deviceId);
  }

}
