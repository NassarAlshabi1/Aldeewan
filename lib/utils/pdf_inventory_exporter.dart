import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:aldeewan_mobile/presentation/providers/inventory_provider.dart';

/// Generates a PDF report of the current inventory snapshot and shares
/// it via the native share sheet. The report includes:
///
/// - Header with title + generation date
/// - Aggregate summary (total products, low-stock count, total stock value)
/// - Tabular breakdown of each product with quantity on hand, prices,
///   threshold, status, and stock value
///
/// Uses the `pdf` + `printing` packages (added to pubspec.yaml).
class PdfInventoryExporter {
  PdfInventoryExporter._();

  /// Builds and shares the inventory PDF.
  ///
  /// [baseCurrency] is the app's default currency code (used for the
  /// stock-value total). Each product's individual values use its own
  /// currency code if set, falling back to [baseCurrency].
  static Future<void> export({
    required List<ProductWithStock> products,
    required String baseCurrency,
    required String appTitle,
    required String subtitle,
    required String Function(bool isLow, bool isOut) statusLabel,
    required Map<String, String> labels,
  }) async {
    if (products.isEmpty) return;

    final pdf = pw.Document();

    // Aggregates
    final totalProducts = products.length;
    final lowStockCount = products.where((p) => p.isLowStock).length;
    double totalStockValueBase = 0;
    for (final p in products) {
      final cost = p.product.costPrice ?? 0;
      totalStockValueBase += p.quantityOnHand * cost;
    }

    // Build table rows
    final headerRow = [
      labels['name'] ?? 'Product',
      labels['sku'] ?? 'SKU',
      labels['qty'] ?? 'Qty',
      labels['cost'] ?? 'Cost',
      labels['sale'] ?? 'Sale',
      labels['threshold'] ?? 'Threshold',
      labels['status'] ?? 'Status',
      labels['value'] ?? 'Stock Value',
    ];

    final dataRows = products.map((item) {
      final p = item.product;
      final cur = p.currencyCode ?? baseCurrency;
      final isOut = item.quantityOnHand <= 0;
      final status = statusLabel(item.isLowStock, isOut);
      final stockValue = (p.costPrice ?? 0) * item.quantityOnHand;
      return [
        p.name,
        p.sku ?? '-',
        '${item.quantityOnHand.toStringAsFixed(2)}${p.unit != null ? " ${p.unit}" : ""}',
        p.costPrice != null ? '$cur ${p.costPrice!.toStringAsFixed(2)}' : '-',
        p.salePrice != null ? '$cur ${p.salePrice!.toStringAsFixed(2)}' : '-',
        p.lowStockThreshold != null ? p.lowStockThreshold!.toStringAsFixed(2) : '-',
        status,
        '$cur ${stockValue.toStringAsFixed(2)}',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              appTitle,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}'
            '  •  Generated ${DateTime.now().toIso8601String().substring(0, 19)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ),
        build: (context) => [
          // Summary band
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(labels['totalProducts'] ?? 'Total Products', totalProducts.toString()),
                _summaryItem(labels['lowStock'] ?? 'Low Stock', lowStockCount.toString()),
                _summaryItem(
                  labels['stockValue'] ?? 'Stock Value',
                  '$baseCurrency ${totalStockValueBase.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          // Table
          pw.Table.fromTextArray(
            headers: headerRow,
            data: dataRows,
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(4),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1),
              7: const pw.FlexColumnWidth(1.4),
            },
          ),
        ],
      ),
    );

    // Render to file
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/inventory_$stamp.pdf');
    await file.writeAsBytes(bytes);

    // Share
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Aldeewan Inventory Report',
      text: 'Inventory snapshot with $totalProducts products.',
    );
  }

  static pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
