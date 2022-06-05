import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';

class HomeAdminView extends TbPageWidget {
  HomeAdminView(TbContext tbContext, {Key? key}) : super(tbContext, key: key);

  @override
  _HomeAdminViewState createState() => _HomeAdminViewState();
}

class _HomeAdminViewState extends TbPageState<HomeAdminView> {
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
              onSelected: (dynamic menu) {
                if (menu == 1) {
                  logout();
                  Navigator.pushNamed(context, '/');
                }
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              sensorManagement(),
              farmerManagement(),
              systemStatus(),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
    );
  }

  Widget sensorManagement() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/sensor_management');
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(image: AssetImage('images/a_sensor_management_icon.png')),
          Text(
            'Sensor management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget farmerManagement() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/customer_management');
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(image: AssetImage('images/farmer_management_icon.png')),
          Text(
            'Customer management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget systemStatus() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/system_status');
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(image: AssetImage('images/system_status_icon.png')),
          Text(
            'System status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await tbClient.logout();
  }
}
