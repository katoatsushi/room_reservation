import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';

// 参考:: https://note.com/hatchoutschool/n/n360353b7f6cc
class TopPage extends StatefulWidget {
 @override
 _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  // WeightData _weightdata
  Map<DateTime, double> _weightData;

  Map<DateTime, double> _data = {};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // 予約情報を取得
  Future<http.Response> initialize() async {
    var headers = await getTokens();
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer_weight";
    final resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);
    print(body);

    for (var obj in body) {
      print(obj);
      DateTime datetime = DateTime.parse('${obj["created_at"]}').toLocal(); 
      print(datetime);
      Map<DateTime, double> NewData = {datetime : obj["weight"]}; //追加する新しいMap
      _data.addAll(NewData);
    }

    // map_name['key'] = 'vallue';
  }

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();

    // Map<DateTime, double> _data = {
    //   now.add(Duration(days: -13)) : 65.9,
    //   now.add(Duration(days: -12)) : 70.5,
    //   now.add(Duration(days: -11)) : 82.5,
    //   now.add(Duration(days: -10)) : 76.2,
    //   now.add(Duration(days: -9)) : 83.2,
    //   now.add(Duration(days: -8)) : 77.5,
    //   now.add(Duration(days: -7)) : 65.9,
    //   now.add(Duration(days: -6)) : 70.5,
    //   now.add(Duration(days: -5)) : 82.5,
    //   now.add(Duration(days: -4)) : 76.2,
    //   now.add(Duration(days: -3)) : 83.2,
    //   now.add(Duration(days: -2)) : 77.5,
    //   now.add(Duration(days: -1)) : 65.9,
    //   now : 82.3,
    // };

   return OriginalGraph(
         data:  _data,
         width: double.infinity,
         height: double.infinity,
    );
 }

}

class OriginalGraph extends StatelessWidget {

 final Map<DateTime, double> data;
 final double width;
 final double height;

 OriginalGraph({this.data, this.width, this.height});

 @override
 Widget build(BuildContext context) {
   return Container(
     color: Colors.white.withOpacity(0.2),
     width: this.width,
     height: this.height,
     child: CustomPaint(
       painter: GraphPainter(
         data: this.data,
       ),
     ),
   );
 }
}

class GraphPainter extends CustomPainter {

 final Map<DateTime, double> data;
 GraphPainter({this.data});

 double padding = 22.0;
 double graphPadding = 1.0;
 double maxValue;

 @override
 void paint(Canvas canvas, Size size) {
   double graphWidth = size.width - (padding * 2);
   double graphHeight = size.height - (padding * 2);

   List<OriginalPath> fillPathList = [];
   fillPathList.add(OriginalPath(x: padding, y: size.height - padding));
   
   Map<DateTime, double> _data = adjustData(data);

   DateTime startDate = _data.keys.toList()[0];
   DateTime lastDate = _data.keys.toList()[_data.length - 1];
   for(int i = 0; i <= lastDate.difference(startDate).inDays; i++) {
      // 縦の線
      canvas.drawLine(Offset(padding + (i * graphWidth / (lastDate.difference(startDate).inDays)), padding), Offset(padding + (i * graphWidth / (lastDate.difference(startDate).inDays)), size.height - padding), Paint()..color = Colors.black.withOpacity(0.3)..strokeWidth = 1);

      // プロット
      DateTime currentDate = startDate.add(Duration(days: i));
      if(_data.containsKey(currentDate)) {
        OriginalPath _originalPath = OriginalPath(x: padding + (i * graphWidth / (lastDate.difference(startDate).inDays)), y: size.height - padding - (graphHeight / (maxValue + graphPadding) * _data[currentDate]));
        canvas.drawCircle(Offset(_originalPath.x, _originalPath.y), 1, Paint()..color = Colors.black);

        // 塗り潰し描画のためのPath更新
        fillPathList.add(_originalPath);
      }

      // 横軸ラベル
      TextPainter(
        text: TextSpan(
          // text: intl.DateFormat('M/d').format(startDate.add(Duration(days: i))),
          text: intl.DateFormat('d').format(startDate.add(Duration(days: i))),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(
        minWidth: 0,
        maxWidth: size.width,
      )..paint(canvas, Offset(padding + (i * graphWidth / (lastDate.difference(startDate).inDays) - 10), size.height - padding + 5));
   }

   double _period = getPeriod(maxValue + graphPadding);
   for(int i = 0; i <= (maxValue + graphPadding) ~/ _period; i++) {
     // 横線
     double _height = size.height - padding - (graphHeight / (maxValue + graphPadding) * (i * _period));
     canvas.drawLine(Offset(padding - 10, _height), Offset(size.width - padding + 10, _height), Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1);

     // 縦軸ラベル
     TextPainter(
       text: TextSpan(
         text: '${(i * _period).round()}kg',
         style: TextStyle(
           color: Colors.grey,
           fontSize: 10,
         ),
       ),
       textDirection: TextDirection.rtl,
     )..layout(
       minWidth: 0,
       maxWidth: size.width,
     )..paint(canvas, Offset(padding - 27, _height - 7));
   }

   // 塗り潰し描画
   var fillPath = Path();
   for(int i = 0; i < fillPathList.length; i++) {
     if(i == 0) {
       fillPath.moveTo(fillPathList[i].x, fillPathList[i].y);
     } else {
       fillPath.lineTo(fillPathList[i].x, fillPathList[i].y);
     }
   }
   fillPath.lineTo(size.width - padding, size.height - padding);

   fillPath.close();
   canvas.drawPath(fillPath, Paint()..color = Colors.black.withOpacity(0.1));

 }

 double getPeriod(double num) {
   // グラフ縦軸の刻み幅
   return 5;
 }

 double getGraphPadding(double value) {
   // グラフの上プラスで10Kg
   return 10;
 }

 Map<DateTime, double> adjustData(Map<DateTime, double> map) {
   Map<DateTime, double> _map = {};
   map.forEach((key, value) {
     _map[DateTime(key.year, key.month, key.day)] = value;

     if(maxValue == null || maxValue < value) {
       maxValue = value;
     }
   });

   // _mapを日付順に並べ替える
   _map = sortMap(_map);

   graphPadding = getGraphPadding(maxValue);

   return _map;
 }

 Map<DateTime, double> sortMap(Map<DateTime, double> map) {
    List<DateDouble> _list = [];
    map.forEach((key, value) {
      _list.add(DateDouble(dateTime: key, num: value));
    });
    _list.sort((a, b) => a.dateTime.isAfter(b.dateTime) ? 1 : 0);

    Map<DateTime, double> _map = {};
    for(DateDouble mapDouble in _list) {
      _map[mapDouble.dateTime] = mapDouble.num;
    }

    return _map;
 }

 @override
 bool shouldRepaint(CustomPainter oldDelegate) {
   return true;
 }
}

class OriginalPath {
  double x;
  double y;
  OriginalPath({this.x, this.y});
}

class DateDouble {
  DateTime dateTime;
  double num;
  DateDouble({this.dateTime, this.num});
}


class Weight {
  final DateTime date;
  final double weight;

  Weight(
      this.date,
      this.weight,
  );

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      json["date"],
      json["weight"],
    );
  }
}
