import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/core/constants/constants.dart';

import '../../features/auth/controller/auth_controller.dart';

class SightInBtn extends ConsumerWidget {
  const SightInBtn({super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(Constants.googlePath, height: 60, width: 100),
        label: Text("Sign in with Google ",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            )));
  }
}
