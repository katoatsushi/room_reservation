import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './select_time.dart';
import './create_result.dart';
import './error_result.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';

class CreateConfirm extends StatefulWidget {

  final int store_id;
  final int fitness_id;
  final String store_name;
  final String fitness_name;
  final int year;
  final int month;
  final int day;
  final String start_hour;
  final String start_min;
  final String finish_hour;
  final String finish_min;

  CreateConfirm({Key key,
                this.store_id, this.fitness_id,
                this.store_name, this.fitness_name,
                this.year, this.month, this.day,
                this.start_hour, this.start_min, this.finish_hour, this.finish_min}): super(key: key);

  @override
  _AppointmentCreateConfirm createState() => _AppointmentCreateConfirm();
}

class _AppointmentCreateConfirm extends State<CreateConfirm> {

  @override
  void initState() {
    super.initState();
  }

  String returnTimeInfo(){
    var timeString = widget.month.toString()+"月"+ widget.day.toString()+ "日 " + widget.start_hour+":"+widget.start_min+" ~ "+widget.finish_hour+":"+widget.finish_min;
    return timeString;
  }

  String returnApointmentInfo(){
    var appointmentString = "【 ${widget.store_name}】${widget.fitness_name}";
    return appointmentString;
  }

  void _onPressedHandleSubmit() async {
    const customer_id = 3;
    // var headers = await getAuthTokens();
    var headers = await getTokens();
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer/${customer_id}/appointments/new/${widget.store_id}/${widget.fitness_id}/${widget.year}/${widget.month}/${widget.day}";
    var params = "?hour=${widget.start_hour}&min=${widget.start_min}";
    url += params;

    http.Response resp = await http.post( url, headers: headers );
    var responseBody =  json.decode( resp.body );

    if (responseBody['error']){ // エラーが生じた場合
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorResult(error_message: responseBody['message'])),
      );
    } else { // エラーなし

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateResult(

            appointment_time: responseBody["data"]["appointment_time"],
            free_box: responseBody["data"]["free_box"],
            store_name: responseBody["data"]["store_name"],
            fitness_name: responseBody["data"]["fitness_name"],

        )),
      );

    }
  }

  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {
    
    // final width = MediaQuery.of(context).size.width;

    return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('予約'),
        ),
        body: Center(
          child: Container(
            // padding: EdgeInsets.fromLTRB(10,10,10,0),
            padding: EdgeInsets.only(top: 150, left: 10, bottom: 150, right: 10),
            width: double.maxFinite,
            child: Card(
              elevation: 5,
              child: Column(
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                    width: double.infinity,
                    child: Text(
                      "予約を確定させますか?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black38,
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 10, left: 10, bottom: 5, right: 10),
                    width: double.infinity,
                    child: Text(
                      '内容: ' + returnApointmentInfo(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black38,
                      ),
                    ),
                  ),

                  Container(
                      margin: EdgeInsets.only(top: 10, left: 5, bottom: 5, right: 10),
                      width: double.infinity,
                      child: Text(
                        '日時：' + returnTimeInfo(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black38,
                        ),
                      )
                  ),
                  // 余白を可能な限り伸ばして入れる
                  Expanded(child: SizedBox( )),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ElevatedButton(
                            child: const Text('確定する'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _onPressedHandleSubmit,
                          ),
                        ),
                      ]
                    ),
                  )

                ]
              ),
            ),
          ),
        ),
      )
    );
  }
}

class SampleRequest {
  final int id;
  final String name;
  SampleRequest({
    this.id,
    this.name,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}