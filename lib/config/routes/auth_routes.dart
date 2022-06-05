import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/core/auth/login/login_view.dart';
import 'package:irrigation_app/core/context/tb_context.dart';

import 'router.dart';

class AuthRoutes extends TbRoutes {

  late var loginHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return LoginView(tbContext);
  });

  AuthRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/", handler: loginHandler);
  }

}
