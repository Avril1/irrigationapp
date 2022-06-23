import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/modules/farmer/notification_view.dart';
import 'package:irrigation_app/modules/farmer/valve_control_view.dart';
import 'package:irrigation_app/modules/farmer/valve_graph_view.dart';


class ValveControlRoutes extends TbRoutes {

  late var valveControlHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return ValveControlView(tbContext, customerId: '', farmType: '',);
  });

  late var valveGraphHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return ValveGraphView(tbContext,deviceName: '',);
  });

  late var notificationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return NotificationView(tbContext);
  });

  ValveControlRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/valve_control", handler: valveControlHandler);
    router.define("/notification", handler: notificationHandler);
    router.define("/valve_graph", handler: valveGraphHandler);
  }

}