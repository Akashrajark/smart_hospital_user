import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../util/file_upload.dart';
import '../../../value/strings.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitialState()) {
    on<ProfileEvent>((event, emit) async {
      try {
        emit(ProfileLoadingState());
        SupabaseQueryBuilder table = Supabase.instance.client.from('patients');
        String userId = Supabase.instance.client.auth.currentUser!.id;

        if (event is GetProfileEvent) {
          final profileData = await table.select().eq('user_id', userId).single();
          emit(ProfileGetSuccessState(profileData: profileData));
        } else if (event is UpdateProfileEvent) {
          if (event.data['image'] != null) {
            event.data['image_url'] = await uploadFile(
              'patient_profile_photo',
              event.data['image'],
              event.data['image_name'],
            );
            event.data.remove('image');
            event.data.remove('image_name');
          }
          await table.update(event.data).eq('user_id', userId);
          emit(ProfileSuccessState());
        }
      } catch (e) {
        emit(ProfileFailureState());
      }
    });
  }
}
