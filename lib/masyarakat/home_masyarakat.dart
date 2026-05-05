import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profil_masyarakat.dart';
import 'daftarcedera_masyarakat.dart';
import 'daftargejala_masyarakat.dart';
import 'edukasi_masyarakat.dart';
import 'konsultasi_masyarakat.dart';
import 'diagnosis_masyarakat.dart'; // <--- JANGAN LUPA IMPORT INI
import '../services/masyarakat/home_service.dart';

class HomeMasyarakat extends StatefulWidget {
  const HomeMasyarakat({super.key});

  @override
  State<HomeMasyarakat> createState() => _HomeMasyarakatState();
}

class _HomeMasyarakatState extends State<HomeMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _teal = Color(0xFF2F6FDB);
  static const Color _tealSoft = Color(0xFFE7F0FF);
  static const Color _amber = Color(0xFF4B7FD8);
  static const Color _amberSoft = Color(0xFFE6EEFF);
  static const Color _rose = Color(0xFF305FD1);
  static const Color _roseSoft = Color(0xFFE7EDFF);
  static const Color _sage = Color(0xFF2B72B8);
  static const Color _sageSoft = Color(0xFFE4F1FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);
  static const Color _navBg = Color(0xFFFFFFFF);

  int _selectedIndex = 0;
  final HomeService _homeService = HomeService();
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _homeService.getCurrentUserName();
    if (mounted) {
      setState(() => _userName = name);
    }
  }

  // ===================== HOME PAGE =====================
  Widget _buildHomePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF5F8FF),
            Color(0xFFEAF1FF),
            Color(0xFFF9FBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ================= HEADER (FIXED) =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: _bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Halo, $_userName",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Yuk cek kondisi lutut Anda hari ini",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT (SCROLL) =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                  // ================= BANNER =================
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_ink, _teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Mulai Diagnosis",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Jawab pertanyaan singkat untuk mengetahui kondisi lutut Anda.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // --- NAVIGASI KE HALAMAN DIAGNOSIS ---
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DiagnosisMasyarakat(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDF9F3),
                              foregroundColor: _ink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: BorderSide(color: _border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Mulai Sekarang",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= TITLE =================
                  Text(
                    "Layanan Utama",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= MENU GRID =================
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    children: [
                      _menuCard(
                        "Daftar Cedera",
                        Icons.healing_rounded,
                        _amberSoft,
                        _amber,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DaftarCederaMasyarakat(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        "Daftar Gejala",
                        Icons.monitor_heart_rounded,
                        _roseSoft,
                        _rose,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DaftarGejalaMasyarakat(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        "Edukasi",
                        Icons.menu_book_rounded,
                        _sageSoft,
                        _sage,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EdukasiMasyarakat(),
                            ),
                          );
                        },
                      ),
                      _menuCard(
                        "Konsultasi",
                        Icons.support_agent_rounded,
                        _tealSoft,
                        _teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const KonsultasiMasyarakat(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENU CARD =================
  Widget _menuCard(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: _selectedIndex == 0 ? _buildHomePage() : const ProfilMasyarakat(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: _navBg,
          elevation: 10,
          selectedItemColor: _teal,
          unselectedItemColor: _muted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}