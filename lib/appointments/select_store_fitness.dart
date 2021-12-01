import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './select_date.dart';
import '../customer/get_customer_status.dart';
import '../setting/set_params.dart';

class SelectStoreFitness extends StatefulWidget {
  const SelectStoreFitness({Key key}) : super(key: key);

  @override
  _SelectStoreFitnessState createState() => _SelectStoreFitnessState();
}

class _SelectStoreFitnessState extends State<SelectStoreFitness> {
  List<Store> _storeLists = [];
  List<Fitness> _fitnessLists = [];
  List<String> _storeNames = [];
  List<String> _fitnessNames = [];
  String selectedStoreName;
  String selectedFitnessName;
  int selectedStoreId;
  int selectedFitnessId;
  String _customerStatus;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<http.Response> initialize() async {
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/calendar/select_store_fitness";

    var resp = await http.get(url);
    var body =  json.decode(resp.body);
    final stores = (body["store"] as List).map((e) => Store.fromJson(e)).toList();
    final fitnesses = (body["fitnesses"] as List).map((e) => Fitness.fromJson(e)).toList();

    final storenames = (body["store"] as List).map((e) => e["store_name"].toString()).toList();
    final fitnessnames = (body["fitnesses"] as List).map((e) => e["name"].toString()).toList();

    var customerStatus = await getCustomerStatus();

    setState(() {
      _storeLists = stores;
      _fitnessLists = fitnesses;
      _storeNames = storenames;
      _fitnessNames = fitnessnames;
      _customerStatus = customerStatus;
    });

  }

  // Widget _cancelButton(BuildContext context) {}
  Widget _nextStepButton() {

      if (selectedStoreId != null && selectedFitnessId != null ) {
        return(
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                child: const Text('日程を選ぶ'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push( context, MaterialPageRoute(builder: (context) =>
                      SelectDate(
                        store_id: selectedStoreId, fitness_id: selectedFitnessId,
                        store_name: selectedStoreName, fitness_name: selectedFitnessName,
                      )
                  ),);
                },
              ),
            )
        );
      }else{
        return(

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                child: const Text('日程を選ぶ'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
        );
      }

  }

  // buildのうえにかく:overrideは描画を上書きする
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'select_store_fitness',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('予約'),
        ),
        body:       Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Text("店舗を選択してください"),
            ),
            InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStoreName,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black54),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    // TODO::ここに選ばれた店舗のidを選択
                    for (var store in _storeLists){
                      if(store.store_name == newValue){
                        setState(() {
                          selectedStoreId = store.id;
                        });
                      }
                    }
                    setState(() {
                      selectedStoreName = newValue;
                    });
                  },
                  items: _storeNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text("メニューを選択してください"),
            ),
            // TODO:: StringではなくStore型で回せるようにリファクタリング
            // 参考: https://www.fixes.pub/program/312523.html
            InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFitnessName,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black54),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    // TODO::ここに選ばれたメニューのidを選択
                    for (var fitness in _fitnessLists){
                      if(fitness.name == newValue){
                        setState(() { selectedFitnessId = fitness.id; });
                      }
                    }
                    setState(() {
                      selectedFitnessName = newValue;
                    });
                  },
                  items: _fitnessNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            // 店舗とメニューを選んでないと次に進めない
            _nextStepButton(),
          ],
        ),
      ),
      ),
    );

    // return Scaffold(
    //   body: Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       // crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
    //           child: Text("店舗を選択してください"),
    //         ),
    //         InputDecorator(
    //           decoration: const InputDecoration(border: OutlineInputBorder()),
    //           child: DropdownButtonHideUnderline(
    //             child: DropdownButton<String>(
    //               value: selectedStoreName,
    //               elevation: 16,
    //               style: const TextStyle(color: Colors.black54),
    //               underline: Container(
    //                 height: 2,
    //                 color: Colors.deepPurpleAccent,
    //               ),
    //               onChanged: (String newValue) {
    //                 // TODO::ここに選ばれた店舗のidを選択
    //                 for (var store in _storeLists){
    //                   if(store.store_name == newValue){
    //                     setState(() {
    //                       selectedStoreId = store.id;
    //                     });
    //                   }
    //                 }
    //                 setState(() {
    //                   selectedStoreName = newValue;
    //                 });
    //               },
    //               items: _storeNames.map<DropdownMenuItem<String>>((String value) {
    //                 return DropdownMenuItem<String>(
    //                   value: value,
    //                   child: Text(value),
    //                 );
    //               }).toList(),
    //             ),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
    //           child: Text("メニューを選択してください"),
    //         ),
    //         // TODO:: StringではなくStore型で回せるようにリファクタリング
    //         // 参考: https://www.fixes.pub/program/312523.html
    //         InputDecorator(
    //           decoration: const InputDecoration(border: OutlineInputBorder()),
    //           child: DropdownButtonHideUnderline(
    //             child: DropdownButton<String>(
    //               value: selectedFitnessName,
    //               elevation: 16,
    //               style: const TextStyle(color: Colors.black54),
    //               underline: Container(
    //                 height: 2,
    //                 color: Colors.deepPurpleAccent,
    //               ),
    //               onChanged: (String newValue) {
    //                 // TODO::ここに選ばれたメニューのidを選択
    //                 for (var fitness in _fitnessLists){
    //                   if(fitness.name == newValue){
    //                     setState(() { selectedFitnessId = fitness.id; });
    //                   }
    //                 }
    //                 setState(() {
    //                   selectedFitnessName = newValue;
    //                 });
    //               },
    //               items: _fitnessNames.map<DropdownMenuItem<String>>((String value) {
    //                 return DropdownMenuItem<String>(
    //                   value: value,
    //                   child: Text(value),
    //                 );
    //               }).toList(),
    //             ),
    //           ),
    //         ),
    //         // 店舗とメニューを選んでないと次に進めない
    //         _nextStepButton(),
    //       ],
    //     ),
    //   ),
    // );

  }
}

class Store {
  final int id;
  final String store_name;
  final String store_address;

  Store(
      this.id,
      this.store_name,
      this.store_address,
      );

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      json["id"],
      json["store_name"],
      json["store_address"]
    );
  }
}

class Fitness {
  final int id;
  final String name;
  final int company_id;

  Fitness(
      this.id,
      this.name,
      this.company_id
      );

  factory Fitness.fromJson(Map<String, dynamic> json) {
    return Fitness(
        json["id"],
        json["name"],
        json["company_id"]
    );
  }
}
