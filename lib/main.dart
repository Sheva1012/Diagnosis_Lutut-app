import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// 1. Tambahkan import ini
import 'package:intl/date_symbol_data_local.dart'; 

import 'core/supabase_client.dart';
import 'screens/splash_screen.dart';
import 'auth/login_page.dart';
import 'screens/onboarding_screen.dart';
import 'admin/admin_dashboard.dart';
import 'masyarakat/home_masyarakat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // 2. Tambahkan baris ini untuk memuat format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Set status bar agar tidak transparan dan icon terlihat jelas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Pakar Lutut',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(baseTheme.primaryTextTheme),
      ),

      // ⬅️ ENTRY POINT
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminDashboard(),
        '/masyarakat': (context) => const HomeMasyarakat(),
      },
    );
  }
}