import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../farmer/sensor_data_view.dart';

class AvailableSensorListView extends TbPageWidget {
  final String customerId;
  AvailableSensorListView(TbContext tbContext, {Key? key, required this.customerId}) : super(tbContext, key: key);

  @override
  _AvailableSensorListViewState createState() => _AvailableSensorListViewState(customerId);
}

class _AvailableSensorListViewState extends TbPageState<AvailableSensorListView> {

  final String customerId;
  List<Widget> sensors = [];
  List<String> sensorTypes = ['CKT-0178','kuman S10'];
  List<String> selectedSensors = [];

  _AvailableSensorListViewState(this.customerId);
  @override
  Widget build(BuildContext context) {
    sensors.add(sensorList('images/sensor1_icon.png', sensorTypes[0]));
    sensors.add(sensorList('images/sensor2_icon.png', sensorTypes[1]));

    return Scaffold(
      appBar: getAppBar(),
      body:  ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: sensors[index],
            onLongPress: (){
              if(!selectedSensors.contains(sensorTypes[index])){
                setState(() {
                  selectedSensors.add(sensorTypes[index]);
                });
              }
            },
          );
        },
      ),
    );
  }

  Future<void> getSensors() async{
    PageLink pageLink = PageLink(20);
    PageData<Device> pageData = await tbClient.getDeviceService().getCustomerDevices(customerId, pageLink);
    List<Device> devices = pageData.data;
    List<Device> sensors = [];

    for(final device in devices){
      if(device.type == 'sensor'){
        sensors.add(device);
      }
    }


  }

  Widget sensorList(String assetName, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0,0,12,0),
            child: Image(
              image: AssetImage(assetName),
            ),
          ),
              Text(
                type,
                style: const TextStyle(fontSize: 18),
                maxLines: 2,
              ),
        ],
      ),
    );
  }

  PreferredSizeWidget getAppBar() {
    return AppBar(
      title: Text(selectedSensors.isEmpty
          ? "Sensor list"
          : "Select sensor"),
      actions:<Widget>[
        selectedSensors.isEmpty
        ? const Text('')
        :
        Row(
        children: [
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: (){
            selectedSensors.removeRange(0, selectedSensors.length-1);
          }
          , ),
        IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: (){
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) =>
              //         SensorDataView(tbContext, customerId: customerId,),
              //     ));
            }),
        ],
        )
      ],
    );
  }


}
