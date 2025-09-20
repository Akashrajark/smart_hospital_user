import 'package:flutter/material.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  late List<Map<String, dynamic>> patients;
  List<Map<String, dynamic>> filteredPatients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          //   child: CustomSearchFilter(theme: Theme.of(context), searchController: _searchController),
          // ),
        ],
      ),
    );
  }
}
