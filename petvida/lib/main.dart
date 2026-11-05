import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SyncService.instance.initialize();
  await NotificationService.instance.initialize();
  runApp(const PetVidaApp());
}

class PetVidaApp extends StatelessWidget {
  const PetVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sessão já salva abre direto na tela inicial, mantendo a função
    // principal em 3 toques: Abrir > Tocar no pet > "Adicionar Vacina".
    final logado = FirebaseAuth.instance.currentUser != null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetVida',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.laranjaArdente),
        scaffoldBackgroundColor: AppColors.cremeSuave,
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: logado ? const HomeScreen() : const LoginScreen(),
    );
  }
}
