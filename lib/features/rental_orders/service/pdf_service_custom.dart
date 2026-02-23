import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class SalePdfService {
  Future<File> downloadRentalOrderPdf(
    int orderId, {
    required SalePdfType pdfType,
    bool openAfterDownload = false,
  }) async {
    final currentSession = await OdooSessionManager.getCurrentSession();
    if (currentSession == null) {
      throw Exception('No active Odoo session found');
    }

    final String baseUrl = currentSession.serverUrl;
    final String sessionId = currentSession.sessionId;

    final String reportTechnicalName = getSaleReportName(pdfType);

    final Uri requestUrl = Uri.parse(
      '$baseUrl/report/pdf/$reportTechnicalName/$orderId',
    );

    final response = await http.get(
      requestUrl,
      headers: {'Cookie': 'session_id=$sessionId', 'Accept': 'application/pdf'},
    );

    if (response.statusCode == 200 &&
        response.headers['content-type']?.contains('pdf') == true) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'Order_${orderId}_${pdfType.name}.pdf';
      final File pdfFile = File('${directory.path}/$fileName');

      await pdfFile.writeAsBytes(response.bodyBytes, flush: true);

      if (openAfterDownload) {
        await OpenFilex.open(pdfFile.path);
      }

      return pdfFile;
    } else {
      throw Exception(
        'Could not generate $reportTechnicalName. Check if the module is installed.',
      );
    }
  }
}

enum SalePdfType { quotation, order }

String getSaleReportName(SalePdfType reportType) {
  switch (reportType) {
    case SalePdfType.quotation:
      return 'sale.report_saleorder';

    case SalePdfType.order:
      return 'sale.report_saleorder_raw';
  }
}

Future<SalePdfType?> showSalePdfTypeSheet(BuildContext context) {
  return showModalBottomSheet<SalePdfType>(
    backgroundColor: Theme.of(context).colorScheme.secondary,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedClipboard),
            title: const Text('PDF Quotation'),
            onTap: () {
              Navigator.pop(context, SalePdfType.quotation);
            },
          ),
          ListTile(
            leading: HugeIcon(icon: HugeIcons.strokeRoundedTask02),
            title: const Text('Quotation / Order'),
            onTap: () {
              Navigator.pop(context, SalePdfType.order);
            },
          ),
          const SizedBox(height: 12),
        ],
      );
    },
  );
}
