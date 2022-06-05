import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';


class ValveGraphView extends TbPageWidget {
  ValveGraphView(TbContext tbContext, {Key? key}) : super(tbContext, key: key);

  @override
  _ValveGraphViewState createState() => _ValveGraphViewState();
}

class _ValveGraphViewState extends TbPageState<ValveGraphView> {

  final List<SubscriberSeries> data = [
    SubscriberSeries(
      date: "20/01",
      minutes: 5,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "21/01",
      minutes: 0,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "22/01",
      minutes: 0,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "23/01",
      minutes: 60,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "24/01",
      minutes: 0,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "25/01",
      minutes: 10,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "26/01",
      minutes: 0,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
    SubscriberSeries(
      date: "27/01",
      minutes: 30,
      barColor: charts.ColorUtil.fromDartColor(Colors.blue),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve graph'),
      ),
      body: _valveGraph(),
    );
  }

  Widget _valveGraph(){
    List<charts.Series<SubscriberSeries, String>> series = [
      charts.Series(
          id: "Subscribers",
          data: data,
          domainFn: (SubscriberSeries series, _) => series.date,
          measureFn: (SubscriberSeries series, _) => series.minutes,
          colorFn: (SubscriberSeries series, _) => series.barColor
      )
    ];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Valve 1",
            style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
              Expanded(
                child: charts.BarChart(series),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriberSeries {
  final String date;
  final int minutes;
  final charts.Color barColor;

  SubscriberSeries(
      {
        required this.date,
        required this.minutes,
        required this.barColor
      }
      );
}