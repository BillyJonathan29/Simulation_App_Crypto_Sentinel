import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class QuickMenu extends StatelessWidget {
  final void Function(int) onTabChange;
  final VoidCallback onQrisTap;

  const QuickMenu({
    super.key,
    required this.onTabChange,
    required this.onQrisTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search and Customize bar (Cari Fitur | Atur Fitur)
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Cari fitur',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Atur fitur favorit di dashboard Anda.')),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF), // Soft blue capsule
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Atur Fitur',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2 Service Grid (Transfer and BRIVA)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGridItem(
                context: context,
                label: 'Transfer',
                bgColor: const Color(0xFFE8F1FF),
                iconWidget: const Icon(Icons.compare_arrows_rounded, color: AppColors.primary, size: 24),
                onTap: () => onTabChange(1), // Transfer Tab
              ),
              _buildGridItem(
                context: context,
                label: 'BRIVA',
                bgColor: const Color(0xFFE6F7ED),
                iconWidget: const Center(
                  child: Text(
                    'BRIVA',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('BRIVA Sentinel Pembayaran aman terintegrasi.')),
                  );
                },
              ),
              _buildGridItem(
                context: context,
                label: 'E-Wallet',
                bgColor: const Color(0xFFFFF3E0),
                iconWidget: const Icon(Icons.account_balance_wallet_rounded, color: Colors.orange, size: 24),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Top Up E-Wallet')),
                  );
                },
              ),
              _buildGridItem(
                context: context,
                label: 'Pulsa',
                bgColor: const Color(0xFFF3E5F5),
                iconWidget: const Icon(Icons.phone_android_rounded, color: Colors.purple, size: 24),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beli Pulsa/Data')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required BuildContext context,
    required String label,
    required Color bgColor,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 78,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
