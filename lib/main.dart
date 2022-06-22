import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:irrigation_app/config/routes/router.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final appRouter = ThingsboardAppRouter();

void main() async{
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/thingsboard_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true
  );

  createNotificationsTable();

  runApp(const MyAPP());
}

void createNotificationsTable() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference.
  final database = openDatabase(
      join(await getDatabasesPath(), 'notification_database.db'),
  // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
  // Run the CREATE TABLE statement on the database.
  return db.execute(
  'CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, text TEXT)',
  );
  },
  // Set the version. This executes the onCreate function and provides a
  // path to perform database upgrades and downgrades.
  version: 1,
  );
}

class MyAPP extends StatefulWidget{
  const MyAPP({ Key? key}) : super(key: key);

  @override
  _MyAPPState createState() => _MyAPPState();
}

class _MyAPPState extends State<MyAPP>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irrigation App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home:MaterialApp(
        onGenerateRoute: appRouter.router.generator,
        navigatorObservers: [appRouter.tbContext.routeObserver],
      ),
    );
  }

}

