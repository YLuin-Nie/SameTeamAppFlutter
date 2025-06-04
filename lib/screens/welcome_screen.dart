import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_switch.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final logo = themeProvider.isDarkMode ? 'assets/logodark.png' : 'assets/logo.png';

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // 🌄 App logo
                      Image.asset(
                        logo,
                        height: 200,
                      ),

                      const SizedBox(height: 40),

                      // 🔐 Sign In button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(userId: 0),
                              ),
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🆕 Sign Up button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),
                // 🌞 ↔️ 🌙 Theme Toggle in Top-Right
                const Positioned(
                  top: 16,
                  right: 16,
                  child: ThemeToggleSwitch(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
