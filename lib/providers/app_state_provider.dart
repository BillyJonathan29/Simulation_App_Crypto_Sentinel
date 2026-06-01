import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/favorite_recipient.dart';
import '../services/dummy_api_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DummyApiService _apiService = DummyApiService();

  // Active User Profile
  final UserModel _currentUser = const UserModel(
    name: 'Billy Jonathan',
    email: 'billy.jonathan@gmail.com',
    accountNumber: '1234567890',
    accountType: 'Nasabah Gold',
    username: 'billy',
  );

  // Reactive Account Balance
  double _balance = 125750000.0; // Rp 125.750.000

  // GNN & SCB Performance Metrics (SupTech Proposal parameters)
  final double gnnAccuracy = 95.8; // F1-score > 95% target
  final double scbLatencyMs = 18.0; // SCB latency < 50ms target
  double totalBlockedValue = 800000000000.0; // Starts with Rp800 billion kerugian kasus nyata

  // Blocked/Intercepted Suspicious Transactions (for Analyst Portal)
  final List<Map<String, dynamic>> _blockedTransactions = [
    {
      'id': 'B1',
      'senderName': 'Billy Jonathan',
      'senderAccount': '1234567890',
      'beneficiaryName': 'Budi Santoso',
      'beneficiaryAccount': '987654', // Suspect mule account Bbud Santoso
      'bankName': 'Bank Central Asia',
      'amount': 45000000.0,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
      'purpose': 'Investasi / Pembelian Aset Crypto',
      'riskScore': 89.0,
      'latencyMs': 18.0,
      'status': 'DIBEKUKAN',
      'referenceNumber': 'REF98234827',
      'shapRiskFactors': {
        'smurfingPattern': 0.94,
        'muleAssociation': 0.88,
        'cryptoEndpoint': 0.95,
      }
    },
    {
      'id': 'B2',
      'senderName': 'Andi Wijaya',
      'senderAccount': '1122334455',
      'beneficiaryName': 'Budi Santoso',
      'beneficiaryAccount': '987654',
      'bankName': 'Bank Central Asia',
      'amount': 25000000.0,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      'purpose': 'Investasi / Pembelian Aset Crypto',
      'riskScore': 92.0,
      'latencyMs': 16.0,
      'status': 'DIBEKUKAN',
      'referenceNumber': 'REF98102938',
      'shapRiskFactors': {
        'smurfingPattern': 0.91,
        'muleAssociation': 0.94,
        'cryptoEndpoint': 0.95,
      }
    },
    {
      'id': 'B3',
      'senderName': 'Siti Rahma',
      'senderAccount': '6543210987',
      'beneficiaryName': 'Dewi Lestari',
      'beneficiaryAccount': '456789',
      'bankName': 'Bank Mandiri',
      'amount': 15000000.0,
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'purpose': 'Lainnya',
      'riskScore': 42.0,
      'latencyMs': 21.0,
      'status': 'DILOLOSKAN',
      'referenceNumber': 'REF88102930',
      'shapRiskFactors': {
        'smurfingPattern': 0.22,
        'muleAssociation': 0.15,
        'cryptoEndpoint': 0.05,
      }
    }
  ];

  // Transaction History
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'TX1',
      title: 'Transfer Masuk dari Kantor',
      description: 'Gaji Bulanan - Crypto Sentinel Ltd',
      amount: 15000000.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: TransactionType.credit,
      status: TransactionStatus.success,
      referenceNumber: 'REF98374298',
    ),
    TransactionModel(
      id: 'TX2',
      title: 'Pembayaran QRIS - Kopi Kenangan',
      description: 'QRIS-NPM/0023491/JAKARTA',
      amount: 45000.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.debit,
      status: TransactionStatus.success,
      referenceNumber: 'REF0023491',
    ),
    TransactionModel(
      id: 'TX3',
      title: 'Top Up E-Wallet OVO',
      description: 'OVO-TRF/88204938/DIGI',
      amount: 150000.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      type: TransactionType.debit,
      status: TransactionStatus.success,
      referenceNumber: 'REF88204938',
    ),
    TransactionModel(
      id: 'TX4',
      title: 'Bunga Rekening Bulanan',
      description: 'INT-ACC/SAVINGS-DIV/01',
      amount: 1200.0,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.credit,
      status: TransactionStatus.success,
      referenceNumber: 'REF88029302',
    ),
  ];

  // Saved/Favorite Recipients
  final List<FavoriteRecipient> _favorites = [
    const FavoriteRecipient(
      id: 'F1',
      name: 'Siti Rahma',
      bankName: 'Bank Rakyat Indonesia',
      bankCode: '002',
      accountNumber: '654321',
    ),
    const FavoriteRecipient(
      id: 'F2',
      name: 'Budi Santoso',
      bankName: 'Bank Central Asia',
      bankCode: '014',
      accountNumber: '987654',
    ),
    const FavoriteRecipient(
      id: 'F3',
      name: 'Dewi Lestari',
      bankName: 'Bank Mandiri',
      bankCode: '008',
      accountNumber: '456789',
    ),
  ];

  // Scheduled Transfers list
  final List<Map<String, dynamic>> _scheduledTransfers = [];

  // System Notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Keamanan Akun',
      'desc': 'Log masuk baru terdeteksi pada perangkat Android 2201117TY.',
      'time': '1 jam yang lalu',
      'isUnread': true,
    },
    {
      'id': '2',
      'title': 'Crypto-Sentinel Terintegrasi',
      'desc': 'Proteksi Smart Circuit Breaker berbasis AI & GNN aktif mengamankan transfer Anda.',
      'time': '1 hari yang lalu',
      'isUnread': false,
    },
  ];

  // Getters
  UserModel get currentUser => _currentUser;
  double get balance => _balance;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<FavoriteRecipient> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get scheduledTransfers => List.unmodifiable(_scheduledTransfers);
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get blockedTransactions => List.unmodifiable(_blockedTransactions);

  // 1. Account Name Lookup Action
  Future<String?> validateAccountNumber(String bankCode, String accountNumber) async {
    return await _apiService.validateAccountNumber(bankCode, accountNumber);
  }

  // 2. Perform Transfer Execution
  Future<TransactionModel> executeTransfer({
    required String beneficiaryName,
    required String accountNumber,
    required double amount,
    required double adminFee,
    required String note,
    required String bankName,
    required String bankCode,
    required String transferMethod,
  }) async {
    final totalCost = amount + adminFee;
    if (_balance < totalCost) {
      throw Exception('Saldo tidak mencukupi untuk melakukan transaksi.');
    }

    final tx = await _apiService.executeTransfer(
      beneficiaryName: beneficiaryName,
      accountNumber: accountNumber,
      amount: amount,
      adminFee: adminFee,
      note: note,
      bankName: bankName,
      bankCode: bankCode,
      transferMethod: transferMethod,
    );

    // Update state reactively
    _balance -= totalCost;
    _transactions.insert(0, tx);

    notifyListeners();
    return tx;
  }

  // 3. Register Intercepted/Blocked Attempt (Real-time SupTech mapping)
  void registerBlockedTransaction({
    required String beneficiaryName,
    required String accountNumber,
    required String bankName,
    required double amount,
    required String purpose,
  }) {
    final newBlock = {
      'id': 'B${DateTime.now().millisecondsSinceEpoch}',
      'senderName': _currentUser.name,
      'senderAccount': _currentUser.accountNumber,
      'beneficiaryName': beneficiaryName,
      'beneficiaryAccount': accountNumber,
      'bankName': bankName,
      'amount': amount,
      'timestamp': DateTime.now(),
      'purpose': purpose,
      'riskScore': purpose == 'Investasi / Pembelian Aset Crypto' ? 95.0 : 89.0,
      'latencyMs': 18.0,
      'status': 'DIBEKUKAN',
      'referenceNumber': 'REF${10000000 + DateTime.now().millisecond}',
      'shapRiskFactors': {
        'smurfingPattern': purpose == 'Investasi / Pembelian Aset Crypto' ? 0.96 : 0.94,
        'muleAssociation': accountNumber == '987654' ? 0.98 : 0.88,
        'cryptoEndpoint': purpose == 'Investasi / Pembelian Aset Crypto' ? 0.98 : 0.95,
      }
    };

    _blockedTransactions.insert(0, newBlock);
    totalBlockedValue += amount; // Increases the cumulative count of blocked laundry devisa
    notifyListeners();
  }

  // 4. Register Scheduled Transfer
  Future<void> scheduleTransfer({
    required String name,
    required String bankName,
    required String accountNumber,
    required double amount,
    required DateTime date,
  }) async {
    final scheduledItem = await _apiService.scheduleTransfer(
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      amount: amount,
      date: date,
    );

    _scheduledTransfers.insert(0, scheduledItem);
    notifyListeners();
  }

  // 5. Mark notifications read
  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n['isUnread'] = false;
    }
    notifyListeners();
  }

  // 6. Delete specific notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }
}
