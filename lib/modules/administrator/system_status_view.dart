import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SystemStatusView extends StatefulWidget {
  const SystemStatusView({Key? key}) : super(key: key);

  @override
  _SystemStatusViewState createState() => _SystemStatusViewState();
}

class _SystemStatusViewState extends State<SystemStatusView> {

  Widget systemStatus(String image, String text){
    return GestureDetector(
      onTap: () {
        if(text == 'Valve status') {
         Navigator.pushNamed(context, '/valve_status');
        }else{
          Navigator.pushNamed(context, '/sensor_status');
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(70, 0, 70, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Image(image: AssetImage(image)),
            ),
            Text(text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status'),
      ),
      body: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            systemStatus('images/valve_icon.png','Valve status'),
            systemStatus('images/sensor_status.png','Sensor status'),
          ],),
    ),
    );
  }
}
