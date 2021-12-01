import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import './select_time.dart';

class SelectDate extends StatefulWidget {
  final int store_id;
  final int fitness_id;
  final String store_name;
  final String fitness_name;
  SelectDate({Key key, this.store_id, this.fitness_id, this.store_name, this.fitness_name}): super(key: key);

  @override
  _SelectDateState createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  DateTime _currentDate = DateTime.now();
  int year;
  int month;
  int day;

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = date);
    year = date.year;
    month = date.month;
    day = date.day;
  }

  void _onPressedSelectTime(){
    // TODO::uncomment below
    final now = DateTime.now();
    final deadLine = now.add(Duration(hours: 48) * 1);
    if (_currentDate.isAfter(deadLine)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectTime(
            store_id: widget.store_id, fitness_id: widget.fitness_id,
            store_name: widget.store_name, fitness_name: widget.fitness_name,
            year: year, month: month, day: day,
        )),
      );
    } else {
      null;
    }
  }

  bool _isAvailable(){
    final now = DateTime.now();
    final deadLine = now.add(Duration(hours: 48) * 1);
    if (_currentDate.isAfter(deadLine)) {
      return true;
    } else {
      return false;
    }
  }
  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('予約'),
        ),
        body: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: CalendarCarousel<Event>(
                        onDayPressed: onDayPressed,
                        weekendTextStyle: TextStyle(color: Colors.red),
                        thisMonthDayBorderColor: Colors.grey,
                        weekFormat: false,
                        height: 420.0,
                        selectedDateTime: _currentDate,
                        daysHaveCircularBorder: true,
                        customGridViewPhysics: NeverScrollableScrollPhysics(),
                        markedDateShowIcon: true,
                        markedDateIconMaxShown: 2,
                        todayTextStyle: TextStyle(
                          color: Colors.blue,
                        ),
                        markedDateIconBuilder: (event) {
                          return event.icon;
                        },
                        locale: 'JA',
                        todayButtonColor: Colors.white24,
                        todayBorderColor: Colors.green,
                        markedDateMoreShowTotal: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text('※2日以上先の日付を選択してください'),
                  ),
                  Padding(
                      padding:  const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: ElevatedButton(
                                  child: const Text('キャンセル'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: (() { // 即時関数を使う
                                if (_isAvailable()) {
                                  return ElevatedButton(
                                    child: const Text('時間を選択'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _onPressedSelectTime
                                  );
                                } else {
                                  return  ElevatedButton(
                                    child: const Text('時間を選択'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _onPressedSelectTime
                                  );
                                }
                                })(),
                            ),
                          ]
                      )
                  ),
                ]
            )
        )
      )
    );

  }
}




