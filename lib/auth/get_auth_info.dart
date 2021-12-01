import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// notice::method名を _getAuthTokens にすると外部で呼び出せなくなる
Future <Map<String, String>> getAuthTokens() async { 
      final storage = new FlutterSecureStorage();

      String client = await storage.read(key: 'client');
      String access_token = await storage.read(key: 'access-token');
      String uid = await storage.read(key: 'uid');

      Map<String, String> response  = {'client': client, 'access-token': access_token,'uid': uid};

      return response;
}

// 呼び出し方
// var headers = await _getAuthTokens();

// notice::method名を _getAuthTokens にすると外部で呼び出せなくなる
Future <Map<String, String>> getTokens() async { 
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final client = prefs.getString('client') ?? '';
      final accessToken = prefs.getString('access-token') ?? '';
      final uid = prefs.getString('uid') ?? '';

      Map<String, String> response  = {'client': client, 'access-token': accessToken,'uid': uid};

      return response;
}

// 呼び出し方
// var headers = await _getTokens();