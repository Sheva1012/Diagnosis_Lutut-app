import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart'; // PENTING: Import halaman login yang baru dibuat

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Diagnosis Mandiri",
      "desc": "Cek kondisi cedera lutut Anda secara cepat dan nyaman dari rumah tanpa perlu antri.",
      "icon": Icons.health_and_safety_rounded,
      "color": const Color(0xFF4A90E2),
    },
    {
      "title": "Metode Terpercaya",
      "desc": "Menggunakan metode pakar untuk memberikan hasil analisis yang terpercaya dan akurat.",
      "icon": Icons.analytics_rounded,
      "color": const Color(0xFF50E3C2),
    },
    {
      "title": "Saran Penanganan",
      "desc": "Dapatkan rekomendasi penanganan awal dan lanjutan yang tepat untuk memulihkan cedera Anda.",
      "icon": Icons.healing_rounded,
      "color": const Color(0xFFF5A623),
    },
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative Background Blob 1
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: _currentPage == 1 ? -50 : -100,
            right: _currentPage == 2 ? 0 : -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage]['color'].withOpacity(0.08),
              ),
            ),
          ),
          // Decorative Background Blob 2
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: _currentPage == 0 ? -50 : -100,
            left: _currentPage == 1 ? -100 : -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage]['color'].withOpacity(0.08),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Header (Skip Button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        child: const Text("Lewati"),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon Container with Hero Animation feeling
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutQuint,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: _pages[index]['color'].withOpacity(0.12),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _pages[index]['color'].withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _pages[index]['icon'],
                                size: 110,
                                color: _pages[index]['color'],
                              ),
                            ),
                            const SizedBox(height: 70),
                            Text(
                              _pages[index]['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _pages[index]['desc'],
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: const Color(0xFF9094A6),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? _pages[_currentPage]['color'] 
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Custom Next/Start Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: _currentPage == _pages.length - 1 ? 160 : 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _pages[_currentPage]['color'],
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage]['color'].withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(32),
                            onTap: () {
                              if (_currentPage == _pages.length - 1) {
                                _goToLogin();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutQuint,
                                );
                              }
                            },
                            child: Center(
                              child: _currentPage == _pages.length - 1
                                  ? Text(
                                      "Mulai Sekarang",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}