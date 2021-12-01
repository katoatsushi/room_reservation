import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../stacks/my_page.dart';
import '../cupertino_tab_scaffold.dart';
import '../setting/routes.dart';

class CreateResult extends StatefulWidget {

  final String appointment_time;
  final String store_name;
  final String fitness_name;
  final String free_box;


  const CreateResult({Key key,
    this.appointment_time,
    this.store_name,
    this.fitness_name,
    this.free_box
  }) : super(key: key);

  @override
  _AppointmentCreateResult createState() => _AppointmentCreateResult();

}

class _AppointmentCreateResult extends State<CreateResult> {

  String parseTime(){
    String appointment_time = widget.appointment_time;
    DateTime datetime = DateTime.parse(appointment_time).toLocal(); 
    return ("${datetime.month}/${datetime.day} ${datetime.hour}:${datetime.minute} ~ ");
  }

  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('予約確定'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(10,10,10,0),
            height: MediaQuery.of(context).size.height * 0.60,
            width: double.maxFinite,
            child: Card(
              shape: new RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(4.0)),
              elevation: 3,
              child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                      width: double.infinity,
                      child: Text(
                        "予約が確定しました！",
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
                        '内容: 【 ${widget.store_name}】${widget.fitness_name}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10, left: 10, bottom: 5, right: 10),
                        width: double.infinity,
                        child: Text(
                          '日時: ' + parseTime(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black38,
                          ),
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                        width: double.infinity,
                        child: Text(
                          '※　キャンセルはセッション開始の72時間までにお願いいたします。',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black38,
                          ),
                        )
                    ),
                    
                    // 余白を可能な限り伸ばして入れる
                    Expanded(child: SizedBox( )),

                    Center(
                      child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ElevatedButton(
                                child: const Text('予約ホームに戻る'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                              ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
      )
    );

  }
}