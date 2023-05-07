import 'package:calendar_scheduler/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // runApp 전에 플러터 코드를 실행하는 경우, 플러터가 준비가 되었는지 확인해야 함
  WidgetsFlutterBinding.ensureInitialized(); // 플러터가 초기화되었는지 확인

  await initializeDateFormatting(); // intl 패키지 안의 모든 언어 설정을 사용할 수 있음

  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSans'
      ),
      home: HomeScreen(),
    ),
  );
}
