import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './record_history.dart';

class RecordCard extends StatefulWidget {
  final List<MainData> recordData;

  const RecordCard({Key key, this.recordData}) : super(key: key);

  @override
  _CustomerRecordCard createState() => _CustomerRecordCard();
}

class _CustomerRecordCard extends State<RecordCard> {
  List<MainData> _monthRecordLists = [];

  @override
  void initState() {
    super.initState();
    setState(() {  _monthRecordLists = widget.recordData;  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Color(int.parse("0xffE7F1F7")),
          width: MediaQuery.of(context).size.width * 1.0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Container(
              child: ListView.builder(
                itemCount: _monthRecordLists.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        color: (_monthRecordLists[index].appointment.finish) ? Colors.grey : Colors.white,
                        child: Column(
                            children: <Widget> [
                              Text('${_monthRecordLists[index].appointment.store_name}/${_monthRecordLists[index].appointment.fitness_name}'),
                              Text('${_monthRecordLists[index].appointment.appointment_time}'),
                              Text('${_monthRecordLists[index].appointment.free_box}'),
                              _monthRecordLists[index].appointment.cancel
                                  ? Text("当日キャンセル")
                                  : Text(""),
                              _monthRecordLists[index].appointment.room_plus
                                  ? Text("ルームプラス")
                                  : Text(""),
                              _monthRecordLists[index].ticket != null
                                  ? Text("繰越分")
                                  : Text(""),
                              _monthRecordLists[index].purchased_ticket != null
                                  ? Text("チケットを使用")
                                  : Text(""),

                              ElevatedButton(
                                child: const Text('キャンセル'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                  onPrimary: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            
                            ]
                        )
                    ),
                  );
                },
              )
          ),
        ),
      ),
    );
  }
}