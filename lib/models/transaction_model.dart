enum TransactionType { credit, debit }
enum TransactionStatus { pending, success, failed }

class TransactionModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final TransactionType type;
  final TransactionStatus status;
  final String? referenceNumber;
  final String? bankName;
  final String? accountNumber;

  TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.type,
    required this.status,
    this.referenceNumber,
    this.bankName,
    this.accountNumber,
  });
}
