import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PetVidaApp());
}

class PetVidaApp extends StatelessWidget {
  const PetVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetVida',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.laranjaArdente),
        scaffoldBackgroundColor: AppColors.cremeSuave,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
