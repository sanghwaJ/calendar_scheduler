import 'package:calendar_scheduler/screen/home_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calendar_scheduler/database/drift_database.dart';

const DEFAULT_COLORS = [
  // 빨강
  'F44336',
  // 주황
  'FF9800',
  // 노랑
  'FFEB3B',
  // 초록
  'FCAF50',
  // 파랑
  '2196F3',
  // 남
  '3F51B5',
  // 보라
  '9C27B0',
];

void main() async {
  // runApp 전에 플러터 코드를 실행하는 경우, 플러터가 준비가 되었는지 확인해야 함
  WidgetsFlutterBinding.ensureInitialized(); // 플러터가 초기화되었는지 확인

  await initializeDateFormatting(); // intl 패키지 안의 모든 언어 설정을 사용할 수 있음

  /**
   * database 설정
   */
  final database = LocalDatabase();

  // Dependency Injection => 파라미터를 따로 넘기지 않아도 어디서든 사용이 가능
  GetIt.I.registerSingleton<LocalDatabase>(database);

  /**
   * Colors data init
   */
  final Colors = await database.getCategoryColors();
  if (Colors.isEmpty) {
    for (String hexCode in DEFAULT_COLORS) {
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode),
        ),
      );
    }
  }

  runApp(
    MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSans'),
      home: HomeScreen(),
    ),
  );
}
