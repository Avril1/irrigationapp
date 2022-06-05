import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/modules/administrator/sensor_management_view.dart';
import 'package:irrigation_app/modules/administrator/sensor_registration_view.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/core/context/tb_context.dart';


class SensorManagementRoutes extends TbRoutes {

  late var sensorManagementHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SensorManagementView(tbContext);
  });

  late var sensorRegistrationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SensorRegistrationView(tbContext);
  });

  SensorManagementRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/sensor_management", handler: sensorManagementHandler);
    router.define("/sensor_registration", handler: sensorRegistrationHandler);
  }

}