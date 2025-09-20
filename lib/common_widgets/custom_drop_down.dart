import 'package:flutter/material.dart';

class CustomDropDownMenu extends StatelessWidget {
  final String hintText, title;
  final bool isRequired, isExpanded, isDense;
  final dynamic selectedValue;
  final IconData iconData;
  final List<DropdownMenuItem<dynamic>> dropdownMenuItems;
  final Function(dynamic) onSelected;
  const CustomDropDownMenu({
    super.key,
    this.isDense = true,
    this.isExpanded = false,
    required this.hintText,
    required this.title,
    required this.dropdownMenuItems,
    required this.onSelected,
    this.isRequired = false,
    this.selectedValue,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          DropdownButtonFormField(
            isExpanded: isExpanded,
            isDense: isDense,
            value: selectedValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (isRequired && value == null) {
                return 'This field is required';
              } else {
                return null;
              }
            },
            hint: Text(hintText),
            items: dropdownMenuItems,
            onChanged: onSelected,
            decoration: InputDecoration(
              prefixIcon: Icon(iconData),
              // contentPadding: const EdgeInsets.symmetric(
              //   vertical: 15,
              //   horizontal: 20,
              // ),
            ),
          ),
          // DropdownMenu(
          //   onSelected: onSelected,
          //   hintText: hintText,
          //   menuStyle: const MenuStyle(
          //     padding: MaterialStatePropertyAll(
          //         EdgeInsets.symmetric(horizontal: 10, vertical: 15)),
          //     backgroundColor: MaterialStatePropertyAll(
          //       backgroundColorLight,
          //     ),
          //   ),
          //   width: 400,
          //   dropdownMenuEntries: dropdownMenuEntries,
          // ),
        ],
      ),
    );
  }
}
