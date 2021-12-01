import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../stacks/my_page.dart';
import '../cupertino_tab_scaffold.dart';
import '../main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../setting/routes.dart';
import '../setting/set_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'login',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Room'),
        ),
        body: Center(
          child: LogInForm(),
        ),
      ),
    );
  }
}

class LogInForm extends StatefulWidget {
  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final storage = new FlutterSecureStorage();

  String _email = '';
  String _password = '';
  // String _email = 'ka.baseball1997@gmail.com';
  // String _password = 'gonza1026';
  bool _isError = false;
  bool _isSubmit = false;
  String _content = '';

  void _handleEmail(String e) {
    setState(() { _email = e; });
  }

  void _handlePassword(String e) {
    setState(() { _password = e; });
  }

  Future<void> _handleSubmit() async {
    setState(() { _isSubmit = true; });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/v1/customer_auth/sign_in";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({'email': _email, 'password': _password, 'from': 'ios'});
    http.Response resp = await http.post(url, headers: headers, body: body);
  

    var responseBody = json.decode(resp.body);
    if (resp.headers['client'] != null && resp.headers['access-token'] != null && responseBody['data']['status'] != null) {
      // FlutterSecureStorage
      await storage.write(key: 'client', value: resp.headers['client']);
      await storage.write(key: 'access-token', value: resp.headers['access-token']);
      await storage.write(key: 'uid', value: resp.headers['uid']);
      await storage.write(key: 'customer_status', value: responseBody['data']['status']);

      // SharedPreferenceに保存
      await prefs.setString('client', resp.headers['client']);
      await prefs.setString('access-token', resp.headers['access-token']);
      await prefs.setString('uid', resp.headers['uid']);
      await prefs.setString('customer_status', responseBody['data']['status']);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return CupertinoMainBar(index_id: 0);
      }));


    }

    if (responseBody['errors'] != null) {
      _isError = true;
      String errorMessage = responseBody['errors'][0];
      _content = errorMessage;
      _isSubmit = false;
    }


    setState(() {
      _isSubmit = false;
    });
  }

  // _incrementCounter() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int counter = (prefs.getInt('counter') ?? 0) + 1;
  //   print('Pressed $counter times.');
  //   await prefs.setInt('counter', counter);
  // }

  Widget _registrationSubmit() {
    if (_email.length > 6 && _password.length >= 6) {
      if(_isSubmit){
        return(
          SizedBox(
            width: MediaQuery.of(context).size.width * 1.0,
            height: 50,
            child: ElevatedButton(
                child: const Text('ログイン確認中'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
              )
          )
        );
      }else{
        return(
          SizedBox(
            width: MediaQuery.of(context).size.width * 1.0,
            height: 50,
            child: ElevatedButton(
                child: const Text('ログイン'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
                onPressed: _handleSubmit,
              )
          )
        );
      }
    } else {
      return(
        SizedBox(
          width: MediaQuery.of(context).size.width * 1.0,
          height: 50,
          child: ElevatedButton(
              child: const Text('ログイン'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                onPrimary: Colors.white,
              ),
            )
        )
      );
    }

  }

  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 20,right: 20, top: 50),
        child: Column(
          children: <Widget>[
            //TODO::TextFormFieldを使ってバリデーションを追加
            //TODO::email最低6文字以上
            //TODO::メールアドレスのバリデーション
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: new Text(
                  "お客様ログインページ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: new Text(
                  "メールアドレスとパスワードを入力し、\nログインボタンを押してください。",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: new TextField(
                enabled: true,
                maxLengthEnforced: false,
                style: TextStyle(color: Colors.black),
                obscureText: false,
                maxLines:1 ,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'メールアドレスを入力してください'
                ),
                onChanged: _handleEmail,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: new TextField(
                enabled: true,
                maxLengthEnforced: false,
                style: TextStyle(color: Colors.black),
                obscureText: true,
                maxLines:1 ,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'パスワードを入力してください'
                ),
                onChanged: _handlePassword,
              ),
            ),
            
           //  CircularProgressIndicator(),
          _registrationSubmit(),
          _isError
            ? Text("${_content}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              )
            : SizedBox.shrink(),

          ],
        )
    );
  }
}