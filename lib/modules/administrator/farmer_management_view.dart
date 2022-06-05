import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/modules/administrator/farmer_registration_view.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import '../../core/context/tb_context_widget.dart';
import 'farmer_activation_view.dart';


class FarmerManagementView extends TbPageWidget {
  late String customerID;
  late CustomerId customerId;
  FarmerManagementView(TbContext tbContext,{required this.customerID,required this.customerId})
      : super(tbContext);
  @override
  _FarmerManagementViewState createState() => _FarmerManagementViewState(customerID, customerId);
}

class _FarmerManagementViewState extends TbPageState<FarmerManagementView>{
  late  Future<List<Widget>> futureWidgets;
  final String customerID;
  late CustomerId customerId;

  _FarmerManagementViewState(this.customerID, this.customerId);

  @override
  void initState(){
    super.initState();
    futureWidgets = loadFarmers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farmer management'),
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
                    futureWidgets = loadFarmers();
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
                        child: Text('Loading...'),
                      )
                    ],
                  ),
                )
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: children,
              ),
            );
          },
        ),
        floatingActionButton: addFarmer(),
      ),
      onWillPop: () async {
        Navigator.pushNamed(context, '/customer_management');
        return false;
      },
    );
  }

  Widget farmerManagement(String image, String name, String id) {
    return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => FarmerActivationView(tbContext,userId: id,),
          ),);
        },
        onLongPress: (){
          showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete'),
              content: const Text("Do you want to delete this user?"),
              actions: <Widget>[
                TextButton(
                  onPressed: (){
                    deleteUser(id);
                    setState(() {
                      futureWidgets = loadFarmers();
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
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(0,0,8,0),
                child: Image(
                  image: AssetImage(image), height: 40, width: 40,
                ),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        )
    );
  }

  Widget addFarmer() {
    return new FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => FarmerRegistrationView(tbContext, customerId: customerId, customerID: customerID,),
        ),);
      },
      backgroundColor: Colors.green,
      child: const Icon(Icons.add),
    );
  }

  Future<List<Widget>> loadFarmers() async{
    final pageLink = PageLink(20);
    PageData<User> pageData = await tbClient.getUserService().getCustomerUsers(customerID, pageLink);
    List<User> users = pageData.data;
    List<Widget> widgets = [];
    for(final user in users){
      String userID = user.id.toString();
      userID = userID.substring(12,48);
      widgets.add(farmerManagement('images/profile_photo1_icon.png', user.getName(),userID ));
    }
    return widgets;
  }

  Future<void> deleteUser(String userId) async{
    await tbClient.getUserService().deleteUser(userId);
  }

}
