import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({Key? key}) : super(key: key);

  @override
  _WeatherViewState createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  Widget _weatherView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '11',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  Text(
                    '℃',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Overcast',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  children: [
                    Text(
                      '16:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/cloudy.png'),
                    ),
                    Text(
                      '13℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '17:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/cloudy.png'),
                    ),
                    Text(
                      '12℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '18:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/cloudy.png'),
                    ),
                    Text(
                      '12℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '19:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      '13℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '20:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      '12℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '21:00',
                      style: TextStyle(fontSize: 16),
                    ),
                    Image(
                      image: AssetImage('images/cloudy.png'),
                    ),
                    Text(
                      '11℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
                    child: Text(
                      'Today',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Tomorrow',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Fri',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Sat',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Sat',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Mon',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Image(
                      image: AssetImage('images/rain.png'),
                    ),
                    Text(
                      'Rain',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      'Partly cloudy',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      'Partly cloudy',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    Image(
                      image: AssetImage('images/sun.png'),
                    ),
                    Text(
                      'Sun',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      'Partly cloudy',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    Image(
                      image: AssetImage('images/sun_cloud.png'),
                    ),
                    Text(
                      'Partly cloudy',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
                    child: Text(
                      '12 / 3℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '14 / 3℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '10 / -2℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '12 / -2℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '13 / 1℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      '13 / 1℃',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Weather'),
      ),
      body: _weatherView(),
    );
  }
}
