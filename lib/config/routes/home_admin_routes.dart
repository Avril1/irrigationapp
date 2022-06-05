import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/router.dart';
import '../../modules/administrator/home_admin_view.dart';
import '../../core/context/tb_context.dart';

class HomeAdminRoutes extends TbRoutes {

  late var homeHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return HomeAdminView(tbContext);
  });

  HomeAdminRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/home_admin", handler: homeHandler);
  }

}