
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorGraphView extends TbPageWidget {
  final String customerId;
  final String deviceName;

  SensorGraphView(TbContext tbContext, {Key? key, required this.customerId, required this.deviceName}) : super(tbContext, key: key);

  @override
  _SensorGraphViewState createState() => _SensorGraphViewState(customerId,deviceName);
}

class _SensorGraphViewState extends TbPageState<SensorGraphView> {
  final String customerId;
  final String deviceName;
  late Future<Widget> graphWidget;

  _SensorGraphViewState(this.customerId, this.deviceName);

  @override
  void initState() {
    super.initState();
    graphWidget = getSensorGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor graph'),
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          FutureBuilder<Widget>(
            future: graphWidget,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              Widget widget;
              if (snapshot.hasData) {
                widget = snapshot.data;
              } else if (snapshot.hasError) {
                widget = ListView(
                  children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]);
              } else {
                widget = Container(
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
                  );
              }
              return widget;
            },
          ),
        ],
      ),
    );
  }

  Future<Widget> getSensorGraph() async{
    var sensorData = await getSensorData();
    List<String> hourList = sensorData.keys.elementAt(0);
    List<FlSpot>? spots = sensorData.values.elementAt(0);
    return _sensorLineChart(spots, hourList);
  }

  Future<Map<List<String>,List<FlSpot>?>> getSensorData() async{
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
    var timeWindow = const Duration(hours: 12).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['humidity'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService =  tbClient.getTelemetryService();

    var subscriber = TelemetrySubscriber(telemetryService, [cmd]);

    subscriber.subscribe();

    List<FlSpot> spots = [];
    List<String> hourList = [];
    subscriber.entityDataStream.listen((entityDataUpdate){
      var data = entityDataUpdate.data;
      if(data.toString().contains('timeseries')){
        var tsValues = data!.data.elementAt(0).timeseries.values.elementAt(0);
        for(final tsValue in tsValues){
          var hour = DateTime.fromMillisecondsSinceEpoch(tsValue.ts).hour;
          var value = tsValue.value;
          if(!hourList.contains('$hour')){
            hourList.add(hour.toString());
            double i = matchHour(hour).toDouble();
            spots.add(FlSpot(i, double.parse(value!)));
            i++;
          }
        }
      }else{}
    });
    await Future.delayed(const Duration(milliseconds: 300));

    Map<List<String>,List<FlSpot>?> map = {hourList : spots};

    subscriber.unsubscribe();

    return map;
  }

  int matchHour(int hour){
    final currentTime = DateTime.now().hour;
    if(currentTime == hour){
      return 12;
    }else if(currentTime - 1 == hour){
      return 11;
    }else if(currentTime - 2 == hour){
      return 10;
    }else if(currentTime - 3 == hour){
      return 9;
    }else if(currentTime - 4 == hour){
      return 8;
    }else if(currentTime - 5 == hour){
      return 7;
    }else if(currentTime - 6 == hour){
      return 6;
    }else if(currentTime - 7 == hour){
      return 5;
    }else if(currentTime - 8 == hour){
      return 4;
    }else if(currentTime - 9 == hour){
      return 3;
    }else if(currentTime - 10 == hour){
      return 2;
    }else if(currentTime - 11 == hour){
      return 1;
    }
    return 0;
  }

  Widget _sensorLineChart(List<FlSpot>? spots, List<String> hourList) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
               Padding(padding: const EdgeInsets.all(8.0),
              child: Text(
                deviceName,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              ),
              Expanded(
                    child: LineChart(
                    LineChartData(
                        minY: 0,
                        maxY: 100,
                        minX: 1,
                        maxX: 12,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Hours',
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta){
                                const style = TextStyle(
                                  fontSize: 12,
                                );
                                Widget text;
                                var currentTime = DateTime.now().hour;
                                switch (value.toInt()) {
                                  case 12:
                                    text = Text('$currentTime:00', style: style);
                                    break;
                                  case 11:
                                    if(currentTime == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 1}:00', style: style);
                                    }
                                    break;
                                  case 10:
                                    if((currentTime - 1)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 2}:00', style: style);
                                    }
                                    break;
                                  case 9:
                                    if((currentTime - 2)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 3}:00', style: style);
                                    }
                                    break;
                                  case 8:
                                    if((currentTime - 3)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 4}:00', style: style);
                                    }
                                    break;
                                  case 7:
                                    if((currentTime - 4)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 5}:00', style: style);
                                    }
                                    break;
                                  case 6:
                                    if((currentTime - 5)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 6}:00', style: style);
                                    }
                                    break;
                                  case 5:
                                    if((currentTime - 6)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 7}:00', style: style);
                                    }
                                    break;
                                  case 4:
                                    if((currentTime - 7)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 8}:00', style: style);
                                    }
                                    break;
                                  case 3:
                                    if((currentTime - 8)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 9}:00', style: style);
                                    }
                                    break;
                                  case 2:
                                    if((currentTime - 9)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 10}:00', style: style);
                                    }
                                    break;
                                  case 1:
                                    if((currentTime - 10)  == 0){
                                      text = const Text('23:00', style: style);
                                    }else{
                                      text = Text('${currentTime - 11}:00', style: style);
                                    }
                                    break;
                                  default:
                                    text = const Text('');
                                    break;
                                }

                                return Padding(child: text, padding: const EdgeInsets.only(top: 10.0));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Humidity',
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                              isCurved: true,
                              color: Colors.blue,
                              spots: spots),
                        ]),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

}
