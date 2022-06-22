
import 'dart:math';

class Weather{
  final String description;
  final String iconCode;

  Weather(this.description,this.iconCode);

  Weather.fromJson(Map<String, dynamic> json)
      : description = json['description'],
  iconCode = json['icon'];

  Map<String, dynamic> toJson() => {
    'description': description,
    'icon' : iconCode
  };
}

class IndexCurrentWeather{
  final Weather weather;
  dynamic temp;

  IndexCurrentWeather(this.weather, this.temp);

  IndexCurrentWeather.fromJson(Map<String, dynamic> json)
      : temp = json['temp'],
  weather = Weather.fromJson(json['weather']);

  Map<String, dynamic> toJson() => {
    'weather': weather,
    'temp' : temp,
  };
}

class Data{
  final List<IndexCurrentWeather> dataList;

  Data(this.dataList);

  factory Data.fromJson(Map<String, dynamic> json){
    var list = json['data'] as List;
    List<IndexCurrentWeather> dataList = list.map((i) => IndexCurrentWeather.fromJson(i)).toList();
    return Data(dataList);
  }
  Map<String, dynamic> toJson() => {
    'data': dataList,
  };
}


class IndexHourlyWeather{
  final Weather weather;
  dynamic temp;
  final String timestampUtc;

  IndexHourlyWeather(this.weather, this.temp, this.timestampUtc);

  IndexHourlyWeather.fromJson(Map<String, dynamic> json)
      : temp = json['temp'],
        weather = Weather.fromJson(json['weather']),
        timestampUtc = json['timestamp_utc'];

  Map<String, dynamic> toJson() => {
    'weather': weather,
    'temp' : temp,
    'timestamp_utc' : timestampUtc
  };
}

class HourlyData{
  final List<IndexHourlyWeather> dataList;

  HourlyData(this.dataList);

  factory HourlyData.fromJson(Map<String, dynamic> json){
    var list = json['data'] as List;
    List<IndexHourlyWeather> dataList = list.map((i) => IndexHourlyWeather.fromJson(i)).toList();
    return HourlyData(dataList);
  }
  Map<String, dynamic> toJson() => {
    'data': dataList,
  };

}

class IndexDailyWeather{
  final Weather weather;
  dynamic lowTemp, maxTemp;
  final String datetime;


  IndexDailyWeather(this.weather, this.datetime, this.lowTemp, this.maxTemp);

  IndexDailyWeather.fromJson(Map<String, dynamic> json)
      : lowTemp = json['low_temp'],
        maxTemp = json['max_temp'],
        weather = Weather.fromJson(json['weather']),
        datetime = json['datetime'];

  Map<String, dynamic> toJson() => {
    'weather': weather,
    'low_temp' : lowTemp,
    'max_temp' : maxTemp,
    'datetime' : datetime
  };
}

class DailyData{
  final List<IndexDailyWeather> dataList;

  DailyData(this.dataList);

  factory DailyData.fromJson(Map<String, dynamic> json){
    var list = json['data'] as List;
    List<IndexDailyWeather> dataList = list.map((i) => IndexDailyWeather.fromJson(i)).toList();
    return DailyData(dataList);
  }
  Map<String, dynamic> toJson() => {
    'data': dataList,
  };

}