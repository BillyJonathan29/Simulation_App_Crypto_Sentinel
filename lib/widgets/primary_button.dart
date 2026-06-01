import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum PrimaryButtonType { primary, secondary, danger }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PrimaryButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = PrimaryButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    Color buttonColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case PrimaryButtonType.primary:
        buttonColor = isDisabled ? AppColors.border : AppColors.primary;
        textColor = isDisabled ? AppColors.textMuted : Colors.white;
        break;
      case PrimaryButtonType.secondary:
        buttonColor = Colors.transparent;
        textColor = isDisabled ? AppColors.textMuted : AppColors.primary;
        borderSide = BorderSide(
          color: isDisabled ? AppColors.border : AppColors.primary,
          width: 1.5,
        );
        break;
      case PrimaryButtonType.danger:
        buttonColor = isDisabled ? AppColors.border : AppColors.danger;
        textColor = isDisabled ? AppColors.textMuted : Colors.white;
        break;
    }

    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: type == PrimaryButtonType.secondary ? AppColors.primary : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: AnimatedScale(
        scale: isDisabled ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 100),
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: buttonColor,
            side: borderSide,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded card style (16px buttons fit 20px card perfectly)
            ),
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}
