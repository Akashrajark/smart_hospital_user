part of 'doctors_bloc.dart';

@immutable
sealed class DoctorsState {}

final class DoctorsInitialState extends DoctorsState {}

final class DoctorsLoadingState extends DoctorsState {}

final class DoctorsSuccessState extends DoctorsState {}

final class DoctorsGetSuccessState extends DoctorsState {
  final List<Map<String, dynamic>> doctors;
  final int doctorCount;

  DoctorsGetSuccessState({required this.doctors, required this.doctorCount});
}

final class DoctorsFailureState extends DoctorsState {
  final String message;

  DoctorsFailureState({this.message = apiErrorMessage});
}
