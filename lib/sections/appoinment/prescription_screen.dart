import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/common_widgets/custom_button.dart';
import 'package:smart_hospital/common_widgets/custom_radio_button.dart';
import 'package:smart_hospital/common_widgets/custom_text_form_field.dart';
import 'package:smart_hospital/sections/appoinment/appointments_bloc/appointments_bloc.dart';
import 'package:smart_hospital/util/value_validators.dart';

import '../../common_widgets/custom_alert_dialog.dart';

class PrescriptionScreen extends StatefulWidget {
  final int appointmentId;
  final Map<String, dynamic>? existingDetails;
  const PrescriptionScreen({super.key, required this.appointmentId, this.existingDetails});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController prescriptionController = TextEditingController();
  String isXrayNeeded = 'Yes';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.existingDetails != null) {
      prescriptionController.text = widget.existingDetails?['prescription'] ?? '';
      isXrayNeeded = widget.existingDetails?['xray_needed'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription'),
      ),
      body: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Failure',
                description: state.message,
                primaryButton: 'Try Again',
                onPrimaryPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is AppointmentsSuccessState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Text("Prescription", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                CustomTextFormField(
                    minLines: 5,
                    maxLines: 5,
                    labelText: 'Prescription',
                    controller: prescriptionController,
                    validator: notEmptyValidator),
                SizedBox(height: 15),
                Text("Xray", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CustomRadioButton(
                      isChecked: isXrayNeeded == 'Yes',
                      label: 'Yes',
                      onPressed: () {
                        setState(() {
                          isXrayNeeded = 'Yes';
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    CustomRadioButton(
                      isChecked: isXrayNeeded == 'No',
                      label: 'No',
                      onPressed: () {
                        setState(() {
                          isXrayNeeded = 'No';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                CustomButton(
                  isLoading: state is AppointmentsLoadingState,
                  inverse: true,
                  label: 'Submit',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      BlocProvider.of<AppointmentsBloc>(context).add(EditAppointmentEvent(appointmentDetails: {
                        'prescription': prescriptionController.text.trim(),
                        'xray_needed': isXrayNeeded,
                        'status': 'prescribed',
                      }, appointmentId: widget.appointmentId));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
