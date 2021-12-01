import 'package:flutter/material.dart';
import '../customer/record_history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';
import '../customer/account_setting.dart';


class MyPage extends StatefulWidget {
  const MyPage({Key key}) : super(key: key);
  static String id = 'my_page';

  @override
  _CustomerMyPage createState() => _CustomerMyPage();
}

class _CustomerMyPage extends State<MyPage> {
  List<bool> _selections = List.generate(2, (_) => false);
  int _selectIndex = 0;
  int this_month = 0;  // 今月予約可能枠
  int next_month = 0;  // 来月予約可能枠
  int ticket= 0;
  int purchased_tickets = 0;
  int this_month_total = 0;
  int next_month_total = 0;
  bool _isLoad = true;
  var selectedColorThisMonth = Color(int.parse("0xff99CCFF"));
  var selectedColorNextMonth = Colors.white;
  var _city = '';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // 予約情報を取得
  Future<http.Response> initialize() async {
    // header呼び出し
    var headers = await getTokens();
    
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/return_customer_all_info/ios";

    final resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);

    final int numbers_of_contract = body["numbers_of_contract"];

    var this_month_count = numbers_of_contract - body["this_month_book_count"];
    if(this_month_count < 0){
      this_month_count = 0;
    }

    var next_month_count = numbers_of_contract - body["next_month_book_count"];
    if(next_month_count < 0){
      next_month_count = 0;
    }
    final int ticket_count = body["tickets"].length;
    final int purchased_ticket_count = body["purchased_tickets"].length;

    setState(() {
      ticket = ticket_count;
      purchased_tickets = purchased_ticket_count;
      this_month = this_month_count;
      next_month = next_month_count;
      this_month_total = this_month_count + ticket_count + purchased_ticket_count;
      next_month_total = next_month_count + purchased_ticket_count;
      _isLoad = false;
    });
  }

  Widget tabMenues(){
    return(
        Drawer(
          child: ListView(
            children: <Widget>[

              DrawerHeader(
                child: Text(
                  '設定一覧',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),

              ListTile(
                title: Text('アカウント設定'),
                onTap: () {
                  setState(() => _city = 'Los Angeles, CA');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountSetting( )),
                  );
                },
              ),

            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

   return MaterialApp(
      title: 'select_date',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        appBar: AppBar(
          title: Text('マイページ'),
        ),

        // drawer: tabMenues(),
        
        body: Container(
        color: Color(int.parse("0xffE7F1F7")),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 上下真ん中に配置
          children: <Widget> [
            Row(
                children: <Widget> [
                  GestureDetector(
                      onTap: (){
                        setState(() {
                          _selectIndex = 0;
                          selectedColorThisMonth = Color(int.parse("0xff99CCFF"));
                          selectedColorNextMonth = Colors.white;
                        });
                      },
                      child: new Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(1),
                          color: selectedColorThisMonth,
                        ),
                        // color: selectedColorThisMonth,
                        alignment: Alignment.center,
                        child: Text("今月の予約枠", textAlign: TextAlign.center),
                      )
                  ),
                  GestureDetector(
                      onTap: (){
                          setState(() {
                            _selectIndex = 1;
                            selectedColorThisMonth = Colors.white;
                            selectedColorNextMonth = Color(int.parse("0xff99CCFF"));
                          });
                      },
                      child: new Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.07,
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(1),
                          color: selectedColorNextMonth,
                        ),
                        // color: selectedColorNextMonth,
                        alignment: Alignment.center,
                        child: Text("来月の予約枠", textAlign: TextAlign.center),
                      )
                  ),
                ],
            ),

            IndexedStack(
              index: _selectIndex,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.white,
                    child: Padding(
                        padding:  const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                      child: Column(
                          children: <Widget> [
                            Container(
                              child: Row(
                                  children: <Widget> [
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.21,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Text("予約可能枠",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    ),
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.21,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Text("先月繰越分",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    ),
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.21,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Text("都度チケット",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    ),
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.08,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Text("",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    ),
                                    Container(
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Text("今月予約可枠合計",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    ),
                                  ]
                              )
                            ),
                              Container(
                                  child: Row(
                                      children: <Widget> [
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.21,
                                            height: MediaQuery.of(context).size.height * 0.07,
                                            alignment: Alignment.center,
                                            child: _isLoad 
                                              ? CircularProgressIndicator() 
                                              :Text('${this_month}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                )
                                        ),
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.21,
                                            height: MediaQuery.of(context).size.height * 0.07,
                                            alignment: Alignment.center,
                                            child: _isLoad
                                              ? CircularProgressIndicator()
                                              : Text('${ticket}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                )
                                        ),
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.21,
                                            height: MediaQuery.of(context).size.height * 0.07,
                                            alignment: Alignment.center,
                                            child: _isLoad
                                              ? CircularProgressIndicator()
                                              : Text('${purchased_tickets}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                )
                                        ),
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.08,
                                            height: MediaQuery.of(context).size.height * 0.07,
                                            alignment: Alignment.center,
                                            child: Text("=",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            )
                                        ),
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.25,
                                            height: MediaQuery.of(context).size.height * 0.07,
                                            alignment: Alignment.center,
                                            child: _isLoad
                                              ? CircularProgressIndicator()
                                              : Text('${this_month_total}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                )
                                        ),
                                      ]
                                  )
                              ),
                          ]
                      ),
                    )
                ),
                // height: 0.2
                Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.white,
                    child: Padding(
                      padding:  const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                      child: Column(
                          children: <Widget> [
                            Container(
                                child: Row(
                                    children: <Widget> [
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          child: Text("予約可能枠",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          child: Text("先月繰越分",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          child: Text("都度チケット",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.08,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          child: Text("",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.25,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          child: Text("今月予約可枠合計",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          )
                                      ),
                                    ]
                                )
                            ),
                            Container(
                                child: Row(
                                    children: <Widget> [
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          // color: Colors.black,
                                          alignment: Alignment.center,
                                          child: Text('${next_month}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          child: Text('-',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.21,
                                          child: Text('${purchased_tickets}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.08,
                                          child: Text("=",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.25,
                                          child: Text('${next_month_total}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          )
                                      ),
                                    ]
                                )
                            ),
                          ]
                      ),
                    )
                ),
              ],
            ),

            RecordHistory(),

          ],
        ),
      ),

      )
   );

  }
}