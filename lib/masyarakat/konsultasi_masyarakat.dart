import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/konsultasi_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KonsultasiMasyarakat extends StatelessWidget {
  const KonsultasiMasyarakat({super.key});

  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _soft = Color(0xFFE7F0FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  @override
  Widget build(BuildContext context) {
    final KonsultasiService service = KonsultasiService();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Konsultasi Lanjutan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
            // 1. INFO CARD ATAS (Warna Cyan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Text(
                "Jika keluhan lutut tidak membaik, disarankan untuk berkonsultasi dengan tenaga medis.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 2. TOMBOL-TOMBOL KONTAK

            // Tombol WhatsApp
            _buildContactButton(
              title: "Hubungi via WhatsApp",
              icon: FontAwesomeIcons.whatsapp, // ✅ ICON ASLI WA
              iconColor: Colors.white,
              iconBgColor: const Color(0xFF25D366), // Hijau resmi WhatsApp
              onTap: () async {
                try {
                  await service.openWhatsApp();
                } catch (e) {
                  _showError(context, "Gagal membuka WhatsApp");
                }
              },
            ),

            const SizedBox(height: 16),

            // Tombol Instagram
            _buildContactButton(
              title: "Hubungi via Instagram",
              icon: FontAwesomeIcons.instagram, // ✅ ICON ASLI IG
              iconColor: Colors.white,
              iconBgColor: const Color(0xFFE1306C), // Pink Instagram
              onTap: () async {
                try {
                  await service.openInstagram();
                } catch (e) {
                  _showError(context, "Gagal membuka Instagram");
                }
              },
            ),

            const SizedBox(height: 16),

            // Tombol Telepon
            _buildContactButton(
              title: "Telepon Klinik",
              icon: Icons.phone, // Icon Telepon
              iconColor: Colors.white,
              iconBgColor: Colors.red, // Warna Merah
              onTap: () async {
                try {
                  await service.callClinic();
                } catch (e) {
                  _showError(context, "Gagal melakukan panggilan");
                }
              },
            ),

            const SizedBox(height: 16),

            // Tombol Lokasi
            _buildContactButton(
              title: "Lokasi Klinik / Praktik",
              icon: Icons.location_on, // Icon Lokasi
              iconColor: Colors.white,
              iconBgColor: Colors.orangeAccent, // Warna Kuning/Orange
              onTap: () async {
                try {
                  await service.openMaps();
                } catch (e) {
                  _showError(context, "Gagal membuka Peta");
                }
              },
            ),

            const SizedBox(height: 30),

            // 3. DISCLAIMER BAWAH (Warna Cyan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Text(
                "Informasi ini bersifat rekomendasi dan tidak menggantikan pemeriksaan langsung oleh tenaga medis.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: _muted),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk menampilkan error snackbar
  void _showError(BuildContext context, String message) {
    Fluttertoast.showToast(
          msg: "Terjadi kesalahan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
  }

  // Widget Tombol Kontak Reusable
  Widget _buildContactButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background tombol putih
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon Bulat
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Teks Tombol
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
