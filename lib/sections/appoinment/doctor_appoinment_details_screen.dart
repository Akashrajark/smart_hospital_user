import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/sections/appoinment/prescription_screen.dart';
import 'package:smart_hospital/sections/patients/patient_detail_screen.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_form_field.dart';
import '../../util/format_functions.dart';
import '../../util/value_validators.dart';
import 'appointments_bloc/appointments_bloc.dart';

class DoctorAppoinmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> itemDetails;
  const DoctorAppoinmentDetailsScreen({super.key, required this.itemDetails});

  @override
  State<DoctorAppoinmentDetailsScreen> createState() => _DoctorAppoinmentDetailsScreenState();
}

class _DoctorAppoinmentDetailsScreenState extends State<DoctorAppoinmentDetailsScreen> {
  final AppointmentsBloc _appointmentsBloc = AppointmentsBloc();
  Map<String, dynamic> appointmentDetails = {};

  @override
  void initState() {
    getAppointmentById();
    super.initState();
  }

  void getAppointmentById() {
    _appointmentsBloc.add(GetAppointmentByIdEvent(appointmentId: widget.itemDetails['id']));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsBloc,
      child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Failure',
                description: state.message,
                primaryButton: 'Try Again',
                onPrimaryPressed: () {
                  getAppointmentById();
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is GetAppointmentsByIdSuccessState) {
            appointmentDetails = state.appointmentDetails;
            setState(() {});
          } else if (state is AppointmentsSuccessState) {
            getAppointmentById();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Appointment Details',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            ),
            body: state is AppointmentsLoadingState
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      PatientCard(patientDetails: widget.itemDetails['patient']),
                      SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Appointment Details',
                                    style:
                                        Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade300,
                              ),
                              Text(
                                'Date Time',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formatDateTime(appointmentDetails['appointment_date']),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Divider(
                                color: Colors.grey.shade300,
                              ),
                              Text(
                                'Reason for Visit',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formatValue(appointmentDetails['reason']),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (appointmentDetails['status'] == 'booked')
                        CustomButton(
                          inverse: true,
                          label: 'Add Prescription',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                          value: _appointmentsBloc,
                                          child: PrescriptionScreen(
                                            appointmentId: appointmentDetails['id'],
                                          ),
                                        ))).then((value) {
                              getAppointmentById();
                            });
                          },
                        ),
                      if (['prescribed', 'submitted', 'reviewed'].contains(appointmentDetails['status']))
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Prescription Details',
                                      style:
                                          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                    if (appointmentDetails['status'] == 'prescribed')
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => BlocProvider.value(
                                                        value: _appointmentsBloc,
                                                        child: PrescriptionScreen(
                                                          appointmentId: appointmentDetails['id'],
                                                          existingDetails: appointmentDetails,
                                                        ),
                                                      ))).then((value) {
                                            getAppointmentById();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                ),
                                Text(
                                  'Prescription',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatValue(appointmentDetails['prescription']),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                ),
                                Text(
                                  'Xray Report',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatValue(appointmentDetails['xray_needed']),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      if (['submitted', 'reviewed'].contains(appointmentDetails['status']))
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Xray',
                                      style:
                                          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                if (appointmentDetails['xray_url'] != null)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8.0),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(),
                                          body: InteractiveViewer(
                                            child: Center(child: Image.network(appointmentDetails['xray_url'])),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        appointmentDetails['xray_url'],
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  'Xray Report',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatValue(appointmentDetails['xray_report']),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      if (appointmentDetails['status'] == 'submitted')
                        CustomButton(
                            inverse: true,
                            label: 'Add Report',
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => BlocProvider.value(
                                        value: _appointmentsBloc,
                                        child: AddEditReportDialog(
                                          existingDetails: appointmentDetails,
                                        ),
                                      )).then((_) {
                                getAppointmentById();
                              });
                            }),
                      if (appointmentDetails['status'] == 'reviewed')
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Xray',
                                      style:
                                          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Doctor Report',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatValue(appointmentDetails['doctor_review']),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class AddEditReportDialog extends StatefulWidget {
  final Map<String, dynamic> existingDetails;
  const AddEditReportDialog({
    super.key,
    required this.existingDetails,
  });

  @override
  State<AddEditReportDialog> createState() => _AddEditReportDialogState();
}

class _AddEditReportDialogState extends State<AddEditReportDialog> {
  final TextEditingController reportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsBloc, AppointmentsState>(
      listener: (context, state) {
        if (state is AppointmentsSuccessState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return CustomAlertDialog(
          title: 'Report',
          content: Form(
            key: _formKey,
            child: Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text("Report", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    minLines: 5,
                    maxLines: 5,
                    labelText: 'Report',
                    controller: reportController,
                    validator: notEmptyValidator,
                  ),
                ],
              ),
            ),
          ),
          primaryButton: 'Submit',
          onPrimaryPressed: () {
            if (_formKey.currentState!.validate()) {
              BlocProvider.of<AppointmentsBloc>(context).add(EditAppointmentEvent(appointmentDetails: {
                'doctor_review': reportController.text,
                'status': 'reviewed',
              }, appointmentId: widget.existingDetails['id']));
            }
          },
        );
      },
    );
  }
}

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patientDetails,
  });

  final Map<String, dynamic> patientDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => patientDataDetailScreen(
                        patientData: patientDetails,
                      )));
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: patientDetails['image_url'] != null
                    ? Image.network(
                        patientDetails['image_url'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${patientDetails['id']}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      formatValue(patientDetails['full_name']),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      formatValue(patientDetails['email']),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
