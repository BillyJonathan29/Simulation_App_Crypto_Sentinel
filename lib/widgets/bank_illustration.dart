import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BankIllustration extends StatelessWidget {
  const BankIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial Glow
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.lightBlueBackground.withOpacity(0.5),
                  AppColors.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Glass Sphere outline
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),

          // City skyline buildings
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

          // Floating Wallet
          Positioned(
            left: screenSize.width * 0.15,
            top: 80,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 55,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -4,
                      left: 12,
                      child: Container(
                        width: 14,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 6,
                      bottom: 6,
                      width: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.premiumGold,
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

          // Organic leaf graphics
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

          // Central Premium Phone Mockup
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
                      color: AppColors.secondary.withOpacity(0.2),
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
                    gradient: const LinearGradient(
                      colors: AppColors.navyGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BRI',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'mo',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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

          // Floating Coins
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
    );
  }

  Widget _buildSkylineBuilding(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
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
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildVectorLeaf(double width, double height, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width),
            bottomRight: Radius.circular(width),
          ),
        ),
      ),
    );
  }

  Widget _buildVectorCoin(double size, double scale) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F1FF),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.star, color: AppColors.premiumGold, size: size * 0.5),
      ),
    );
  }
}
