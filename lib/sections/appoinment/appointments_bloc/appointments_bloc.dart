import 'package:bloc/bloc.dart';
import 'package:logger/web.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../../../util/file_upload.dart';
import '../../../util/format_functions.dart';
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
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query = table
              .select('*,doctor:doctors(id, full_name, specialization,image_url)')
              .eq('patient_id', getCurrentUserId()!);

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
          await table.update(event.appointmentDetails).eq('id', event.appointmentId);
          emit(AppointmentsSuccessState());
        } else if (event is DeleteAppointmentEvent) {
          await table.delete().eq('id', event.appointmentId);
          emit(AppointmentsSuccessState());
        } else if (event is GetDailyAppointmentsEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query = table.select('*').eq('doctor_id', event.doctor_id);
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
          try {
            // Extract file path from xrayDetails map
            String? filePath = event.xrayDetails['xray_file_path'];
            String? fileName = event.xrayDetails['fileName'] ?? 'xray_image.jpg';

            if (filePath == null) {
              Logger().e('X-ray upload failed: xray_file_path is required in xrayDetails');
              emit(AppointmentsFailureState(message: 'File path is required for X-ray upload'));
              return;
            }

            // Create multipart request
            var uri = Uri.parse('https://hospital-api-k13i.onrender.com/predict');
            var request = http.MultipartRequest('POST', uri);

            // Add headers if needed
            request.headers['Content-Type'] = 'multipart/form-data';
            request.headers['Accept'] = 'application/json';

            // Add the image file
            var file = await http.MultipartFile.fromPath(
              'file', // Field name for the file
              filePath,
              filename: fileName,
            );
            request.files.add(file);

            // Add other fields from xrayDetails (excluding xray_file_path and fileName and file)
            event.xrayDetails.forEach((key, value) {
              if (key != 'xray_file_path' && key != 'fileName' && key != 'file' && value != null) {
                request.fields[key] = value.toString();
              }
            });

            // Send the request
            Logger().e('Uploading X-ray to: ${uri.toString()}');
            var streamedResponse = await request.send();
            var response = await http.Response.fromStream(streamedResponse);

            // Log the response
            Logger().e('X-ray upload response status: ${response.statusCode}');
            Logger().e('X-ray upload response body: ${response.body}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              Logger().e('Response is successful, starting to process...');
              try {
                Logger().e('Attempting to decode JSON response...');
                var responseData = json.decode(response.body);
                Logger().e('JSON decoded successfully. Analysis result: $responseData');

                // Get Gemini interpretation of the results
                Logger().e('Starting Gemini interpretation process...');
                String cleanData = "";
                try {
                  // Extract just the probabilities for a cleaner prompt
                  Logger().e('Raw response data: $responseData');
                  Logger().e('Response data type: ${responseData.runtimeType}');
                  Logger().e('Probabilities key exists: ${responseData.containsKey('probabilities')}');

                  if (responseData['probabilities'] != null) {
                    Logger().e('Probabilities found, processing...');
                    Map<String, dynamic> probs = responseData['probabilities'];
                    Logger().e('Probabilities data: $probs');
                    cleanData = probs.entries
                        .where((entry) => entry.value > 20) // Only include >20%
                        .map((entry) => "${entry.key}: ${entry.value}%")
                        .join(", ");
                    Logger().e('Clean data formatted: $cleanData');
                  } else {
                    Logger().e('No probabilities found in response');
                    cleanData = "No probability data available";
                  }
                } catch (e) {
                  Logger().e('Data parsing error: $e');
                  cleanData = "Data parsing error: $e";
                }

                Logger().e('About to create Gemini prompt...');
                String geminiPrompt = "Interpret these chest X-ray probabilities: $cleanData";
                Logger().e('Gemini prompt created: $geminiPrompt');

                try {
                  final gemini = Gemini.instance;
                  Logger().e('Sending clean prompt to Gemini: $geminiPrompt');

                  final geminiResponse = await gemini.text(geminiPrompt);

                  if (geminiResponse?.output != null) {
                    Logger().e('Gemini interpretation: ${geminiResponse!.output}');
                    // You can store both the raw results and Gemini interpretation
                    responseData['gemini_interpretation'] = geminiResponse.output;
                    event.xrayDetails['xray_report'] = geminiResponse.output;
                    if (event.xrayDetails['file'] != null) {
                      event.xrayDetails['xray_url'] = await uploadFile(
                        'xray',
                        event.xrayDetails['file'],
                        event.xrayDetails['xray_file_path'],
                      );
                      event.xrayDetails.remove('file');
                      event.xrayDetails.remove('xray_file_path');
                    }
                    event.xrayDetails['status'] = 'submitted';
                    await table.update(event.xrayDetails).eq('id', event.appoinmentId);
                  } else {
                    Logger().e('Gemini interpretation failed: No output received');
                  }
                } catch (geminiError) {
                  Logger().e('Gemini interpretation error: $geminiError');
                  if (geminiError.toString().contains('429')) {
                    Logger().e('Rate limit exceeded. Please wait before trying again.');
                    Logger().e('Consider upgrading to paid tier for higher limits.');
                  }
                  Logger().e('Prompt was: $geminiPrompt');
                  // Continue with original response even if Gemini fails
                }

                emit(AppointmentsSuccessState());
              } catch (e) {
                Logger().e('X-ray upload successful. Response: ${response.body}');
                emit(AppointmentsSuccessState());
              }
            } else {
              Logger().e('X-ray upload failed with status: ${response.statusCode}, body: ${response.body}');
              emit(AppointmentsFailureState(message: 'X-ray upload failed'));
            }
          } catch (e, s) {
            Logger().e('X-ray upload error: $e\n$s');
            emit(AppointmentsFailureState(message: 'X-ray upload failed: ${e.toString()}'));
          }
        }
        if (event is GetDoctorAppointmentsEvent) {
          PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
              table.select('*,patient:patients!inner(*)').eq('doctor_id', getCurrentUserId()!);

          if (event.params['query'] != null) {
            // Check if the query is a string and can be parsed to an int

            // If it's not a valid int, use it for name query
            query = query.filter('patient.full_name', 'ilike', '%${event.params['query']}%');
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
        }
      } catch (e, s) {
        Logger().e('$e\n$s');
        emit(AppointmentsFailureState(message: apiErrorMessage));
      }
    });
  }
}
