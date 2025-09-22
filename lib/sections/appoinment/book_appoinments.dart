import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:smart_hospital/common_widgets/custom_button.dart';
import 'package:smart_hospital/util/value_validators.dart';
import 'package:smart_hospital/value/color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_text_form_field.dart';
import '../../util/format_functions.dart';
import 'appointments_bloc/appointments_bloc.dart';

class BookAppoinments extends StatefulWidget {
  final Map<String, dynamic> doctorDetails;
  const BookAppoinments({super.key, required this.doctorDetails});

  @override
  State<BookAppoinments> createState() => _BookAppoinmentsState();
}

class _BookAppoinmentsState extends State<BookAppoinments> {
  final TextEditingController reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int selectedTimeIndex = -1;
  DateTime? selectedDate;
  final AppointmentsBloc _appointmentsBloc = AppointmentsBloc();
  List<DateTime> bookedDateTime = [];

  @override
  void initState() {
    getDailyAppointments();
    super.initState();
  }

  final List<String> availableTimes = [
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:30 PM",
  ];
  late final DateTime baseDate = DateTime.now();

  late final List<DateTime> availableDateTimes = [
    baseDate.copyWith(hour: 9, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 9, minute: 30, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 10, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 10, minute: 30, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 11, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 11, minute: 30, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 12, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 14, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 14, minute: 30, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 15, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 15, minute: 30, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 16, minute: 0, second: 0, millisecond: 0, microsecond: 0),
    baseDate.copyWith(hour: 16, minute: 30, second: 0, millisecond: 0, microsecond: 0),
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void getDailyAppointments() {
    _appointmentsBloc.add(GetDailyAppointmentsEvent(doctor_id: widget.doctorDetails['user_id']));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsBloc,
      child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsSuccessState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Success',
                description: 'Appointment booked successfully!',
                primaryButton: 'Ok',
                onPrimaryPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
              ),
            );
          } else if (state is AppointmentsFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Error',
                description: state.message,
                primaryButton: 'Ok',
              ),
            );
          } else if (state is GetDailyAppointmentsState) {
            bookedDateTime = state.appointments.map<DateTime>((e) => DateTime.parse(e['appointment_date'])).toList();
            setState(() {});
            Logger().i(bookedDateTime);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Book Appointments'),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  DoctorCard(doctorDetails: widget.doctorDetails),
                  SizedBox(
                    height: 10,
                  ),
                  if (state is AppointmentsLoadingState)
                    Center(child: CircularProgressIndicator())
                  else if (state is GetDailyAppointmentsState)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Appointment Time',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(availableTimes.length, (index) {
                                return CustomTimeChip(
                                  time: availableTimes[index],
                                  onTap: () {
                                    setState(() {
                                      selectedTimeIndex = index;
                                      selectedDate = availableDateTimes[index];
                                    });
                                  },
                                  isSelected: selectedTimeIndex == index,
                                  isDisabled: bookedDateTime.any((bookedDate) =>
                                      bookedDate.year == availableDateTimes[index].year &&
                                      bookedDate.month == availableDateTimes[index].month &&
                                      bookedDate.day == availableDateTimes[index].day &&
                                      bookedDate.hour == availableDateTimes[index].hour &&
                                      bookedDate.minute == availableDateTimes[index].minute),
                                );
                              }),
                            )
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Reason for Visit", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 5),
                  CustomTextFormField(
                    labelText: "Enter Reason for Visit",
                    controller: reasonController,
                    validator: notEmptyValidator,
                    minLines: 4,
                    maxLines: 4,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    inverse: true,
                    isLoading: state is AppointmentsLoadingState,
                    label: "Book Appointment",
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (selectedTimeIndex == -1) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomAlertDialog(
                              title: 'Error',
                              description: 'Please select an appointment time.',
                              primaryButton: 'Ok',
                            ),
                          );
                          return;
                        }

                        // Get current user information
                        final currentUser = Supabase.instance.client.auth.currentUser;
                        if (currentUser == null) {
                          showDialog(
                            context: context,
                            builder: (context) => CustomAlertDialog(
                              title: 'Error',
                              description: 'Please login to book an appointment.',
                              primaryButton: 'Ok',
                            ),
                          );
                          return;
                        }

                        // Create appointment details
                        Map<String, dynamic> appointmentDetails = {
                          'patient_id': currentUser.id,
                          'doctor_id': widget.doctorDetails['user_id'],
                          'appointment_date': selectedDate?.toIso8601String(),
                          'reason': reasonController.text.trim(),
                        };

                        // Add appointment using bloc
                        context
                            .read<AppointmentsBloc>()
                            .add(AddAppointmentEvent(appointmentDetails: appointmentDetails));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctorDetails,
  });

  final Map<String, dynamic> doctorDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(doctorDetails['image_url'], height: 100, width: 100, fit: BoxFit.cover),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${doctorDetails['id']}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    formatValue(doctorDetails['full_name']),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    formatValue(doctorDetails['specialization']),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTimeChip extends StatelessWidget {
  final String time;
  final Function() onTap;
  final bool isSelected;
  final bool isDisabled;
  const CustomTimeChip({
    super.key,
    required this.time,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? primaryColor.withAlpha(100)
          : isDisabled
              ? Colors.red.withAlpha(100)
              : Colors.green.withAlpha(100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: isSelected
                ? primaryColor
                : isDisabled
                    ? Colors.red
                    : Colors.green,
            width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
