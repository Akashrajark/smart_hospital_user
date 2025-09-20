import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final String? title;
  final double width;
  final int? maxLines, minLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? prefixIconData;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final TextInputAction textInputAction;
  final bool isObscure;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.width = 400,
    this.title,
    required this.controller,
    required this.validator,
    this.prefixIconData,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.contentPadding,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title!, style: Theme.of(context).textTheme.bodyMedium),
          if (title != null) const SizedBox(height: 5),
          TextFormField(
            obscureText: isObscure,
            controller: controller,
            validator: validator,
            minLines: minLines ?? 1,
            maxLines: maxLines ?? 1,
            textInputAction: textInputAction,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: contentPadding,
              labelText: labelText,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIconData != null
                  ? Padding(
                      padding: EdgeInsets.only(bottom: minLines != null ? 45 : 0),
                      child: Icon(prefixIconData),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
