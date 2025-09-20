// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'routes.dart';

// void checkLogin(BuildContext context) {
//   Future.delayed(
//       const Duration(
//         milliseconds: 100,
//       ), () {
//     User? currentUser = Supabase.instance.client.auth.currentUser;
//     if (!(currentUser != null && (currentUser.appMetadata['role'] == 'employee'))) {
//       Navigator.of(context).pushReplacementNamed(Screens.login);
//     }
//   });
// }
