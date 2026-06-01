import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../core/theme/app_colors.dart';

class BankSelector extends StatefulWidget {
  final BankModel? selectedBank;
  final ValueChanged<BankModel> onBankSelected;

  const BankSelector({
    super.key,
    this.selectedBank,
    required this.onBankSelected,
  });

  static void show(BuildContext context, {
    BankModel? selectedBank,
    required ValueChanged<BankModel> onBankSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BankSelector(
          selectedBank: selectedBank,
          onBankSelected: onBankSelected,
        );
      },
    );
  }

  @override
  State<BankSelector> createState() => _BankSelectorState();
}

class _BankSelectorState extends State<BankSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<BankModel> _filteredBanks = BankModel.availableBanks;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBanks);
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = BankModel.availableBanks;
      } else {
        _filteredBanks = BankModel.availableBanks.where((b) {
          return b.name.toLowerCase().contains(query) ||
                 b.shortName.toLowerCase().contains(query) ||
                 b.code.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          const Text(
            'Pilih Bank Tujuan',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari bank (e.g. BCA, Mandiri)...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              fillColor: AppColors.background,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bank List
          Expanded(
            child: _filteredBanks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_rounded, color: AppColors.textMuted.withOpacity(0.3), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Bank tidak ditemukan.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBanks.length,
                    itemBuilder: (context, index) {
                      final bank = _filteredBanks[index];
                      final isSelected = widget.selectedBank?.code == bank.code;

                      // Make a beautiful rounded colored avatar circle based on shortName
                      Color avatarBgColor = AppColors.lightBlueBackground;
                      Color avatarTextColor = AppColors.primary;
                      if (bank.shortName == 'BCA') {
                        avatarBgColor = const Color(0xFFE8F1FF);
                        avatarTextColor = const Color(0xFF00388F);
                      } else if (bank.shortName == 'BRI') {
                        avatarBgColor = const Color(0xFFE6F0FA);
                        avatarTextColor = const Color(0xFF0F52BA);
                      } else if (bank.shortName == 'Mandiri') {
                        avatarBgColor = const Color(0xFFFFF7E6);
                        avatarTextColor = const Color(0xFFE5A93B);
                      } else if (bank.shortName == 'BNI') {
                        avatarBgColor = const Color(0xFFE6F5F5);
                        avatarTextColor = const Color(0xFF008080);
                      } else if (bank.shortName == 'CIMB') {
                        avatarBgColor = const Color(0xFFFFF2F2);
                        avatarTextColor = const Color(0xFFD32F2F);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightBlueBackground : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
                        ),
                        child: ListTile(
                          onTap: () {
                            widget.onBankSelected(bank);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: avatarBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                bank.shortName,
                                style: TextStyle(
                                  color: avatarTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            bank.name,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Kode Bank: ${bank.code}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              : const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.border, size: 14),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
