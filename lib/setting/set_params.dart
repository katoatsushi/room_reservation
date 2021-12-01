const bool isProduction = bool.fromEnvironment('dart.vm.product');

const VariablesDev = {
  'isProd': false,
  'apiBaseUri': 'http://localhost:3000',
  // 'apiBaseUri': 'https://room-backend-sample.herokuapp.com',
  'company_id': 1
};

const VariablesProd = {
  'isProd': true,
  'apiBaseUri': 'https://room-backend-sample.herokuapp.com',
  'company_id': 4
};

final environment = isProduction ? VariablesProd : VariablesDev;


// 呼び出し方
// import '../setting/set_params.dart';
// final String _apiBaseUri = environment['apiBaseUri'];