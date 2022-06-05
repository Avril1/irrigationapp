import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/modules/farmer/home_farmer_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class CropsListView extends TbPageWidget{
  final String customerId;
  CropsListView(TbContext tbContext, {Key? key, required this.customerId}) : super(tbContext, key: key);

  @override
  _CropsListViewState createState() => _CropsListViewState(customerId);
}

class _CropsListViewState extends TbPageState<CropsListView> {
  final String customerId;
  late Future<List<Widget>> futureWidget;

  _CropsListViewState(this.customerId);

  @override
  void initState() {
    super.initState();
    futureWidget = getCrops();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Crops list'),
      ),
      body: FutureBuilder<List<Widget>>(
        future: futureWidget,
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
    ), onWillPop: () async {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return false;
    },);
  }

  Future<List<Widget>> getCrops() async{
    PageLink pageLink = PageLink(20);
    PageData<Asset> pageData = await tbClient.getAssetService().getCustomerAssets(customerId, pageLink);
    List<Asset> assets = pageData.data;
    List<Widget> widgets = [];
    for(final asset in assets){
      if(asset.type == 'farm'){
        switch(asset.name){
          case 'Corn': widgets.add(cropList('images/corn_icon.png', 'corn')); break;
          case 'Tomato': widgets.add(cropList('images/tomate_icon.png', 'tomato')); break;
          case 'Wheat': widgets.add(cropList('images/wheat_icon.png', 'wheat')); break;
        }
      }
    }

    return widgets;
  }

  Widget cropList(String image, String farmType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                HomeFarmerView(tbContext, customerId: customerId, farmType: farmType,),
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              Image(
                image: AssetImage(image),
              ),
          ],
        ),
      ),
    );
  }

}
