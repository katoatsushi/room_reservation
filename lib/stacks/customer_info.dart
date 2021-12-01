import 'package:flutter/material.dart';
import '../customer/record_history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';
import '../customer/account_setting.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import './weight_history.dart';

class CustomerInfos extends StatefulWidget {
  const CustomerInfos({Key key}) : super(key: key);
  @override
  _CustomerInfoPage createState() => _CustomerInfoPage();
}

class _CustomerInfoPage extends State<CustomerInfos> {
  List<bool> _selections = List.generate(2, (_) => false);
  Customer _customer;
  CustomerInfo _customer_info;
  CustomerStatus _customer_status;
  List<Interest> _customer_interests;
  List<Interest>  _all_interests;
  var _chipList = List<Chip>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // 予約情報を取得
  Future<http.Response> initialize() async {
    var customer_id = 3;
    var headers = await getTokens();

    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/return_customer_info";

    final resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);

    final customer = Customer.fromJson(body["data"]["customer"]);
    final customer_info = CustomerInfo.fromJson(body["data"]["customer_info"]);
    final customer_status = CustomerStatus.fromJson(body["data"]["customer_status"]);
    final customer_interests = (body["data"]["customer_intrests"] as List).map((e) => Interest.fromJson(e)).toList();
    final all_interests = (body["interests"] as List).map((e) => Interest.fromJson(e)).toList();

    setState(() {
      _customer = customer;
      _customer_info = customer_info;
      _customer_status = customer_status;
      _customer_interests = customer_interests;
      _all_interests = all_interests;
    });

    customer_interests.forEach((interest) {
      _chipList.add(
        Chip(
          backgroundColor: Colors.lightBlue[100],
          // key: interest.id,
          label: Text(interest.name),
          // onDeleted: () => _deleteChip(chipKey),
        ),
      );
    });

  }

  Widget registerStatus(data){
    String statusString;
    String timeString;
    if( data.dead_line != null){
      DateTime datetime = DateTime.parse(data.dead_line).toLocal();
      timeString = '( ${datetime.year}'+"年"+'${datetime.month}'+"月"+'${datetime.day}'+"日 ";
    }else{
      timeString = "";
    }
    if(data.status == "unenrolled"){
      statusString = "未入会";
    }else if(data.status == "join_in"){
      statusString = "会員";
    }else if(data.status == "recess"){
      statusString = "休会" + timeString +"日付)";
    }else if(data.status == "quit"){
      statusString = "退会" + timeString +"日付)";
    }
    return(
      Padding(
        padding: const EdgeInsets.only(top: 5, left: 10),
        child: Text('${statusString}', textAlign: TextAlign.left),
      )
    );
  }


  // final weightList = <WeightData>[
  //   WeightData(DateTime(2020, 10, 2), 50),
  //   WeightData(DateTime(2020, 10, 3), 53),
  //   WeightData(DateTime(2020, 10, 4), 40),
  //   WeightData(DateTime(2020, 10, 5), 50),
  //   WeightData(DateTime(2020, 10, 6), 53),
  //   WeightData(DateTime(2020, 10, 7), 40)
  // ];

  // List<charts.Series<WeightData, DateTime>> _createWeightData(List<WeightData> weightList) {
  //   return [
  //     charts.Series<WeightData, DateTime>(
  //       id: 'Muscles',
  //       data: weightList,
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (WeightData weightData, _) => weightData.date,
  //       measureFn: (WeightData weightData, _) => weightData.weight,
  //     )
  //   ];
  // }

  @override
  Widget build(BuildContext context) {

   return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('マイページ'),
        ),        
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center( // 個人情報
                child: Container(
                  color: Colors.white10,
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.15,

                  child: _customer != null ?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 10),
                        child: Text('${_customer.first_name_kanji} ${_customer.last_name_kanji}', 
                           style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        textAlign: TextAlign.left),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 10),
                        child: Text('${_customer.first_name_kana} ${_customer.last_name_kana}', textAlign: TextAlign.left),
                      ),
                      registerStatus(_customer),
                    ],
                  )
                  :Column(children: [])

                ),
              ),
              Text('興味・関心', 
                    style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                textAlign: TextAlign.left),
              // 興味関心
              // 興味関心リストが12個以上ある場合は、さらに見るのような表記にするか、スクロール
              Container(
                color: Colors.white10,
                width: MediaQuery.of(context).size.width * 0.95,
                // height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 3.0,
                        runSpacing: 0.0,
                        direction: Axis.horizontal,
                        children: _chipList,
                      ),
                    ),
                  ],
                ),
              ),
              Text('体重変化', 
                    style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                textAlign: TextAlign.left),
              // 体重変化
              Container(
                // color: Colors.black87,
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.40,
                child: TopPage(),
                // child: charts.TimeSeriesChart(
                //   _createWeightData(weightList),
                // ),
              ),
            ],
          )
        )
      )
   );
  } 
}

class WeightData {
  final DateTime date;
  final double weight;

  WeightData(this.date, this.weight);
}

class Customer {
  final int id;
  final String first_name_kanji;
  final String last_name_kanji;
  final String first_name_kana;
  final String last_name_kana;
  final String email;
  final String status;
  final String dead_line;

  Customer(
    this.id,
    this.first_name_kanji,
    this.last_name_kanji,
    this.first_name_kana,
    this.last_name_kana,
    this.email,
    this.status,
    this.dead_line
  );

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      json["id"],
      json["first_name_kanji"],
      json["last_name_kanji"],
      json["first_name_kana"],
      json["last_name_kana"],
      json["email"],
      json["status"],
      json["dead_line"]
    );
  }
}

class CustomerInfo {
  final int id;
  final String age;
  final String birthday;
  final String postal_code;
  final String address;
  final String gender;
  final String phone_number;
  final String emergency_phone_number;
  final int job_id;
  final String job_name;

  CustomerInfo(
      this.id,
      this.age,
      this.birthday,
      this.postal_code,
      this.address,
      this.gender,
      this.phone_number,
      this.emergency_phone_number,
      this.job_id,
      this.job_name,
  );

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      json["id"],
      json["age"],
      json["birthday"],
      json["postal_code"],
      json["address"],
      json["gender"],
      json["phone_number"],
      json["emergency_phone_number"],
      json["job_id"],
      json["job_name"],
    );
  }
}

class CustomerStatus {
  final int id;
  final String appointment_time;
  final String free_box;
  final String store_name;
  final String fitness_name;
  final bool finish;
  final bool room_plus;
  final bool cancel;

  CustomerStatus(
      this.id,
      this.store_name,
      this.appointment_time,
      this.free_box,
      this.fitness_name,
      this.finish,
      this.room_plus,
      this.cancel,
  );

  factory CustomerStatus.fromJson(Map<String, dynamic> json) {
    return CustomerStatus(
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

class Interest {
  final int id;
  final String name;
  final int interest_family_id;

  Interest(
      this.id,
      this.name,
      this.interest_family_id,
  );

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      json["id"],
      json["name"],
      json["interest_family_id"],
    );
  }
}