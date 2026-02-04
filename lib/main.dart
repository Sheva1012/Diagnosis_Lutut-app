import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Pakar Lutut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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