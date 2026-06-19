import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Centralised CSV export utilities. Replaces the duplicated `_exportPersonsCsv`
/// logic that previously lived in both `analytics_screen.dart` and
/// `settings_screen.dart`.
class CsvExporter {
  /// Generic CSV writer. Escapes fields per RFC 4180 (wraps in quotes when
  /// the field contains a comma, newline, or double quote; doubles internal
  /// double quotes).
  static Future<void> exportToCsv({
    required String fileName,
    required List<List<dynamic>> rows,
    required String subject,
    required String text,
  }) async {
    final csvContent = _encode(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
    );
  }

  /// Pure CSV encoder — also used by unit tests.
  static String encode(List<List<dynamic>> rows) => _encode(rows);

  static String _encode(List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      buffer.write(row.map(_escapeField).join(','));
      if (i < rows.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }

  static String _escapeField(dynamic field) {
    if (field == null) return '';
    String value = field.toString();
    if (value.contains('"')) {
      value = value.replaceAll('"', '""');
    }
    if (value.contains(',') || value.contains('\n') || value.contains('"')) {
      value = '"$value"';
    }
    return value;
  }
}
