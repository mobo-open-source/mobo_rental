// import 'package:flutter/material.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';

//   Company? currentCompany;
//   bool isLoading = false;

//     try {
//         'model': 'res.users',
//         'method': 'read',
//         'args': [
//           [userId],
//         ],
//         'kwargs': {
//           'fields': ['company_ids', 'company_id'],
//         },
//       });

//           .cast<int>();

//         'model': 'res.company',
//         'method': 'search_read',
//         'args': [
//           [
//             ['id', 'in', allowedIds],
//           ],
//         ],
//         'kwargs': {
//           'fields': ['id', 'name'],
//         },
//       });

//             .map((json) => Company.fromJson(json))
//             .toList();

//         currentCompany ??= allowedCompanies.firstWhere(
//           (company) => company.id == defaultCompanyId,
//           orElse: () => allowedCompanies.isNotEmpty
//               ? allowedCompanies.first
//               : Company(id: 1, name: 'Unknown'),
//     } on FormatException catch (e) {
   
//     } catch (e) {
//     } finally {

//   int get currentCompanyId => currentCompany?.id ?? 1;
