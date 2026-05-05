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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.93, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.58;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE6F0FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -60,
              child: Container(
                width: 230,
                height: 230,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x22E07A2A),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x221B7C8A),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: logoSize,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 26,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo-kmc.jpg',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Knee Check',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F4A56),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Diagnosis Cedera Lutut Mandiri',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: const Color(0xFF325E67),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 34),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          color: Color(0xFFE07A2A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}