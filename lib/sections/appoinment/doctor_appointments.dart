import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:smart_hospital/sections/appoinment/appointments_bloc/appointments_bloc.dart';
import 'package:smart_hospital/sections/appoinment/doctor_appoinment_details_screen.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_seearch_filter.dart' show CustomSearchFilter;
import '../../util/format_functions.dart';

class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  List<Map<String, dynamic>> appointments = [];
  final AppointmentsBloc _appointmentsBloc = AppointmentsBloc();

  Map<String, dynamic> params = {'query': null, 'range_start': 0, 'range_end': 24};

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _totalAppointmentsCount = 0;
  final int _itemsPerPage = 25;

  @override
  void initState() {
    _setupScrollListener();
    getAppointments();
    super.initState();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Load more data when user is 200 pixels from the bottom
        _loadMoreProjects();
      }
    });
  }

  void getAppointments({bool isLoadMore = false}) {
    if (!isLoadMore) {
      // Reset pagination for new search/filter
      params['range_start'] = 0;
      params['range_end'] = _itemsPerPage - 1;
      _hasMoreData = true;
    }
    _appointmentsBloc.add(GetDoctorAppointmentsEvent(params: params));
  }

  void _loadMoreProjects() {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Calculate next range
    params['range_start'] = appointments.length;
    params['range_end'] = appointments.length + _itemsPerPage - 1;

    _appointmentsBloc.add(GetDoctorAppointmentsEvent(params: params));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _appointmentsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsBloc,
      child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Failure',
                description: state.message,
                primaryButton: 'Try Again',
                onPrimaryPressed: () {
                  getAppointments();
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state is AppointmentsGetSuccessState) {
            setState(() {
              if (_isLoadingMore) {
                // Append new data to existing list
                appointments.addAll(state.appointments);
                _isLoadingMore = false;

                // Check if we have more data to load
                _hasMoreData = state.appointments.length == _itemsPerPage;
              } else {
                // Replace list for new search/filter
                appointments = state.appointments;
                _hasMoreData = state.appointments.length == _itemsPerPage;
              }
              _totalAppointmentsCount = state.appointmentCount;
            });
            Logger().w("Appointments loaded: ${state.appointments.length}, Total: $_totalAppointmentsCount");
          } else if (state is AppointmentsSuccessState) {
            getAppointments();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              controller: _scrollController,
              children: [
                Text("Appointments List", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                CustomSearchFilter(
                  onSearch: (search) {
                    params['query'] = search.trim();
                    getAppointments();
                  },
                ),
                const SizedBox(height: 16),
                if (state is AppointmentsLoadingState && !_isLoadingMore)
                  Center(child: CircularProgressIndicator())
                else if (appointments.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments found',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => CustomDoctorAppointmentCard(
                        appointmentDetails: appointments[index],
                        onViewAppointment: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorAppoinmentDetailsScreen(itemDetails: appointments[index]))).then((value) {
                            getAppointments();
                          });
                        }),
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemCount: appointments.length,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomDoctorAppointmentCard extends StatelessWidget {
  final Map<String, dynamic>? appointmentDetails;
  final Function() onViewAppointment;
  const CustomDoctorAppointmentCard({
    super.key,
    this.appointmentDetails,
    required this.onViewAppointment,
  });

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'booked':
        return Colors.teal;
      case 'prescribed':
        return Colors.orange;
      case 'submitted':
        return Colors.purple;
      case 'reviewed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    return _getStatusColor(status).withAlpha(50);
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'booked':
      case 'prescribed':
      case 'submitted':
      case 'reviewed':
        return _getStatusColor(status);
      default:
        return Colors.black87;
    }
  }

  String _capitalizeStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    final lowerStatus = status.toLowerCase();
    return lowerStatus[0].toUpperCase() + lowerStatus.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.black.withAlpha(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${appointmentDetails?['id']}",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey, fontWeight: FontWeight.w700),
                ),
                Chip(
                  label: Text(
                    _capitalizeStatus(appointmentDetails?['status']),
                    style: TextStyle(
                      color: _getStatusTextColor(appointmentDetails?['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _getStatusBackgroundColor(appointmentDetails?['status']),
                  side: BorderSide(
                    color: _getStatusColor(appointmentDetails?['status']),
                    width: 1.5,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.withAlpha(50), thickness: 1, height: 20),
            Text(
              formatDateTime(appointmentDetails?['appointment_date']),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Divider(color: Colors.grey.withAlpha(50), thickness: 1, height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: appointmentDetails?['patient']?['image_url'] != null
                      ? Image.network(
                          appointmentDetails?['patient']?['image_url'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatValue(appointmentDetails?['patient']?['full_name']),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        formatValue(appointmentDetails?['patient']?['email']),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.withAlpha(50), thickness: 1, height: 20),
            CustomButton(
              onPressed: onViewAppointment,
              label: "View Appointment",
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              iconData: Icons.arrow_forward_ios_rounded,
              backGroundColor: Colors.white,
              color: Colors.blue,
              outlineColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
