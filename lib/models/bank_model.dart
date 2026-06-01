class BankModel {
  final String code;
  final String name;
  final String shortName;

  const BankModel({
    required this.code,
    required this.name,
    required this.shortName,
  });

  static const List<BankModel> availableBanks = [
    BankModel(code: '002', name: 'Bank Rakyat Indonesia', shortName: 'BRI'),
    BankModel(code: '008', name: 'Bank Mandiri', shortName: 'Mandiri'),
    BankModel(code: '014', name: 'Bank Central Asia', shortName: 'BCA'),
    BankModel(code: '009', name: 'Bank Negara Indonesia', shortName: 'BNI'),
    BankModel(code: '022', name: 'Bank CIMB Niaga', shortName: 'CIMB'),
    BankModel(code: '200', name: 'Bank Tabungan Negara', shortName: 'BTN'),
    BankModel(code: '111', name: 'Bank DKI', shortName: 'DKI'),
    BankModel(code: '503', name: 'Bank Syariah Indonesia', shortName: 'BSI'),
  ];
}
