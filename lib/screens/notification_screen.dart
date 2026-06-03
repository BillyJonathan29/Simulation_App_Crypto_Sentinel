import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final notifs = state.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false, // Nested tab navigation
        centerTitle: true,
        title: const Text(
          'Aktivitas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter Aktivitas terbuka.')),
              );
            },
            icon: const Icon(
              Icons.tune_rounded, // Filter adjustment icon (Matches Image 3)
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppColors.textMuted.withOpacity(0.3),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada aktivitas transaksi.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                final isTransfer = notif['title']?.toString().contains('Transfer') ?? true;
                final status = notif['status']?.toString();

                Color iconBgColor = const Color(0xFFE8F1FF); // default soft blue
                Color iconColor = AppColors.primary; // default primary
                IconData iconData = isTransfer ? Icons.compare_arrows_rounded : Icons.qr_code_scanner_rounded;

                if (status == 'failed') {
                  iconBgColor = const Color(0xFFFEE2E2); // soft red
                  iconColor = const Color(0xFFEF4444); // vivid red
                  iconData = Icons.gpp_bad_rounded;
                } else if (status == 'pending') {
                  iconBgColor = const Color(0xFFFEF3C7); // soft orange
                  iconColor = const Color(0xFFF59E0B); // vivid orange
                  iconData = Icons.hourglass_empty_rounded;
                } else if (status == 'success') {
                  iconBgColor = const Color(0xFFDCFCE7); // soft green
                  iconColor = const Color(0xFF22C55E); // vivid green
                  iconData = isTransfer ? Icons.compare_arrows_rounded : Icons.qr_code_scanner_rounded;
                } else if (status == 'info') {
                  iconBgColor = const Color(0xFFE0F2FE); // soft blue-sky
                  iconColor = const Color(0xFF0284C7); // sky blue
                  iconData = Icons.shield_rounded;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 1. Transaction Icon Container (Dynamic status-based styling)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 2. Transaction Text Details (Matches Image 3)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title'] ?? 'Transaksi',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              notif['desc'] ?? '',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['time'] ?? '',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Dynamic Badge Pill (Matches Image 3 exactly but with status-based colors)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'failed'
                              ? const Color(0xFFEF4444)
                              : status == 'pending'
                                  ? const Color(0xFFF59E0B)
                                  : status == 'info'
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status == 'failed'
                              ? 'Gagal'
                              : status == 'pending'
                                  ? 'Pending'
                                  : status == 'info'
                                      ? 'Info'
                                      : 'Sukses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
