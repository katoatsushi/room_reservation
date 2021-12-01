import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';

class RecordHistory extends StatefulWidget {
  final int customer_id;

  RecordHistory({Key key,  this.customer_id }): super(key: key);

  @override
  _CustomerRecordHistory createState() => _CustomerRecordHistory();
}

class _CustomerRecordHistory extends State<RecordHistory> {
  List<MainData> _thisMonthLists = [];
  List<MainData> _lastMonthLists = [];
  List<MainData> _nextMonthLists = [];
  int _selectIndex = 1;
  var selectedColorThisMonth = Color(int.parse("0xff99CCFF"));
  var selectedColorNextMonth = Colors.white;
  var selectedColorLastMonth = Colors.white;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // 予約情報を取得
  Future<http.Response> initialize() async {
    var id = "ios";
    DateTime now = DateTime.now();
    var year = now.year;
    var month = now.month;
    // var headers = await getAuthTokens();
    var headers = await getTokens();

    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer_page/my_past/ios_records/${id}/year/${year}/month/${month}";

    http.Response resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);
    // エラーがある場合、認証エラーなのでログイン画面に戻す。
    if(body["error"] != null && body["status"] != 200){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return LogIn();
      }));

    } else {

      final lastMonthDatas = (body["last_month"] as List).map((e) => MainData.fromJson(e)).toList();
      final thisMonthDatas = (body["this_month"] as List).map((e) => MainData.fromJson(e)).toList();
      final nextMonthDatas = (body["next_month"] as List).map((e) => MainData.fromJson(e)).toList();

      setState(() {
        _thisMonthLists = thisMonthDatas;
        _lastMonthLists = lastMonthDatas;
        _nextMonthLists = nextMonthDatas;
      });

    }
  }

  // 予約をキャンセル
  Future<http.Response> appointmentCancel(id) async {
    // var headers = await getAuthTokens();
    var headers = await getTokens();
    
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/appointment/${id}";

    var resp = await http.delete(url, headers: headers);
    var body = json.decode(resp.body);

    // TODO::今月の予約枠を更新させる 予約可能枠が1増えるはず
    if(resp.statusCode == 200){
      initialize();
    }
  }

  String _parseApoTime(appointment_time) {
    DateTime apo_time = DateTime.parse(appointment_time).toLocal();
    String apos_time_str = '${apo_time.month}月${apo_time.day}日\n${apo_time.hour}:${apo_time.minute} ~ ';
    return apos_time_str;
  }

  Widget _appointmentTag(data) {
    var apo = data.appointment;

    if(data.purchased_ticket != null){
      return(
        Container(
          width: MediaQuery.of(context).size.width * 0.24,
          child: Chip(
            label: Text(
              "チケット使用",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white
              ),
            ),
            backgroundColor: Colors.blueAccent,
          )
        )
      );
    }else if(data.ticket != null){
      return(
        Container(
          width: MediaQuery.of(context).size.width * 0.24,
          child: Chip(
            label: Text(
              "繰越分",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white
              ),
            ),
            backgroundColor: Colors.cyan,
          )
        )
      );
    }else if(apo.room_plus){
      return(
        Container(
          width: MediaQuery.of(context).size.width * 0.24,
          child: Chip(
            label: Text(
              "roomプラス",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white
              ),
            ),
            backgroundColor: Colors.blue,
          )
        )
      );
    }else if(apo.cancel){
      return(
        Container(
          width: MediaQuery.of(context).size.width * 0.24,
          child: Chip(
            label: Text(
              "当日キャンセル",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white
              ),
            ),
            backgroundColor: Colors.red,
          )
        )
      );
    }else{
      return(
        SizedBox( width: MediaQuery.of(context).size.width * 0.24, )
      );
    }
  }

  List<Widget> buildItems(data){
    var appointment = data.appointment;
    DateTime apo_time = DateTime.parse(appointment.appointment_time).toLocal();
    String apos_time_str = '${apo_time.month}月${apo_time.day}日  ${apo_time.hour}:${apo_time.minute} ~';

    List<Widget> items = [ 
        Text("【${appointment.store_name}店】"),
        Text("メニュー: ${appointment.fitness_name}"),
        Text("開始時間: ${apos_time_str}"),
        Text("備考: ${appointment.free_box}"),
    ];

    if(data.record.recordMenues != null){
      //TODO::ここに空白を入れる
      if(data.trainer != null){
        items.add(Text('${data.trainer.first_name_kanji}/${data.trainer.last_name_kanji}トレーナー', style: TextStyle( fontSize: 14 )));
      }
      data.record.recordMenues.forEach((CustomerRecordMenue menu){
        if (menu.weight != null && menu.time != null){
          items.add(Text('${menu.fitness_name}/${menu.fitness_third_name} ${menu.weight}kg×${menu.time}回', style: TextStyle( fontSize: 14 )));
        }else{
          items.add(Text('${menu.fitness_name}/${menu.fitness_third_name}'));
        }
      });
      if(data.record.customerRecord.detail != null){
        items.add(Text('備考: ${data.record.customerRecord.detail}', style: TextStyle( fontSize: 14 )));
      }
    }
    
    return items;
  }

  Widget _detailButton(data) {
    var appointment = data.appointment;
    DateTime apo_time = DateTime.parse(appointment.appointment_time).toLocal();
    String apos_time_str = '${apo_time.month}月${apo_time.day}日  ${apo_time.hour}:${apo_time.minute} ~';

    return(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.22,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          child: ElevatedButton(
            child: const Text('詳細', style: TextStyle( fontSize: 15 ),),
            style: ElevatedButton.styleFrom(
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
            ),
            onPressed: () async {
              var result = await showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text( '予約詳細', style: TextStyle( fontSize: 20 ), ),
                    content: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: data.record != null ? 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildItems(data),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("【${appointment.store_name}店】"),
                          Text("メニュー: ${appointment.fitness_name}"),
                          Text("開始時間: ${apos_time_str}"),
                          Text("備考: ${appointment.free_box}"),
                        ],
                      )
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('戻る'),
                        onPressed: () => Navigator.of(context).pop(0),
                      )
                    ],
                  );
                },
              );
            },
          )
        )
      )
    );
  }

  Widget _cancelButton(appointment) {
    final now = DateTime.now();
    final deadLine = now.add(Duration(hours: 72) * 1);
    DateTime apo_time = DateTime.parse(appointment.appointment_time).toLocal();
    String apos_time_str = '予約時間: ${apo_time.month}月${apo_time.day}日  ${apo_time.hour}:${apo_time.minute}';

    if (apo_time.isAfter(deadLine)) {
      return(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.22,
             child: ElevatedButton(
                child: const Text('キャンセル', style: TextStyle( fontSize: 15 ),),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent,
                  onPrimary: Colors.white,
                ),
                onPressed: () async {
                  var result = await showDialog<int>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                              '予約をキャンセルしますか？',
                              style: TextStyle( fontSize: 14, ),
                            ),
                        content: Text("【${appointment.store_name}店】\nメニュー: ${appointment.fitness_name}\n${apos_time_str}\n${appointment.free_box}"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('戻る'),
                            onPressed: () => Navigator.of(context).pop(0),
                          ),
                          FlatButton(
                            child: Text('キャンセルする'),
                            onPressed: () {
                              appointmentCancel(appointment.id);
                              Navigator.of(context).pop(1);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              )
          )
      );
    } else {
      if(appointment.finish){
        return(
            SizedBox.shrink()
        );
      }else{
        return(
            SizedBox(
              child: ElevatedButton(
              child: const Text('キャンセル'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                onPrimary: Colors.white,
              ),
            )
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        color: Color(int.parse("0xffE7F1F7")),
        child: Column(
          children: <Widget> [
            Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: Row(
                children: <Widget> [
                  GestureDetector(
                      onTap: (){
                        setState(() {
                          _selectIndex = 0;
                          selectedColorThisMonth = Colors.white;
                          selectedColorNextMonth = Colors.white;
                          selectedColorLastMonth = Color(int.parse("0xff99CCFF"));
                        });
                      },
                      child: new Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(1),
                          color: selectedColorLastMonth,
                        ),
                        //color: selectedColorLastMonth,
                        child: Text("先月"),
                      )
                  ),
                  GestureDetector(
                      onTap: (){
                        setState(() {
                          _selectIndex = 1;
                          selectedColorThisMonth = Color(int.parse("0xff99CCFF"));
                          selectedColorNextMonth = Colors.white;
                          selectedColorLastMonth = Colors.white;
                        });
                      },
                      child: new Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(1),
                          color: selectedColorThisMonth,
                        ),
                        // color: selectedColorThisMonth,
                        child: Text("今月"),
                      )
                  ),
                  GestureDetector(
                      onTap: (){
                        setState(() {
                          _selectIndex = 2;
                          selectedColorThisMonth = Colors.white;
                          selectedColorNextMonth = Color(int.parse("0xff99CCFF"));
                          selectedColorLastMonth = Colors.white;
                        });
                      },
                      child: new Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(1),
                          color: selectedColorNextMonth,
                        ),
                        // color: selectedColorNextMonth,
                        child: Text("来月"),
                      )
                  ),
                ],
              ),
            ),

            IndexedStack(
                index: _selectIndex,
                children: <Widget>[
                  //TODO::値をうまく渡して描画できるように
                  Padding(
                  padding: const EdgeInsets.all(1.0),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: _thisMonthLists.length == 0
                      ? Text('先月のカルテはありません',
                            textAlign: TextAlign.center,
                            style: TextStyle( fontSize: 15, color: Colors.black, ),
                        )
                      : Container(
                        child: ListView.builder(
                          shrinkWrap: true, // 追加
                          itemCount: _lastMonthLists.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(1),
                                  color: (_lastMonthLists[index].appointment.finish) ? Color(int.parse("0xffDDDDDD")) : Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: <Widget> [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        child: Text(_parseApoTime(_lastMonthLists[index].appointment.appointment_time))
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        child: Text('${_lastMonthLists[index].appointment.store_name}\n${_lastMonthLists[index].appointment.fitness_name}')
                                      ),
                                      _appointmentTag(_lastMonthLists[index]),
                                      _detailButton(_lastMonthLists[index]),
                                    ]
                                  )
                                )

                              ),
                            );
                          },
                        )
                      ),
                    ),
                  ),

                  // 今月のカルテ
                  Padding(
                  padding: const EdgeInsets.all(1.0),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: _thisMonthLists.length == 0
                      ? Text('今月のカルテはありません',
                            textAlign: TextAlign.center,
                            style: TextStyle( fontSize: 15, color: Colors.black, ),
                        )
                      : Container(
                        child: ListView.builder(
                          shrinkWrap: true, // 追加
                          itemCount: _thisMonthLists.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(1),
                                  color: (_thisMonthLists[index].appointment.finish) ? Color(int.parse("0xffDDDDDD")) : Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: <Widget> [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        child: Text(_parseApoTime(_thisMonthLists[index].appointment.appointment_time))
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        child: Text('${_thisMonthLists[index].appointment.store_name}\n${_thisMonthLists[index].appointment.fitness_name}')
                                      ),
                                      _cancelButton(_thisMonthLists[index].appointment),
                                      _detailButton(_thisMonthLists[index]),
                                    ]
                                  )
                                )

                              ),
                            );
                          },
                        )
                      ),
                    ),
                  ),

                  // 来月のカルテ
                Padding(
                  padding: const EdgeInsets.all(1.0),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: _nextMonthLists.length == 0
                      ? Text('来月のカルテはありません',
                            textAlign: TextAlign.center,
                            style: TextStyle( fontSize: 15, color: Colors.black, ),
                        )
                      : Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _nextMonthLists.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(1),
                                  color: (_nextMonthLists[index].appointment.finish) ? Color(int.parse("0xffDDDDDD")) : Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: <Widget> [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        child: Text(_parseApoTime(_nextMonthLists[index].appointment.appointment_time))
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        child: Text('${_nextMonthLists[index].appointment.store_name}\n${_nextMonthLists[index].appointment.fitness_name}')
                                      ),
                                      _cancelButton(_nextMonthLists[index].appointment),
                                      _detailButton(_nextMonthLists[index]),
                                    ]
                                  )
                                )
                              ),
                            );
                          },
                        )
                      ),
                    ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}


