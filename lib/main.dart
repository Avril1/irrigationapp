import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:irrigation_app/config/routes/router.dart';

final appRouter = ThingsboardAppRouter();

void main(){
  runApp(const MyAPP());
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

