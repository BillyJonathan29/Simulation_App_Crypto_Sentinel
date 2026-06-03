import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  // Base URL detection (Using PC local IP: 192.168.100.75 so a real phone on the same Wi-Fi can connect)
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    } else {
      // IP lokal PC - pastikan HP & PC terhubung ke WiFi yang sama
      return 'http://192.168.100.75:8080/api/v1';
    }
  }

  // 1. Validates account number using the actual FastAPI backend (GET /bri/account/{id})
  Future<String?> validateAccountNumber(String bankCode, String accountNumber) async {
    try {
      final uri = Uri.parse('$baseUrl/bri/account/$accountNumber');
      debugPrint('Validating account number via API: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['owner_name'] as String?;
      }
    } catch (e) {
      debugPrint('Error validating account via API: $e');
      throw Exception('Gagal memvalidasi rekening: Tidak dapat terhubung ke server backend ($baseUrl). Pastikan HP & PC terhubung ke Wi-Fi yang sama, dan firewall di PC Anda mengizinkan port 8000. (Detail: $e)');
    }

    // Fallback to original mock logic if server is offline or not found
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_accountValidationMap.containsKey(accountNumber)) {
      return _accountValidationMap[accountNumber];
    }
    
    if (accountNumber.length >= 6) {
      return 'Nasabah Bank #${accountNumber.substring(0, min(accountNumber.length, 4))}';
    }
    
    return null; // Not found / invalid
  }

  // Fetch detailed account information (like balance) from FastAPI backend
  Future<Map<String, dynamic>?> getAccountDetails(String accountNumber) async {
    try {
      final uri = Uri.parse('$baseUrl/bri/account/$accountNumber');
      debugPrint('Fetching account details via API: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('Failed to fetch account details. Status: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('Error fetching account details: $e\n$stack');
    }
    return null;
  }

  // 2. Executes transfer using actual FastAPI backend (POST /bri/transfer or /bri/transfer-interbank)
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
    // Cek apakah transfer sesama BRI (intrabank) atau ke bank lain (interbank)
    // bankCode '002' = BRI, atau nama bank mengandung variasi nama BRI
    final bankNameUpper = bankName.toUpperCase();
    final isIntrabank = bankCode == '002' ||
        bankNameUpper.contains('BRI') ||
        bankNameUpper.contains('RAKYAT INDONESIA') ||
        bankNameUpper.contains('BANK RAKYAT');
    final url = isIntrabank ? '$baseUrl/bri/transfer' : '$baseUrl/bri/transfer-interbank';

    final body = {
      'sender_account': '1234567890', // Billy Jonathan's account (configured in seeder.py)
      'receiver_account': accountNumber,
      'amount': amount.toInt().toString(),
      'latitude': '-6.2000',
      'longitude': '106.8000',
    };

    if (!isIntrabank) {
      body['bank_code'] = bankCode;
    }

    try {
      debugPrint('Sending API transfer request to: $url with body: $body');
      final response = await http.post(
        Uri.parse(url),
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final txInfo = data['transfer_info'];
        final txId = data['transaction_id'] ?? 'TX${Random().nextInt(10000)}';
        
        return TransactionModel(
          id: txId,
          title: 'Transfer ke ${txInfo['receiver'] ?? beneficiaryName}',
          description: note.isNotEmpty ? note : 'Transfer $transferMethod',
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.debit,
          status: TransactionStatus.success,
          referenceNumber: txId,
          bankName: bankName,
          accountNumber: accountNumber,
        );
      } else {
        // Handle specific server-side errors (e.g. balance insufficient, blocked account)
        try {
          final errData = json.decode(response.body);
          final String errMsg = errData['detail'] ?? 'Transaksi ditolak oleh server.';
          throw Exception(errMsg);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Gagal melakukan transfer (Server Error: ${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('API transfer failed: $e');
      
      // Rethrow validation or business rule errors (e.g., account blocked or balance insufficient)
      if (e is Exception && !e.toString().contains('SocketException') && !e.toString().contains('TimeoutException') && !e.toString().contains('Connection refused')) {
        rethrow;
      }
      
      throw Exception('Gagal melakukan transfer: Tidak dapat terhubung ke server backend ($baseUrl). Pastikan HP & PC terhubung ke Wi-Fi yang sama, dan firewall di PC Anda mengizinkan port 8000. (Detail: $e)');
    }
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

  // 4. Fetches real transactions from backend database
  Future<List<TransactionModel>> getTransactions(String accountNumber) async {
    try {
      final uri = Uri.parse('$baseUrl/bri/transactions/$accountNumber');
      debugPrint('Fetching transactions via API: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<TransactionModel> list = [];
        for (var item in data) {
          try {
            final isDebit = item['sender_account'] == accountNumber;
            final otherAcc = isDebit ? item['receiver_account'] : item['sender_account'];
            
            String otherName = 'Penerima';
            String otherBank = 'BANK';
            
            if (otherAcc == '1122334455') {
              otherName = 'Penerima Dummy 1';
              otherBank = 'BANK BCA';
            } else if (otherAcc == '9876543210') {
              otherName = 'Penerima Dummy 2';
              otherBank = 'BANK BRI';
            } else if (otherAcc == '0123456789') {
              otherName = 'Pengirim Dummy 1';
              otherBank = 'BANK BRI';
            } else if (otherAcc == '5544332211') {
              otherName = 'Pengirim Dummy 2';
              otherBank = 'BANK BRI';
            } else if (otherAcc == '1234567890') {
              otherName = 'Billy Jonathan';
              otherBank = 'BANK BRI';
            } else if (otherAcc != null && otherAcc.toString().isNotEmpty) {
              final accStr = otherAcc.toString();
              otherName = 'Nasabah #${accStr.substring(0, min(accStr.length, 4))}';
            }
            
            final txStatus = item['status'] == 'SUCCESS' 
                ? TransactionStatus.success 
                : (item['status'] == 'FAILED' ? TransactionStatus.failed : TransactionStatus.pending);

            list.add(TransactionModel(
              id: item['transaction_id']?.toString() ?? '',
              title: isDebit ? 'Transfer ke $otherName' : 'Transfer dari $otherName',
              description: item['description']?.toString() ?? 'Transfer',
              amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
              timestamp: item['timestamp'] != null ? DateTime.parse(item['timestamp'].toString()) : DateTime.now(),
              type: isDebit ? TransactionType.debit : TransactionType.credit,
              status: txStatus,
              referenceNumber: item['transaction_id']?.toString(),
              bankName: otherBank,
              accountNumber: otherAcc?.toString(),
            ));
          } catch (itemErr, stack) {
            debugPrint('Error parsing transaction item $item: $itemErr\n$stack');
          }
        }
        return list;
      } else {
        debugPrint('Failed to fetch transactions. Status code: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('Error fetching transactions: $e\n$stack');
    }
    return [];
  }
}
