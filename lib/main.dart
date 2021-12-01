import 'package:flutter/material.dart';
import './cupertino_tab_scaffold.dart';
import './stacks/my_page.dart';
import './appointments/select_store_fitness.dart';
import './customer/record_history.dart';
import './auth/login.dart';
import 'cupertino_tab_scaffold.dart';
import './auth/get_auth_info.dart';
import './setting/set_params.dart';
import './customer/account_setting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // stream型の関数
  Future<bool> isLoggedIn() async {
    var headers =  await getTokens();
    if(headers == null){
      return false;
    }else{
      var headers = await getTokens();
      final String _apiBaseUri = environment['apiBaseUri'];
      String url = _apiBaseUri + '/auth/check/customer';
      final resp = await http.get(url, headers: headers);
      final int statusCode = resp.statusCode;

      if(statusCode~/100 == 2){
        // 200台のステータスコードなら成功
        print("ステータスコード");
        print(statusCode);
        return true;
      }else{
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 日本語フォントに直す
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
      ],
      // ここまで
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            // ロード中
            return const SizedBox();
          }
          if(!snapshot.hasData){
            // snapshotにデータがない時
            return const SizedBox();
          }
          return snapshot.data ? CupertinoMainBar(index_id: 1) : LogIn();
        }
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder> {
        '/root': (BuildContext context) => new CupertinoMainBar(),
        '/home': (BuildContext context) => new MyPage(),
        '/record_history': (BuildContext context) => new RecordHistory(),
        '/appointment': (BuildContext context) => new SelectStoreFitness(),
      },
    );
  }

  // FutureBuilder(
  //   future: initialize(),
  //   builder: (context, snapshot) {
  //   return MaterialApp(
  //     home: initialize()
  //     ? LogIn()
  //     : CupertinoMainBar(index_id: 1),
  //     debugShowCheckedModeBanner: false,
  //     routes: <String, WidgetBuilder> {
  //       '/root': (BuildContext context) => new CupertinoMainBar(),
  //       '/home': (BuildContext context) => new MyPage(),
  //       '/record_history': (BuildContext context) => new RecordHistory(),
  //       '/appointment': (BuildContext context) => new SelectStoreFitness(),
  //     },
  //   );
  //   },
  // )

}