import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../../core/context/tb_context_widget.dart';
import 'farmer_management_view.dart';

class CustomerManagementView extends TbPageWidget {
  CustomerManagementView(TbContext tbContext, {Key? key})
      : super(tbContext, key: key);
  @override
  _CustomerManagementViewState createState() => _CustomerManagementViewState();
}

class _CustomerManagementViewState extends TbPageState<CustomerManagementView>{
  late  Future<List<Widget>> futureWidgets;

  @override
  void initState(){
    super.initState();
    futureWidgets = loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer management'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Refresh'),
                  ),
                ),
              ],
              onSelected: (dynamic menu){
                if(menu == 1){
                  setState(() {
                    futureWidgets = loadCustomers();
                  });
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Widget>>(
          future: futureWidgets,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
            List<Widget> children;
            if (snapshot.hasData) {
              List<Widget> widgets = snapshot.data;
              children = <Widget>[
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widgets.length,
                    itemBuilder: (context, index){
                      return widgets[index];
                    }),
              ];
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Loading customers'),
                      )
                    ],
                  ),
                )
              ];
            }
            return ListView(
                children: children,
            );
          },
        ),
        floatingActionButton: addCustomer(),
      ),
      onWillPop: () async {
        Navigator.pushNamed(context, '/home_admin');
        return false;
      },
    );
  }

  Widget customerManagement(String name, String id, CustomerId? customerId) {
    return GestureDetector(
      onTap: (){

        Navigator.push(context, MaterialPageRoute(
          builder: (context) => FarmerManagementView(tbContext,customerID: id,customerId: customerId!,),
        ),);
      },
        onLongPress: (){
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete'),
              content: const Text("Do you want to delete this customer?"),
              actions: <Widget>[
                TextButton(
                  onPressed: (){
                    deleteCustomer(id);
                    setState(() {
                      futureWidgets = loadCustomers();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed:(){
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        )
    );
  }

  Widget addCustomer() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/customer_registration');
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add),
    );
  }

   Future<List<Widget>> loadCustomers() async{
    final pageLink = PageLink(20);
    PageData<Customer> pageData = await tbClient.getCustomerService().getCustomers(pageLink);
    List<Customer> customers = pageData.data;
    List<Widget> widgets = [];
    for(final customer in customers){
      String customerID = customer.id.toString();
      customerID = customerID.substring(16,52);
      widgets.add(customerManagement(customer.title,customerID, customer.id ));
    }
    return widgets;
  }

  Future<void> deleteCustomer(String customerId) async{
    await tbClient.getCustomerService().deleteCustomer(customerId);
  }

}
