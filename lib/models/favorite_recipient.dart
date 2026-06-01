class FavoriteRecipient {
  final String id;
  final String name;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  
  const FavoriteRecipient({
    required this.id,
    required this.name,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
  });

  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
