import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_hospital/sections/sign_up/sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common_widgets/custom_alert_dialog.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_form_field.dart';
import '../../util/value_validators.dart';
import '../home_screen.dart';
import 'login_bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      User? currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null && currentUser.appMetadata['role'] != 'admin') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is LoginFailureState) {
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
                      SizedBox(height: MediaQuery.sizeOf(context).height / 6),
                      Icon(Icons.local_hospital, size: 100, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(
                        'Smart Hospital',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      CustomTextFormField(
                        controller: _emailController,
                        labelText: 'Email',
                        validator: emailValidator,
                        prefixIconData: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _passwordController,
                        isObscure: _obscurePassword,
                        labelText: 'Password',
                        prefixIconData: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: passwordValidator,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        label: 'Sign In',
                        inverse: true,
                        isLoading: state is LoginLoadingState,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginBloc>().add(
                                  LoginEvent(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 26),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Dont have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
