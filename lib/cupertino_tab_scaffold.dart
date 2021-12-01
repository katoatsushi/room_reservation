import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import './stacks/my_page.dart';
import './stacks/customer_info.dart';
import './appointments/select_store_fitness.dart';
import './appointments/room_plus_list.dart';
import './setting/routes.dart';


class CupertinoMainBar extends StatefulWidget {
  final int index_id;
  const CupertinoMainBar({Key key, this.index_id}) : super(key: key);

  @override
  _CupertinoMainBarState createState() => _CupertinoMainBarState();
}

class _CupertinoMainBarState extends State<CupertinoMainBar> {

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {  _selectedIndex = widget.index_id;   } );
  }

  @override
  Widget build(BuildContext) {
    return CupertinoTabScaffold(

        tabBar: CupertinoTabBar(

          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(Icons.home,),
              title: Text('ホーム'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today,),
                title: Text('メニュー')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person,),
                title: Text('予約管理')
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person,),
                title: Text('マイページ')
            ),
          ],
          // onTap: _onItemTapped(index), // 実は無くても動く

          onTap: (index) {
              if(index == _selectedIndex){
                // popUntilFirstみたいなやつで、widgetをpopする
                // 画面をすべて除いてスプラッシュを表示
                if (index == 0){
                  
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute( builder: (context) => new CupertinoMainBar(index_id: 0) ), (_) => false);
                }else if(index == 1){
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute( builder: (context) => new CupertinoMainBar(index_id: 1) ), (_) => false);
                }else if(index == 2){
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute( builder: (context) => new CupertinoMainBar(index_id: 2) ), (_) => false);
                }else if(index == 3){
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute( builder: (context) => new CupertinoMainBar(index_id: 3) ), (_) => false);
                }

              }
              setState(() {
                _selectedIndex = index;
              });
          },
          currentIndex: _selectedIndex, // 実は無くても動く
        ),

        tabBuilder: (context, index) {
          switch (index) {
            case 0: // 1番左のタブが選ばれた時の画面
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: RoomPlusList(), // 表示したい画面のWidget
                );
              });
            case 1: // ほぼ同じなので割愛
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: SelectStoreFitness(), // 表示したい画面のWidget
                );
              });
            case 2:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: MyPage(), // 表示したい画面のWidget
                );
              });
            case 3:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: CustomerInfos(), // 表示したい画面のWidget
                );
              });
          }
        }

    );
  }
}