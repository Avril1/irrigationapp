import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';

import '../../core/context/tb_context.dart';

class NotificationView extends TbPageWidget {
  NotificationView( TbContext tbContext, {Key? key}) : super(tbContext, key: key);

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends TbPageState<NotificationView> {

  Widget _textView(String text, String time){
    return Container(
      padding: const EdgeInsets.all(14),
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          Row(
            children: [
              Text('Thingsboard',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Text('(${time})')
            ],
          ),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Notifications'),
      ),
      body: new ListView(
        children: [
          _textView('Hi, Farmer1. You should irrigate your farm for 10min now. ','10:40'),
          _textView('Hi, Farmer1. You should irrigate your farm for 18min now.','16:30'),
          _textView('Hi, Farmer1. You should irrigate your farm for 12min now.','19:20'),
        ],
      ),
    );
  }
}
