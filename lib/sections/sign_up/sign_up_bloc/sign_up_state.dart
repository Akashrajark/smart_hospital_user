part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState {}

final class SignUpInitialState extends SignUpState {}

final class SignUpSuccessState extends SignUpState {}

final class SignUpLoadingState extends SignUpState {}

final class SignUpFailureState extends SignUpState {
  final String message;

  SignUpFailureState({this.message = apiErrorMessage});
}
