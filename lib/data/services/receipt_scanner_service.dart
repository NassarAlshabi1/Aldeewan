import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// AutoDispose so the native ML Kit handle is released when no screen
/// is using it (previously it leaked for the app's entire lifetime).
final receiptScannerServiceProvider = Provider.autoDispose<ReceiptScannerService>((ref) {
  final service = ReceiptScannerService();
  ref.onDispose(service.dispose);
  return service;
});

/// Structured data extracted from a receipt
class ParsedReceipt {
  final double? amount;
  final DateTime? date;
  final String? reference;
  final String cleanedNotes;
  final String rawText;

  ParsedReceipt({
    this.amount,
    this.date,
    this.reference,
    required this.cleanedNotes,
    required this.rawText,
  });
}

/// Receipt OCR + parser.
///
/// Uses **both** Latin and Arabic script recognisers so the service works
/// on receipts from the MENA region (the app's primary market). Arabic
/// keyword patterns like `المبلغ` / `الإجمالي` are now actually matchable
/// because the Arabic recogniser returns text for Arabic-script receipts.
class ReceiptScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _latinRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final TextRecognizer _arabicRecognizer =
      TextRecognizer(script: TextRecognitionScript.arabic);

  Future<File?> pickReceiptImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  /// Runs both recognisers and concatenates the results — Latin first,
  /// then Arabic on a separate line block. This ensures English/Latin
  /// receipts still work while Arabic receipts are no longer blank.
  Future<String> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final StringBuffer buffer = StringBuffer();
    try {
      final RecognizedText latinText =
          await _latinRecognizer.processImage(inputImage);
      buffer.writeln(latinText.text);
    } catch (e, s) {
      // Latin recognizer is the most reliable — if it fails, surface to
      // caller rather than silently returning empty Arabic-only output.
      if (kDebugMode) debugPrint('ReceiptScannerService latin OCR error: $e\n$s');
      rethrow;
    }
    try {
      final RecognizedText arabicText =
          await _arabicRecognizer.processImage(inputImage);
      if (arabicText.text.trim().isNotEmpty) {
        buffer.writeln();
        buffer.writeln(arabicText.text);
      }
    } catch (e, s) {
      // Arabic recognizer failure is non-fatal — many receipts have no
      // Arabic script at all.
      if (kDebugMode) {
        debugPrint('ReceiptScannerService arabic OCR skipped: $e\n$s');
      }
    }
    return buffer.toString();
  }

  /// Parse raw OCR text and extract structured receipt data
  Future<ParsedReceipt> parseReceipt(File image) async {
    final rawText = await extractTextFromImage(image);

    return ParsedReceipt(
      amount: _extractAmount(rawText),
      date: _extractDate(rawText),
      reference: _extractReference(rawText),
      cleanedNotes: _cleanNotes(rawText),
      rawText: rawText,
    );
  }

  /// Extract the **most-likely total** amount from the text.
  ///
  /// Heuristic (in priority order):
  /// 1. Lines explicitly labelled as total (English `TOTAL`, Arabic `الإجمالي`
  ///    or `المبلغ`).
  /// 2. Lines starting with a currency symbol followed by a number.
  /// 3. As a last resort, the largest decimal number that is NOT a year
  ///    (excludes 1900-2099) and NOT a phone number (excludes >10 digits).
  double? _extractAmount(String text) {
    final lines = text.split('\n');

    // 1. Explicit "total" lines (English + Arabic).
    final totalPatterns = [
      RegExp(r'(?:total|amount|المبلغ|الإجمالي|المجموع)[:\s]*'
          r'[\$€£¥]?\s?[\d,]+\.?\d*',
          caseSensitive: false),
      RegExp(r'[\$€£¥]\s?[\d,]+\.?\d*'),
    ];
    for (final pattern in totalPatterns) {
      for (final line in lines) {
        final match = pattern.firstMatch(line);
        if (match == null) continue;
        final numStr = match.group(0)!
            .replaceAll(RegExp(r'[^\d.,]'), '')
            .replaceAll(',', '');
        final amount = double.tryParse(numStr);
        if (amount != null && amount > 0) return amount;
      }
    }

    // 2. Fallback: largest non-year, non-phone decimal on any line.
    double? largestAmount;
    final genericPattern = RegExp(r'\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\b');
    for (final match in genericPattern.allMatches(text)) {
      final numStr = match.group(0)!.replaceAll(',', '');
      final amount = double.tryParse(numStr);
      if (amount == null || amount <= 0) continue;
      // Skip years (1900-2099) — they're not amounts.
      if (amount >= 1900 && amount <= 2099 && numStr.length == 4) continue;
      // Skip very large integers (likely phone numbers or invoice IDs).
      if (amount > 999999 && numStr.length > 6) continue;
      if (largestAmount == null || amount > largestAmount) {
        largestAmount = amount;
      }
    }
    return largestAmount;
  }

  /// Extract date from the text. Returns a local-midnight DateTime so it
  /// compares correctly with transaction dates stored as `DateTime.now()`.
  DateTime? _extractDate(String text) {
    final patterns = [
      // DD/MM/YYYY or DD-MM-YYYY
      RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})\b'),
      // YYYY/MM/DD or YYYY-MM-DD
      RegExp(r'\b(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})\b'),
      // Month DD, YYYY
      RegExp(
          r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}\b',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final matchText = match.group(0) ?? '';

          final ddmmyyyy =
              RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})').firstMatch(matchText);
          if (ddmmyyyy != null) {
            final day = int.tryParse(ddmmyyyy.group(1) ?? '');
            final month = int.tryParse(ddmmyyyy.group(2) ?? '');
            final year = int.tryParse(ddmmyyyy.group(3) ?? '');
            if (day != null && month != null && year != null &&
                day >= 1 && day <= 31 && month >= 1 && month <= 12) {
              return DateTime(year, month, day);
            }
          }

          final yyyymmdd =
              RegExp(r'(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})').firstMatch(matchText);
          if (yyyymmdd != null) {
            final year = int.tryParse(yyyymmdd.group(1) ?? '');
            final month = int.tryParse(yyyymmdd.group(2) ?? '');
            final day = int.tryParse(yyyymmdd.group(3) ?? '');
            if (day != null && month != null && year != null &&
                day >= 1 && day <= 31 && month >= 1 && month <= 12) {
              return DateTime(year, month, day);
            }
          }
        } catch (_) {
          // Continue to next pattern
        }
      }
    }

    return null;
  }

  /// Extract reference/invoice number (English + Arabic keywords).
  String? _extractReference(String text) {
    final patterns = [
      RegExp(
          r'(?:ref|reference|invoice|receipt|رقم|فاتورة|مرجع)[:\s#]*([A-Z0-9\-]+)',
          caseSensitive: false),
      RegExp(r'#\s*([A-Z0-9\-]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Clean up the notes - remove garbage and format nicely.
  String _cleanNotes(String rawText) {
    final lines = rawText.split('\n');

    final cleanedLines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => line.length > 2)
        .where((line) => !RegExp(r'^[\d\s\.\,\-\$€£]+$').hasMatch(line))
        .where((line) => !RegExp(r'^[*\-=_]{3,}$').hasMatch(line))
        .take(5)
        .toList();

    return cleanedLines.join('; ');
  }

  void dispose() {
    _latinRecognizer.close();
    _arabicRecognizer.close();
  }
}
