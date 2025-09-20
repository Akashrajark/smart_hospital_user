// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../util/value_validators.dart';

// class CustomDatePicker extends StatefulWidget {
//   final String label;
//   final bool filled, isRequired;
//   final Function(DateTime?) onPick;
//   final DateTime? selectedDate, firstDate, lastDate, initialDate;

//   const CustomDatePicker({
//     super.key,
//     this.label = 'Select Date',
//     this.filled = false,
//     this.isRequired = false,
//     required this.onPick,
//     this.selectedDate,
//     this.firstDate,
//     this.lastDate,
//     this.initialDate,
//   });

//   @override
//   State<CustomDatePicker> createState() => _CustomDatePickerState();
// }

// class _CustomDatePickerState extends State<CustomDatePicker> {
//   DateTime? _selectedDate;
//   final TextEditingController _dobController = TextEditingController();

//   @override
//   void initState() {
//     _selectedDate = widget.selectedDate;
//     if (_selectedDate != null) {
//       _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: _dobController,
//       showCursor: false,
//       readOnly: true,
//       validator: widget.isRequired ? dateValidator : null,
//       onTap: () async {
//         DateTime? tempDate = await showDatePicker(
//           context: context,
//           initialDate: widget.initialDate ?? DateTime.now(),
//           firstDate: widget.firstDate ?? DateTime(2020),
//           lastDate: widget.lastDate ?? DateTime.now(),
//         );

//         if (tempDate != null) {
//           _selectedDate = tempDate;
//           _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
//           widget.onPick(_selectedDate);
//           setState(() {});
//         }
//       },
//       decoration: InputDecoration(
//         labelText: widget.label,
//         filled: widget.filled,
//         suffixIcon: _selectedDate != null
//             ? IconButton(
//                 onPressed: () {
//                   _selectedDate = null;
//                   widget.onPick(null);
//                   _dobController.clear();
//                   setState(() {});
//                 },
//                 icon: const Icon(
//                   Icons.clear,
//                 ),
//               )
//             : const Icon(
//                 Icons.date_range_outlined,
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util/value_validators.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final bool filled, isRequired, isDateTime;
  final Function(DateTime?) onPick;
  final DateTime? selectedDate, firstDate, lastDate, initialDate;

  const CustomDatePicker({
    super.key,
    this.label = 'Select Date',
    this.filled = true,
    this.isRequired = false,
    this.isDateTime = false, // Default to date-only picker
    required this.onPick,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    if (_selectedDate != null) {
      _dateController.text = widget.isDateTime
          ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!)
          : DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      showCursor: false,
      readOnly: true,
      validator: widget.isRequired ? dateValidator : null,
      onTap: () async {
        if (widget.isDateTime) {
          // Date-Time Picker
          await _showDateTimePicker(context);
        } else {
          // Date-Only Picker
          await _showDatePicker(context);
        }
      },
      decoration: InputDecoration(
        hintText: widget.label,
        filled: widget.filled,
        suffixIcon: _selectedDate != null
            ? IconButton(
                onPressed: () {
                  _selectedDate = null;
                  widget.onPick(null);
                  _dateController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              )
            : const Icon(Icons.date_range_outlined),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime? tempDate = await showDatePicker(
      context: context,
      calendarDelegate: CustomCalendarDelegate(),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      // initialDate: widget.initialDate ?? DateTime.now(),
      // firstDate: widget.firstDate ?? DateTime(1900),
      // lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (tempDate != null) {
      _selectedDate = tempDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      widget.onPick(_selectedDate);
      setState(() {});
    }
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    DateTime now = widget.initialDate ?? DateTime.now();
    DateTime? tempDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (tempDate != null) {
      TimeOfDay? tempTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (tempTime != null) {
        _selectedDate = DateTime(
          tempDate.year,
          tempDate.month,
          tempDate.day,
          tempTime.hour,
          tempTime.minute,
        );
        _dateController.text = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(_selectedDate!);
        widget.onPick(_selectedDate);
        setState(() {});
      }
    }
  }
}

class CustomCalendarDelegate extends CalendarDelegate<DateTime> {
  const CustomCalendarDelegate();

  // Formats the date as 'dd MM yyyy'
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) =>
      DateTime(monthDate.year, monthDate.month + monthsToAdd);

  @override
  String dateHelpText(MaterialLocalizations localizations) =>
      'Enter date in dd/MM/yyyy format';

  @override
  DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    final weekdayFromMonday = DateTime(year, month, 1).weekday;
    return (weekdayFromMonday - localizations.firstDayOfWeekIndex) % 7;
  }

  @override
  String formatCompactDate(
    DateTime date,
    MaterialLocalizations localizations,
  ) => _formatDate(date);

  @override
  String formatFullDate(DateTime date, MaterialLocalizations localizations) =>
      _formatDate(date);

  @override
  String formatMediumDate(DateTime date, MaterialLocalizations localizations) =>
      _formatDate(date);

  @override
  String formatMonthYear(DateTime date, MaterialLocalizations localizations) =>
      '${date.month.toString().padLeft(2, '0')} ${date.year}';

  @override
  String formatShortDate(DateTime date, MaterialLocalizations localizations) =>
      _formatDate(date);

  @override
  String formatShortMonthDay(
    DateTime date,
    MaterialLocalizations localizations,
  ) =>
      '${date.day.toString().padLeft(2, '0')} ${date.month.toString().padLeft(2, '0')}';

  @override
  DateTime getDay(int year, int month, int day) => DateTime(year, month, day);

  @override
  int monthDelta(DateTime startDate, DateTime endDate) =>
      (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime? parseCompactDate(
    String? inputString,
    MaterialLocalizations localizations,
  ) {
    if (inputString == null || inputString.trim().isEmpty) return null;
    try {
      final parts = inputString.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  @override
  int getDaysInMonth(int year, int month) {
    final nextMonth = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  DateTime getMonth(int year, int month) => DateTime(year, month, 1);
}
