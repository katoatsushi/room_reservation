import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// notice::method名を _getAuthTokens にすると外部で呼び出せなくなる
Future <String> getCustomerStatus() async {
  final storage = new FlutterSecureStorage();

  String customer_status = await storage.read(key: 'customer_status');

  return customer_status;
}

// 呼び出し方
// var headers = await _getAuthTokens();