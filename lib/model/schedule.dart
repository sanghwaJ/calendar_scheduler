// drift => Flutter의 JPA 역할
import 'package:drift/drift.dart';

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()(); // PK
  TextColumn get content => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get startTime => integer()();
  IntColumn get endTime => integer()();
  IntColumn get colorId => integer()(); // CategoryColor Table PK
  // clientDefault에는 default 값을 지정할 수 있음
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
