import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/common_widgets/custom_image_picker_button.dart';
import 'package:smart_hospital/util/value_validators.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_date_picker.dart';
import '../../common_widgets/custom_radio_button.dart';
import '../../common_widgets/custom_text_form_field.dart';
import 'profile_bloc/profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({
    super.key,
    required this.profileData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final TextEditingController medicalHistoryController = TextEditingController();
  final TextEditingController chronicConditionController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController pastSurgeriesController = TextEditingController();
  final TextEditingController familyHistoryController = TextEditingController();
  final TextEditingController currentMedicationController = TextEditingController();
  final TextEditingController lifestyleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String gender = 'male';
  DateTime? dob;
  File? profileImage;
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.profileData;

    fullNameController.text = data['full_name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    emergencyContactController.text = data['emergency_contact'] ?? '';
    medicalHistoryController.text = data['medical_history'] ?? '';
    chronicConditionController.text = data['chronic_condition'] ?? '';
    allergiesController.text = data['allergies'] ?? '';
    pastSurgeriesController.text = data['past_surgeries'] ?? '';
    familyHistoryController.text = data['family_history'] ?? '';
    currentMedicationController.text = data['current_medication'] ?? '';
    lifestyleController.text = data['lifestyle'] ?? '';

    gender = data['gender'] ?? 'male';
    currentImageUrl = data['image_url'];

    if (data['dob'] != null) {
      try {
        dob = DateTime.parse(data['dob']);
      } catch (e) {
        dob = null;
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emergencyContactController.dispose();
    medicalHistoryController.dispose();
    chronicConditionController.dispose();
    allergiesController.dispose();
    pastSurgeriesController.dispose();
    familyHistoryController.dispose();
    currentMedicationController.dispose();
    lifestyleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                title: 'Failed',
                description: state.message,
                primaryButton: 'Ok',
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              elevation: 0,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Profile Picture Section
                      Text(
                        "Profile Picture",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      CustomImagePickerButton(
                        selectedImage: currentImageUrl,
                        onPick: (pick) {
                          profileImage = pick;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Personal Information Section
                      _buildSectionHeader(context, 'Personal Information'),
                      const SizedBox(height: 16),

                      // Full Name
                      RichText(
                        text: TextSpan(
                          text: "Full Name ",
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Full Name",
                        controller: fullNameController,
                        validator: alphabeticWithSpaceValidator,
                        prefixIconData: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      RichText(
                        text: TextSpan(
                          text: "Phone ",
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Phone",
                        controller: phoneController,
                        validator: phoneNumberValidator,
                        prefixIconData: Icons.phone,
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      RichText(
                        text: TextSpan(
                          text: "Gender ",
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomRadioButton(
                              isChecked: gender == 'male',
                              label: "Male",
                              onPressed: () {
                                setState(() {
                                  gender = 'male';
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: CustomRadioButton(
                              isChecked: gender == 'female',
                              label: "Female",
                              onPressed: () {
                                setState(() {
                                  gender = 'female';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      RichText(
                        text: TextSpan(
                          text: "Date of Birth ",
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomDatePicker(
                        isRequired: true,
                        selectedDate: dob,
                        onPick: (pick) {
                          dob = pick;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Emergency Contact
                      RichText(
                        text: TextSpan(
                          text: "Emergency Contact ",
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Emergency Contact Phone",
                        controller: emergencyContactController,
                        validator: phoneNumberValidator,
                        prefixIconData: Icons.emergency,
                      ),
                      const SizedBox(height: 24),

                      // Medical Information Section
                      _buildSectionHeader(context, 'Medical Information'),
                      const SizedBox(height: 16),

                      // Medical History (Optional)
                      Text("Medical History", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Medical History (Optional)",
                        controller: medicalHistoryController,
                        validator: null,
                        prefixIconData: Icons.medical_information,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Chronic Conditions (Optional)
                      Text("Chronic Conditions", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Chronic Conditions (Optional)",
                        controller: chronicConditionController,
                        validator: null,
                        prefixIconData: Icons.healing,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Allergies (Optional)
                      Text("Allergies (especially to medicines)", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Allergies (Optional)",
                        controller: allergiesController,
                        validator: null,
                        prefixIconData: Icons.warning,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Past Surgeries/Hospitalizations (Optional)
                      Text("Past Surgeries/Hospitalizations", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Past Surgeries/Hospitalizations (Optional)",
                        controller: pastSurgeriesController,
                        validator: null,
                        prefixIconData: Icons.local_hospital_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Family History (Optional)
                      Text("Family History", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Family History (Optional)",
                        controller: familyHistoryController,
                        validator: null,
                        prefixIconData: Icons.family_restroom,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Current Medications (Optional)
                      Text("Current Medications", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text(
                        "Format: Drug name, Dosage, Frequency, Duration (e.g., Metformin, 500mg, Twice daily, 6 months)",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Current Medications (Optional)",
                        controller: currentMedicationController,
                        validator: null,
                        prefixIconData: Icons.medication,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Lifestyle (Optional)
                      Text("Lifestyle", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text(
                        "Include alcohol consumption, smoking habits, exercise routine, etc.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Lifestyle (Optional)",
                        controller: lifestyleController,
                        validator: null,
                        prefixIconData: Icons.health_and_safety,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Update Button
                      CustomButton(
                        label: 'Update Profile',
                        inverse: true,
                        isLoading: state is ProfileLoadingState,
                        onPressed: () {
                          if (_formKey.currentState!.validate() && dob != null) {
                            final Map<String, dynamic> data = {
                              'full_name': fullNameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'gender': gender,
                              'dob': dob!.toIso8601String(),
                              'emergency_contact': emergencyContactController.text.trim(),
                              'medical_history': medicalHistoryController.text.trim().isNotEmpty
                                  ? medicalHistoryController.text.trim()
                                  : null,
                              'chronic_condition': chronicConditionController.text.trim().isNotEmpty
                                  ? chronicConditionController.text.trim()
                                  : null,
                              'allergies':
                                  allergiesController.text.trim().isNotEmpty ? allergiesController.text.trim() : null,
                              'past_surgeries': pastSurgeriesController.text.trim().isNotEmpty
                                  ? pastSurgeriesController.text.trim()
                                  : null,
                              'family_history': familyHistoryController.text.trim().isNotEmpty
                                  ? familyHistoryController.text.trim()
                                  : null,
                              'current_medication': currentMedicationController.text.trim().isNotEmpty
                                  ? currentMedicationController.text.trim()
                                  : null,
                              'lifestyle':
                                  lifestyleController.text.trim().isNotEmpty ? lifestyleController.text.trim() : null,
                            };

                            if (profileImage != null) {
                              data['image'] = profileImage;
                              data['image_name'] = profileImage!.path;
                            }

                            BlocProvider.of<ProfileBloc>(context).add(
                              UpdateProfileEvent(data: data),
                            );
                          } else if (dob == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a date of birth'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}
