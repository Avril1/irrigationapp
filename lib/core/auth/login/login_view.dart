import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/modules/farmer/crops_list_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../../context/tb_context.dart';
import '../../context/tb_context_widget.dart';

class LoginView extends TbPageWidget {
  LoginView(TbContext tbContext) : super(tbContext);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends TbPageState<LoginView> {
  static String account = '';
  static String password = '';

  static TextEditingController accountEditingController =
      TextEditingController();
  static TextEditingController passwordEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    initTbContext();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log in'),
        ),
        body: ListView(
          children: [
            textSection(),
            loginButton(),
          ],
        ),
      ),
      onWillPop: () async {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
    );
  }

  static Widget buildAccountTextField(TextEditingController controller) {
    return TextField(
      keyboardType: TextInputType.text,
      controller: controller,
      maxLines: 1,
      autocorrect: true,
      autofocus: false,
      obscureText: false,
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 20, color: Colors.black),
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      enabled: true,
      decoration: InputDecoration(
          fillColor: Colors.blue[50],
          filled: true,
          labelText: 'Account',
          prefixIcon: const Icon(Icons.person),
          contentPadding: const EdgeInsets.all(5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(21.11),
            borderSide: const BorderSide(color: Colors.black, width: 25.0),
          )),
    );
  }

  static Widget buildPasswordTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        keyboardType: TextInputType.visiblePassword,
        controller: controller,
        maxLines: 1,
        autocorrect: true,
        autofocus: false,
        obscureText: true,
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 20, color: Colors.black),
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        enabled: true,
        decoration: InputDecoration(
            fillColor: Colors.blue[50],
            filled: true,
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            contentPadding: const EdgeInsets.all(5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(21.11),
              borderSide: const BorderSide(color: Colors.black, width: 25.0),
            )),
      ),
    );
  }

  Widget textSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildAccountTextField(accountEditingController),
          buildPasswordTextField(passwordEditingController),
        ],
      ),
    );
  }

  Widget loginButton() {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35),
      child: SizedBox(
        height: 50,
        child: RaisedButton(
          color: Colors.green,
          child: const Text(
            'Log in',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            account = accountEditingController.text;
            password = passwordEditingController.text;
            tbLogin(account, password);
          },
        ),
      ),
    );
  }

  Future<void> tbLogin(String account, String password) async {
    try {
      // Perform login with default Tenant Administrator credentials
      await tbClient.login(LoginRequest(account, password));

      if (tbClient.isAuthenticated()) {
        if (tbClient.isTenantAdmin()) {
          Navigator.pushNamed(context, '/home_admin');
        } else {
          AuthUser? user = tbClient.getAuthUser();
          String? customerId = user?.customerId.toString();

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CropsListView(
              tbContext,
              customerId: customerId!,
            );
          }));
        }
      } else {
        showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Hint'),
            content: const Text("Account o password is wrong"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }
}
