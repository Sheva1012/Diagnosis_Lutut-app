import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';
import '../services/masyarakat/profile_service.dart';
import 'edit_profil_masyarakat.dart';
import 'bantuan_masyarakat.dart';
import 'riwayat_masyarakat.dart';

class ProfilMasyarakat extends StatefulWidget {
  const ProfilMasyarakat({super.key});

  @override
  State<ProfilMasyarakat> createState() => _ProfilMasyarakatState();
}

class _ProfilMasyarakatState extends State<ProfilMasyarakat> {
  final ProfileService _profileService = ProfileService();

  String _headerName = "Memuat...";
  String _namaAsli = "-";
  String _email = "-";
  String _noHP = "-";
  String _tanggalBergabung = "-";
  String _fotoProfil = ""; // Pastikan variabel ini ada

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _profileService.getUserProfile();
    if (mounted) {
      setState(() {
        _headerName = data['header_name']!;
        _namaAsli = data['nama_asli']!;
        _email = data['email']!;
        _noHP = data['no_hp']!;
        _tanggalBergabung = data['joined_at']!;
        _fotoProfil = data['foto_profil'] ?? "";
      });
    }
  }

  // --- FUNGSI BARU: LIHAT FOTO POP-UP ---
  void _viewPhoto() {
    if (_fotoProfil.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Belum ada foto profil")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan klik di luar gambar
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Background dialog transparan
          insetPadding: const EdgeInsets.all(10), // Jarak dari tepi layar
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. GAMBAR UTAMA (BISA DI-ZOOM)
              InteractiveViewer(
                panEnabled: true, // Bisa digeser
                minScale: 0.5,
                maxScale: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black, // Background hitam di belakang gambar
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_fotoProfil, fit: BoxFit.contain),
                  ),
                ),
              ),

              // 2. TOMBOL CLOSE (SILANG) DI POJOK KANAN ATAS GAMBAR
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    // ... (Kode Logout Tetap Sama) ...
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar Akun',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _profileService.logout();
      if (mounted)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // --- AVATAR (DIBUNGKUS GESTURE DETECTOR) ---
                GestureDetector(
                  onTap: _viewPhoto, // PANGGIL FUNGSI LIHAT FOTO
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                      image: _fotoProfil.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_fotoProfil),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _fotoProfil.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.blue.shade400,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                // Judul Besar
                Text(
                  _headerName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),

                const SizedBox(height: 2),

                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    "Masyarakat",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- BAGIAN INFORMASI AKUN ---
                _buildInfoRow(Icons.badge_outlined, "Nama Lengkap", _namaAsli),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(Icons.phone_android_rounded, "Nomor HP", _noHP),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(Icons.email_outlined, "Email", _email),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  "Tanggal Bergabung",
                  _tanggalBergabung,
                ),

                const SizedBox(height: 25),

                // --- MENU MENU ---
                _buildMenuTile(
                  icon: Icons.edit_outlined,
                  title: "Edit Profil",
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilMasyarakat(
                          currentName: _namaAsli,
                          currentPhone: _noHP,
                          currentEmail: _email,
                          currentPhotoUrl:
                              _fotoProfil, // Kirim URL foto ke edit
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadUserData();
                    }
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuTile(
                  icon: Icons.history_rounded,
                  title: "Riwayat Diagnosis",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RiwayatMasyarakat(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: "Bantuan & Tentang",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BantuanMasyarakat(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Tombol Keluar
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Keluar Akun",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.blue.shade600, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.03),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3142),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
