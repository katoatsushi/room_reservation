import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  static getTitleData() => FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          getTitles: (value) {
            print(value);
            print("bottomTitles");
            switch (value.toInt()) {
              case 0:
                return '8/31';
              case 1:
                return '9/1';
              case 2:
                return '9/7';
              case 3:
                return '9/14';
              case 4:
                return '9/21';
              case 5:
                return '9/27';
              case 6:
                return '10/3';
              case 7:
                return '10/10';
              case 8:
                return '10/14';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          margin: 20,
          getTitles: (value) {
            // print(value);
            // print("leftTitles");
            if(value.toInt() != null){
              return '${value.toInt()}';
            }else{
              return '';
            }
          },
        ),
        topTitles: SideTitles(
          showTitles: false,
        ),
        rightTitles: SideTitles(
          showTitles: false,
        ),
      );
}