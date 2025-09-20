import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? label;
  final IconData? iconData;
  final Color? color, backGroundColor, labelColor, outlineColor;

  final Function()? onPressed;
  final bool inverse, isLoading;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    this.label,
    this.iconData,
    this.color,
    this.inverse = false,
    this.isLoading = false,
    required this.onPressed,
    this.backGroundColor,
    this.labelColor,
    this.padding,
    this.outlineColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.backGroundColor ?? Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.backGroundColor ?? backgroundColor,
        border: widget.inverse
            ? null
            : Border.all(color: widget.outlineColor ?? Theme.of(context).colorScheme.outline, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onPressed,
        autofocus: widget.inverse,
        child: Padding(
          padding:
              widget.padding ??
              EdgeInsets.only(
                left: widget.label != null ? 15 : 10,
                right: widget.iconData != null ? 10 : 15,
                top: widget.iconData != null ? 15 : 15,
                bottom: widget.iconData != null ? 15 : 15,
              ),
          child: Row(
            mainAxisAlignment: widget.label != null && widget.iconData != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (widget.label != null && !widget.isLoading)
                Text(
                  widget.label!,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.labelColor ?? (widget.inverse ? Colors.white : widget.color),
                  ),
                ),
              SizedBox(width: widget.label != null && widget.iconData != null ? 5 : 0),
              if (widget.iconData != null && !widget.isLoading)
                Icon(widget.iconData, color: widget.inverse ? Colors.white : widget.color, size: 20),
              if (widget.isLoading) CircularProgressIndicator(color: widget.inverse ? Colors.white : widget.color),
            ],
          ),
        ),
      ),
    );
  }
}
