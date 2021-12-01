import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './create_confirm.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';

class SelectTime extends StatefulWidget {
  final int store_id;
  final int fitness_id;
  final int year;
  final int month;
  final int day;
  final String store_name;
  final String fitness_name;
  SelectTime({Key key,this.store_id, this.fitness_id, this.store_name, this.fitness_name, this.year, this.month, this.day}): super(key: key);

  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {

  int _value;
  bool _isLoad = false;
  List<AppointmentTime> _appointmentTimeLists = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<http.Response> initialize() async {
    setState(() { _isLoad = true; } );
    // var headers = await getAuthTokens();
    var headers = await getTokens();
    
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/appointments/flutter_new/customer/1/${widget.store_id}/${widget.fitness_id}/${widget.year}/${widget.month}/${widget.day}";

    final resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);

    final appointment_times = (body["data"] as List).map((e) => AppointmentTime.fromJson(e)).toList();
    setState(() {
      _appointmentTimeLists = appointment_times;
      _isLoad = false;
    });
  }

  void _onPressedCreateConfirm(){
    // selectTime is AppointmentTime class
    var selectTime = _appointmentTimeLists[_value];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          CreateConfirm(
            store_id: widget.store_id, fitness_id: widget.fitness_id,
            store_name: widget.store_name, fitness_name: widget.fitness_name,
            year: widget.year, month: widget.month, day: widget.day,
            start_hour: selectTime.start_hour,
            start_min: selectTime.start_min,
            finish_hour: selectTime.finish_hour,
            finish_min: selectTime.finish_min,
          )
      ),
    );

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
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: _isLoad 
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Text("予約可能時刻をロード中です",style: TextStyle(fontSize: 15.0),),
                            ],
                          ),
                        )
                      : Container(
                      child: ListView.builder(
                          itemCount: _appointmentTimeLists.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 45,
                              child: (() { // 即時関数を使う
                                if (_appointmentTimeLists[index].available_num == 0) {
                                  return ListTile(
                                        title: Text(
                                            '${_appointmentTimeLists[index].start_hour}:${_appointmentTimeLists[index].start_min} '
                                                '~ ${_appointmentTimeLists[index].finish_hour}:${_appointmentTimeLists[index].finish_min}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 23, decoration: TextDecoration.lineThrough, color: Colors.grey)
                                        ),
                                        leading: Radio(
                                          value: index,
                                          groupValue: _value,
                                          activeColor: Colors.grey,
                                          onChanged: null,
                                        ),
                                      );
                                } else {
                                  return ListTile(
                                    title: Text(
                                        '${_appointmentTimeLists[index].start_hour}:${_appointmentTimeLists[index].start_min} '
                                            '~ ${_appointmentTimeLists[index].finish_hour}:${_appointmentTimeLists[index].finish_min}'
                                        ,textAlign: TextAlign.center
                                        , style: TextStyle(fontSize: 23)
                                    ),
                                    leading: Radio(
                                      value: index,
                                      groupValue: _value,
                                      activeColor: Color(0xFF6200EE),
                                      onChanged: (int value) {
                                        setState(() {
                                          _value = value;
                                        });
                                      },
                                    ),
                                  );
                                }
                              })(),
                            );
                          },
                        ),
                      ),
                    ),
                ),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: "補足情報",
                  ),
                ),
                Padding(
                  padding:  const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.43,
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
                        width: MediaQuery.of(context).size.width * 0.43,
                        child: _value == null
                          ? ElevatedButton(
                            child: const Text('予約する'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                          : ElevatedButton(
                            child: const Text('予約する'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _onPressedCreateConfirm
                          )
                      ),
                    ]
                  )
                ),
              ]
          ),
        ),
      )
    );
  }
}

class AppointmentTime {
  final String start_hour;
  final String start_min;
  final String finish_hour;
  final String finish_min;
  final int available_num;

  AppointmentTime (
      this.start_hour,
      this.start_min,
      this.finish_hour,
      this.finish_min,
      this.available_num,
      );

  factory AppointmentTime .fromJson(Map<String, dynamic> json) {
    return AppointmentTime (
        json["start_hour"],
        json["start_min"],
        json["finish_hour"],
        json["finish_min"],
        json["available_num"]
    );
  }
}