import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class SensorGraphView extends TbPageWidget {
  final String customerId;

  SensorGraphView(TbContext tbContext, {Key? key, required this.customerId}) : super(tbContext, key: key);

  @override
  _SensorGraphViewState createState() => _SensorGraphViewState(customerId);
}

class _SensorGraphViewState extends TbPageState<SensorGraphView> {
  final String customerId;
  _SensorGraphViewState(this.customerId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor graph'),
      ),
      body: _sensorLineChart(),
    );
  }

  Widget _sensorLineChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(8.0),
              child: Text(
                'Sensor 1',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              ),
              Expanded(
                    child: LineChart(
                    LineChartData(
                        minY: -2,
                        maxY: 2,
                        minX: 1,
                        maxX: 7,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: bottomTitleWidgets,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
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
                              spots: [
                                const FlSpot(1, 1),
                                const FlSpot(2, 1.5),
                                const FlSpot(3, 2),
                                const FlSpot(4, -0.4),
                                const FlSpot(5, -0.1),
                                const FlSpot(6, 0),
                              ])
                        ]),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('10/01', style: style);
        break;
      case 2:
        text = const Text('11/01', style: style);
        break;
      case 3:
        text = const Text('12/01', style: style);
        break;
      case 4:
        text = const Text('13/01', style: style);
        break;
      case 5:
        text = const Text('14/01', style: style);
        break;
      case 6:
        text = const Text('15/01', style: style);
        break;
      case 7:
        text = const Text('16/01', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return Padding(child: text, padding: const EdgeInsets.only(top: 10.0));
  }

}
