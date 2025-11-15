import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:smart_hospital/sections/sign_in/login_screen.dart';
import 'package:smart_hospital/theme/apptheme.dart';
import 'package:smart_hospital/theme/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Gemini
  Gemini.init(apiKey: 'AIzaSyBW8nQqHa6dUFQHSFGQTJDX5af7pQzOnGs');

  await Supabase.initialize(
    url: 'https://ifcksfwmrvraauyqcwde.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmY2tzZndtcnZyYWF1eXFjd2RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1OTQ5MjQsImV4cCI6MjA3MTE3MDkyNH0.DP6i3LCtF_5jwmPEBBoJt5JIaLZtZDz3-iJihD6b6kU',
  );

  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(), child: const SmartHospitalApp()));
}

class SmartHospitalApp extends StatelessWidget {
  const SmartHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hospital',
      // themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: lightMode,
      // darkTheme: darkMode,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
