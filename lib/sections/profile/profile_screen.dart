import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/sections/profile/edit_profile_screen.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import 'profile_bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(GetProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailureState) {
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
          if (state is ProfileLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileGetSuccessState) {
            return _buildProfileContent(context, state.profileData);
          } else if (state is ProfileFailureState) {
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
                      context.read<ProfileBloc>().add(GetProfileEvent());
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

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> profileData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context, profileData),
          const SizedBox(height: 32),

          // Personal Information Section
          _buildSectionHeader(context, 'Personal Information'),
          const SizedBox(height: 16),
          _buildInfoTile(context, 'Full Name', profileData['full_name'], Icons.person),
          _buildInfoTile(context, 'Email', profileData['email'], Icons.email),
          _buildInfoTile(context, 'Phone', profileData['phone'], Icons.phone),
          _buildInfoTile(context, 'Gender', _capitalizeFirst(profileData['gender']), Icons.wc),
          _buildInfoTile(context, 'Date of Birth', _formatDate(profileData['dob']), Icons.calendar_today),
          _buildInfoTile(context, 'Emergency Contact', profileData['emergency_contact'], Icons.emergency),

          const SizedBox(height: 32),

          // Medical Information Section
          _buildSectionHeader(context, 'Medical Information'),
          const SizedBox(height: 16),
          _buildInfoTile(context, 'Medical History', profileData['medical_history'], Icons.medical_information,
              isOptional: true),
          _buildInfoTile(context, 'Chronic Conditions', profileData['chronic_condition'], Icons.healing,
              isOptional: true),
          _buildInfoTile(context, 'Allergies', profileData['allergies'], Icons.warning, isOptional: true),
          _buildInfoTile(context, 'Past Surgeries', profileData['past_surgeries'], Icons.local_hospital_outlined,
              isOptional: true),
          _buildInfoTile(context, 'Family History', profileData['family_history'], Icons.family_restroom,
              isOptional: true),
          _buildInfoTile(context, 'Current Medications', profileData['current_medication'], Icons.medication,
              isOptional: true),
          _buildInfoTile(context, 'Lifestyle', profileData['lifestyle'], Icons.health_and_safety, isOptional: true),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> profileData) {
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
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        profileData: profileData,
                      ),
                    ),
                  ).then((_) {
                    // Refresh profile data when returning from edit screen
                    context.read<ProfileBloc>().add(GetProfileEvent());
                  });
                },
              ),
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
                profileData['image_url'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileData['full_name'] ?? 'Unknown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            profileData['email'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
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
