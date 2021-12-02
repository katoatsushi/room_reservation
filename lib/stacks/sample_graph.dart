import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import './line_title.dart';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login.dart';
import '../auth/get_auth_info.dart';
import '../setting/set_params.dart';

class LineChartWeight extends StatefulWidget {

  // 予約情報を取得
  @override
  State<LineChartWeight> createState() => _LineChartWeightState();
}

class _LineChartWeightState extends State<LineChartWeight> {
  List<WeightData> _data = [];
  double _minXData = 0;
  double _maxXData;
  double _minYData;
  double _maxYData;
  
  // グラデーションの色
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<http.Response> initialize() async {
    var headers = await getTokens();
    final String _apiBaseUri = environment['apiBaseUri'];
    String url = _apiBaseUri + "/customer_weight";
    http.Response resp = await http.get(url, headers: headers);
    var body = json.decode(resp.body);

    final weightHistory = (body["data"] as List).map((e) => WeightData.fromJson(e)).toList();

    setState(() { 
      _data = weightHistory; 
      _maxXData = (weightHistory.length - 1).toDouble();
      // _minYData = 
      // _maxYData = 
    });

  }

  double minYData = 50;
  double maxYData = 100;

  List<FlSpot> initData(){
    List<FlSpot> res = [];
    // List<WeightData> _data = [
    //   WeightData(0, DateTime(2021, 10,20), 77.0),
    //   WeightData(1, DateTime(2021, 10,21), 78.0),
    //   WeightData(2, DateTime(2021, 10,22), 79.0),
    // ];

    for (var i = 0; i < _data.length; i++) {
      res.add(FlSpot(i.toDouble(), _data[i].weight));
      // {value: 0.0, datetime: 9/1}みたいなのを作る
    }

    return res;
  }

  @override
  Widget build(BuildContext context) => LineChart(
    LineChartData(
      minX: _minXData,
      maxX: _maxXData,
      minY: minYData,
      maxY: maxYData,
      titlesData: LineTitles.getTitleData(),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 0.2,
          );
        },
        drawVerticalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 0.2,
          );
        }
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1)
      ),
      lineBarsData: [
        LineChartBarData(
          spots: initData(),
          isCurved: true,
          colors: gradientColors,
          barWidth: 1,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors
            .map((color) => color.withOpacity(0.5))
            .toList(),
          ),
        )
      ]

    ),
  );
}


// 体重のデータ
class WeightData {
  final double index;
  final DateTime date;
  final double weight;

  WeightData(
    this.index,
    this.date,
    this.weight
  );

  factory WeightData.fromJson(Map<String, dynamic> json) {
      print(json);
    return WeightData(
      json["id"].toDouble(),
      DateTime.parse(json["created_at"]).toLocal(),
      json["weight"],
    );
  }

}