class MainData {
  final Appointment appointment;
  final Record record;
  final Trainer trainer;
  final Ticket ticket;
  final PurchasedTicket purchased_ticket;

  MainData(
      this.appointment,
      this.record,
      this.trainer,
      this.ticket,
      this.purchased_ticket,
  );

  factory MainData.fromJson(Map<String, dynamic> json) {
    return MainData(
      Appointment.fromJson(json["appointment"]),
      Record.fromJson(json["record"]),
      Trainer.fromJson(json["trainer"]),
      Ticket.fromJson(json["ticket"]),
      PurchasedTicket.fromJson(json["purchased_ticket"]),
    );
  }

}

class Appointment {
  final int id;
  final String appointment_time;
  final String free_box;
  final String store_name;
  final String fitness_name;
  final bool finish;
  final bool room_plus;
  final bool cancel;

  Appointment(
      this.id,
      this.store_name,
      this.appointment_time,
      this.free_box,
      this.fitness_name,
      this.finish,
      this.room_plus,
      this.cancel,
  );

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      json["id"],
      json["store_name"],
      json["appointment_time"],
      json["free_box"],
      json["fitness_name"],
      json["finish"],
      json["room_plus"],
      json["cancel"],
    );
  }

}

class Record {
  final CustomerRecord customerRecord;
  final List<CustomerRecordMenue> recordMenues;

