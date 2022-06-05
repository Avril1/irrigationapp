import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/modules/farmer/crops_list_view.dart';
import 'package:irrigation_app/modules/farmer/sensor_data_view.dart';
import 'package:irrigation_app/modules/farmer/valve_control_view.dart';

class HomeFarmerView extends TbPageWidget{
  final String customerId;
  final String farmType;
  HomeFarmerView(TbContext tbContext, {Key? key, required this.customerId, required this.farmType}) : super(tbContext,key: key);

  @override
  _HomeFarmerViewState createState() => _HomeFarmerViewState(customerId, farmType);
}

class _HomeFarmerViewState extends TbPageState<HomeFarmerView> {
  final String customerId;
  final String farmType;

  _HomeFarmerViewState(this.customerId, this.farmType);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                ),
              ),
            ],
            onSelected: (dynamic menu){
              if(menu == 1){
                logout();
                Navigator.pushNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          homeFarmer('images/weather_icon.png', 'forecast'),
          homeFarmer('images/sensor_data_icon.png', 'sensor data'),
          homeFarmer('images/valve_control_icon.png', 'valve control'),
        ],
    ),
        ),
      onWillPop: () async {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                CropsListView(tbContext, customerId: customerId),
            ));
        return false;
      },
    );
  }

  Widget homeFarmer(String image, String text) {
    return GestureDetector(
      onTap: () {
        if(text == 'forecast'){
          Navigator.pushNamed(context, '/weather');
        }else if(text == 'sensor data'){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  SensorDataView(tbContext, customerId: customerId, farmType: farmType,),
              ));
        }else{
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  ValveControlView(tbContext, customerId: customerId, farmType: farmType,),
              ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(image),
            ),
          ],
        ),
      ),
    );
  }

  void logout() async{
    await tbClient.logout();
  }
}
