import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/modules/administrator/sensor_management_view.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorRegistrationView extends TbPageWidget {
  SensorRegistrationView(TbContext tbContext, {Key? key}) : super(tbContext, key: key);

  @override
  _SensorRegistrationViewState createState() => _SensorRegistrationViewState();
}

class _SensorRegistrationViewState extends TbPageState<SensorRegistrationView> {

  late String name, type;
  static TextEditingController sensorNameEditingController = TextEditingController();
  static TextEditingController sensorTypeEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor registration'),
      ),
      body: ListView(
        children: [
          buildTextField(sensorNameEditingController, 'Sensor name', Icons.text_snippet),
          buildTextField(sensorTypeEditingController, 'Sensor type',Icons.text_snippet),
          signInButton(),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icons ) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.text,
            controller: controller,
            maxLength: 30,
            maxLines: 1,
            autocorrect: true,
            autofocus: false,
            obscureText: false,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            enabled: true,
            decoration: InputDecoration(
                fillColor: Colors.blue[50],
                filled: true,
                labelText: label,
                prefixIcon: Icon(icons),
                contentPadding: const EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21.11),
                  borderSide: const BorderSide(color: Colors.black, width: 25.0),
                )),
          ),
        ],
      ),
    );
  }

  Widget signInButton() {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35),
      child: SizedBox(
        height: 50,
        child: RaisedButton(
          color: Colors.green,
          child: const Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            saveSensor();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) =>
                     SensorManagementView(tbContext),
              ),);
          },
        ),
      ),
    );
  }

  Future<void> saveSensor() async {
    name = sensorNameEditingController.text;
    type = sensorTypeEditingController.text;

    Device device = Device(name, type);
    tbClient.getDeviceService().saveDevice(device);
  }


}
