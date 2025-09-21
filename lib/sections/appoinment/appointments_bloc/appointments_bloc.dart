import 'package:bloc/bloc.dart';
import 'package:logger/web.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../value/strings.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc() : super(AppointmentsInitialState()) {
    on<AppointmentsEvent>((event, emit) async {
      try {
        emit(AppointmentsLoadingState());
        SupabaseQueryBuilder table = Supabase.instance.client.from('appointments');

        if (event is GetAllAppointmentsEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
              table.select('*,doctor:doctors(id, full_name, specialization,image_url)');

          if (event.params['query'] != null) {
            // Check if the query is a string and can be parsed to an int

            // If it's not a valid int, use it for name query
            query =
                query.or('full_name.ilike.%${event.params['query']}%, specialization.ilike.%${event.params['query']}%');
          }

          List<Map<String, dynamic>> result;
          int? count;
          if (event.params['limit'] != null) {
            result = await query.order('appointment_date', ascending: false).limit(event.params['limit']);
          } else {
            result = await query
                .order('appointment_date', ascending: false)
                .range(event.params['range_start'], event.params['range_end']);
            count = (await query.count(CountOption.exact)).count;
          }

          emit(AppointmentsGetSuccessState(appointments: result, appointmentCount: count ?? 0));
        } else if (event is AddAppointmentEvent) {
          await table.insert(event.appointmentDetails);
          emit(AppointmentsSuccessState());
        } else if (event is EditAppointmentEvent) {
          await table.update(event.appointmentDetails).eq('id', event.appointmentDetails['id']);
          emit(AppointmentsSuccessState());
        } else if (event is DeleteAppointmentEvent) {
          await table.delete().eq('id', event.appointmentId);
          emit(AppointmentsSuccessState());
        } else if (event is GetDailyAppointmentsEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query = table.select('*');
          DateTime now = DateTime.now();
          String today =
              "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
          query = query
              .gte('appointment_date', '${today}T00:00:00+00:00')
              .lt('appointment_date', '${today}T23:59:59+00:00');
          List<Map<String, dynamic>> result = await query.order('id', ascending: false);
          emit(GetDailyAppointmentsState(appointments: result));
        } else if (event is GetAppointmentByIdEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query = table.select('*');
          query = query.eq('id', event.appointmentId);
          Map<String, dynamic>? result = await query.single();
          emit(GetAppointmentsByIdSuccessState(appointmentDetails: result));
        } else if (event is UploadXrayEvent) {
          //TODO: Implement Xray upload functionality
          emit(AppointmentsSuccessState());
        }
      } catch (e, s) {
        Logger().e('$e\n$s');
        emit(AppointmentsFailureState(message: apiErrorMessage));
      }
    });
  }
}
