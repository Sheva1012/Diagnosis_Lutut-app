import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/login_page.dart';
import 'admin_theme.dart';
import 'admin_dashboard.dart';
import 'admin_kelola_gejala.dart';
import 'admin_kelola_cedera.dart';
import 'admin_kelola_basis_aturan.dart';
import 'admin_kelola_penanganan.dart';
import 'admin_kelola_pengguna.dart';
import 'admin_laporan_statistik.dart';
import 'admin_profile.dart';

class AdminSidebar extends StatelessWidget {
  final String activePage;

  const AdminSidebar({super.key, required this.activePage});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Konfirmasi Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text("Apakah Anda yakin ingin keluar?", style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Tidak", style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Ya", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

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
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "-";
    final userId = user?.id;

    return Drawer(
      backgroundColor: AdminTheme.bg,
      child: Column(
        children: [
          // 🔵 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
            decoration: const BoxDecoration(gradient: AdminTheme.appBarGradient),
            child: Text(
              "Menu Admin",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 🔥 PROFIL (SUDAH BISA DIKLIK)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfile()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
              child: Row(
                children: [
                  // 🔥 AVATAR + USERNAME (GABUNG)
                  Expanded(
                    child: StreamBuilder(
                      stream: Supabase.instance.client
                          .from('users')
                          .stream(primaryKey: ['id_user'])
                          .eq('id_user', userId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading...");
                        }

                        if (snapshot.data!.isEmpty) {
                          return const Text("User Not Found");
                        }

                        final data = snapshot.data!.first;
                        final username = data['username'] ?? "Administrator";
                        final avatar = data['foto_profil'];

                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: avatar != null && avatar.toString().isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar == null
                                  ? const Icon(Icons.person, size: 22)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AdminTheme.ink,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF8A6E5B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AdminTheme.ink,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: AdminTheme.stroke),

          // 📋 MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              children: [
                _menu(
                  context,
                  "Dashboard",
                  Icons.grid_view_rounded,
                  'dashboard',
                  const AdminDashboard(),
                ),
                _menu(
                  context,
                  "Kelola Data Gejala",
                  Icons.monitor_heart,
                  'gejala',
                  const AdminKelolaGejala(),
                ),
                _menu(
                  context,
                  "Kelola Data Cedera",
                  Icons.health_and_safety_outlined,
                  'cedera',
                  const AdminKelolaCedera(),
                ),
                _menu(
                  context,
                  "Basis Aturan & Bobot CF",
                  Icons.percent_rounded,
                  'aturan',
                  const AdminKelolaBasisAturan(),
                ),
                _menu(
                  context,
                  "Kelola Penanganan",
                  Icons.local_hospital_rounded,
                  'penanganan',
                  const AdminKelolaPenanganan(),
                ),
                _menu(
                  context,
                  "Kelola Pengguna",
                  Icons.people_alt_rounded,
                  'pengguna',
                  const AdminKelolaPengguna(),
                ),
                _menu(
                  context,
                  "Laporan & Statistik",
                  Icons.bar_chart_rounded,
                  'laporan',
                  const AdminLaporanStatistik(),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AdminTheme.stroke),

          // 🔴 LOGOUT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: InkWell(
                onTap: () => _logout(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AdminTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20, color: AdminTheme.danger),
                      const SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AdminTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    String title,
    IconData icon,
    String key,
    Widget? destination,
  ) {
    final selected = activePage == key;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AdminTheme.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 26,
        leading: Icon(
          icon,
          color: selected ? AdminTheme.primary : const Color(0xFF8A6E5B),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AdminTheme.primaryDark : AdminTheme.ink,
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
