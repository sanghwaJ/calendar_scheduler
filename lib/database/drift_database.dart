// import => private 값은 불러올 수 없음
import 'dart:io';

import 'package:calendar_scheduler/model/category_color.dart';
import 'package:calendar_scheduler/model/schedule.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// part => private 값도 불러올 수 있음
part 'drift_database.g.dart'; // 'g'를 붙이면 해당 파일을 자동으로 생성해줌

@DriftDatabase(
  // table 지정
  tables: [
    Schedules,
    CategoryColors,
  ],
)
// Code Generation
// 클래스명에 _$를 붙인 클래스를 extends하면 part에 선언한 drift_database.g.dart 파일 안에 LocalDatabase 클래스를 생성해줌
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  // Future<Schedule> getScheduleById(int id) =>
  //     (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle();

  /**
   * insert
   */
  // PK 값을 리턴 받기 떄문에 Future<int>로 리턴 값 지정
  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  /**
   * select
   */
  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  // Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
  //     (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);
  //
  // Future<int> removeSchedule(int id) =>
  //     (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();
  //
  // Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
  //   final query = select(schedules).join([
  //     innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
  //   ]);
  //
  //   query.where(schedules.date.equals(date));
  //   query.orderBy(
  //     [
  //       // asc -> ascending 오름차순
  //       // desc -> descending 내림차순
  //       OrderingTerm.asc(schedules.startTime),
  //     ],
  //   );
  //
  //   return query.watch().map(
  //         (rows) => rows
  //             .map(
  //               (row) => ScheduleWithColor(
  //                 schedule: row.readTable(schedules),
  //                 categoryColor: row.readTable(categoryColors),
  //               ),
  //             )
  //             .toList(),
  //       );
  // }

  @override
  int get schemaVersion => 1; // 스키마가 변경될 때마다 버전을 올려줘야 함
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 기기에 app별로 사용할 수 있는 특정 db path를 가져올 수 있음
    final dbFolder = await getApplicationDocumentsDirectory();
    // db.sqlite 파일 안에 database 정보 생성
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
