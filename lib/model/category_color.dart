import 'package:drift/drift.dart';

class CategoryColors extends Table {
  IntColumn get id => integer().autoIncrement()(); // PK
  TextColumn get hexCode => text()();
}