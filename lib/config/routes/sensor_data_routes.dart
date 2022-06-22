import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/modules/farmer/sensor_data_view.dart';
import 'package:irrigation_app/modules/farmer/sensor_graph_view.dart';


class SensorDataRoutes extends TbRoutes {

  late var sensorDataHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SensorDataView(tbContext, customerId: '', farmType: '',);
  });

  late var sensorGraphHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return SensorGraphView(tbContext, customerId: '',);
  });


  SensorDataRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/sensor_data", handler: sensorDataHandler);
    router.define("/sensor_graph", handler: sensorGraphHandler);
  }

}