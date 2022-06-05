import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/modules/administrator/sensor_status_view.dart';
import 'package:irrigation_app/modules/administrator/system_status_view.dart';
import 'package:irrigation_app/modules/administrator/valve_status_view.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/core/context/tb_context.dart';

class SystemStatusRoutes extends TbRoutes {

  late var sensorStatusHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SensorStatusView(tbContext);
  });

  late var valveStatusHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return ValveStatusView(tbContext);
  });

  late var systemStatusHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SystemStatusView();
  });

  SystemStatusRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/sensor_status", handler: sensorStatusHandler);
    router.define("/valve_status", handler: valveStatusHandler);
    router.define("/system_status", handler: systemStatusHandler);
  }

}