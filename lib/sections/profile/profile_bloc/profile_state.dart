part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitialState extends ProfileState {}

final class ProfileLoadingState extends ProfileState {}

final class ProfileSuccessState extends ProfileState {}

final class ProfileGetSuccessState extends ProfileState {
  final Map<String, dynamic> profileData;

  ProfileGetSuccessState({
    required this.profileData,
  });
}

final class ProfileFailureState extends ProfileState {
  final String message;

  ProfileFailureState({this.message = apiErrorMessage});
}
