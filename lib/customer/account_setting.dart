import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:room_reservation/appointments/select_store_fitness.dart';
import 'dart:convert';
import '../customer/get_customer_status.dart';
import '../setting/set_params.dart';
import '../auth/get_auth_info.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({Key key}) : super(key: key);

  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  bool _isLoad = false;
  bool _isEdit = false;
  bool _isSubmit = false;
  CustomerData _data;

  String phone_number;
  String emergency_phone_number;
  String postal_code;
  String address;


  @override
  void initState() {
    super.initState();
    initialize();
  }

  String parseTime(data){
    var dataTime = data.status_time;
    DateTime datetime = DateTime.parse(dataTime).toLocal(); 

    if(data.available){
      return ("${datetime.year}年${datetime.month}月${datetime.day}日開始");
    }else{
      return ("${datetime.year}年${datetime.month}月${datetime.day}日付");
    }
    
    
  }


  Future<http.Response> initialize() async {
    setState(() { _isLoad = true; });
    
    //var headers = await getAuthTokens();
    var headers = await getTokens();
    
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer_get_my_info";
    final resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);
    final data = CustomerData.fromJson(body);

    setState(() {
      _isLoad = false;
      _data = data;
      phone_number = data.phone_number;
      emergency_phone_number = data.phone_number;
      postal_code = data.postal_code;
      address = data.address;
    });

  }

  void handleSubmit() async {
    setState(() { _isEdit = false; });
    // var headers = await getAuthTokens();
    var headers = await getTokens();

    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer_update_customer_info";
    final resp = await http.put(url, headers: headers);

    setState(() {
      _isSubmit = true;
    });

  }
  
  void _handlePhoneNumber(String e) {
    setState(() { phone_number = e; });
  }

  void _handleEmergencyPhoneNumber(String e) {
    setState(() { emergency_phone_number = e; });
  }

  void _handlePostalCode(String e) {
    setState(() { postal_code = e; });
  }

  void _handleAddress(String e) {
    setState(() { address = e; });
  }
  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'account_setting',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('アカウント設定'),
        ),
        body: Center(

          child: _isLoad
          ? Center(

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  CircularProgressIndicator(),
                  Text("お客様情報を取得中です...",style: TextStyle(fontSize: 15.0),),

                ],
              ),
            )

          : Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [

                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("ステータス", textAlign: TextAlign.left),
                  ),

                 Container(
                   child: Row(
                     children: [

                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Center(
                              child: Text( _data.status ,textAlign: TextAlign.left )
                            )
                          ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Center(
                              child: Text( parseTime(_data) ,textAlign: TextAlign.left )
                            )
                          ),
                      ),

                    ],
                   ),
                 ),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("お名前", textAlign: TextAlign.left),
                  ),

                 Container(
                   child: Row(
                     children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Center(
                              child: Text( _data.first_name_kanji ,textAlign: TextAlign.center,)
                            )
                          ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: Text( _data.last_name_kanji ,textAlign: TextAlign.center,)
                          )
                          ),
                        ),
                    ],
                   ),
                 ),

                 Container(
                   child: Row(
                     children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Center(
                              child: Text( _data.first_name_kana ,textAlign: TextAlign.center,)
                            )
                          ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Center(
                              child: Text( _data.last_name_kana ,textAlign: TextAlign.center,)
                            )
                          ),
                        ),
                    ],
                   ),
                 ),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("電話番号", textAlign: TextAlign.left),
                  ),
                ),

                Container(
                   child: Row(
                     children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 5),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: TextEditingController(text: phone_number ),
                              onChanged: _handlePhoneNumber,
                            )
                          ),
                        ),
                      ),

                    ],
                   ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 5),
                  child: new TextField(
                    enabled: true,
                    maxLengthEnforced: false,
                    style: TextStyle(color: Colors.black),
                    obscureText: false,
                    maxLines:1 ,
                    controller: TextEditingController(text: phone_number ),
                    decoration: const InputDecoration(
                        // border: OutlineInputBorder(),
                        labelText: '電話番号を入力してください'
                    ),
                    onChanged: _handlePhoneNumber,
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text("緊急連絡先", textAlign: TextAlign.left),
                ),
                Container(
                   child: Row(
                     children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 5),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: TextEditingController(text:  _data.emergency_phone_number ),
                              onChanged:  _handleEmergencyPhoneNumber
                            )
                          ),
                        ),
                      ),

                    ],
                   ),
                 ),


                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("郵便番号", textAlign: TextAlign.left),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 5),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextField(
                                controller: TextEditingController(text:  _data.postal_code ),
                                onChanged: _handlePostalCode
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("住所", textAlign: TextAlign.left),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 5),
                          child: Center(
                            child: Container(

                              width: MediaQuery.of(context).size.width * 0.9,
                              child: TextField(
                                controller: TextEditingController(text:  _data.address ),
                                onChanged: _handleAddress
                              )

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 5),
                    child: Container(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,

                          child: ElevatedButton(
                            child: const Text('保存する'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              handleSubmit();
                            }
                          )

                        ),
                    ),
                  )

              ]
            )
            

        )
      )
      ),
    );

  }
}


class CustomerData {

  final String first_name_kanji;
  final String last_name_kanji;
  final String first_name_kana;
  final String last_name_kana;
  final String status;
  final String status_time;
  final bool available;
  final String email;

  final String phone_number;
  final String emergency_phone_number;
  final String postal_code;
  final String address;


  CustomerData(
    this.first_name_kanji,
    this.last_name_kanji,
    this.first_name_kana,
    this.last_name_kana,
    this.status,
    this.status_time,
    this.available,
    this.email,
    this.phone_number,
    this.emergency_phone_number,
    this.postal_code,
    this.address,
  );

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      json["first_name_kanji"],
      json["last_name_kanji"],
      json["first_name_kana"],
      json["last_name_kana"],
      json["status"],
      json["status_time"],
      json["available"],
      json["email"],
      json["phone_number"],
      json["emergency_phone_number"],
      json["postal_code"],
      json["address"],
    );
  }

}