  Record(
      this.customerRecord,
      this.recordMenues,
  );

  var noCustomerRecordMenue = [];

  factory Record.fromJson(Map<String, dynamic> json) {
    final recordMenues = json["menues"] as List;

    if (recordMenues != null){
      return Record(
        CustomerRecord.fromJson(json["record"]),
        recordMenues.map((e) => CustomerRecordMenue.fromJson(e),).toList(),
      );
    } else {
      return Record(
        CustomerRecord.fromJson(json["record"]),
        recordMenues,
      );
    }
  }

}

class CustomerRecord {
  final int id;
  final int appointment_id;
  final int customer_id;
  final int trainer_id;
  final String apo_time;
  final String detail;

  CustomerRecord(
      this.id,
      this.appointment_id,
      this.customer_id,
      this.trainer_id,
      this.apo_time,
      this.detail,
  );

  factory CustomerRecord.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return CustomerRecord(
        json["id"],
        json["appointment_id"],
        json["customer_id"],
        json["trainer_id"],
        json["apo_time"],
        json["detail"],
      );
    }else{
      return null;
    }
  }

}

class CustomerRecordMenue {
  final int id;
  final int time;
  final int weight;
  final int fitness_third_id;
  final int customer_record_id;
  final int fitness_id;
  final String fitness_name;
  final String fitness_third_name;

