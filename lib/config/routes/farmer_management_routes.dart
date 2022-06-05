import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/modules/administrator/customer_management_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../../modules/administrator/customer_management_view.dart';
import '../../modules/administrator/farmer_activation_view.dart';
import '../../modules/administrator/customer_registration_view.dart';
import '../../modules/administrator/farmer_management_view.dart';
import '../../modules/administrator/farmer_registration_view.dart';

class FarmerManagementRoutes extends TbRoutes {

  late var customerManagementHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return CustomerManagementView(tbContext);
  });

  late var customerRegistrationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return CustomerRegistrationView(tbContext);
  });

  late var farmerManagementHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return FarmerManagementView(tbContext, customerID: '', customerId: CustomerId(''),);
  });

  late var farmerRegistrationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return FarmerRegistrationView(tbContext, customerID: '', customerId: CustomerId(''),);
  });

  late var farmerDetailsHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return FarmerActivationView(tbContext,userId: '',);
  });

  FarmerManagementRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/customer_management", handler: customerManagementHandler);
    router.define("/customer_registration", handler: customerRegistrationHandler);
    router.define("/farmer_management", handler: farmerManagementHandler);
    router.define("/farmer_registration", handler: farmerRegistrationHandler);
    router.define("/farmer_details", handler: farmerDetailsHandler);
  }

}