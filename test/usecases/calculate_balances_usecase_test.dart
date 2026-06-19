import 'package:flutter_test/flutter_test.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/domain/usecases/calculate_balances_usecase.dart';

void main() {
  final useCase = CalculateBalancesUseCase();

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

  Transaction tx(String id, String personId, TransactionType type, double amount) =>
      Transaction(
        id: id,
        type: type,
        amount: amount,
        date: DateTime(2025, 1, 1),
        personId: personId,
      );

  group('CalculateBalancesUseCase', () {
    test('empty persons & transactions → empty map', () {
      final result = useCase([], []);
      expect(result, isEmpty);
    });

    test('saleOnCredit increases customer balance (they owe us)', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.saleOnCredit, 100),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 100);
    });

    test('paymentReceived decreases customer balance', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.saleOnCredit, 100),
        tx('t2', 'c1', TransactionType.paymentReceived, 40),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 60);
    });

    test('debtGiven increases customer balance (we lent them money)', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.debtGiven, 250),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 250);
    });

    test('supplier purchaseOnCredit increases supplier balance (we owe them)', () {
      final persons = [supplier('s1')];
      final transactions = [
        tx('t1', 's1', TransactionType.purchaseOnCredit, 500),
      ];
      final result = useCase(persons, transactions);
      expect(result['s1'], 500);
    });

    test('supplier paymentMade decreases balance (we paid them)', () {
      final persons = [supplier('s1')];
      final transactions = [
        tx('t1', 's1', TransactionType.purchaseOnCredit, 500),
        tx('t2', 's1', TransactionType.paymentMade, 200),
      ];
      final result = useCase(persons, transactions);
      expect(result['s1'], 300);
    });

    test('cash-only transactions are ignored even with personId set', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.cashSale, 999),
        tx('t2', 'c1', TransactionType.cashIncome, 999),
        tx('t3', 'c1', TransactionType.cashExpense, 999),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 0);
    });

    test('transaction with unknown personId is silently ignored', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'unknown', TransactionType.saleOnCredit, 1000),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 0);
      expect(result['unknown'], isNull);
    });

    test('multiple customers and mixed transactions aggregate correctly', () {
      final persons = [customer('c1'), customer('c2'), supplier('s1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.saleOnCredit, 200),
        tx('t2', 'c1', TransactionType.paymentReceived, 50),
        tx('t3', 'c2', TransactionType.debtGiven, 100),
        tx('t4', 's1', TransactionType.purchaseOnCredit, 300),
        tx('t5', 's1', TransactionType.paymentMade, 300),
      ];
      final result = useCase(persons, transactions);
      expect(result['c1'], 150);
      expect(result['c2'], 100);
      expect(result['s1'], 0);
    });

    test('customer with overpayment has negative balance', () {
      final persons = [customer('c1')];
      final transactions = [
        tx('t1', 'c1', TransactionType.saleOnCredit, 100),
        tx('t2', 'c1', TransactionType.paymentReceived, 150),
      ];
      final result = useCase(persons, transactions);
      // Overpaid by 50 → customer effectively has credit (-50)
      expect(result['c1'], -50);
    });

    test('static calculate() matches call() (isolate-safe entrypoint)', () {
      final persons = [customer('c1')];
      final transactions = [tx('t1', 'c1', TransactionType.saleOnCredit, 75)];
      final viaCall = useCase(persons, transactions);
      final viaStatic =
          CalculateBalancesUseCase.calculate((persons, transactions));
      expect(viaCall, equals(viaStatic));
    });
  });
}
