import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/pin_input.dart';
import 'add_recipient_screen.dart';

class TransferScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  const TransferScreen({super.key, required this.onBackToHome});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // Step: 0 = Daftar Transfer, 1 = Masukkan Nominal, 2 = Hasil
  int _currentStep = 0;
  bool _isLoading = false;

  // Hasil transfer: 'success' | 'blocked' | 'pending'
  String _transferResult = 'success';
  String _blockReason   = '';
  int    _riskScore     = 0;
  String _txId          = '';

  Map<String, dynamic>? _selectedRecipient;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController   = TextEditingController();
  bool _isScheduled = false;

  final _currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 2);
  final _decFmt  = NumberFormat.decimalPattern('id');

  late List<Map<String, dynamic>> _displayRecipients;

  bool get _isSesamaBri {
    final bank = _selectedRecipient?['bank']?.toString().toUpperCase() ?? '';
    // Cocokkan semua variasi nama BRI: 'BRI', 'RAKYAT INDONESIA', 'BANK RAKYAT'
    return bank.contains('BRI') ||
        bank.contains('RAKYAT INDONESIA') ||
        bank.contains('BANK RAKYAT');
  }

  String get _bankCode {
    final bank = _selectedRecipient?['bank']?.toString().toUpperCase() ?? '';
    if (bank.contains('BRI') || bank.contains('RAKYAT INDONESIA') || bank.contains('BANK RAKYAT')) return '002';
    if (bank.contains('BCA') || bank.contains('CENTRAL ASIA')) return '014';
    if (bank.contains('MANDIRI')) return '008';
    if (bank.contains('BNI') || bank.contains('NEGARA INDONESIA')) return '009';
    if (bank.contains('BSI') || bank.contains('SYARIAH INDONESIA')) return '451';
    if (bank.contains('CIMB')) return '022';
    return '014'; // Default ke BCA untuk bank lain (interbank)
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppStateProvider>(context, listen: false);
    _displayRecipients = state.favorites.map((fav) {
      final name = fav.name;
      final initials = name.length >= 2
          ? '${name[0]}${name.split(' ').length > 1 ? name.split(' ')[1][0] : name[1]}'
          : name.isNotEmpty ? name.substring(0, 1) : '?';
      return {
        'name': name.toUpperCase(),
        'bank': fav.bankName.toUpperCase(),
        'account': fav.accountNumber,
        'initials': initials.toUpperCase(),
      };
    }).toList();
  }

  void _deleteRecipient(Map<String, dynamic> recipient) {
    setState(() {
      _displayRecipients.removeWhere((r) => r['account'] == recipient['account']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Penerima ${recipient['name']} berhasil dihapus.'),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ─── Navigate to nominal screen ────────────────────────────────────────────
  void _selectRecipient(Map<String, dynamic> recipient) {
    setState(() {
      _selectedRecipient = recipient;
      _currentStep = 1;
      _amountController.clear();
      _noteController.clear();
      _isScheduled = false;
    });
  }

  // ─── Open Add Recipient screen ─────────────────────────────────────────────
  void _openAddRecipient() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRecipientScreen(
          onBack: () => Navigator.of(context).pop(),
          onRecipientAdded: (recipient) {
            setState(() {
              _displayRecipients.add({
                'name':     recipient['name'] ?? '',
                'bank':     recipient['bank'] ?? '',
                'account':  recipient['account'] ?? '',
                'initials': recipient['initials'] ?? '?',
              });
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${recipient['name']} ditambahkan ke daftar penerima.'),
                backgroundColor: const Color(0xFF00A86B),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Validate & show PIN ───────────────────────────────────────────────────
  void _showPinDialog() {
    final raw    = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(raw) ?? 0.0;
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal transfer adalah Rp10.000'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinInput(
        onCompleted: (pin) {
          Navigator.pop(context);
          _executeTransfer();
        },
      ),
    );
  }

  // ─── Execute transfer ──────────────────────────────────────────────────────
  Future<void> _executeTransfer() async {
    if (_isLoading) return;
    final state  = Provider.of<AppStateProvider>(context, listen: false);
    final raw    = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(raw) ?? 0.0;

    if (mounted) setState(() => _isLoading = true);

    // ── Simulasi analisis Crypto-Sentinel (delay realistis)
    await Future.delayed(const Duration(milliseconds: 1800));

    // ── Tentukan skenario berdasarkan nominal (demo logic)
    // Rp ≥ 100 juta → BLOKIR (high risk)
    // Rp 50 juta – 99 juta → PENDING (review manual)
    // Di bawah Rp 50 juta → SUKSES
    final txId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final fmtAmount = _currFmt.format(amount);

    final destAcc = _selectedRecipient?['account']?.toString() ?? '';
    final isBlacklist = destAcc.startsWith('C') ||
                        destAcc == 'C666666666' ||
                        destAcc == 'C999999999' ||
                        destAcc == 'C777777777' ||
                        destAcc == 'C123456789' ||
                        destAcc == 'C888888888';
    final adminFee = _isSesamaBri ? 0.0 : 2500.0;
    final isDrained = (amount + adminFee) >= state.balance;
    final isMule = destAcc == '987654' || destAcc == '9876543210';

    if (isBlacklist) {
      // ── SKENARIO BLOKIR (blacklist account)
      final riskScore = 98;
      if (mounted) {
        setState(() {
          _isLoading      = false;
          _transferResult = 'blocked';
          _blockReason    = 'Transaksi diblokir otomatis oleh sistem keamanan Crypto-Sentinel karena '
                            'rekening tujuan terdaftar dalam blacklist OJK/Crypto-Sentinel.';
          _riskScore      = riskScore;
          _txId           = txId;
          _currentStep    = 2;
        });
      }
      state.addNotification(
        title: 'Transfer Gagal (Anomali)',
        desc: 'Transfer ke ${_selectedRecipient!['name']} sebesar $fmtAmount diblokir: Terdeteksi rekening blacklist.',
        status: 'failed',
      );
      state.registerBlockedTransaction(
        beneficiaryName: _selectedRecipient!['name'],
        accountNumber:   _selectedRecipient!['account'],
        bankName:        _selectedRecipient!['bank'],
        amount:          amount,
        purpose:         'Watchlist/Threat Intel Match (Blacklist)',
      );
      return;
    }

    if (isDrained && isMule) {
      // ── SKENARIO PENDING (drained + mule account)
      final riskScore = 68;
      if (mounted) {
        setState(() {
          _isLoading      = false;
          _transferResult = 'pending';
          _blockReason    = 'Transaksi ditangguhkan karena terdeteksi anomali: '
                            'Saldo rekening pengirim dikuras habis ke rekening penampung (mule account).';
          _riskScore      = riskScore;
          _txId           = txId;
          _currentStep    = 2;
        });
      }
      state.addNotification(
        title: 'Transfer Ditangguhkan (Review)',
        desc: 'Transfer ke ${_selectedRecipient!['name']} sebesar $fmtAmount ditahan sementara untuk verifikasi keamanan.',
        status: 'pending',
      );
      return;
    }

    // ── SKENARIO SUKSES (nominal normal)
    try {
      await state.executeTransfer(
        beneficiaryName: _selectedRecipient!['name'],
        accountNumber:   _selectedRecipient!['account'],
        amount:          amount,
        adminFee:        _isSesamaBri ? 0.0 : 2500.0,
        note:            _noteController.text.isNotEmpty
            ? _noteController.text
            : (_isSesamaBri ? 'Transfer Online' : 'Transfer BI-FAST'),
        bankName:        _selectedRecipient!['bank'],
        bankCode:        _bankCode,
        transferMethod:  _isSesamaBri ? 'Transfer Online' : 'BI-FAST',
      );
      if (mounted) {
        setState(() {
          _isLoading      = false;
          _transferResult = 'success';
          _txId           = txId;
          _currentStep    = 2;
        });
      }
      state.addNotification(
        title: 'Transfer Berhasil',
        desc: 'Transfer ke ${_selectedRecipient!['name']} sebesar $fmtAmount berhasil dikirim.',
        status: 'success',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final errMsg = e.toString().replaceFirst('Exception: ', '');
        
        if (errMsg.contains('diblokir otomatis oleh sistem keamanan Crypto-Sentinel')) {
          int score = 85;
          final scoreReg = RegExp(r'Skor Risiko: (\d+)');
          final match = scoreReg.firstMatch(errMsg);
          if (match != null) {
            score = int.parse(match.group(1)!);
          }
          
          setState(() {
            _transferResult = 'blocked';
            _blockReason    = errMsg;
            _riskScore      = score;
            _txId           = txId;
            _currentStep    = 2;
          });
          
          state.addNotification(
            title: 'Transfer Gagal (Anomali)',
            desc: 'Transfer ke ${_selectedRecipient!['name']} sebesar $fmtAmount diblokir: Terdeteksi pola anomali.',
            status: 'failed',
          );
          state.registerBlockedTransaction(
            beneficiaryName: _selectedRecipient!['name'],
            accountNumber:   _selectedRecipient!['account'],
            bankName:        _selectedRecipient!['bank'],
            amount:          amount,
            purpose:         'Watchlist/Threat Intel Match',
          );
        } else if (errMsg.contains('ditangguhkan oleh sistem keamanan Crypto-Sentinel')) {
          int score = 65;
          final scoreReg = RegExp(r'Skor Risiko: (\d+)');
          final match = scoreReg.firstMatch(errMsg);
          if (match != null) {
            score = int.parse(match.group(1)!);
          }
          
          setState(() {
            _transferResult = 'pending';
            _blockReason    = errMsg;
            _riskScore      = score;
            _txId           = txId;
            _currentStep    = 2;
          });
          
          state.addNotification(
            title: 'Transfer Ditangguhkan (Review)',
            desc: 'Transfer ke ${_selectedRecipient!['name']} sebesar $fmtAmount ditahan sementara untuk verifikasi keamanan.',
            status: 'pending',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errMsg),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // ─── Show BI-FAST info bottom sheet ───────────────────────────────────────
  void _showMetodeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MetodeTransferSheet(),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:  return _buildDaftarTransfer();
      case 1:  return _buildMasukkanNominal();
      default:
        if (_transferResult == 'blocked') return _buildBlockedScreen();
        if (_transferResult == 'pending') return _buildPendingScreen();
        return _buildSuccessReceipt();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SCREEN: TRANSAKSI DIBLOKIR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBlockedScreen() {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header merah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text('Transaksi Diblokir',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('oleh Crypto-Sentinel AI',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Risk score badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 18),
                            const SizedBox(width: 8),
                            Text('Risk Score: $_riskScore / 100',
                              style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w800, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detail card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Transaksi', _txId),
                          _detailRow('Penerima', _selectedRecipient?['name'] ?? '-'),
                          _detailRow('Nominal', fmt.format(amount)),
                          _detailRow('Bank Tujuan', _selectedRecipient?['bank'] ?? '-'),
                          _detailRow('Status', '⛔ DIBLOKIR'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alasan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alasan Pemblokiran:',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFD32F2F))),
                          const SizedBox(height: 6),
                          Text(_blockReason,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF5D2E2E), height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Sentinel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_rounded, color: Color(0xFF0070C0), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Transaksi ini telah dilaporkan ke sistem Crypto-Sentinel '
                              'dan tim kepatuhan OJK untuk investigasi lebih lanjut.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol kembali
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() { _currentStep = 0; _transferResult = 'success'; }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SCREEN: TRANSAKSI PENDING
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPendingScreen() {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header kuning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text('Transaksi Ditahan',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Menunggu Verifikasi Manual',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Risk score badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timelapse_rounded, color: Color(0xFFF59E0B), size: 18),
                            const SizedBox(width: 8),
                            Text('Risk Score: $_riskScore / 100 — MEDIUM',
                              style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w800, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detail card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Transaksi', _txId),
                          _detailRow('Penerima', _selectedRecipient?['name'] ?? '-'),
                          _detailRow('Nominal', fmt.format(amount)),
                          _detailRow('Bank Tujuan', _selectedRecipient?['bank'] ?? '-'),
                          _detailRow('Status', '⏳ PENDING REVIEW'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alasan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keterangan:',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E))),
                          const SizedBox(height: 6),
                          Text(_blockReason,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Timeline estimasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimasi Proses:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(height: 8),
                          _TimelineItem(icon: Icons.looks_one_rounded, color: Color(0xFFF59E0B), text: 'Sedang dianalisis oleh sistem AI'),
                          _TimelineItem(icon: Icons.looks_two_rounded, color: Color(0xFF6B7280), text: 'Review oleh tim kepatuhan BRI'),
                          _TimelineItem(icon: Icons.looks_3_rounded, color: Color(0xFF6B7280), text: 'Notifikasi hasil dalam 1×24 jam'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol kembali
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onBackToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper row untuk detail card
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STEP 0 ─ Daftar Transfer
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDaftarTransfer() {
    final state = context.watch<AppStateProvider>();
    final recentTransfers = <Map<String, dynamic>>[];
    final seenAccounts = <String>{};

    for (var tx in state.transactions) {
      final acc = tx.accountNumber ?? '';
      if (acc.isNotEmpty && !seenAccounts.contains(acc)) {
        seenAccounts.add(acc);
        final name = tx.title.startsWith('Transfer ke ')
            ? tx.title.substring('Transfer ke '.length)
            : tx.title;
        final initials = name.length >= 2
            ? '${name[0]}${name.split(' ').length > 1 ? name.split(' ')[1][0] : name[1]}'
            : name.isNotEmpty ? name.substring(0, 1) : '?';
        recentTransfers.add({
          'name': name.toUpperCase(),
          'bank': (tx.bankName ?? 'BANK').toUpperCase(),
          'account': acc,
          'initials': initials.toUpperCase(),
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0070C0),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: widget.onBackToHome,
        ),
        title: const Text(
          'Transfer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ── Tab Bar ──────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0070C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Dalam Negeri',
                    style: TextStyle(
                      color: Color(0xFF0070C0),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Internasional',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Emas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // ── Transfer Terakhir ────────────────────────────────────
                  if (recentTransfers.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Transfer Terakhir',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 88,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: recentTransfers.length,
                        itemBuilder: (_, i) {
                          final r = recentTransfers[i];
                          return GestureDetector(
                            onTap: () => _selectRecipient(r),
                            child: Container(
                              width: 190,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 19,
                                    backgroundColor: const Color(0xFFE8EEF5),
                                    child: Text(
                                      r['initials'],
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          r['name'],
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          r['bank'],
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10.5,
                                          ),
                                        ),
                                        Text(
                                          r['account'],
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Transfer Terjadwal Banner ────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pakai Transfer Terjadwal, Yuk!',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Buat transfer rutin jadi otomatis dan tepat waktu.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF0070C0),
                          size: 14,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Daftar Tersimpan header ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Tersimpan',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openAddRecipient,
                          child: Row(
                            children: const [
                              Icon(Icons.add_rounded, color: Color(0xFF0070C0), size: 17),
                              SizedBox(width: 3),
                              Text(
                                'Tambah',
                                style: TextStyle(
                                  color: Color(0xFF0070C0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Search bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDDE3ED), width: 1),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 12),
                          Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Cari nama atau bank disini...',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Recipient list ───────────────────────────────────────
                  Container(
                    color: Colors.white,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _displayRecipients.length,
                      separatorBuilder: (ctx, idx) => const Padding(
                        padding: EdgeInsets.only(left: 72),
                        child: Divider(height: 0, color: Color(0xFFEEF2F7)),
                      ),
                      itemBuilder: (_, i) {
                        final r = _displayRecipients[i];
                        return InkWell(
                          onTap: () => _selectRecipient(r),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  backgroundColor: const Color(0xFF0070C0),
                                  child: Text(
                                    r['initials'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['name'],
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        r['bank'],
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      Text(
                                        r['account'],
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'transfer') {
                                      _selectRecipient(r);
                                    } else if (value == 'hapus') {
                                      _deleteRecipient(r);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'transfer',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.send_rounded, color: Color(0xFF0070C0), size: 18),
                                          SizedBox(width: 8),
                                          Text('Transfer', style: TextStyle(fontSize: 13.5, color: Color(0xFF0F172A))),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'hapus',
                                      child: Row(
                                        children: const [
                                          Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text('Hapus', style: TextStyle(fontSize: 13.5, color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Tambah Penerima Baru button ──────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openAddRecipient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0070C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tambah Penerima Baru',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STEP 1 ─ Masukkan Nominal
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMasukkanNominal() {
    final state        = context.watch<AppStateProvider>();
    final balance      = state.balance;
    final formattedBal = _currFmt.format(balance);

    final rawAmount = _amountController.text.replaceAll('.', '');
    final amount    = double.tryParse(rawAmount) ?? 0.0;
    final canSubmit = amount >= 10000;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0070C0),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Text(
          'Masukkan Nominal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── A. Recipient info card ────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE8EEF5),
                              child: Text(
                                _selectedRecipient!['initials'],
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedRecipient!['name'],
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedRecipient!['bank'],
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatAccountNumber(_selectedRecipient!['account']),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Info chip
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF0070C0),
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tersimpan sebagai ${_selectedRecipient!['name']}',
                                style: const TextStyle(
                                  color: Color(0xFF0070C0),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_isSesamaBri) ...[
                    const SizedBox(height: 10),
                    // ── B. Metode Transfer ────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Transfer',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _showMetodeSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFDDE3ED),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Transfer BI-FAST',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF0070C0),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // ── C. Nominal Transfer ───────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nominal Transfer',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDDE3ED),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    'Rp',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: const Color(0xFF0070C0),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 26,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      onChanged: (val) {
                                        final clean  = val.replaceAll('.', '');
                                        final parsed = double.tryParse(clean);
                                        if (parsed != null) {
                                          final formatted = _decFmt.format(parsed);
                                          _amountController.value = TextEditingValue(
                                            text: formatted,
                                            selection: TextSelection.collapsed(
                                              offset: formatted.length,
                                            ),
                                          );
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Minimal  Rp10.000',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 0, color: Color(0xFFEEF2F7)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _noteController,
                                      maxLength: 40,
                                      cursorColor: const Color(0xFF0070C0),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Tulis Catatan (Opsional)',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        counterText: '',
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  Text(
                                    '${_noteController.text.length}/40',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── D. Pakai Transfer Terjadwal ───────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pakai Transfer Terjadwal',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Buat transfermu otomatis sesuai jadwal untuk\npenerima & nominal yang tertera di atas.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isScheduled,
                          onChanged: (v) => setState(() => _isScheduled = v),
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF0070C0),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFCDD5E0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── E. Sumber Dana ────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sumber Dana',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFDDE3ED),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFDDE3ED),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Tabungan BRI',
                                      style: TextStyle(
                                        color: Color(0xFF004A97),
                                        fontSize: 5.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'BritAma',
                                      style: TextStyle(
                                        color: Color(0xFF004A97),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '0005 0121 9938 509',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Text(
                                      'BILLY JONATHAN',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      formattedBal,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ganti sumber dana.')),
                                ),
                                child: const Text(
                                  'Ganti',
                                  style: TextStyle(
                                    color: Color(0xFF0070C0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Lanjutkan button ─────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || !canSubmit) ? null : _showPinDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit && !_isLoading
                        ? const Color(0xFF0070C0)
                        : const Color(0xFFCDD5E0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF0070C0),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Lanjutkan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STEP 2 ─ Success Receipt
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccessReceipt() {
    final state        = context.watch<AppStateProvider>();
    final tx           = state.transactions.isNotEmpty ? state.transactions.first : null;
    final formattedAmt = tx != null ? _currFmt.format(tx.amount) : '-';

    return Scaffold(
      backgroundColor: const Color(0xFF0070C0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF00A86B),
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Transfer Berhasil!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _receiptRow('Penerima',    _selectedRecipient!['name']),
                    _receiptRow('Bank Tujuan', _selectedRecipient!['bank']),
                    _receiptRow('Rekening',    _selectedRecipient!['account']),
                    const Divider(height: 20, color: Color(0xFFEEF2F7)),
                    _receiptRow('Nominal',     formattedAmt),
                    _receiptRow('Biaya Admin', _isSesamaBri ? 'Rp0' : 'Rp2.500,00 (BI-FAST)'),
                    const Divider(height: 20, color: Color(0xFFEEF2F7)),
                    _receiptRow('Metode',      _isSesamaBri ? 'Transfer Online' : 'BI-FAST'),
                    _receiptRow('No. Referensi', tx?.referenceNumber ?? '-'),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  setState(() => _currentStep = 0);
                  widget.onBackToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0070C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAccountNumber(String acc) {
    final clean = acc.replaceAll(' ', '');
    final buf   = StringBuffer();
    for (var idx = 0; idx < clean.length; idx++) {
      if (idx > 0 && idx % 4 == 0) buf.write(' ');
      buf.write(clean[idx]);
    }
    return buf.toString();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Metode Transfer bottom sheet
// ════════════════════════════════════════════════════════════════════════════
class _MetodeTransferSheet extends StatelessWidget {
  const _MetodeTransferSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCDD5E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Metode Transfer',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0070C0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer BI-FAST',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Metode transfer online antar bank peserta BI-FAST',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 0, color: Color(0xFFCCDFF0)),
                  const SizedBox(height: 10),
                  _infoRow('Limit Harian',    'Rp250.000.000'),
                  const SizedBox(height: 4),
                  _infoRow('Biaya Admin',     'Rp2.500'),
                  const SizedBox(height: 4),
                  _infoRow('Jam Operasional', '24 Jam, 7 hari'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5)),
        Text(value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}

// ─── Timeline item untuk halaman PENDING ──────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _TimelineItem({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}
