import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 44),
        title: const Text('Keluar Aplikasi'),
        content: const Text(
          'Apakah Anda yakin ingin mengakhiri sesi perbankan aman Anda saat ini?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anda telah berhasil keluar dari akun dengan aman.')),
              );
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Nested tab navigation
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile banner header card (Matches Image 4 exactly)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  // Circular initials avatar: blue circle background, AS initials (Matches Image 4)
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F1FF), // Soft grey/blue background circle
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'AS', // Initials for AAM SETIANA
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Profile details: AAM SETIANA, Points with yellow-blue badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Points badge row: Yellow-blue points logo and "5.000 Poin" (Matches Image 4)
                        Row(
                          children: [
                            // Custom BRIpoin badge looking like Image 4
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF2D4), // Soft orange/yellow tint
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.shade300, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  // Yellow/blue circle symbol representing BRIpoin
                                  Container(
                                    width: 11,
                                    height: 11,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: Colors.yellow,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '5.000 Poin',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Arrow Indicator
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),

            // 2. Settings Group: Pengaturan (Matches Image 4 exactly)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Pengaturan',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildProfileListTile(context, Icons.grid_view_rounded, 'Fast Menu'),
                  _buildDivider(),
                  _buildProfileListTile(context, Icons.account_balance_wallet_outlined, 'Update Rekening'),
                  _buildDivider(),
                  _buildProfileListTile(context, Icons.credit_card_rounded, 'Pengelolaan Kartu'),
                  _buildDivider(),
                  _buildProfileListTile(context, Icons.qr_code_2_rounded, 'Sumber Dana QRIS'),
                  _buildDivider(),
                  _buildProfileListTile(context, Icons.language_rounded, 'Bahasa'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Settings Group: Keamanan (Matches Image 4 exactly)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Keamanan',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildProfileListTile(context, Icons.dialpad_rounded, 'Ubah Pin'),
                  _buildDivider(),
                  _buildProfileListTile(context, Icons.lock_outline_rounded, 'Ubah Password'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () => _handleLogOut(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                label: const Text(
                  'Keluar Akun',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileListTile(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600, size: 20),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membuka menu $label...')),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.border,
      height: 0.5,
      indent: 16,
      endIndent: 16,
    );
  }
}
