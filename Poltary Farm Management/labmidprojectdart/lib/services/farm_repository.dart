import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/farm_models.dart';

class FarmRepository extends ChangeNotifier {
  static final FarmRepository instance = FarmRepository._internal();

  factory FarmRepository() => instance;

  FarmRepository._internal() {
    loadSampleDemoData();
  }

  final List<FarmRecord> _dailyRecords = [];
  final List<BreedingStock> _breedingStocks = [];
  final List<EggRecord> _eggRecords = [];
  final List<IncubationRecord> _incubationRecords = [];
  final List<StockRecord> _stockRecords = [];
  final List<TransactionRecord> _transactions = [];
  final List<ExpenseRecord> _expenses = [];

  // Getters
  List<FarmRecord> get dailyRecords => List.unmodifiable(_dailyRecords);
  List<BreedingStock> get breedingStocks => List.unmodifiable(_breedingStocks);
  List<EggRecord> get eggRecords => List.unmodifiable(_eggRecords);
  List<IncubationRecord> get incubationRecords => List.unmodifiable(_incubationRecords);
  List<StockRecord> get stockRecords => List.unmodifiable(_stockRecords);
  List<TransactionRecord> get transactions => List.unmodifiable(_transactions);
  List<ExpenseRecord> get expenses => List.unmodifiable(_expenses);

  // Statistics & Derived Data
  int get totalEggsCollected {
    int total = 0;
    for (var r in _dailyRecords) {
      total += r.eggs;
    }
    for (var e in _eggRecords) {
      total += e.collected;
    }
    return total;
  }

  int get totalChicksProduced {
    int total = 0;
    for (var r in _dailyRecords) {
      total += r.chicks;
    }
    for (var i in _incubationRecords) {
      total += i.chicksHatched;
    }
    return total;
  }

  double get totalExpensesAmount {
    double total = 0;
    for (var r in _dailyRecords) {
      total += r.expenses;
    }
    for (var e in _expenses) {
      total += e.amount;
    }
    for (var t in _transactions) {
      if (t.type == 'Purchase') {
        total += t.totalAmount;
      }
    }
    return total;
  }

  double get totalSalesAmount {
    double total = 0;
    for (var t in _transactions) {
      if (t.type == 'Sale') {
        total += t.totalAmount;
      }
    }
    return total;
  }

  double get netProfit => totalSalesAmount - totalExpensesAmount;

  int get totalBreedingBirds {
    int total = 0;
    for (var b in _breedingStocks) {
      total += b.totalBirds;
    }
    return total;
  }

  int get totalLiveStock {
    int total = 0;
    for (var s in _stockRecords) {
      total += s.netLive;
    }
    return total;
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> map = {
      'Feed': 0.0,
      'Medicine': 0.0,
      'Salaries': 0.0,
      'Utilities': 0.0,
      'Equipment': 0.0,
      'Other': 0.0,
    };
    for (var e in _expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    for (var r in _dailyRecords) {
      if (r.expenses > 0) {
        map['Other'] = (map['Other'] ?? 0.0) + r.expenses;
      }
    }
    return map;
  }

  // --- CRUD Operations ---

  // Daily Records
  void addDailyRecord(FarmRecord record) {
    _dailyRecords.insert(0, record);
    notifyListeners();
  }

  void updateDailyRecord(FarmRecord record) {
    final index = _dailyRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _dailyRecords[index] = record;
      notifyListeners();
    }
  }

