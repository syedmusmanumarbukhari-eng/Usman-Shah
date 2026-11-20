class UserModel {
  final String id;
  final String fullName;
  final String farmName;
  final String email;
  final String password;

  UserModel({
    required this.id,
    required this.fullName,
    required this.farmName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'farmName': farmName,
        'email': email,
        'password': password,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        farmName: json['farmName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );
}

class FarmRecord {
  final String id;
  final String date;
  final String flock;
  final int eggs;
  final int chicks;
  final double expenses;
  final String notes;

  FarmRecord({
    required this.id,
    required this.date,
    required this.flock,
    required this.eggs,
    required this.chicks,
    required this.expenses,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'flock': flock,
        'eggs': eggs,
        'chicks': chicks,
        'expenses': expenses,
        'notes': notes,
      };

  factory FarmRecord.fromJson(Map<String, dynamic> json) => FarmRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        flock: json['flock'] as String? ?? '',
        eggs: (json['eggs'] as num?)?.toInt() ?? 0,
        chicks: (json['chicks'] as num?)?.toInt() ?? 0,
        expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );
}

class BreedingStock {
  final String id;
  final String date;
  final String batchName;
  final String breed;
  final int males;
  final int females;
  final int ageWeeks;
  final String notes;

  BreedingStock({
    required this.id,
    required this.date,
    required this.batchName,
    required this.breed,
    required this.males,
    required this.females,
    required this.ageWeeks,
    required this.notes,
  });

  int get totalBirds => males + females;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'batchName': batchName,
        'breed': breed,
        'males': males,
        'females': females,
        'ageWeeks': ageWeeks,
        'notes': notes,
      };

  factory BreedingStock.fromJson(Map<String, dynamic> json) => BreedingStock(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        batchName: json['batchName'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
        males: (json['males'] as num?)?.toInt() ?? 0,
        females: (json['females'] as num?)?.toInt() ?? 0,
        ageWeeks: (json['ageWeeks'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class EggRecord {
  final String id;
  final String date;
  final String batchName;
  final int collected;
  final int damaged;
  final int sold;
  final String notes;

  EggRecord({
    required this.id,
    required this.date,
    required this.batchName,
    required this.collected,
    required this.damaged,
    required this.sold,
    required this.notes,
  });

  int get available => (collected - damaged - sold) < 0 ? 0 : (collected - damaged - sold);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'batchName': batchName,
        'collected': collected,
        'damaged': damaged,
        'sold': sold,
        'notes': notes,
      };

  factory EggRecord.fromJson(Map<String, dynamic> json) => EggRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        batchName: json['batchName'] as String? ?? '',
        collected: (json['collected'] as num?)?.toInt() ?? 0,
        damaged: (json['damaged'] as num?)?.toInt() ?? 0,
        sold: (json['sold'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class IncubationRecord {
  final String id;
  final String settingDate;
  final String hatchDate;
  final String batchName;
  final int eggsSet;
  final int chicksHatched;
  final int infertile;
  final String notes;

  IncubationRecord({
    required this.id,
    required this.settingDate,
    required this.hatchDate,
    required this.batchName,
    required this.eggsSet,
    required this.chicksHatched,
    required this.infertile,
    required this.notes,
  });

  double get hatchRate => eggsSet > 0 ? (chicksHatched / eggsSet) * 100 : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'settingDate': settingDate,
        'hatchDate': hatchDate,
        'batchName': batchName,
        'eggsSet': eggsSet,
        'chicksHatched': chicksHatched,
        'infertile': infertile,
        'notes': notes,
      };

  factory IncubationRecord.fromJson(Map<String, dynamic> json) => IncubationRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        settingDate: json['settingDate'] as String? ?? '',
        hatchDate: json['hatchDate'] as String? ?? '',
        batchName: json['batchName'] as String? ?? '',
        eggsSet: (json['eggsSet'] as num?)?.toInt() ?? 0,
        chicksHatched: (json['chicksHatched'] as num?)?.toInt() ?? 0,
        infertile: (json['infertile'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class StockRecord {
  final String id;
  final String date;
  final String batchName;
  final String category; // 'Newborn', 'Growing', 'Adult', 'Sick'
  final int quantity;
  final int mortality;
  final String notes;

  StockRecord({
    required this.id,
    required this.date,
    required this.batchName,
    required this.category,
    required this.quantity,
    required this.mortality,
    required this.notes,
  });

  int get netLive => (quantity - mortality) < 0 ? 0 : (quantity - mortality);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'batchName': batchName,
        'category': category,
        'quantity': quantity,
        'mortality': mortality,
        'notes': notes,
      };

  factory StockRecord.fromJson(Map<String, dynamic> json) => StockRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        batchName: json['batchName'] as String? ?? '',
        category: json['category'] as String? ?? 'Growing',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        mortality: (json['mortality'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}

class TransactionRecord {
  final String id;
  final String date;
  final String type; // 'Sale', 'Purchase'
  final String itemType; // 'Eggs', 'Chickens', 'Feed', 'Supplies', 'Other'
  final String partyName;
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final String notes;

  TransactionRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.itemType,
    required this.partyName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'type': type,
        'itemType': itemType,
        'partyName': partyName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'notes': notes,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        type: json['type'] as String? ?? 'Sale',
        itemType: json['itemType'] as String? ?? 'Eggs',
        partyName: json['partyName'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );
}

class ExpenseRecord {
  final String id;
  final String date;
  final String category; // 'Feed', 'Medicine', 'Salaries', 'Utilities', 'Equipment', 'Other'
  final double amount;
  final String paidTo;
  final String notes;

  ExpenseRecord({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paidTo,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'category': category,
        'amount': amount,
        'paidTo': paidTo,
        'notes': notes,
      };

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] as String? ?? '',
        category: json['category'] as String? ?? 'Feed',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paidTo: json['paidTo'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );
}
