import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/core/common/sight_in_btn.dart';
import '../../../core/constants/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                "Skip",
                style: GoogleFonts.poppins(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Column(children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              Constants.loginEmotePath,
              height: 150,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Dive into the world of Amigo",
            style: GoogleFonts.tajawal(
              fontSize: 55,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 120),
          const SightInBtn(),
          const SizedBox(height: 40),
          Text(
            "By signing in you agree to our user agreement and acknowledge reading our privacy policy ",
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ]));
  }
}
