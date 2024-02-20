import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/core/common/sight_in_btn.dart';
import 'package:untitled/responsive/responsive.dart';

import '../../../core/constants/constants.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  void signInAsGuest(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () {
                    signInAsGuest(context, ref);
                  },
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
            body: isLoading
                ? const Loader()
                : Column(children: [
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
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 100),
                    const Responsive(child: SightInBtn()),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "By signing in you agree to our user agreement and acknowledge reading our privacy policy ",
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]));
  }
}
