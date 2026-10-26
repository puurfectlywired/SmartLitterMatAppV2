
import 'package:flutter/material.dart';

//////////////////////////////////////////SELECTION BUTTON//////////////////////////////////////////
class SelectionButton extends StatelessWidget {

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final double height;

  const SelectionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final buttonStyle = ElevatedButtonTheme.of(context).style;

    // SELECTED BUTTON COLOURS
    final selectedColor = buttonStyle?.backgroundColor
        ?.resolve(<WidgetState>{}) ??
        colorScheme.primary;

    final selectedTextColor = buttonStyle?.foregroundColor
        ?.resolve(<WidgetState>{}) ??
        colorScheme.onPrimary;

    return SizedBox(
      height: height,

      child: OutlinedButton(
        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),

          // BACKGROUND COLOUR
          backgroundColor: selected
              ? selectedColor
              : colorScheme.surfaceContainer,

          // TEXT COLOUR
          foregroundColor: selected
              ? selectedTextColor
              : colorScheme.onSurface,

          // BORDER COLOUR
          side: BorderSide(
            color: selected
                ? selectedColor
                : colorScheme.outline,
          ),

          // ROUNDED CORNERS
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        child: FittedBox(
          fit: BoxFit.scaleDown,

          child: Text(
            label,
            maxLines: 1,

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
