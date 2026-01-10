import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding_screen.dart'; 
// Import Halaman Tujuan
import '../admin/admin_dashboard.dart';
import '../masyarakat/home_masyarakat.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    // 1. Jika BELUM login -> Ke Onboarding
    if (session == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    // 2. Jika SUDAH login -> Cek Role di Database
    try {
      final userId = session.user.id;
      final userData = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', userId)
          .maybeSingle(); // Gunakan maybeSingle agar tidak crash jika data kosong

      // Default ke Masyarakat jika role null/error
      final role = userData != null ? userData['role'] : 'Masyarakat';

      if (!mounted) return;

      if (role == 'Admin') {
        // Arahkan ke Dashboard Admin
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const AdminDashboard())
        );
      } else {
        // Arahkan ke Home Masyarakat
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const HomeMasyarakat())
        );
      }
    } catch (e) {
      // Jika terjadi error (misal data user terhapus di DB tapi sesi di HP masih ada)
      // Paksa Logout dan kembali ke Onboarding
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              "Knee Expert",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Diagnosis Cedera Lutut Mandiri",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}