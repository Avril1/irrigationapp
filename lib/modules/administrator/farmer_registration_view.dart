import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/modules/administrator/farmer_management_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import '../../core/context/tb_context.dart';
import '../../core/context/tb_context_widget.dart';

class FarmerRegistrationView extends TbPageWidget {
  late String customerID;
  late CustomerId customerId;
  FarmerRegistrationView(TbContext tbContext, {required this.customerID, required this.customerId}) : super(tbContext);

  @override
  _FarmerRegistrationViewState createState() => _FarmerRegistrationViewState(customerID, customerId);
}

class _FarmerRegistrationViewState extends TbPageState<FarmerRegistrationView> {

  late String customerID;
  late CustomerId customerId;
  static TextEditingController emailEditingController =
  new TextEditingController();

  _FarmerRegistrationViewState(this.customerID, this.customerId);

  Widget buildTextField(TextEditingController controller, String label, IconData icons ) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: new Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: controller,
            maxLength: 30,
            maxLines: 1,
            autocorrect: true,
            autofocus: false,
            obscureText: false,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 20, color: Colors.black),
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            enabled: true,
            decoration: InputDecoration(
                fillColor: Colors.blue[50],
                filled: true,
                labelText: label,
                prefixIcon: Icon(icons),
                contentPadding: EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21.11),
                  borderSide: BorderSide(color: Colors.black, width: 25.0),
                )),
          ),
        ],
      ),
    );
  }

  Widget signInButton() {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35),
      child: new SizedBox(
        height: 50,
        child: new RaisedButton(
          color: Colors.green,
          child: new Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            saveUser(emailEditingController.text);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => FarmerManagementView(tbContext, customerID: customerID, customerId: customerId,),
            ),);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Farmer registration'),
      ),
      body: new ListView(
        children: [
          buildTextField(emailEditingController, 'Email', Icons.email),
          signInButton(),
        ],
      ),
    );
  }

  Future<void> saveUser(String email) async{
    User user = User(email, Authority.CUSTOMER_USER);
    user.customerId = customerId;
    await tbClient.getUserService().saveUser(user);
  }

}