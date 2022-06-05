import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/modules/farmer/crops_list_view.dart';
import 'package:irrigation_app/modules/farmer/home_farmer_view.dart';
import 'package:irrigation_app/modules/farmer/weather_view.dart';

import '../../core/context/tb_context.dart';

class HomeFarmerRoutes extends TbRoutes {

  late var homeHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return HomeFarmerView(tbContext, customerId: '', farmType: '', );
  });

  late var cropsListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return CropsListView(tbContext, customerId: '');
  });

  late var weatherHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const WeatherView();
  });

  HomeFarmerRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/home_farmer", handler: homeHandler);
    router.define("/crops_list", handler: cropsListHandler);
    router.define("/weather", handler: weatherHandler);
  }

}