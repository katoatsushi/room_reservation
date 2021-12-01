import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:room_reservation/appointments/select_store_fitness.dart';
import 'dart:convert';
import '../customer/get_customer_status.dart';
import '../setting/set_params.dart';

class RoomPlusList extends StatefulWidget {
  const RoomPlusList({Key key}) : super(key: key);

  @override
  _RoomPlusListState createState() => _RoomPlusListState();
}

class _RoomPlusListState extends State<RoomPlusList> {
  List<RoomPlusData> _roomPlusList = [];
  bool _isLoad = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<http.Response> initialize() async {
    
    setState(() { _isLoad = true; });

    final int company_id = environment['company_id'];
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/room_plus_ios/company/${company_id}";

    var resp = await http.get(url);
    var body =  json.decode(resp.body);

    final responseData = (body["data"] as List).map((e) => RoomPlusData.fromJson(e)).toList();

    setState(() {
      _roomPlusList = responseData;
      _isLoad = false;
    });

  }

  Widget roomPlusByStore(data){
    List<Widget> items = [];

    items.add(Text('${data.month}/${data.day}【${data.store_name}】', style: TextStyle( fontSize: 20 )));
    data.time_cell.forEach((TimeCell cell){
        items.add(Text('${cell.time_range}', style: TextStyle( fontSize: 18 )));
    });

    Widget response = Container(
        //  width: MediaQuery.of(context).size.width * 0.50,
        child: Column( children: items )
    );

    return response;
  }

  List<Widget> roomPlusItems(roomPlusStores){
    List<Widget> items = [];

    roomPlusStores.forEach((RoomPlusData roomPlusData){
      var dataByStore = roomPlusByStore(roomPlusData);
      // dataByStore は Container
      items.add(dataByStore);

    });

    return items;
  }

  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'room_plus',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Roomプラス'),
        ),
        body: Center(
        child: _isLoad 
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                Text("roomプラス予約可能時刻をロード中です",style: TextStyle(fontSize: 15.0),),
              ],
            ),
          )
        : Container(
          child: Column(
            children: [

            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 20),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: roomPlusItems(_roomPlusList)
                    ),
                  )
                ),
              ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                child: Text("下にスクロールしてください", style: TextStyle( fontSize: 15 , color: Colors.black87)),
              ),
            ]
          )
        )
      )
      ),
    );

  }

}

class RoomPlusData {

  final int month;
  final int day;
  final String store_name;
  final List<TimeCell> time_cell;

  RoomPlusData(
    this.month,
    this.day,
    this.store_name,
    this.time_cell,
  );

  factory RoomPlusData.fromJson(Map<String, dynamic> json) {
    final recordMenues = json["data"] as List;

    return RoomPlusData(

      json["month"],
      json["day"],
      json["store_name"],
      recordMenues.map((e) => TimeCell.fromJson(e),).toList(),
      
    );
  }

}

class TimeCell {
  final String time_range;
  final int available;

  TimeCell(
    this.time_range,
    this.available,
  );
  factory TimeCell.fromJson(Map<String, dynamic> json) {
    return TimeCell(
        json["time_range"],
        json["available"]
    );
  }
}
