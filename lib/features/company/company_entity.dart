import 'package:isar_community/isar.dart';
part 'company_entity.g.dart';

@Collection()
class CompanyEntity {
  Id id = Isar.autoIncrement; // local id

  @Index(unique: true, replace: true)
  late int companyId; // Odoo company id

  @Index()
  late String name;

  late String nameLower;

  CompanyEntity();

  CompanyEntity.fromMap(Map<String, dynamic> map) {
    companyId = map['id'] as int;
    name = (map['name']?.toString() ?? '').trim();
    nameLower = name.toLowerCase();
  }

  Map<String, dynamic> toMap() => {'id': companyId, 'name': name};
}
