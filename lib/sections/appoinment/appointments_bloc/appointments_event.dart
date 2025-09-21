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
  final String appointmentId;

  EditAppointmentEvent({required this.appointmentDetails, required this.appointmentId});
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;

  DeleteAppointmentEvent({required this.appointmentId});
}

class GetDailyAppointmentsEvent extends AppointmentsEvent {
  GetDailyAppointmentsEvent();
}

class GetAppointmentByIdEvent extends AppointmentsEvent {
  final int appointmentId;

  GetAppointmentByIdEvent({required this.appointmentId});
}

class UploadXrayEvent extends AppointmentsEvent {
  final Map<String, dynamic> xrayDetails;

  UploadXrayEvent({required this.xrayDetails});
}
