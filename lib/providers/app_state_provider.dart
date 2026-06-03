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
  double _balance = 125750000.0; // Initial default balance, will be updated dynamically

  // GNN & SCB Performance Metrics (SupTech Proposal parameters)
  final double gnnAccuracy = 95.8; // F1-score > 95% target
  final double scbLatencyMs = 18.0; // SCB latency < 50ms target
  double totalBlockedValue = 800000000000.0; // Starts with Rp800 billion kerugian kasus nyata

  // Blocked/Intercepted Suspicious Transactions (for Analyst Portal) - cleared for dynamic flow
  final List<Map<String, dynamic>> _blockedTransactions = [];

  // Transaction History - cleared for dynamic flow
  final List<TransactionModel> _transactions = [];

  // Saved/Favorite Recipients matching PostgreSQL database seeded values
  final List<FavoriteRecipient> _favorites = [
    const FavoriteRecipient(
      id: 'F1',
      name: 'Penerima Dummy 1',
      bankName: 'Bank Central Asia',
      bankCode: '014',
      accountNumber: '1122334455',
    ),
    const FavoriteRecipient(
      id: 'F2',
      name: 'Penerima Dummy 2',
      bankName: 'Bank Rakyat Indonesia',
      bankCode: '002',
      accountNumber: '9876543210',
    ),
    const FavoriteRecipient(
      id: 'F3',
      name: 'Pengirim Dummy 1',
      bankName: 'Bank Rakyat Indonesia',
      bankCode: '002',
      accountNumber: '0123456789',
    ),
    const FavoriteRecipient(
      id: 'F4',
      name: 'Pengirim Dummy 2',
      bankName: 'Bank Rakyat Indonesia',
      bankCode: '002',
      accountNumber: '5544332211',
    ),
    const FavoriteRecipient(
      id: 'F5',
      name: 'INDODAX MULE ACCOUNT (BLACKLIST)',
      bankName: 'Bank Central Asia',
      bankCode: '014',
      accountNumber: 'C666666666',
    ),
    const FavoriteRecipient(
      id: 'F6',
      name: 'BUDI SANTOSO (MULE)',
      bankName: 'Bank Central Asia',
      bankCode: '014',
      accountNumber: '987654',
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
      'status': 'info',
    },
    {
      'id': '2',
      'title': 'Crypto-Sentinel Terintegrasi',
      'desc': 'Proteksi Smart Circuit Breaker berbasis AI & GNN aktif mengamankan transfer Anda.',
      'time': '1 hari yang lalu',
      'isUnread': false,
      'status': 'success',
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

  // Action to load the real user balance from the backend
  Future<void> loadUserBalance() async {
    try {
      debugPrint('AppStateProvider: Loading user balance for ${_currentUser.accountNumber}...');
      final details = await _apiService.getAccountDetails(_currentUser.accountNumber);
      if (details != null) {
        _balance = (details['balance'] as num).toDouble();
        debugPrint('AppStateProvider: Loaded user balance successfully: $_balance');
        notifyListeners();
      } else {
        debugPrint('AppStateProvider: Failed to load user balance (details is null)');
      }
    } catch (e) {
      debugPrint('Error loading user balance from API: $e');
    }
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

  // 6b. Add a new notification dynamically
  void addNotification({
    required String title,
    required String desc,
    String? status,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'desc': desc,
      'time': 'Baru saja',
      'isUnread': true,
      'status': status,
    });
    notifyListeners();
  }

  // 7. Load transactions from backend database
  Future<void> loadTransactions() async {
    try {
      debugPrint('AppStateProvider: Loading transactions for ${_currentUser.accountNumber}...');
      final txList = await _apiService.getTransactions(_currentUser.accountNumber);
      _transactions.clear();
      _transactions.addAll(txList);
      debugPrint('AppStateProvider: Loaded ${txList.length} transactions successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions from API: $e');
    }
  }

  // 8. Reset provider state on logout
  void resetState() {
    _balance = 125750000.0;
    _blockedTransactions.clear();
    _transactions.clear();
    _scheduledTransfers.clear();
    _notifications.clear();
    _notifications.addAll([
      {
        'id': '1',
        'title': 'Keamanan Akun',
        'desc': 'Log masuk baru terdeteksi pada perangkat Android 2201117TY.',
        'time': '1 jam yang lalu',
        'isUnread': true,
        'status': 'info',
      },
      {
        'id': '2',
        'title': 'Crypto-Sentinel Terintegrasi',
        'desc': 'Proteksi Smart Circuit Breaker berbasis AI & GNN aktif mengamankan transfer Anda.',
        'time': '1 hari yang lalu',
        'isUnread': false,
        'status': 'success',
      },
    ]);
    notifyListeners();
  }
}
