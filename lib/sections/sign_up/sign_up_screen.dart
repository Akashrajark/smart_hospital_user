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
import '../sign_in/login_screen.dart';
import 'sign_up_bloc/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  File? profileImage;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
      create: (context) => SignUpBloc(),
      child: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
            // Show success message
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                  title: 'Success',
                  description: 'Account created successfully! Please check your email to verify your account.',
                  primaryButton: 'Ok'),
            );
          } else if (state is SignUpFailureState) {
            showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(title: 'Failed', description: state.message, primaryButton: 'Ok'),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height / 17),
                      Icon(Icons.local_hospital, size: 80, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(
                        'Smart Hospital',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Create Patient Account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Text("Profile Picture", style: Theme.of(context).textTheme.bodyLarge),

                      const SizedBox(height: 8),
                      // Profile Image
                      CustomImagePickerButton(
                        onPick: (pick) {
                          profileImage = pick;
                        },
                      ),
                      const SizedBox(height: 24),

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

                      // Email
                      RichText(
                        text: TextSpan(
                          text: "Email ",
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
                        labelText: "Email",
                        controller: emailController,
                        validator: emailValidator,
                        prefixIconData: Icons.email,
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

                      // Password
                      RichText(
                        text: TextSpan(
                          text: "Password ",
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
                        labelText: "Password",
                        controller: passwordController,
                        validator: passwordValidator,
                        isObscure: _obscurePassword,
                        prefixIconData: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      RichText(
                        text: TextSpan(
                          text: "Confirm Password ",
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
                        labelText: "Confirm Password",
                        controller: confirmPasswordController,
                        validator: (value) => confirmPasswordValidator(value, passwordController.text),
                        isObscure: _obscureConfirmPassword,
                        prefixIconData: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
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
                      const SizedBox(height: 16),

                      // Optional Fields Section Divider
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Optional Medical Information',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                          ],
                        ),
                      ),

                      // Medical History (Optional)
                      Text("Medical History", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Medical History (Optional)",
                        controller: medicalHistoryController,
                        validator: null, // Optional field
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
                        validator: null, // Optional field
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
                        validator: null, // Optional field
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
                        validator: null, // Optional field
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
                        validator: null, // Optional field
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
                        validator: null, // Optional field
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
                        validator: null, // Optional field
                        prefixIconData: Icons.health_and_safety,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Sign Up Button
                      CustomButton(
                        label: 'Create Account',
                        inverse: true,
                        isLoading: state is SignUpLoadingState,
                        onPressed: () {
                          if (_formKey.currentState!.validate() && dob != null) {
                            final Map<String, dynamic> data = {
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                              'fullName': fullNameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'gender': gender,
                              'dateOfBirth': dob!.toIso8601String(),
                              'emergencyContact': emergencyContactController.text.trim(),
                              'medicalHistory': medicalHistoryController.text.trim().isNotEmpty
                                  ? medicalHistoryController.text.trim()
                                  : null,
                              'chronicCondition': chronicConditionController.text.trim().isNotEmpty
                                  ? chronicConditionController.text.trim()
                                  : null,
                              'allergies':
                                  allergiesController.text.trim().isNotEmpty ? allergiesController.text.trim() : null,
                              'pastSurgeries': pastSurgeriesController.text.trim().isNotEmpty
                                  ? pastSurgeriesController.text.trim()
                                  : null,
                              'familyHistory': familyHistoryController.text.trim().isNotEmpty
                                  ? familyHistoryController.text.trim()
                                  : null,
                              'currentMedication': currentMedicationController.text.trim().isNotEmpty
                                  ? currentMedicationController.text.trim()
                                  : null,
                              'lifestyle':
                                  lifestyleController.text.trim().isNotEmpty ? lifestyleController.text.trim() : null,
                            };
                            if (profileImage != null) {
                              data['image'] = profileImage;
                              data['image_name'] = profileImage!.path;
                            }
                            BlocProvider.of<SignUpBloc>(context).add(
                              SignUpEvent(data: data),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
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
}
