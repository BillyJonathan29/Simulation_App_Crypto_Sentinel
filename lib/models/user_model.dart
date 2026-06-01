class UserModel {
  final String name;
  final String email;
  final String accountNumber;
  final String accountType; // e.g., Nasabah Gold
  final String username;

  const UserModel({
    required this.name,
    required this.email,
    required this.accountNumber,
    required this.accountType,
    required this.username,
  });
}
