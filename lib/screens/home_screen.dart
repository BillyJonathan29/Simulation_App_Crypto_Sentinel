import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/qris_scanner_overlay.dart';
import '../providers/app_state_provider.dart';
import '../widgets/transaction_card.dart';

// Sub Tab Screens
import 'history_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showQrisScanner = false;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      _showQrisScanner = false;
    });
  }

  void _triggerQris() {
    setState(() {
      _showQrisScanner = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeTabBody;
    switch (_currentIndex) {
      case 0:
        activeTabBody = _HomeTab(
          onTabChange: _onTabChange,
          onQrisTap: _triggerQris,
        );
        break;
      case 1:
        activeTabBody = TransferScreen(
          onBackToHome: () => _onTabChange(0),
        );
        break;
      case 2:
        activeTabBody = const HistoryScreen();
        break;
      case 3:
        activeTabBody = const NotificationScreen();
        break;
      case 4:
        activeTabBody = const ProfileScreen();
        break;
      default:
        activeTabBody = Container();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Current Active Tab
          Positioned.fill(child: activeTabBody),

          // Glowing QRIS Camera overlay covers the whole screen when active
          if (_showQrisScanner)
            Positioned.fill(
              child: QrisScannerOverlay(
                onClose: () {
                  setState(() {
                    _showQrisScanner = false;
                  });
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildCustomPremiumNavBar(),
    );
  }

  Widget _buildCustomPremiumNavBar() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.home_rounded, 'Home'),
            _buildNavBarItem(2, Icons.receipt_long_rounded, 'Mutasi'),

            // Center Floating QRIS Scanner button (Matches Image 3)
            Expanded(
              child: InkWell(
                onTap: _triggerQris,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'QRIS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildNavBarItem(
              3,
              Icons.notifications_none_rounded,
              'Aktivitas',
              badgeKey: true,
            ),
            _buildNavBarItem(4, Icons.person_outline_rounded, 'Akun'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
    int index,
    IconData icon,
    String label, {
    bool badgeKey = false,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textMuted;

    // Check state for unread notifications
    final unreadNotifs = context.select<AppStateProvider, bool>(
      (state) => state.notifications.any((n) => n['isUnread'] == true),
    );

    return Expanded(
      child: InkWell(
        onTap: () => _onTabChange(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
                if (badgeKey && unreadNotifs)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inner Widget for Dashboard Tab (HomeTab)
class _HomeTab extends StatefulWidget {
  final void Function(int) onTabChange;
  final VoidCallback onQrisTap;

  const _HomeTab({required this.onTabChange, required this.onQrisTap});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _showBalance = true;
  final PageController _promoController = PageController();
  int _activePromoPage = 0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;
    final transactions = state.transactions;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(width: double.infinity, height: 380),
              // Deep Royal Blue Gradient Background (matches official BRImo look)
              Container(
                width: double.infinity,
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0073E6), // Bright vibrant royal blue
                      Color(0xFF004B87), // Deep cobalt blue
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(500, 40),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Header Row: Logo, Greeting, Notification, Pusat Bantuan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: BRImo logo & greeting text
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // BRImo White Text Logo
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: const [
                                      Text(
                                        'BRI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        'mo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Separator Line
                              Container(
                                width: 1,
                                height: 26,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(width: 14),

                              // Greeting "Selamat Sore, Billy Jonathan"
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Selamat Sore,',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Billy Jonathan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Right side: Bell icon with '9+' Badge & Pusat Bantuan pill
                          Row(
                            children: [
                              // Notification Bell Icon with Red Circle Badge (Matches Image exactly)
                              GestureDetector(
                                onTap: () => widget.onTabChange(3),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    Positioned(
                                      top: -3,
                                      right: -3,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF4500), // Bright Orange-Red Badge
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '9+',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Pusat Bantuan Capsule Button (Headset logo)
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Menghubungkan ke Pusat Bantuan BRImo...')),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.headset_mic_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pusat',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w600,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            'Bantuan',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w800,
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Overlapping White Card (Housing Saldo Rekening Utama and main 3 menus)
              Positioned(
                top: 135,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dark Blue Saldo Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00529C), // Rich Deep Blue
                              Color(0xFF003F78), // Deep Navy
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo Rekening Utama',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _showBalance ? 'Rp15.800,00' : 'Rp ••••••••',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showBalance = !_showBalance;
                                    });
                                  },
                                  child: Icon(
                                    _showBalance
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 0.5,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Semua Rekeningmu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Feature Row (Transfer, BRIVA, Setor only!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(
                            label: 'Transfer',
                            iconWidget: const Icon(
                              Icons.compare_arrows_rounded,
                              color: Color(0xFF0070C0),
                              size: 22,
                            ),
                            bgColor: const Color(0xFFE8F1FF), // Soft Blue
                            onTap: () => widget.onTabChange(1),
                          ),
                          _buildFeatureItem(
                            label: 'BRIVA',
                            iconWidget: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'BRIVA',
                                style: TextStyle(
                                  color: Color(0xFF00A86B), // Vivid Green
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            bgColor: const Color(0xFFE6F7ED), // Soft Green
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur BRIVA sedang bersiap...')),
                              );
                            },
                          ),
                          _buildFeatureItem(
                            label: 'Setor',
                            iconWidget: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFFFF9900), // Golden Amber
                              size: 22,
                            ),
                            bgColor: const Color(0xFFFFF3E0), // Soft Amber
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur Setor Tunai sedang bersiap...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Spacing to account for the overlapping card container
          const SizedBox(height: 15),

          // 2. Promo & Info Carousel Banners (Scrollable PageView matching Mockup)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                child: PageView(
                  controller: _promoController,
                  onPageChanged: (index) {
                    setState(() {
                      _activePromoPage = index;
                    });
                  },
                  children: [
                    // Banner 1: Qita Hadir Lebih Cepat Buatmu!
                    _buildPromoBanner(
                      gradientColors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
                      title: 'Qita Hadir Lebih Cepat Buatmu!',
                      subtitle: 'Klik disini untuk mengakses Qita.',
                      logoText: 'Qita',
                      subLogoText: 'by BRI',
                    ),
                    // Banner 2: Cicil Emas Masa Depan
                    _buildPromoBanner(
                      gradientColors: [const Color(0xFF0052CC), const Color(0xFF1E70EB)],
                      title: 'Cicil Emas Masa Depan Cemerlang',
                      subtitle: 'Dapatkan Cashback Rp 200 ribu sekarang.',
                      logoText: 'Emas',
                      subLogoText: 'BRImo',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _activePromoPage == index ? 14 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _activePromoPage == index ? const Color(0xFF0070C0) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Search Bar and Customize Bar (Cari Fitur | Atur Fitur)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Light Grey
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Cari fitur',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Atur fitur favorit di dashboard Anda.')),
                    );
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF), // Soft Blue capsule
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.edit_note_rounded, color: Color(0xFF0070C0), size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Atur Fitur',
                          style: TextStyle(
                            color: Color(0xFF0070C0),
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
          ),

          const SizedBox(height: 24),

          // 4. Recent Transactions List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onTabChange(2), // Mutasi tab
                      child: const Text(
                        'Lihat Mutasi',
                        style: TextStyle(
                          color: Color(0xFF0070C0),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                transactions.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: const Text(
                          'Belum ada transaksi terbaru.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: transactions.take(3).length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return TransactionCard(transaction: tx);
                        },
                      ),
              ],
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // Feature icon button builder
  Widget _buildFeatureItem({
    required String label,
    required Widget iconWidget,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: iconWidget),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Promo card banner builder
  Widget _buildPromoBanner({
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required String logoText,
    required String subLogoText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                logoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -1,
                ),
              ),
              Text(
                subLogoText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

