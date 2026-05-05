import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _primary = Color(0xFF2F6FDB);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

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
      Fluttertoast.showToast(
          msg: "Belum ada foto profil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin logout?',
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
              'Logout',
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
      backgroundColor: _bg,
      body: Container(
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
                      border: Border.all(color: _border, width: 2),
                      image: _fotoProfil.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_fotoProfil),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _fotoProfil.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 45,
                            color: _primary,
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
                    color: _ink,
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
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    "Masyarakat",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- BAGIAN INFORMASI AKUN ---
                _buildInfoRow(Icons.badge_outlined, "Nama Lengkap", _namaAsli),
                Divider(height: 24, color: _border),

                _buildInfoRow(Icons.phone_android_rounded, "Nomor HP", _noHP),
                Divider(height: 24, color: _border),

                _buildInfoRow(Icons.email_outlined, "Email", _email),
                Divider(height: 24, color: _border),

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
                          "Logout",
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
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _ink.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: _primary, size: 20),
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
                  color: _muted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _ink,
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
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _ink.withOpacity(0.04),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: _muted, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
