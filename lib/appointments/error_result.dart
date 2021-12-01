import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ErrorResult extends StatefulWidget {
  final String error_message;

  ErrorResult({Key key,  this.error_message, }): super(key: key);

  @override
  _AppointmentErrorResult createState() => _AppointmentErrorResult();
}

class _AppointmentErrorResult extends State<ErrorResult> {

  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: Text('予約失敗'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(10,10,10,0),
            height: MediaQuery.of(context).size.height * 0.60,
            width: double.maxFinite,
            child: Card(
              shape: new RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.red, width: 2.0),
                  borderRadius: BorderRadius.circular(4.0)),
              elevation: 3,
              child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                      width: double.infinity,
                      child: Text(
                        widget.error_message,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    
                    // 余白を可能な限り伸ばして入れる
                    Expanded(child: SizedBox( )),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                          child: const Text('ホームに戻る'),
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
                  ]
              ),
            ),
          ),
        )
      )
    );

  }
}
