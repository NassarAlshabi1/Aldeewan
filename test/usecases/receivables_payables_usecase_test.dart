import 'package:flutter_test/flutter_test.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_receivables_usecase.dart';
import 'package:aldeewan_mobile/domain/usecases/get_total_payables_usecase.dart';

void main() {
  final receivablesUseCase = GetTotalReceivablesUseCase();
  final payablesUseCase = GetTotalPayablesUseCase();

  Person customer(String id) => Person(
        id: id,
        role: PersonRole.customer,
        name: 'Customer $id',
        createdAt: DateTime(2025),
      );

  Person supplier(String id) => Person(
        id: id,
        role: PersonRole.supplier,
        name: 'Supplier $id',
        createdAt: DateTime(2025),
      );

  group('GetTotalReceivablesUseCase', () {
    test('empty persons → 0', () {
      expect(receivablesUseCase([], {}), 0);
    });

    test('customer with positive balance is counted as receivable', () {
      final persons = [customer('c1')];
      final balances = {'c1': 200.0};
      expect(receivablesUseCase(persons, balances), 200);
    });

    test('customer with zero balance is not counted', () {
      final persons = [customer('c1')];
      final balances = {'c1': 0.0};
      expect(receivablesUseCase(persons, balances), 0);
    });

    test('customer with negative balance (advance paid) is not counted', () {
      final persons = [customer('c1')];
      final balances = {'c1': -50.0};
      expect(receivablesUseCase(persons, balances), 0);
    });

    test('supplier with negative balance is counted as receivable', () {
      final persons = [supplier('s1')];
      final balances = {'s1': -100.0};
      expect(receivablesUseCase(persons, balances), 100);
    });

    test('supplier with positive balance is NOT counted (that is payable)', () {
      final persons = [supplier('s1')];
      final balances = {'s1': 500.0};
      expect(receivablesUseCase(persons, balances), 0);
    });

    test('mix of customers and suppliers sums correctly', () {
      final persons = [customer('c1'), customer('c2'), supplier('s1')];
      final balances = {
        'c1': 100.0,
        'c2': 50.0,
        's1': -25.0,
      };
      expect(receivablesUseCase(persons, balances), 175);
    });
  });

  group('GetTotalPayablesUseCase', () {
    test('empty persons → 0', () {
      expect(payablesUseCase([], {}), 0);
    });

    test('supplier with positive balance is counted as payable', () {
      final persons = [supplier('s1')];
      final balances = {'s1': 400.0};
      expect(payablesUseCase(persons, balances), 400);
    });

    test('customer with negative balance is counted as payable (advance)', () {
      final persons = [customer('c1')];
      final balances = {'c1': -75.0};
      expect(payablesUseCase(persons, balances), 75);
    });

    test('customer with positive balance is NOT counted (that is receivable)', () {
      final persons = [customer('c1')];
      final balances = {'c1': 100.0};
      expect(payablesUseCase(persons, balances), 0);
    });

    test('mix of customers and suppliers sums correctly', () {
      final persons = [customer('c1'), supplier('s1'), supplier('s2')];
      final balances = {
        'c1': -50.0,
        's1': 200.0,
        's2': 0.0,
      };
      expect(payablesUseCase(persons, balances), 250);
    });
  });
}
