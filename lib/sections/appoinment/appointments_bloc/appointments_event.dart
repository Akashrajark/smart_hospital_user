part of 'appointments_bloc.dart';

@immutable
sealed class AppointmentsEvent {}

class GetAllAppointmentsEvent extends AppointmentsEvent {
  final Map<String, dynamic> params;

  GetAllAppointmentsEvent({required this.params});
}

class AddAppointmentEvent extends AppointmentsEvent {
  final Map<String, dynamic> appointmentDetails;

  AddAppointmentEvent({required this.appointmentDetails});
}

class EditAppointmentEvent extends AppointmentsEvent {
  final Map<String, dynamic> appointmentDetails;
  final int appointmentId;

  EditAppointmentEvent({required this.appointmentDetails, required this.appointmentId});
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;

  DeleteAppointmentEvent({required this.appointmentId});
}

class GetDailyAppointmentsEvent extends AppointmentsEvent {
  final String doctor_id;
  GetDailyAppointmentsEvent({required this.doctor_id});
}

class GetAppointmentByIdEvent extends AppointmentsEvent {
  final int appointmentId;

  GetAppointmentByIdEvent({required this.appointmentId});
}

class UploadXrayEvent extends AppointmentsEvent {
  final Map<String, dynamic> xrayDetails;
  final int appoinmentId;

  UploadXrayEvent({
    required this.xrayDetails,
    required this.appoinmentId,
  });
}

class GetDoctorAppointmentsEvent extends AppointmentsEvent {
  final Map<String, dynamic> params;

  GetDoctorAppointmentsEvent({required this.params});
}
