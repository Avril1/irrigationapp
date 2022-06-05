import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/farmer_management_routes.dart';
import 'package:irrigation_app/config/routes/home_farmer_routs.dart';
import 'package:irrigation_app/config/routes/home_admin_routes.dart';
import 'package:irrigation_app/config/routes/sensor_data_routes.dart';
import 'package:irrigation_app/config/routes/sensor_management_routes.dart';
import 'package:irrigation_app/config/routes/system_status_routes.dart';
import 'package:irrigation_app/config/routes/valve_control_routes.dart';

import 'auth_routes.dart';
import '../../core/context/tb_context.dart';


class ThingsboardAppRouter {
  final router = FluroRouter();
  late final _tbContext = TbContext(router);

  ThingsboardAppRouter() {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      var settings = context!.settings;
      return Scaffold(
        appBar: AppBar(
            title: Text('Not Found')
        ),
        body: Center(
            child: Text('Route not defined: ${settings!.name}')
        ),
      );
    });
    //InitRoutes(_tbContext).registerRoutes();
    AuthRoutes(_tbContext).registerRoutes();
    FarmerManagementRoutes(_tbContext).registerRoutes();
    HomeAdminRoutes(_tbContext).registerRoutes();
    SensorManagementRoutes(_tbContext).registerRoutes();
    SystemStatusRoutes(_tbContext).registerRoutes();
    HomeFarmerRoutes(_tbContext).registerRoutes();
    SensorDataRoutes(_tbContext).registerRoutes();
    ValveControlRoutes(_tbContext).registerRoutes();

  }

  TbContext get tbContext => _tbContext;
}

abstract class TbRoutes {

  final TbContext _tbContext;

  TbRoutes(this._tbContext);

  void registerRoutes() {
    doRegisterRoutes(_tbContext.router);
  }

  void doRegisterRoutes(FluroRouter router);

  TbContext get tbContext => _tbContext;

}
