import 'package:isar_community/isar.dart';

part 'account_entity.g.dart';

@collection
class AccountEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true, composite: [CompositeIndex('dbName'), CompositeIndex('url')])
  String? userId;

  String? userName;
  String? userLogin;
  String? sessionId;
  String? serverVersion;
  String? userLang;
  String? partnerId;
  String? userTimezone;
  String? companyId;
  bool? isSystem;
  
  @Index()
  String? url;
  
  @Index()
  String? dbName;
  
  String? password;
  String? image;
  DateTime? lastLogin;
}
