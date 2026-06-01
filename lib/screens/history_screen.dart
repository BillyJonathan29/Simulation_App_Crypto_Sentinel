import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _activeSubTab = 0; // 0 for Mutasi Transaksi, 1 for e-Statement

  String _formatCurrency(double val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2, // Matches "- Rp2.500,00" from screenshot
    ).format(val);
  }

  String _formatDateHeader(DateTime date) {
    // Format to match "1 Jun 2026", "29 Mei 2026"
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final transactions = state.transactions;
    final user = state.currentUser;

    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var tx in transactions) {
      final dateKey = _formatDateHeader(tx.timestamp);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Blue solid header with integrated sub-tab navigation pill (Matches Image 2)
          Container(
            padding: const EdgeInsets.only(bottom: 14),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Mutasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Pill Tab bar container (Matches Image 2)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeSubTab = 0),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeSubTab == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Mutasi Transaksi',
                                style: TextStyle(
                                  color: _activeSubTab == 0 ? AppColors.primary : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeSubTab = 1),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeSubTab == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'e-Statement',
                                style: TextStyle(
                                  color: _activeSubTab == 1 ? AppColors.primary : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Dropdowns Row below header (Matches Image 2)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Sumber Rekening Dropdown Card
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sumber Rekening',
                              style: TextStyle(color: Colors.grey, fontSize: 10.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.accountNumber,
                              style: const TextStyle(
                                color: Color(0xFF0F75BD),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Rentang Waktu filter Card
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_alt_rounded, color: Color(0xFF0F75BD), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Rentang Waktu',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Transactions Grouped List (Matches Image 2)
          Expanded(
            child: _activeSubTab == 1
                ? const Center(
                    child: Text(
                      'Layanan e-Statement belum diaktifkan.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  )
                : groupedTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada transaksi ditemukan.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: groupedTransactions.keys.length,
                        itemBuilder: (context, index) {
                          final dateHeader = groupedTransactions.keys.elementAt(index);
                          final dateTxs = groupedTransactions[dateHeader]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Date Header Strip (Matches Image 2 exactly)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: const Color(0xFFF2F4F7), // Soft grey background strip
                                child: Text(
                                  dateHeader,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Date Transaction Items
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: dateTxs.length,
                                separatorBuilder: (context, i) => const Divider(
                                  color: AppColors.border,
                                  height: 0.5,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, i) {
                                  final tx = dateTxs[i];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Left Side details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.title,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                tx.description, // Time stamp (e.g. 14:09:02 WIB)
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Right Side Amount (Indonesian format "- Rp2.500,00" in bold black)
                                        Text(
                                          '- ${_formatCurrency(tx.amount)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
