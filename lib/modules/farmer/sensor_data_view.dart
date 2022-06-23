import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/modules/farmer/home_farmer_view.dart';
import 'package:irrigation_app/modules/farmer/sensor_graph_view.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorDataView extends TbPageWidget {
  final String customerId;
  final String farmType;
  SensorDataView(TbContext tbContext, {Key? key, required this.customerId, required this.farmType}) : super(tbContext, key: key);

  @override
  _SensorDataViewState createState() => _SensorDataViewState(customerId, farmType);
}

class _SensorDataViewState extends TbPageState<SensorDataView> {
  final String customerId;
  final String farmType;
  late TelemetrySubscriber subscriber;
  late Future<List<Widget>> futureWidgets;

  _SensorDataViewState(this.customerId, this.farmType);

  @override
  void initState() {
    super.initState();
    futureWidgets = getSensors();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sensor data'),
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
                    futureWidgets = getSensors();
                  });
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Widget>>(
          future: futureWidgets,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              List<Widget> widgets = snapshot.data;
              children = <Widget>[
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widgets.length,
                    itemBuilder: (context, index) {
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
            return ListView(
              children: children,
            );
          },
        ),
      ),
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeFarmerView(tbContext, customerId: customerId, farmType: farmType,)
        ));
        return false;
      },
    );
  }


  @override
  void dispose() {
    subscriber.unsubscribe();
    super.dispose();
  }

  Future<List<Widget>> getSensors() async {
    PageLink pageLink = PageLink(20);
    var pageData = await tbClient.getDeviceService().getCustomerDevices(
        customerId, pageLink);
    var devices = pageData.data;
    List<Device> sensors = [];
    for (final device in devices) {
      if (device.type == 'sensor' && device.label == farmType) {
        sensors.add(device);
      }
    }

    List<Widget> widgets = [];
    for (final sensor in sensors) {
      String humidity = await getSensorData(sensor.name);
      widgets.add(sensorData('images/sensor1_icon.png', sensor.name, humidity));
    }

    return widgets;
  }

  Future<String> getSensorData(String deviceName) async{
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: deviceName);

    // Prepare list of queried device fields
    var deviceFields = <EntityKey>[
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime')
    ];

    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'humidity')
    ];

    var devicesQuery = EntityDataQuery(
        entityFilter: entityFilter,
        entityFields: deviceFields,
        latestValues: deviceTelemetry,
        pageLink: EntityDataPageLink(
            pageSize: 10,
            sortOrder: EntityDataSortOrder(
                key: EntityKey(
                    type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
                direction: EntityDataSortOrderDirection.DESC)));

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['humidity'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService =  tbClient.getTelemetryService();

    subscriber = TelemetrySubscriber(telemetryService, [cmd]);

    subscriber.subscribe();

    String humidity = '';
    subscriber.entityDataStream.listen((entityDataUpdate) {
      var data = entityDataUpdate.toString();

      if(data.contains('Page',17)){
        var index = data.indexOf('humidity');
        humidity = (data.substring(index + 44, index + 46));
      } else if(data.contains('null', 17)){
        var index = data.length;
        humidity =  data.substring(index -8, index - 6);
      } else{
        humidity = 'null';
      }
    });
    await Future.delayed(const Duration(milliseconds: 300));
    return  humidity;
  }

  Widget sensorData(String image, String text, String data){
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SensorGraphView(tbContext, customerId: customerId, deviceName: text,),
          ));
    },
    child: Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:<Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            child: Image(image: AssetImage(image)),
          ),
          Column(
            children:<Widget>[
              Text(text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              Text('Humidity:  $data%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            ],
          )
        ],
      ),
    ),
    );
  }
  }
