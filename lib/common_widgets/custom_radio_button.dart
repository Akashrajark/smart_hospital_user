import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String label;
  final bool isChecked;
  final Function() onPressed;
  const CustomRadioButton({super.key, required this.label, this.isChecked = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
              //  color: isChecked ? iconColor : Colors.grey,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  // color: isChecked ? iconColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
