import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../../core/context/tb_context.dart';
import '../../core/context/tb_context_widget.dart';
import 'customer_management_view.dart';

class CustomerRegistrationView extends TbPageWidget {
  CustomerRegistrationView(TbContext tbContext, {Key? key}) : super(tbContext,key: key);

  @override
  _CustomerRegistrationViewState createState() => _CustomerRegistrationViewState();
}

class _CustomerRegistrationViewState extends TbPageState<CustomerRegistrationView> {

  static TextEditingController usernameEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer registration'),
      ),
      body: ListView(
        children: [
          buildTextField(usernameEditingController, 'Username', Icons.person),
          signInButton(),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icons ) {
    return Container(
        padding: const EdgeInsets.all(15),
      child: Column(
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.text,
          controller: controller,
          maxLength: 30,
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
              labelText: label,
              prefixIcon: Icon(icons),
              contentPadding: const EdgeInsets.all(5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(21.11),
                borderSide: const BorderSide(color: Colors.black, width: 25.0),
              )),
        ),
      ],
      ),
    );
  }

  Widget signInButton() {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35),
      child: SizedBox(
        height: 50,
        child: RaisedButton(
          color: Colors.green,
          child: const Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
              saveCustomer(usernameEditingController.text);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CustomerManagementView(tbContext),
              ),);
          },
        ),
      ),
    );
  }

  Future<void> saveCustomer(String name) async{
    Customer customer = Customer(name);
    await tbClient.getCustomerService().saveCustomer(customer);
  }

}