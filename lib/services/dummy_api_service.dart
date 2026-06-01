import 'dart:math';
import '../models/transaction_model.dart';

class DummyApiService {
  // Destination account lookup map for mock API queries
  final Map<String, String> _accountValidationMap = {
    '1234567890': 'Billy Jonathan',
    '654321': 'Siti Rahma',
    '987654': 'Budi Santoso', // Mule Account
    '456789': 'Dewi Lestari',
    '112233': 'Adi Wijaya',
    '001201': 'Billy Jonathan (BRI)',
  };

  // 1. Simulates account validation REST API call: GET /api/accounts/validate?number=...
  Future<String?> validateAccountNumber(String bankCode, String accountNumber) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network delay
    
    if (_accountValidationMap.containsKey(accountNumber)) {
      return _accountValidationMap[accountNumber];
    }
    
    // Auto-generate some name if it has length of 6 digits or more to simulate a database query
    if (accountNumber.length >= 6) {
      return 'Nasabah Bank #${accountNumber.substring(0, min(accountNumber.length, 4))}';
    }
    
    return null; // Not found / invalid
  }

  // 2. Simulates mock transfer execution REST API call: POST /api/transfers
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
    await Future.delayed(const Duration(milliseconds: 1000)); // Processing delay

    final rand = Random();
    final refNum = 'REF${10000000 + rand.nextInt(90000000)}';
    final txId = 'TX${rand.nextInt(10000)}';

    return TransactionModel(
      id: txId,
      title: 'Transfer ke $beneficiaryName',
      description: note.isNotEmpty ? note : 'Transfer $transferMethod',
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.debit,
      status: TransactionStatus.success,
      referenceNumber: refNum,
      bankName: bankName,
      accountNumber: accountNumber,
    );
  }

  // 3. Simulates scheduling a transfer: POST /api/transfers/scheduled
  Future<Map<String, dynamic>> scheduleTransfer({
    required String name,
    required String bankName,
    required String accountNumber,
    required double amount,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final rand = Random();
    
    return {
      'id': 'S${rand.nextInt(10000)}',
      'title': 'Transfer Berkala ke $name',
      'desc': 'Transfer pada ${date.day}/${date.month}/${date.year}',
      'dateStr': '${date.day} ${_getMonthName(date.month)} ${date.year}',
      'amount': amount,
      'status': 'Terjadwal',
    };
  }

  // Helper
  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}
