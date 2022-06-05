import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/modules/farmer/valve_control_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class AvailableValveListView extends TbPageWidget {
  final String customerId;
  AvailableValveListView(TbContext tbContext, {Key? key, required this.customerId}) : super(tbContext, key: key);

  @override
  _AvailableValveListViewState createState() => _AvailableValveListViewState(customerId);
}

class _AvailableValveListViewState extends TbPageState<AvailableValveListView> {

  final String customerId;
  List<Widget> sensors = [];
  List<String> sensorTypes = ['CKT-0178','kuman S10'];
  List<String> selectedSensors = [];

  _AvailableValveListViewState(this.customerId);
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
    tbClient.getDeviceService().getCustomerDevices(customerId, pageLink);
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
                  //         ValveControlView(tbContext, customerId: customerId,),
                  //     ));
                }),
          ],
        )
      ],
    );
  }


}