  void deleteDailyRecord(String id) {
    _dailyRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Breeding Stock
  void addBreedingStock(BreedingStock stock) {
    _breedingStocks.insert(0, stock);
    notifyListeners();
  }

  void updateBreedingStock(BreedingStock stock) {
    final index = _breedingStocks.indexWhere((b) => b.id == stock.id);
    if (index != -1) {
      _breedingStocks[index] = stock;
      notifyListeners();
    }
  }

  void deleteBreedingStock(String id) {
    _breedingStocks.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // Egg Records
  void addEggRecord(EggRecord record) {
    _eggRecords.insert(0, record);
    notifyListeners();
  }

  void updateEggRecord(EggRecord record) {
    final index = _eggRecords.indexWhere((e) => e.id == record.id);
    if (index != -1) {
      _eggRecords[index] = record;
      notifyListeners();
    }
  }

  void deleteEggRecord(String id) {
    _eggRecords.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Incubation Records
  void addIncubationRecord(IncubationRecord record) {
    _incubationRecords.insert(0, record);
    notifyListeners();
  }

  void updateIncubationRecord(IncubationRecord record) {
    final index = _incubationRecords.indexWhere((i) => i.id == record.id);
    if (index != -1) {
      _incubationRecords[index] = record;
      notifyListeners();
    }
  }

  void deleteIncubationRecord(String id) {
    _incubationRecords.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // Stock Records
  void addStockRecord(StockRecord record) {
    _stockRecords.insert(0, record);
    notifyListeners();
  }

  void updateStockRecord(StockRecord record) {
    final index = _stockRecords.indexWhere((s) => s.id == record.id);
    if (index != -1) {
      _stockRecords[index] = record;
      notifyListeners();
    }
  }

  void deleteStockRecord(String id) {
    _stockRecords.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Transaction Records
  void addTransaction(TransactionRecord transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void updateTransaction(TransactionRecord transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Expense Records
  void addExpense(ExpenseRecord expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void updateExpense(ExpenseRecord expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Backup & Restore Logic
  String exportBackupAsJson() {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'dailyRecords': _dailyRecords.map((e) => e.toJson()).toList(),
      'breedingStocks': _breedingStocks.map((e) => e.toJson()).toList(),
      'eggRecords': _eggRecords.map((e) => e.toJson()).toList(),
      'incubationRecords': _incubationRecords.map((e) => e.toJson()).toList(),
      'stockRecords': _stockRecords.map((e) => e.toJson()).toList(),
      'transactions': _transactions.map((e) => e.toJson()).toList(),
      'expenses': _expenses.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importBackupFromJson(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      _dailyRecords.clear();
      _breedingStocks.clear();
      _eggRecords.clear();
      _incubationRecords.clear();
      _stockRecords.clear();
      _transactions.clear();
      _expenses.clear();

      if (data['dailyRecords'] != null) {
        for (var item in data['dailyRecords']) {
          _dailyRecords.add(FarmRecord.fromJson(item));
        }
      }
      if (data['breedingStocks'] != null) {
        for (var item in data['breedingStocks']) {
          _breedingStocks.add(BreedingStock.fromJson(item));
        }
      }
      if (data['eggRecords'] != null) {
        for (var item in data['eggRecords']) {
          _eggRecords.add(EggRecord.fromJson(item));
        }
      }
      if (data['incubationRecords'] != null) {
        for (var item in data['incubationRecords']) {
          _incubationRecords.add(IncubationRecord.fromJson(item));
        }
      }
      if (data['stockRecords'] != null) {
        for (var item in data['stockRecords']) {
          _stockRecords.add(StockRecord.fromJson(item));
        }
      }
      if (data['transactions'] != null) {
        for (var item in data['transactions']) {
          _transactions.add(TransactionRecord.fromJson(item));
        }
      }
      if (data['expenses'] != null) {
        for (var item in data['expenses']) {
          _expenses.add(ExpenseRecord.fromJson(item));
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing JSON backup: $e');
      return false;
    }
  }

  void clearAllData() {
    _dailyRecords.clear();
    _breedingStocks.clear();
    _eggRecords.clear();
    _incubationRecords.clear();
    _stockRecords.clear();
    _transactions.clear();
    _expenses.clear();
    notifyListeners();
  }

  void loadSampleDemoData() {
    final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    _dailyRecords.clear();
    _breedingStocks.clear();
    _eggRecords.clear();
    _incubationRecords.clear();
    _stockRecords.clear();
    _transactions.clear();
    _expenses.clear();

    _dailyRecords.addAll([
      FarmRecord(
        id: 'd1',
        date: today,
        flock: 'Shed A - Layer Hens',
        eggs: 450,
        chicks: 0,
        expenses: 2500,
        notes: 'Normal feed consumption',
      ),
      FarmRecord(
        id: 'd2',
        date: today,
        flock: 'Hatchery Batch 12',
        eggs: 0,
        chicks: 320,
        expenses: 1200,
        notes: 'Healthy chick production',
      ),
    ]);

    _breedingStocks.addAll([
      BreedingStock(
        id: 'b1',
        date: today,
        batchName: 'Rhode Island Red Batch #1',
        breed: 'Rhode Island Red',
        males: 50,
        females: 450,
        ageWeeks: 32,
        notes: 'High fertility strain',
      ),
      BreedingStock(
        id: 'b2',
        date: today,
        batchName: 'Leghorn Breeder Batch #2',
        breed: 'White Leghorn',
        males: 30,
        females: 300,
        ageWeeks: 24,
        notes: 'Peak egg laying cycle',
      ),
    ]);

    _eggRecords.addAll([
      EggRecord(
        id: 'e1',
        date: today,
        batchName: 'Shed A - Layer Hens',
        collected: 500,
        damaged: 12,
        sold: 350,
        notes: 'Grade A eggs collected',
      ),
      EggRecord(
        id: 'e2',
        date: today,
        batchName: 'Shed B - Broiler Breeders',
        collected: 380,
        damaged: 5,
        sold: 200,
        notes: 'Good shell quality',
      ),
    ]);

    _incubationRecords.addAll([
      IncubationRecord(
        id: 'i1',
        settingDate: '01/10/2024',
        hatchDate: '22/10/2024',
        batchName: 'Incubator Alpha #4',
        eggsSet: 600,
        chicksHatched: 528,
        infertile: 40,
        notes: '88% hatchability rate achieved',
      ),
    ]);

    _stockRecords.addAll([
      StockRecord(
        id: 's1',
        date: today,
        batchName: 'Nursery Shed 1',
        category: 'Newborn',
        quantity: 520,
        mortality: 4,
        notes: 'Vaccinated on day 1',
      ),
      StockRecord(
        id: 's2',
        date: today,
        batchName: 'Grower House 2',
        category: 'Growing',
        quantity: 800,
        mortality: 2,
        notes: 'Week 4 starter feed',
      ),
      StockRecord(
        id: 's3',
        date: today,
        batchName: 'Layer House 1',
        category: 'Adult',
        quantity: 1200,
        mortality: 1,
        notes: 'Active laying',
      ),
    ]);

    _transactions.addAll([
      TransactionRecord(
        id: 't1',
        date: today,
        type: 'Sale',
        itemType: 'Eggs',
        partyName: 'City Grocery Mart',
        quantity: 10, // 10 crates
        unitPrice: 350,
        totalAmount: 3500,
        notes: '350 eggs delivered',
      ),
      TransactionRecord(
        id: 't2',
        date: today,
        type: 'Purchase',
        itemType: 'Feed',
        partyName: 'Supreme Feeds Ltd',
        quantity: 20, // 20 bags
        unitPrice: 2800,
        totalAmount: 56000,
        notes: 'Layer Feed bags',
      ),
    ]);

    _expenses.addAll([
      ExpenseRecord(
        id: 'ex1',
        date: today,
        category: 'Feed',
        amount: 15000,
        paidTo: 'Agri Supply Store',
        notes: 'Poultry starter feed',
      ),
      ExpenseRecord(
        id: 'ex2',
        date: today,
        category: 'Medicine',
        amount: 3500,
        paidTo: 'Vet Pharmacy',
        notes: 'Vaccines and vitamins',
      ),
      ExpenseRecord(
        id: 'ex3',
        date: today,
        category: 'Salaries',
        amount: 25000,
        paidTo: 'Farm Workers',
        notes: 'Monthly wages payout',
      ),
    ]);

    notifyListeners();
  }
}
