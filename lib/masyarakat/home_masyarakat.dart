import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

class HomeMasyarakat extends StatefulWidget {
  const HomeMasyarakat({super.key});

  @override
  State<HomeMasyarakat> createState() => _HomeMasyarakatState();
}

class _HomeMasyarakatState extends State<HomeMasyarakat> {
  int _selectedIndex = 0; // 0 = Home, 1 = Profil

  // Fungsi Logout
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Tampilan Halaman Home (Tab 1)
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Biru
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, User 👋", // Nanti bisa diganti nama asli dari DB
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text("Yuk cek kondisi lutut Anda hari ini", style: GoogleFonts.poppins()),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Banner Mulai Diagnosis
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "Mulai Diagnosis",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Jawab pertanyaan untuk mengetahui kondisi lutut Anda",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Arahkan ke halaman Pertanyaan Diagnosis (Sprint 5)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Diagnosis (Sprint 5)")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Mulai"),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _menuCard("Daftar Cedera", Icons.healing),
              _menuCard("Daftar Gejala", Icons.monitor_heart),
              _menuCard("Edukasi", Icons.menu_book),
              _menuCard("Konsultasi", Icons.support_agent),
            ],
          ),
        ],
      ),
    );
  }

  // Tampilan Halaman Profil (Tab 2)
  Widget _buildProfilePage() {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "User";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(email, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text("Masyarakat"),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Keluar Akun"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 
          ? AppBar(title: const Text("Beranda"), backgroundColor: Colors.blue, foregroundColor: Colors.white)
          : null, // Profil tidak butuh AppBar standar
      
      // Ganti body berdasarkan tab yang dipilih
      body: _selectedIndex == 0 ? _buildHomePage() : _buildProfilePage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}