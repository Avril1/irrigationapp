import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:irrigation_app/core/sqlite/notification.dart' as notification;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../core/context/tb_context.dart';

class NotificationView extends TbPageWidget {
  NotificationView(TbContext tbContext, {Key? key})
      : super(tbContext, key: key);

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends TbPageState<NotificationView> {
  final StreamController<ReceivedAction> _actionSubject =
      StreamController<ReceivedAction>();
  String notificationText = '';
  late Future<Database> database;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    listenNotifications();
    getNotifications();
  }

  @override
  void dispose() {
    _actionSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          _textView(
              'Hi, Farmer1. You should irrigate your farm for 10min now. ',
              '10:40'),
          _textView('Hi, Farmer1. You should irrigate your farm for 18min now.',
              '16:30'),
          _textView(notificationText, ''),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNotifications();
        },
      ),
    );
  }

  void requestPermissions() async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog<String>(
          context: context as BuildContext,
          barrierDismissible: true,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Allow Notifications'),
            content: const Text('Our app would like to send you notifications'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Deny"),
              ),
              TextButton(
                onPressed: () async => await AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((value) => Navigator.pop(context)),
                child: const Text("Allow"),
              ),
            ],
          ),
        );
      }
    });
  }

  void listenNotifications() {
    _actionSubject.stream.listen((notification) {
      if (notification.channelKey == 'basic_channel' && Platform.isIOS) {
        AwesomeNotifications().getGlobalBadgeCounter().then(
              (value) =>
                  AwesomeNotifications().setGlobalBadgeCounter(value - 1),
            );
      }
      Navigator.pushNamed(context as BuildContext, '/notification');
    });
  }

  void createNotifications() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Thingsboard Notification',
      body: notificationText,
    ));
  }

  Future<void> getNotifications() async {
    TimePageLink pageLink =
        TimePageLink(20, 0, null, SortOrder('endTs', Direction.DESC));
    DeviceId entityId = DeviceId('04348ed0-cbc2-11ec-ae32-d588de44dd8b');
    AlarmQuery query = AlarmQuery(pageLink,
        affectedEntityId: entityId,
        fetchOriginator: true,
        status: AlarmStatus.ACTIVE_UNACK);

    var alarm = await tbClient.getAlarmService().getAlarms(query);
    var alarmInfo = alarm.data.toString();
    var index = alarmInfo.indexOf('endTs');
    var index2 = alarmInfo.indexOf('ackTs');
    var source = alarmInfo.substring(index + 7, index2 - 2);
    var datetime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(source)).toString();
    datetime = datetime.substring(0, 16);

    var index3 = alarmInfo.indexOf('data');
    var index4 = alarmInfo.indexOf('originatorName');
    notificationText = alarmInfo.substring(index3 + 6, index4 - 3);

    var notification1 =
        notification.Notification(date: '2022', text: notificationText);
    //await notification.Notification.insertNotification(notification1);
    //print(await notifications());
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<notification.Notification>> notifications() async {
    // Get a reference to the database.
    database = openDatabase(
      join(await getDatabasesPath(), 'notification_database.db'),
    );
    final db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('notifications');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return notification.Notification(
        id: maps[i]['id'],
        date: maps[i]['date'],
        text: maps[i]['text'],
      );
    });
  }

  Widget _textView(String text, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Thingsboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('($time)')
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}
