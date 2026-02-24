import 'package:isar_community/isar.dart';
import 'package:mobo_rental/features/company/company_entity.dart';
import 'package:mobo_rental/features/login/models/account_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:mobo_rental/Core/Isarmodel/user_profile.dart';


class IsarDatabase {
  IsarDatabase._();
  static Isar? _instance;

  static Future<Isar> instance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [CompanyEntitySchema, AccountEntitySchema, UserProfileSchema, SignedAccountSchema, SignedAccountListingSchema],
      directory: dir.path,
      inspector: false,
    );
    return _instance!;
  }
}
