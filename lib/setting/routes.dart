import 'package:flutter/material.dart';
import '../appointments/create_confirm.dart';
import '../appointments/create_result.dart';
import '../appointments/error_result.dart';
import '../appointments/room_plus_list.dart';
import '../appointments/select_date.dart';
import '../appointments/select_store_fitness.dart';
import '../appointments/select_time.dart';
import '../auth/login.dart';
import '../stacks/my_page.dart';
import '../cupertino_tab_scaffold.dart';

// ルーティング一覧
void main() {
  runApp(
    MaterialApp(
      title: 'Room予約システム',
      initialRoute: '/log_in',
      routes: {
        '/': (context) => CupertinoMainBar(),
        '/log_in': (context) => LogIn(),
        '/room_plus': (context) => RoomPlusList(),
        '/my_page': (context) => MyPage(),
        '/select_store_fitness': (context) => SelectStoreFitness(),
        '/select_date': (context) => SelectDate(),
        '/select_time': (context) => SelectTime(),
        '/confirm': (context) => CreateConfirm(),
        '/confirm_success': (context) => CreateResult(),
        '/confirm_error': (context) => ErrorResult(),
      },
    ),
  );
}

class PushCupertinoMainBar extends StatelessWidget {

  @override
  final int index_id;
  PushCupertinoMainBar(this.index_id); 

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => CupertinoMainBar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoMainBar(index_id: index_id);
  }
}