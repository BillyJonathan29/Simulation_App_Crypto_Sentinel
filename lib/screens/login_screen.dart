import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Set the status bar color and icon brightness to fit the blue theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const LoginBottomSheetMockup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Blue Curved Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenSize.height * 0.52,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F75BD), // Solid bright blue
                    Color(0xFF0B5C96), // Deeper royal blue
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 90),
                ),
              ),
            ),
          ),
          // 2. Main Content Scrollable View
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Header Row: Language selector, Logo, and Help center
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Language selector pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Indonesian Flag
                              Container(
                                width: 22,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: const Color(0xFFFF0000),
                                      ), // Red
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                      ), // White
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'ID',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Center Logo
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'BRI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 0.9,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'mo',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),
                        // Contact center pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.headset_mic_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Kontak\nKami',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Greeting Banner
                    const Text(
                      'Yuk! mulai transaksimu\nbersama BRImo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Central Premium Vector Illustration Stack
                    SizedBox(
                      height: 290,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // A: Glowing Light Blue Radial Dome Background
                          Container(
                            width: 270,
                            height: 270,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFD4ECFF).withOpacity(0.7),
                                  const Color(0xFF8CCDFD).withOpacity(0.3),
                                  const Color(0xFF0F75BD).withOpacity(0.0),
                                ],
                                stops: const [0.3, 0.7, 1.0],
                              ),
                            ),
                          ),
                          // B: Fine Glowing Glass Sphere Outline
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // C: Vector Skyline Buildings (Bottom Right)
                          Positioned(
                            right: screenSize.width * 0.16,
                            bottom: 30,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildSkylineBuilding(16, 65),
                                const SizedBox(width: 4),
                                _buildSkylineBuilding(16, 95),
                                const SizedBox(width: 4),
                                _buildSkylineBuilding(16, 50),
                              ],
                            ),
                          ),
                          // D: Vector Floating Wallet (Left Side)
                          Positioned(
                            left: screenSize.width * 0.15,
                            top: 80,
                            child: Transform.rotate(
                              angle: -0.22,
                              child: Container(
                                width: 55,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C5389),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Card peaking out
                                    Positioned(
                                      top: -4,
                                      left: 12,
                                      child: Container(
                                        width: 14,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4FC3F7),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Wallet band
                                    Positioned(
                                      right: 8,
                                      top: 6,
                                      bottom: 6,
                                      width: 14,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E88E5),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              color: Colors.yellow,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // E: Floating Vector Leaves (Foliage)
                          Positioned(
                            left: screenSize.width * 0.18,
                            bottom: 25,
                            child: _buildVectorLeaf(32, 60, -0.15),
                          ),
                          Positioned(
                            right: screenSize.width * 0.22,
                            bottom: 20,
                            child: _buildVectorLeaf(28, 50, 0.2),
                          ),
                          // F: Centered Premium Smartphone Mockup
                          Positioned(
                            bottom: 12,
                            child: Transform.rotate(
                              angle: -0.06,
                              child: Container(
                                width: 135,
                                height: 245,
                                padding: const EdgeInsets.all(4.5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF074878,
                                      ).withOpacity(0.25),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.9),
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0F75BD,
                                    ), // Match the screen blue
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0B558B,
                                        ), // Inner logo square
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.12,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'BRI',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              height: 0.9,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            'mo',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.95,
                                              ),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              height: 0.9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // G: Floating Coins (Sparkling accents)
                          Positioned(
                            left: screenSize.width * 0.20,
                            top: 140,
                            child: _buildVectorCoin(22, 1.2),
                          ),
                          Positioned(
                            right: screenSize.width * 0.16,
                            top: 120,
                            child: _buildVectorCoin(18, 0.8),
                          ),
                          Positioned(
                            right: screenSize.width * 0.28,
                            top: 70,
                            child: _buildVectorCoin(14, 0.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // 3. Fast Menu Title Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Fast Menu',
                          style: TextStyle(
                            color: Color(0xFF0F75BD),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fast Menu allows quick access to essential features.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.info,
                            color: Color(0xFF0F75BD),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _showLoginBottomSheet,
                          child: _buildFastMenuItem(
                            icon: Icons.compare_arrows_rounded,
                            label: 'Transfer',
                            bgColor: const Color(0xFFE8F8F5),
                            iconColor: const Color(0xFF1ABC9C),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showLoginBottomSheet,
                          child: _buildFastMenuItem(
                            icon: Icons.payments_rounded,
                            label: 'Setor BRIVA',
                            bgColor: const Color(0xFFE8F3FD),
                            iconColor: const Color(0xFF0F75BD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 5. Custom Page Indicator Decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F75BD),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 32,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // 6. Action Button Bar (At the bottom of standard content scroll)
                    Row(
                      children: [
                        // Main Login Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showLoginBottomSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F75BD),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Biometric/Face Unlock Button
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mengaktifkan Face ID / Sidik Jari untuk Login...',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F75BD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.face_unlock_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper builder for city skyline rectangles
  Widget _buildSkylineBuilding(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF8DC6F4).withOpacity(0.35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          (height / 14).floor(),
          (index) => Container(
            width: width - 6,
            height: 3,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // Helper builder for organic vector leaf structures
  Widget _buildVectorLeaf(double width, double height, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width),
            bottomRight: Radius.circular(width),
          ),
        ),
      ),
    );
  }

  // Helper builder for floating 3D looking vector coins
  Widget _buildVectorCoin(double size, double scale) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8CD7FF), Color(0xFF0F75BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  // Helper builder for Fast Menu grid items
  Widget _buildFastMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Bottom Sheet Login Mockup Stateful Widget
// -----------------------------------------------------------------------------
class LoginBottomSheetMockup extends StatefulWidget {
  const LoginBottomSheetMockup({super.key});
  @override
  State<LoginBottomSheetMockup> createState() => _LoginBottomSheetMockupState();
}

class _LoginBottomSheetMockupState extends State<LoginBottomSheetMockup> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'billy',
  );
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isUsernameFilled = true;
  bool _isPasswordFilled = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {
        _isUsernameFilled = _usernameController.text.isNotEmpty;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _isPasswordFilled = _passwordController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleMockLogin() {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((username == 'aam' || username == 'billy') && password == '12345678') {
      FocusScope.of(context).unfocus();

      // Load real balance and transaction history from backend database
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      provider.loadUserBalance();
      provider.loadTransactions();

      // Show success dialog popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00A86B),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Login Berhasil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Selamat datang kembali di BRImo, Billy Jonathan!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF0F75BD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password salah! (Demo: aam / 12345678)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic offset when keyboard pops up
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isSubmitEnabled = _isUsernameFilled && _isPasswordFilled;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  alignment: Alignment.centerLeft,
                ),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(
                    color: Color(0xFF0F75BD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Spacer button on the right to perfectly balance the header title
              const Opacity(
                opacity: 0.0,
                child: Text(
                  'Batalkan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 1. Interactive Username input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isUsernameFilled
                    ? const Color(0xFF0F75BD)
                    : Colors.grey.shade300,
                width: _isUsernameFilled ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    cursorColor: const Color(0xFF0F75BD),
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _handleMockLogin(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 2. Interactive Password input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isPasswordFilled
                    ? const Color(0xFF0F75BD)
                    : Colors.grey.shade300,
                width: _isPasswordFilled ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    cursorColor: const Color(0xFF0F75BD),
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _handleMockLogin(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 3. Dynamic Mockup Submit Button
          ElevatedButton(
            onPressed: isSubmitEnabled ? _handleMockLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F75BD),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          // 4. Lost Username / Password link
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Membuka halaman pemulihan Username/Password...',
                  ),
                ),
              );
            },
            child: const Center(
              child: Text(
                'Lupa Username/Password?',
                style: TextStyle(
                  color: Color(0xFF0F75BD),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
