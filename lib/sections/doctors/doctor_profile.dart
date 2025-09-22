import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import 'doctors_bloc/doctors_bloc.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final DoctorsBloc _doctorsBloc = DoctorsBloc();

  @override
  void initState() {
    getDoctorById();
    super.initState();
  }

  void getDoctorById() {
    _doctorsBloc.add(GetDoctorByIdEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorsBloc,
      child: BlocConsumer<DoctorsBloc, DoctorsState>(
        listener: (context, state) {
          if (state is DoctorsFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Error',
                description: state.message,
                primaryButton: 'Ok',
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DoctorsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetDoctorByIdSuccessState) {
            return _buildProfileContent(context, state.doctorDetails);
          } else if (state is DoctorsFailureState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DoctorsBloc>().add(GetDoctorByIdEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data available'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> doctorData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context, doctorData),
          const SizedBox(height: 32),

          // Personal Information Section
          _buildSectionHeader(context, 'Personal Information'),
          const SizedBox(height: 16),
          _buildInfoTile(context, 'Full Name', doctorData['full_name'], Icons.person),
          _buildInfoTile(context, 'Email', doctorData['email'], Icons.email),
          _buildInfoTile(context, 'Phone', doctorData['phone'], Icons.phone),
          _buildInfoTile(context, 'Gender', _capitalizeFirst(doctorData['gender']), Icons.wc),
          _buildInfoTile(context, 'Date of Birth', _formatDate(doctorData['dob']), Icons.calendar_today),

          const SizedBox(height: 32),

          // Professional Information Section
          _buildSectionHeader(context, 'Professional Information'),
          const SizedBox(height: 16),
          _buildInfoTile(context, 'Specialization', doctorData['specialization'], Icons.medical_services),
          _buildInfoTile(context, 'Qualification', doctorData['qualification'], Icons.school),
          _buildInfoTile(context, 'Experience', doctorData['experience'], Icons.work_history),
          _buildInfoTile(context, 'Status', _capitalizeFirst(doctorData['status']), Icons.verified_user),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> doctorData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              // Note: Edit functionality can be added later if needed
              // IconButton(
              //   icon: Icon(
              //     Icons.edit,
              //     color: Colors.orange,
              //   ),
              //   onPressed: () {
              //     // Navigate to edit screen
              //   },
              // ),
            ],
          ),
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                doctorData['image_url'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doctorData['full_name'] ?? 'Unknown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            doctorData['specialization'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            doctorData['email'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, dynamic value, IconData icon, {bool isOptional = false}) {
    String displayValue = _getDisplayValue(value, isOptional);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: displayValue == 'Not provided'
                            ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurface,
                        fontStyle: displayValue == 'Not provided' ? FontStyle.italic : FontStyle.normal,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayValue(dynamic value, bool isOptional) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return isOptional ? 'Not provided' : 'N/A';
    }
    return value.toString();
  }

  String _capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return 'N/A';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
