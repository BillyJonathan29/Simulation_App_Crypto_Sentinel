import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QrisScannerOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const QrisScannerOverlay({super.key, required this.onClose});

  @override
  State<QrisScannerOverlay> createState() => _QrisScannerOverlayState();
}

class _QrisScannerOverlayState extends State<QrisScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(_laserController);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          // Simulated Camera Target Viewport
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                
                // Camera Target Frame
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Animated green laser scanner line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 250 * _laserAnimation.value,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Faded Watermark QR Symbol inside
                        const Center(
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              color: Colors.white,
                              size: 140,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Arahkan kamera ke barcode QRIS untuk memindai',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const Spacer(flex: 2),

                // Flash and Gallery buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOverlayOption(Icons.flash_off_rounded, 'Senter'),
                    const SizedBox(width: 48),
                    _buildOverlayOption(Icons.image_search_rounded, 'Galeri'),
                  ],
                ),
                
                const Spacer(flex: 2),
              ],
            ),
          ),

          // Header with close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pindai QRIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayOption(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
