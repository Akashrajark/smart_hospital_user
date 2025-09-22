import 'package:flutter/material.dart';
import 'package:smart_hospital/sections/appoinment/appointments_screen.dart';
import 'package:smart_hospital/sections/appoinment/doctor_appointments.dart';
import 'package:smart_hospital/sections/doctors/doctor_profile.dart';
import 'package:smart_hospital/sections/doctors/doctors_screen.dart';
import 'package:smart_hospital/util/format_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common_widgets/custom_alert_dialog.dart';
import 'profile/profile_screen.dart';
import 'sign_in/login_screen.dart';
import '../common_widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      User? currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Hospital',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: Colors.grey.withAlpha(100), height: 1.0),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Logout',
                  description: 'Are you sure you want to logout?',
                  primaryButton: 'Yes',
                  secondaryButton: 'No',
                  onPrimaryPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          if (isDoctor()) DoctorAppointments() else DoctorsScreen(),
          if (!isDoctor()) AppointmentsScreen(),
          if (isDoctor()) DoctorProfile() else ProfileScreen()
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: _currentIndex, onTap: _onNavTap),
    );
  }
}
