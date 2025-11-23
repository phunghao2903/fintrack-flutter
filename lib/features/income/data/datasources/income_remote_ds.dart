import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/features/income/data/datasources/income_data.dart';
import 'package:fintrack/features/income/data/models/income_model.dart';

/// Remote data source that aggregates income transactions from Firestore per category
class IncomeRemoteDataSourceImpl implements IncomeLocalDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  IncomeRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<List<IncomeModel>> getIncome({required String category}) async {
    final now = DateTime.now();
    final start = _startOfCurrentPeriod(category, now);
    final end = now;
    return _aggregateTransactions(start, end);
  }

  @override
  Future<List<IncomeModel>> getPreviousIncome({
    required String category,
  }) async {
    final now = DateTime.now();
    final start = _startOfCurrentPeriod(category, now);
    final duration = _periodDuration(category);
    final prevStart = start.subtract(duration);
    final prevEnd = start.subtract(const Duration(seconds: 1));
    return _aggregateTransactions(prevStart, prevEnd);
  }

  @override
  Future<List<String>> getCategories() async {
    return const ['Weekly', 'Monthly', 'Yearly'];
  }

  @override
  Future<List<IncomeModel>> searchIncome({required String query}) async {
    final results = await getIncome(category: 'Weekly');
    if (query.isEmpty) return results;
    final q = query.toLowerCase();
    return results
        .where((e) => e.categoryName.toLowerCase().contains(q))
        .toList();
  }

  Future<List<IncomeModel>> _aggregateTransactions(
    DateTime start,
    DateTime end,
  ) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final Map<String, double> sums = {};
    final Map<String, String> names = {};
    final Set<String> categoryIds = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final isIncome = data['isIncome'] as bool? ?? false;
      // only include incomes
      if (!isIncome) continue;

      final catId = data['categoryId'] as String? ?? '';
      final catName = data['categoryName'] as String? ?? 'Unknown';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

      sums[catId] = (sums[catId] ?? 0.0) + amount;
      names[catId] = catName;
      if (catId.isNotEmpty) categoryIds.add(catId);
    }

    // Fetch category icons in batch
    final Map<String, String?> icons = {};
    if (categoryIds.isNotEmpty) {
      final futures = await Future.wait(
        categoryIds.map(
          (id) => firestore.collection('categories').doc(id).get(),
        ),
      );
      for (var doc in futures) {
        if (doc.exists) icons[doc.id] = doc.data()?['icon'] as String?;
      }
    }

    final List<IncomeModel> result = [];
    for (var entry in sums.entries) {
      final catId = entry.key;
      result.add(
        IncomeModel(
          id: null,
          categoryId: catId,
          categoryName: names[catId] ?? 'Unknown',
          categoryIcon: icons[catId],
          amount: entry.value,
          isIncome: true,
        ),
      );
    }

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  DateTime _startOfCurrentPeriod(String category, DateTime now) {
    switch (category) {
      case 'Weekly':
        return now.subtract(const Duration(days: 7));
      case 'Monthly':
        return now.subtract(const Duration(days: 30));
      case 'Yearly':
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  Duration _periodDuration(String category) {
    switch (category) {
      case 'Weekly':
        return const Duration(days: 7);
      case 'Monthly':
        return const Duration(days: 30);
      case 'Yearly':
        return const Duration(days: 365);
      default:
        return const Duration(days: 7);
    }
  }
}
