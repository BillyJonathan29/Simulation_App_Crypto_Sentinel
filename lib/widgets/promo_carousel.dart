import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController();
  int _activePage = 0;

  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'Cicil Emas Masa Depan Cemerlang',
      'desc': 'Dapatkan Cashback Rp 200 ribu untuk pembukaan cicilan emas baru.',
      'gradient': [Color(0xFF0052CC), Color(0xFF1E70EB)],
      'badge': 'EMAS',
    },
    {
      'title': 'Investasi Reksa Dana Mulai Rp10 Ribu',
      'desc': 'Rencanakan impian jangka panjangmu langsung dari Sentinel Mobile.',
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'badge': 'REKSA',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Promo & Info Menarik',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary.withOpacity(0.9),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Page Slider
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _promos.length,
            onPageChanged: (index) {
              setState(() {
                _activePage = index;
              });
            },
            itemBuilder: (context, index) {
              final p = _promos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: p['gradient'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20), // Standard 20px card radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                            p['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['desc'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          p['badge'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _activePage == index ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _activePage == index ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
