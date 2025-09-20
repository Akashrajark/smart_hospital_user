import 'package:bloc/bloc.dart';
import 'package:logger/web.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../util/file_upload.dart';
import '../../../value/strings.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitialState()) {
    on<SignUpEvent>((event, emit) async {
      try {
        emit(SignUpLoadingState());
        SupabaseQueryBuilder table = Supabase.instance.client.from('patients');
        // Create user with Supabase Auth
        AuthResponse authResponse = await Supabase.instance.client.auth.signUp(
          password: event.data['password'],
          email: event.data['email'],
        );

        if (authResponse.user != null) {
          event.data['user_id'] = authResponse.user!.id;
          event.data['image_url'] = await uploadFile(
            'patient_profile_photo',
            event.data['image'],
            event.data['image_name'],
          );
          event.data.remove('image');
          event.data.remove('image_name');
          event.data.remove('password');
          await table.insert(event.data);
          emit(SignUpSuccessState());
        } else {
          emit(SignUpFailureState(message: 'Failed to create account'));
        }
      } catch (e, s) {
        Logger().e('SignUp Error: $e\n$s');

        if (e is AuthException) {
          emit(SignUpFailureState(message: e.message));
        } else {
          emit(SignUpFailureState());
        }
      }
    });
  }
}
