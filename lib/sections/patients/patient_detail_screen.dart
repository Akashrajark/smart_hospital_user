import 'package:flutter/material.dart';
import 'package:smart_hospital/common_widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class patientDataDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const patientDataDetailScreen({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(context, patientData),
            const SizedBox(height: 32),

            // Personal Information Section
            _buildSectionHeader(context, 'Personal Information'),
            const SizedBox(height: 16),
            _buildInfoTile(context, 'Full Name', patientData['full_name'], Icons.person),
            _buildInfoTile(context, 'Email', patientData['email'], Icons.email),
            _buildInfoTile(context, 'Phone', patientData['phone'], Icons.phone),
            _buildInfoTile(context, 'Gender', _capitalizeFirst(patientData['gender']), Icons.wc),
            _buildInfoTile(context, 'Date of Birth', _formatDate(patientData['dob']), Icons.calendar_today),
            _buildInfoTile(context, 'Emergency Contact', patientData['emergency_contact'], Icons.emergency),
            _buildInfoTile(context, 'Emergency Phone', patientData['emergency_phone'], Icons.phone_in_talk),

            const SizedBox(height: 32),

            // Medical Information Section
            _buildSectionHeader(context, 'Medical Information'),
            const SizedBox(height: 16),
            _buildInfoTile(context, 'Medical History', patientData['medical_history'], Icons.medical_information,
                isOptional: true),
            _buildInfoTile(context, 'Chronic Conditions', patientData['chronic_condition'], Icons.healing,
                isOptional: true),
            _buildInfoTile(context, 'Allergies', patientData['allergies'], Icons.warning, isOptional: true),
            _buildInfoTile(context, 'Past Surgeries', patientData['past_surgeries'], Icons.local_hospital_outlined,
                isOptional: true),
            _buildInfoTile(context, 'Family History', patientData['family_history'], Icons.family_restroom,
                isOptional: true),
            _buildInfoTile(context, 'Current Medications', patientData['current_medication'], Icons.medication,
                isOptional: true),
            _buildInfoTile(context, 'Lifestyle', patientData['lifestyle'], Icons.health_and_safety, isOptional: true),

            const SizedBox(height: 24),
            CustomButton(
              inverse: true,
              label: 'Call Patient',
              onPressed: () async {
                final phone = patientData['phone'];
                if (phone != null && phone.toString().isNotEmpty) {
                  final Uri phoneUri = Uri(scheme: 'tel', path: phone.toString());
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              inverse: true,
              label: 'Call Emergency Contact',
              onPressed: () async {
                final emergencyPhone = patientData['emergency_contact'];
                if (emergencyPhone != null && emergencyPhone.toString().isNotEmpty) {
                  final Uri phoneUri = Uri(scheme: 'tel', path: emergencyPhone.toString());
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> patientData) {
  return SafeArea(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: patientData['image_url'] != null
                  ? Image.network(
                      patientData['image_url'],
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
          ),
          const SizedBox(height: 16),
          Text(
            patientData['full_name'] ?? 'Unknown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            patientData['email'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
          ),
        ],
      ),
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
