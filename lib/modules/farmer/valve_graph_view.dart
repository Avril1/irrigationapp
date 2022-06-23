import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class ValveGraphView extends TbPageWidget {
  final String deviceName;
  ValveGraphView(TbContext tbContext, {Key? key, required this.deviceName})
      : super(tbContext, key: key);

  @override
  _ValveGraphViewState createState() => _ValveGraphViewState(deviceName);
}

class _ValveGraphViewState extends TbPageState<ValveGraphView> {
  final String deviceName;
  late Future<Widget> graphWidget;

  _ValveGraphViewState(this.deviceName);

  @override
  void initState() {
    super.initState();
    graphWidget = _getValveGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve graph'),
      ),
      body: FutureBuilder<Widget>(
        future: graphWidget,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = snapshot.data;
          } else if (snapshot.hasError) {
            widget = ListView(children: [
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
    );
  }

  Future<Widget> _getValveGraph() async {
    var map = await getValveData();
    var irrigationTimeList = map.values.elementAt(0);
    var dateList = map.keys.toList().elementAt(0);

    var currentDay = DateTime.now().day;
    var currentMonth = DateTime.now().month;
    int n = dateList.length;
    for (int j = 0; j < n; j++) {

    }
    List<SubscriberSeries> data = [];
    for (int i = 6; i >= 0; i--) {
            if ((currentDay - i) > 0) {
              print('>0');
            data.add(SubscriberSeries(
                date: '${currentDay - i}/$currentMonth',
                minutes: matchDate(dateList,'${currentDay - i}/$currentMonth') == -1 ? 0 :irrigationTimeList.elementAt(matchDate(dateList,'${currentDay - i}/$currentMonth')),
                barColor: charts.ColorUtil.fromDartColor(Colors.blue)));
          } else {
            var n = i - currentDay;
            var days = getDays(currentMonth);
            if (currentMonth == 1) {
              data.add(SubscriberSeries(
                  date: '${days - n}/12',
                  minutes: matchDate(dateList,'${days - n}/12') == -1 ? 0 :irrigationTimeList.elementAt(matchDate(dateList,'${days - n}/12')),
                  barColor: charts.ColorUtil.fromDartColor(Colors.blue)));
            } else {
              data.add(SubscriberSeries(
                  date: '${days - n}/${currentMonth - 1}',
                  minutes: matchDate(dateList,'${days - n}/${currentMonth - 1}') == -1 ? 0: irrigationTimeList.elementAt(matchDate(dateList,'${days - n}/${currentMonth - 1}')),
                  barColor: charts.ColorUtil.fromDartColor(Colors.blue)));
            }
      }
    }

    List<charts.Series<SubscriberSeries, String>> series = [
      charts.Series(
        id: "Subscribers",
        data: data,
        domainFn: (SubscriberSeries series, _) => series.date,
        measureFn: (SubscriberSeries series, _) => series.minutes,
        colorFn: (SubscriberSeries series, _) => series.barColor,
      )
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                deviceName,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  behaviors: [
                    charts.ChartTitle('Date',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleStyleSpec:
                            const common.TextStyleSpec(fontSize: 18),
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea),
                    charts.ChartTitle('Minute',
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleStyleSpec:
                            const common.TextStyleSpec(fontSize: 18),
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int matchDate(List<String> dateList, String date) {
    for(int i=0; i < dateList.length; i++){
      print('Datelist: ${dateList.elementAt(i)}');
      print("Date: $date");
      if(date == dateList.elementAt(i)){
        return i;
      }
    }
    return -1;
  }

  int getDays(int month) {
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      return 31;
    } else if (month == 2) {
      if (isLeapYear(DateTime.now().year)) {
        return 29;
      } else {
        return 28;
      }
    } else {
      return 30;
    }
  }

  bool isLeapYear(int year) {
    return ((((year) % 4) == 0 && ((year) % 100) != 0) || ((year) % 400) == 0);
  }

  Future<Map<List<String>, List<int>>> getValveData() async {
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: deviceName);

    // Prepare list of queried device fields
    var deviceFields = <EntityKey>[
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime')
    ];

    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'time')
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
    var timeWindow = const Duration(days: 7).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['time'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService = tbClient.getTelemetryService();

    var subscriber = TelemetrySubscriber(telemetryService, [cmd]);

    subscriber.subscribe();

    List<int> irrigationTimeList = [];
    List<String> dateList = [];
    subscriber.entityDataStream.listen((entityDataUpdate) {
      var data = entityDataUpdate.data;
      if (data.toString().contains('timeseries')) {
        var tsValues = data!.data.elementAt(0).timeseries.values.elementAt(0);
        for (final tsValue in tsValues) {
          var day = DateTime.fromMillisecondsSinceEpoch(tsValue.ts).day;
          var month = DateTime.fromMillisecondsSinceEpoch(tsValue.ts).month;
          var date = '$day/$month';
          var irrigationTime = int.parse(tsValue.value!);
          if (!dateList.contains(date) && (irrigationTime != 0)) {
            dateList.add(date.toString());
            irrigationTimeList.add(irrigationTime);
          }
        }
      } else {}
    });
    await Future.delayed(const Duration(milliseconds: 300));

    Map<List<String>, List<int>> map = {dateList: irrigationTimeList};

    subscriber.unsubscribe();

    return map;
  }
}

class SubscriberSeries {
  final String date;
  final int minutes;
  final charts.Color barColor;

  SubscriberSeries(
      {required this.date, required this.minutes, required this.barColor});
}
