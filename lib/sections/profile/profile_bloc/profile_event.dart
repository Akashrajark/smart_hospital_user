part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> data;

  UpdateProfileEvent({
    required this.data,
  });
}
