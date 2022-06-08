import 'package:thingsboard_client/thingsboard_client.dart';

class DeviceAttribute {
  final ThingsboardClient _tbClient;

  factory DeviceAttribute(ThingsboardClient tbClient) {
    return DeviceAttribute._internal(tbClient);
  }

  DeviceAttribute._internal(this._tbClient);

  Future<DeviceAttributes?> getDeviceAttributes(String deviceToken,
      {RequestConfig? requestConfig}) async {
    return nullIfNotFound(
          (RequestConfig requestConfig) async {
        var response = await _tbClient.get<Map<String, dynamic>>(
            '/api/v1/$deviceToken/attributes?clientKeys=status',
            options: defaultHttpOptionsFromConfig(requestConfig));
        return response.data != null
            ? DeviceAttributes.fromJson(response.data!)
            : null;
      },
      requestConfig: requestConfig,
    );
  }

}

class DeviceAttributes {
  DeviceStatus client;

  DeviceAttributes.fromJson(Map<String, dynamic> json)
      : client = DeviceStatus.fromJson(json['client']);
}

class DeviceStatus {
  String? status;

  DeviceStatus() : status = '';

  DeviceStatus.fromJson(Map<String, dynamic> json) : status = json['status'];
}