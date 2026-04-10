import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'semerbak_transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        total INTEGER,
        tanggal TEXT,
        isPemasukan INTEGER
      )
    ''');

    // Setup mock data
    List<TransactionModel> mockData = [
      TransactionModel(
        nama: 'Parfum Dior Sauvage 50ml',
        total: 150000,
        tanggal: '12 Okt 2026 10:30',
        isPemasukan: true,
      ),
      TransactionModel(
        nama: 'Botol Kaca Kosong 50ml',
        total: 50000,
        tanggal: '11 Okt 2026 09:15',
        isPemasukan: false,
      ),
      TransactionModel(
        nama: 'Parfum Baccarat Rouge 100ml',
        total: 250000,
        tanggal: '10 Okt 2026 14:00',
        isPemasukan: true,
      )
    ];

    for (var d in mockData) {
      await db.insert('transactions', d.toMap());
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'id DESC');
  }

  Future<int> insertTransaction(Map<String, dynamic> transactionMap) async {
    final db = await database;
    return await db.insert('transactions', transactionMap);
  }
}
