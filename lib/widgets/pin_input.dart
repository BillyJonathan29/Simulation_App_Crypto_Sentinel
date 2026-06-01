import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PinInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final VoidCallback? onBiometricPressed;
  final bool isLoading;

  const PinInput({
    super.key,
    required this.onCompleted,
    this.onBiometricPressed,
    this.isLoading = false,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  String _pin = '';

  void _onKeyPress(String digit) {
    if (widget.isLoading) return;
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == 6) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _onBackspace() {
    if (widget.isLoading) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void reset() {
    setState(() {
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Animated Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final isFilled = index < _pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isFilled ? AppColors.primary : Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            );
          }),
        ),

        const SizedBox(height: 52),

        // 2. Numerical Pad Grid
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPadRow(['1', '2', '3']),
              const SizedBox(height: 20),
              _buildPadRow(['4', '5', '6']),
              const SizedBox(height: 20),
              _buildPadRow(['7', '8', '9']),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Biometric Trigger
                  widget.onBiometricPressed != null
                      ? _buildBiometricKey()
                      : const SizedBox(width: 72, height: 72),
                  
                  // '0' Key
                  _buildPadKey('0'),
                  
                  // Backspace Key
                  _buildBackspaceKey(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _buildPadKey(d)).toList(),
    );
  }

  Widget _buildPadKey(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricKey() {
    return InkWell(
      onTap: widget.onBiometricPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.04),
        ),
        child: const Center(
          child: Icon(
            Icons.fingerprint_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.04),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
