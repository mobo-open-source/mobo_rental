import 'package:isar_community/isar.dart';
import 'package:mobo_rental/features/company/isar_database.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = IsarDatabase.instance();
  }

  static Future<Isar> get instance => IsarDatabase.instance();
}
