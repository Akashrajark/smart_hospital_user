part of 'doctors_bloc.dart';

@immutable
sealed class DoctorsEvent {}

class GetAllDoctorsEvent extends DoctorsEvent {
  final Map<String, dynamic> params;

  GetAllDoctorsEvent({required this.params});
}

class AddDoctorEvent extends DoctorsEvent {
  final Map<String, dynamic> doctorDetails;

  AddDoctorEvent({required this.doctorDetails});
}

class EditDoctorEvent extends DoctorsEvent {
  final Map<String, dynamic> doctorDetails;
  final String doctorId;

  EditDoctorEvent({required this.doctorDetails, required this.doctorId});
}

class BlockUnblockDoctorEvent extends DoctorsEvent {
  final String doctorId;
  final String status;

  BlockUnblockDoctorEvent({required this.doctorId, required this.status});
}
