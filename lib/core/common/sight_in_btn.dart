import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/core/constants/constants.dart';

class SightInBtn extends StatelessWidget {
  const SightInBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {},
        icon: Image.asset(Constants.googlePath, height: 60, width: 100),
        label: Text("Sign in with Google ",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            )));
  }
}