  CustomerRecordMenue(
      this.id,
      this.time,
      this.weight,
      this.fitness_third_id,
      this.customer_record_id,
      this.fitness_id,
      this.fitness_name,
      this.fitness_third_name,
  );

  factory CustomerRecordMenue.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return CustomerRecordMenue(
        json["id"],
        json["time"],
        json["weight"],
        json["fitness_third_id"],
        json["customer_record_id"],
        json["fitness_id"],
        json["fitness_name"],
        json["fitness_third_name"],
      );
    }else{
      return null;
    }
  }

}

// トレーナー
class Trainer {
  final int id;
  final int company_id;
  final String first_name_kanji;
  final String last_name_kanji;
  final String first_name_kana;
  final String last_name_kana;

  Trainer(
      this.id,
      this.company_id,
      this.first_name_kanji,
      this.last_name_kanji,
      this.first_name_kana,
      this.last_name_kana,
  );

  factory Trainer.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Trainer(
        json["id"],
          json["company_id"],
          json["first_name_kanji"],
          json["last_name_kanji"],
          json["first_name_kana"],
          json["last_name_kana"],
      );
    }else{
      return null;
    }
  }

}

// 繰越チケット
class Ticket {
  final int id;
  final int customer_id;
  final int appointment_id;
  final String expiration_date;
  final bool usable;
  final bool finish;

  Ticket(
      this.id,
      this.customer_id,
      this.appointment_id,
      this.expiration_date,
      this.usable,
      this.finish,
  );

  factory Ticket.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Ticket(
        json["id"],
        json["customer_id"],
        json["appointment_id"],
        json["expiration_date"],
        json["usable"],
        json["finish"],
      );
    }else{
      return null;
    }
  }
}

// 購入チケット
class PurchasedTicket {
  final int id;
  final int customer_id;
  final int appointment_id;
  final String use_time;  // DateTime型
  final String payment_date;  // Date型
  final String ticketing_date;  // Date型
  final bool finish;

  PurchasedTicket(
      this.id,
      this.customer_id,
      this.appointment_id,
      this.use_time,  // DateTime型
      this.payment_date,  // Date型
      this.ticketing_date,  // Date型
      this.finish,
  );

  factory PurchasedTicket.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return PurchasedTicket(
        json["id"],
        json["customer_id"],
        json["appointment_id"],
        json["use_time"],
        json["payment_date"],
        json["ticketing_date"],
        json["finish"],
      );
    }else{
      return null;
    }
  }
}