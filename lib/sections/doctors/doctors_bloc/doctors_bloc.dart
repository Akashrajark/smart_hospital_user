import 'package:bloc/bloc.dart';
import 'package:logger/web.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../value/strings.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  DoctorsBloc() : super(DoctorsInitialState()) {
    on<DoctorsEvent>((event, emit) async {
      try {
        emit(DoctorsLoadingState());
        SupabaseQueryBuilder table = Supabase.instance.client.from('doctors');

        if (event is GetAllDoctorsEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query = table.select('*');

          if (event.params['query'] != null) {
            // Check if the query is a string and can be parsed to an int

            // If it's not a valid int, use it for name query
            query = query
                .or('full_name.ilike.%${event.params['query']}%,  specialization.ilike.%${event.params['query']}%');
          }

          List<Map<String, dynamic>> result;
          int? count;
          if (event.params['limit'] != null) {
            result = await query.order('id', ascending: false).limit(event.params['limit']);
          } else {
            result =
                await query.order('id', ascending: false).range(event.params['range_start'], event.params['range_end']);
            count = (await query.count(CountOption.exact)).count;
          }

          emit(DoctorsGetSuccessState(doctors: result, doctorCount: count ?? 0));
        }
      } catch (e, s) {
        Logger().e('$e\n$s');
        emit(DoctorsFailureState(message: apiErrorMessage));
      }
    });
  }
}
