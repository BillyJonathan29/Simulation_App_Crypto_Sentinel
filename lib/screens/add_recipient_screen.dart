import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Halaman Tambah Penerima Baru — BRImo style
class AddRecipientScreen extends StatefulWidget {
  final VoidCallback onBack;
  /// Called when user finishes adding and we should navigate to nominal screen
  final void Function(Map<String, dynamic> recipient)? onRecipientAdded;

  const AddRecipientScreen({
    super.key,
    required this.onBack,
    this.onRecipientAdded,
  });

  @override
  State<AddRecipientScreen> createState() => _AddRecipientScreenState();
}

class _AddRecipientScreenState extends State<AddRecipientScreen> {
  // 0 = Nomor Rekening, 1 = Kontak BI-FAST
  int _tab = 0;

  // Nomor Rekening tab controllers
  String _selectedBank = 'BANK BRI';
  final TextEditingController _accountCtrl = TextEditingController();

  // Kontak BI-FAST tab controllers
  final TextEditingController _phoneEmailCtrl = TextEditingController();

  // Bank list for dropdown
  final List<String> _banks = [
    'BANK BRI',
    'BANK BCA',
    'BANK MANDIRI',
    'BANK BNI',
    'BANK BSI',
    'BANK CIMB NIAGA',
    'BANK DANAMON',
    'BANK PERMATA',
    'BANK BTN',
    'BANK OCBC',
    'BPR SERANG',
    'Dana',
    'Shopeepay',
    'OVO',
    'GoPay',
  ];

  @override
  void dispose() {
    _accountCtrl.dispose();
    _phoneEmailCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_tab == 0) {
      return _accountCtrl.text.trim().isNotEmpty;
    } else {
      return _phoneEmailCtrl.text.trim().isNotEmpty;
    }
  }

  void _onLanjutkan() {
    if (!_canProceed) return;

    final Map<String, dynamic> recipient;
    if (_tab == 0) {
      final name = _accountCtrl.text.trim().toUpperCase();
      final initials = name.length >= 2
          ? '${name[0]}${name.split(' ').length > 1 ? name.split(' ')[1][0] : name[1]}'
          : name.substring(0, 1);
      recipient = {
        'name': name,
        'bank': _selectedBank,
        'account': _accountCtrl.text.trim(),
        'initials': initials.toUpperCase(),
      };
    } else {
      final input = _phoneEmailCtrl.text.trim();
      recipient = {
        'name': input.toUpperCase(),
        'bank': 'BI-FAST',
        'account': input,
        'initials': input.isNotEmpty ? input[0].toUpperCase() : '?',
      };
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Penerima berhasil ditambahkan!'),
        backgroundColor: const Color(0xFF00A86B),
        duration: const Duration(seconds: 2),
      ),
    );

    if (widget.onRecipientAdded != null) {
      widget.onRecipientAdded!(recipient);
    } else {
      widget.onBack();
    }
  }

  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BankPickerSheet(
        banks: _banks,
        selected: _selectedBank,
        onSelected: (bank) {
          setState(() => _selectedBank = bank);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0070C0),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Penerima Baru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: _buildTabBar(),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: _tab == 0 ? _buildNomorRekeningTab() : _buildKontakBiFastTab(),
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
                child: AnimatedBuilder(
                  animation: Listenable.merge([_accountCtrl, _phoneEmailCtrl]),
                  builder: (context4, widget2) {
                    final active = _canProceed;
                    return ElevatedButton(
                      onPressed: active ? _onLanjutkan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: active
                            ? const Color(0xFF0070C0)
                            : const Color(0xFFCDD5E0),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFCDD5E0),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0070C0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF00337A),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _tabItem(0, 'Nomor Rekening'),
            _tabItem(1, 'Kontak BI-FAST'),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF0070C0) : Colors.white70,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 0: Nomor Rekening ─────────────────────────────────────────────────
  Widget _buildNomorRekeningTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank Tujuan label
        const Text(
          'Bank Tujuan',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Bank dropdown
        GestureDetector(
          onTap: _showBankPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE3ED), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedBank,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF0070C0),
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Nomor Rekening/Alias label
        const Text(
          'Nomor Rekening/Alias',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Account number input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDE3ED), width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.credit_card_outlined,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _accountCtrl,
                  keyboardType: TextInputType.text,
                  cursorColor: const Color(0xFF0070C0),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nomor rekening atau alias',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),

        const SizedBox(height: 6),
        const Text(
          'Masukkan alias diawali dengan "@"',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
        ),

        const SizedBox(height: 14),

        // Info box
        _infoBox(
          'Nama alias digunakan untuk pengganti nomor rekening transfer ke BRI',
        ),
      ],
    );
  }

  // ── Tab 1: Kontak BI-FAST ─────────────────────────────────────────────────
  Widget _buildKontakBiFastTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Nomor Telp/Email',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Phone/Email input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDE3ED), width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: const Color(0xFF0070C0),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan Nomor Telp/Email',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              // Phone book icon on right
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih dari kontak HP.')),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.contact_phone_outlined,
                    color: Color(0xFF0070C0),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Info box
        _infoBox(
          'Kini transfer lewat BI-FAST lebih cepat, cuma perlu nomor handphone atau email. Yuk, coba sekarang!',
          title: 'Informasi',
        ),
      ],
    );
  }

  // ── Info box widget ───────────────────────────────────────────────────────
  Widget _infoBox(String message, {String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBED8F8), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF0070C0),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.info_outline, color: Colors.white, size: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Bank Picker Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════
class _BankPickerSheet extends StatelessWidget {
  final List<String> banks;
  final String selected;
  final void Function(String) onSelected;

  const _BankPickerSheet({
    required this.banks,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
            'Pilih Bank Tujuan',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFEEF2F7)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: banks.length,
              separatorBuilder: (context3, index3) =>
                  const Divider(height: 0, color: Color(0xFFEEF2F7)),
              itemBuilder: (_, i) {
                final bank = banks[i];
                final isSelected = bank == selected;
                return InkWell(
                  onTap: () => onSelected(bank),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: isSelected
                              ? const Color(0xFF0070C0)
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            bank,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0070C0)
                                  : const Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0070C0),
                            size: 20,
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
    );
  }
}
