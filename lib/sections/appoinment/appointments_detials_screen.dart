import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/common_widgets/custom_button.dart';
import 'package:smart_hospital/common_widgets/custom_image_picker_button.dart';
import 'package:smart_hospital/sections/appoinment/appointments_bloc/appointments_bloc.dart';
import 'package:smart_hospital/util/format_functions.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import 'book_appoinments.dart';

class AppointmentsDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> itemDetails;
  const AppointmentsDetailsScreen({super.key, required this.itemDetails});

  @override
  State<AppointmentsDetailsScreen> createState() => _AppointmentsDetailsScreenState();
}

class _AppointmentsDetailsScreenState extends State<AppointmentsDetailsScreen> {
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
                      DoctorCard(doctorDetails: widget.itemDetails['doctor']),
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
                                appointmentDetails['reason'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (['prescribed', 'submitted', 'reviewed'].contains(appointmentDetails['status']))
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Prescription Details',
                                      style:
                                          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
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
                      SizedBox(height: 20),
                      if (appointmentDetails['status'] == 'prescribed' && appointmentDetails['xray_needed'] == 'Yes')
                        CustomButton(
                          inverse: true,
                          label: 'Upload Xray',
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => BlocProvider.value(
                                      value: _appointmentsBloc,
                                      child: UploadXrayDialog(
                                        appoinmentId: appointmentDetails['id'],
                                      ),
                                    ));
                          },
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
                                      'Doctor Report',
                                      style:
                                          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ],
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

class UploadXrayDialog extends StatefulWidget {
  final int appoinmentId;
  const UploadXrayDialog({
    super.key,
    required this.appoinmentId,
  });

  @override
  State<UploadXrayDialog> createState() => _UploadXrayDialogState();
}

class _UploadXrayDialogState extends State<UploadXrayDialog> {
  File? pickedFile;

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
          isLoading: state is AppointmentsLoadingState,
          title: 'Upload Xray',
          content: CustomImagePickerButton(
              width: double.infinity,
              onPick: (pick) {
                pickedFile = pick;
              }),
          primaryButton: 'Submit',
          onPrimaryPressed: () {
            if (pickedFile != null) {
              BlocProvider.of<AppointmentsBloc>(context).add(
                UploadXrayEvent(
                  appoinmentId: widget.appoinmentId,
                  xrayDetails: {'file': pickedFile!, 'xray_file_path': pickedFile!.path},
                ),
              );
            }
          },
        );
      },
    );
  }
}
