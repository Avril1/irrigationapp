import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:irrigation_app/utils/weather_model.dart';
import 'package:geocoding/geocoding.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({Key? key}) : super(key: key);

  @override
  _WeatherViewState createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  late Position position;
  late Future<String> city;
  late Future<List<Widget>> widgets;
  @override
  void initState() {
    super.initState();
    requestPermission();
    widgets = getWeather();
    city = getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: city,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            Widget widget;
            if (snapshot.hasData) {
              widget = Text(snapshot.data);
            } else if (snapshot.hasError) {
              widget = const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              );
            } else {
              widget = const Text('');
            }
            return widget;
          },
        ),
      ),
      body: FutureBuilder(
        future: widgets,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            List<Widget> widgetList;
            if (snapshot.hasData) {
              widgetList = snapshot.data;
            } else if (snapshot.hasError) {
              print(snapshot.error);
              print(snapshot.stackTrace);
              widgetList = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,),
              ];
            } else {
              widgetList = <Widget>[
                const Text('Loding'),
              ];
            }
            return ListView(children: widgetList,);
          },),
    );
  }

  Future<String> getAddress() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.first.locality!;
  }

  Future<List<Widget>> getWeather() async {
    List<Widget> widgetList = [];
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var client = http.Client();
    try {
      var url = 'https://weatherbit-v1-mashape.p.rapidapi.com/';
      Map<String, String> headers = {
        "x-rapidapi-key": "4c31161da5msh90f9dee41026b90p1a79b8jsnd719ed9c09aa",
        "x-rapidapi-host": "weatherbit-v1-mashape.p.rapidapi.com"
      };
      //current weather data
      await client
          .get(
              Uri.parse(
                  '${url}current?lon=${position.longitude}&lat=${position.latitude}'),
              headers: headers)
          .then((response) {
        Map<String, dynamic> currentWeaMap = jsonDecode(response.body);
        var data = Data.fromJson(currentWeaMap).dataList;
        var index0 = data.elementAt(0);
        var temp = index0.temp;
        var weather = index0.weather;
        var description = weather.description;

        widgetList.add(_currentWeatherView(temp, description));

        //6 hours forecast
        return client
            .get(
                Uri.parse(
                    '${url}forecast/hourly?lon=${position.longitude}&lat=${position.latitude}&hours=6'),
                headers: headers)
            .then((response) {
          Map<String, dynamic> hourlyWeaMap = jsonDecode(response.body);
          var data = HourlyData.fromJson(hourlyWeaMap).dataList;
          var index0 = data.elementAt(0);
          var temp = index0.temp;
          var hour = index0.timestampUtc.substring(11,16);
          var weather = index0.weather;
          var iconCode = weather.iconCode;
          var imageSrc= 'https://www.weatherbit.io/static/img/icons/$iconCode.png';
          var widget = _hourlyWeatherView(temp, hour, imageSrc);

          var index1 = data.elementAt(1);
          var temp1 = index1.temp;
          var hour1 = index1.timestampUtc.substring(11,16);
          var weather1 = index1.weather;
          var iconCode1 = weather1.iconCode;
          var imageSrc1 = 'https://www.weatherbit.io/static/img/icons/$iconCode1.png';
          var widget1 = _hourlyWeatherView(temp1, hour1, imageSrc1);

          var index2 = data.elementAt(2);
          var temp2 = index2.temp;
          var hour2 = index2.timestampUtc.substring(11,16);
          var weather2 = index2.weather;
          var iconCode2 = weather2.iconCode;
          var imageSrc2 = 'https://www.weatherbit.io/static/img/icons/$iconCode2.png';
          var widget2 = _hourlyWeatherView(temp2, hour2, imageSrc2);

          var index3 = data.elementAt(3);
          var temp3 = index3.temp;
          var hour3 = index3.timestampUtc.substring(11,16);
          var weather3 = index3.weather;
          var iconCode3 = weather3.iconCode;
          var imageSrc3 = 'https://www.weatherbit.io/static/img/icons/$iconCode3.png';
          var widget3 = _hourlyWeatherView(temp3, hour3, imageSrc3);

          var index4 = data.elementAt(4);
          var temp4 = index4.temp;
          var hour4 = index4.timestampUtc.substring(11,16);
          var weather4 = index4.weather;
          var iconCode4 = weather4.iconCode;
          var imageSrc4 = 'https://www.weatherbit.io/static/img/icons/$iconCode4.png';
          var widget4 = _hourlyWeatherView(temp4, hour4, imageSrc4);

          var index5 = data.elementAt(5);
          var temp5 = index5.temp;
          var hour5 = index5.timestampUtc.substring(11,16);
          var weather5 = index5.weather;
          var iconCode5 = weather5.iconCode;
          var imageSrc5 = 'https://www.weatherbit.io/static/img/icons/$iconCode5.png';
          var widget5 = _hourlyWeatherView(temp5, hour5, imageSrc5);

          widgetList.add(
              Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [widget, widget1, widget2, widget3, widget4, widget5],
                  )
              ));

          //16 days forecast
          return client.get(
              Uri.parse(
                  '${url}forecast/daily?lon=${position.longitude}&lat=${position.latitude}&'),
              headers: headers);
        }).then((response) {
          Map<String, dynamic> dailyWeaMap = jsonDecode(response.body);
          var data = DailyData.fromJson(dailyWeaMap).dataList;
          var index = data.elementAt(0);
          var lowTemp = index.lowTemp;
          var maxTemp = index.maxTemp;
          var weekday = "Today";
          var weather = index.weather;
          var description = weather.description;
          var iconCode = weather.iconCode;
          var imageSrc = 'https://www.weatherbit.io/static/img/icons/$iconCode.png';
          var widget = _dailyWeatherView(lowTemp, maxTemp, weekday, imageSrc, description);

          var index1 = data.elementAt(1);
          var lowTemp1 = index1.lowTemp;
          var maxTemp1 = index1.maxTemp;
          var weekday1 = 'Tomorrow';
          var weather1 = index1.weather;
          var description1 = weather1.description;
          var iconCode1 = weather1.iconCode;
          var imageSrc1 = 'https://www.weatherbit.io/static/img/icons/$iconCode1.png';
          var widget1 = _dailyWeatherView(lowTemp1, maxTemp1, weekday1, imageSrc1, description1);

          var index2 = data.elementAt(2);
          var lowTemp2 = index2.lowTemp;
          var maxTemp2 = index2.maxTemp;
          dynamic weekday2 = DateTime.parse(index2.datetime).weekday;
          weekday2 = getWeekDay(weekday2);
          dynamic weather2 = index2.weather;
          var description2 = weather2.description;
          var iconCode2 = weather2.iconCode;
          var imageSrc2 = 'https://www.weatherbit.io/static/img/icons/$iconCode2.png';
          var widget2 = _dailyWeatherView(lowTemp2, maxTemp2, weekday2, imageSrc2, description2);

          var index3 = data.elementAt(3);
          var lowTemp3 = index3.lowTemp;
          var maxTemp3 = index3.maxTemp;
          dynamic weekday3 = DateTime.parse(index3.datetime).weekday;
          weekday3 = getWeekDay(weekday3);
          var weather3 = index3.weather;
          var description3 = weather3.description;
          var iconCode3 = weather3.iconCode;
          var imageSrc3 = 'https://www.weatherbit.io/static/img/icons/$iconCode3.png';
          var widget3 = _dailyWeatherView(lowTemp3, maxTemp3, weekday3, imageSrc3, description3);

          var index4 = data.elementAt(4);
          var lowTemp4 = index4.lowTemp;
          var maxTemp4 = index4.maxTemp;
          dynamic weekday4 = DateTime.parse(index4.datetime).weekday;
          weekday4 = getWeekDay(weekday4);
          var weather4 = index4.weather;
          var description4 = weather4.description;
          var iconCode4 = weather4.iconCode;
          var imageSrc4 = 'https://www.weatherbit.io/static/img/icons/$iconCode4.png';
          var widget4 = _dailyWeatherView(lowTemp4, maxTemp4, weekday4, imageSrc4, description4);

          var index5 = data.elementAt(5);
          var lowTemp5 = index5.lowTemp;
          var maxTemp5 = index5.maxTemp;
          dynamic weekday5 = DateTime.parse(index5.datetime).weekday;
          weekday5 = getWeekDay(weekday5);
          var weather5 = index5.weather;
          var description5 = weather5.description;
          var iconCode5 = weather5.iconCode;
          var imageSrc5 = 'https://www.weatherbit.io/static/img/icons/$iconCode5.png';
          var widget5 = _dailyWeatherView(lowTemp5, maxTemp5, weekday5, imageSrc5, description5);

          widgetList.add(const Divider(
            thickness: 2,
          ),);
          widgetList.add(Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [widget, widget1, widget2, widget3, widget4, widget5],
              )
          ));
        });
      });
    } finally {
      client.close();
    }

    return widgetList;
  }

  Future<void> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Widget _currentWeatherView(dynamic temp, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                temp.toString(),
                style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:[
                      const Text(
                      '℃',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hourlyWeatherView(dynamic temp, String hour, String imageSrc){
    return Column(
            children: [
              Text(
                hour,
                style: const TextStyle(fontSize: 16),
              ),
              Image.network(imageSrc,width: 50, height: 50,),
              Text(
                '$temp℃',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          );
  }

  Widget _dailyWeatherView(dynamic lowTemp, dynamic maxTemp, String weekday, String imageSrc, String description){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                weekday,
                style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
          ],
        ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              Image.network(imageSrc, width: 50, height: 50,),
              Text(
                description,
                style: const TextStyle(fontSize: 18),
              ),
            ]),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
              child: Text(
                '$maxTemp/ $lowTemp℃',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String getWeekDay(int n){
    String weekday;

    switch(n){
      case 1 : weekday = 'Mon';break;
      case 2 : weekday = 'Tue';break;
      case 3 : weekday = 'Wed';break;
      case 4 : weekday = 'Thu';break;
      case 5 : weekday = 'Fri';break;
      case 6 : weekday = 'Sat';break;
      case 7 : weekday = 'Sun';break;
      default: weekday = 'null';
    }
    return weekday;
  }
}
