import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/login_page.dart';
import 'admin_dashboard.dart';
// import 'admin_kelola_gejala.dart';
// import 'admin_kelola_cedera.dart';
// import 'admin_kelola_basis_aturan.dart';
// import 'admin_kelola_penanganan.dart';
// import 'admin_kelola_pengguna.dart';
// import 'admin_laporan_statistik.dart';

class AdminSidebar extends StatelessWidget {
  final String activePage;

  const AdminSidebar({super.key, required this.activePage});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? "-";

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header Biru
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
            color: const Color(0xFF1E88E5),
            child: Text(
              "Admin Dashboard",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Profil + Menu Icon
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Administrator",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.menu, size: 20),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              children: [
                _menu(context, "Dashboard", Icons.grid_view_rounded, 'dashboard', const AdminDashboard()),
                // _menu(context, "Kelola Data Gejala", Icons.monitor_heart, 'gejala', const AdminKelolaGejala()),
                // _menu(context, "Kelola Data Cedera", Icons.health_and_safety_outlined, 'cedera', const AdminKelolaCedera()),
                // _menu(context, "Basis Aturan & Bobot CF", Icons.percent_rounded, 'aturan', const AdminKelolaBasisAturan()),
                // _menu(context, "Kelola Penanganan", Icons.local_hospital_rounded, 'penanganan', const AdminKelolaPenanganan()),
                // _menu(context, "Kelola Pengguna", Icons.people_alt_rounded, 'pengguna', const AdminKelolaPengguna()),
                // _menu(context, "Laporan & Statistik", Icons.bar_chart_rounded, 'laporan', const AdminLaporanStatistik()),
              ],
            ),
          ),
          
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => _logout(context),
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 10),
                  Text("Logout",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        ],
      ), 
    );
  }

  Widget _menu(BuildContext context, String title, IconData icon,
      String key, Widget? destination) {
    final selected = activePage == key;

    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 26,
        leading: Icon(icon,
            color: selected ? const Color(0xFF1E88E5) : Colors.grey[700], size: 22),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? const Color(0xFF1E88E5) : Colors.black87,
          ),
        ),
        onTap: () {
          if (!selected && destination != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
