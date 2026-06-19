import 'package:flutter_test/flutter_test.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';

void main() {
  group('CsvExporter.encode', () {
    test('simple rows', () {
      final csv = CsvExporter.encode([
        ['ID', 'Name', 'Amount'],
        ['1', 'Ahmed', '100'],
        ['2', 'Sara', '250.50'],
      ]);
      expect(csv, 'ID,Name,Amount\n1,Ahmed,100\n2,Sara,250.50');
    });

    test('field with comma is wrapped in quotes', () {
      final csv = CsvExporter.encode([
        ['Name', 'Note'],
        ['Ahmed', 'Rent, electricity, water'],
      ]);
      expect(csv, 'Name,Note\nAhmed,"Rent, electricity, water"');
    });

    test('field with double quote escapes by doubling and wraps in quotes', () {
      final csv = CsvExporter.encode([
        ['Name', 'Note'],
        ['Ahmed', 'He said "hello"'],
      ]);
      expect(csv, 'Name,Note\nAhmed,"He said ""hello"""');
    });

    test('field with newline is wrapped in quotes', () {
      final csv = CsvExporter.encode([
        ['Name', 'Note'],
        ['Ahmed', 'Line1\nLine2'],
      ]);
      expect(csv, 'Name,Note\nAhmed,"Line1\nLine2"');
    });

    test('null field renders as empty string', () {
      final csv = CsvExporter.encode([
        ['ID', 'Note'],
        ['1', null],
      ]);
      expect(csv, 'ID,Note\n1,');
    });

    test('empty rows list returns empty string', () {
      expect(CsvExporter.encode([]), '');
    });

    test('single row (header only) has no trailing newline', () {
      expect(CsvExporter.encode([['A', 'B']]), 'A,B');
    });

    test('numeric fields are stringified', () {
      final csv = CsvExporter.encode([
        ['A', 'B'],
        [1, 2.5],
      ]);
      expect(csv, 'A,B\n1,2.5');
    });
  });
}
