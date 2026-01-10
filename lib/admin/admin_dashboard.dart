import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
// import 'admin_kelola_gejala.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Widget _card(BuildContext context, String title, String value, IconData icon, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1E88E5)),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
      drawer: const AdminSidebar(activePage: 'dashboard'),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selamat Datang, Admin", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Sistem Pakar Diagnosis Cedera Lutut", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Grid Stats
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.3,
                children: [
                  _card(context, "Total Pengguna", "120", Icons.people, null),
                  _card(context, "Total Diagnosis", "340", Icons.medical_services, null),
                  _card(context, "Total Gejala", "25", Icons.monitor_heart, null),
                  _card(context, "Total Cedera", "6", Icons.healing, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}