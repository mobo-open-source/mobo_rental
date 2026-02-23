import 'package:isar_community/isar.dart';
import 'package:mobo_rental/features/company/company_entity.dart';
import 'package:mobo_rental/features/company/isar_database.dart';

class CompanyLocalDataSource {
  const CompanyLocalDataSource();

  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    final isar = await IsarDatabase.instance();
    final list = await isar.companyEntitys.where().sortByName().findAll();
    return list.map((e) => e.toMap()).toList();
  }

  Future<void> putAllCompanies(List<Map<String, dynamic>> companies) async {
    final isar = await IsarDatabase.instance();
    final entities = companies.map((m) => CompanyEntity.fromMap(m)).toList();
    await isar.writeTxn(() async {
      // Upsert by unique index companyId
      for (final e in entities) {
        final existing = await isar.companyEntitys
            .filter()
            .companyIdEqualTo(e.companyId)
            .findFirst();
        if (existing != null) {
          e.id = existing.id;
        }
        await isar.companyEntitys.put(e);
      }
    });
  }

  Future<void> clear() async {
    final isar = await IsarDatabase.instance();
    await isar.writeTxn(() => isar.companyEntitys.clear());
  }
}
