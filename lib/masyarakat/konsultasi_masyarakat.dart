import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/konsultasi_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KonsultasiMasyarakat extends StatelessWidget {
  const KonsultasiMasyarakat({super.key});

  @override
  Widget build(BuildContext context) {
    final KonsultasiService service = KonsultasiService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background abu sangat muda
      appBar: AppBar(
        title: Text(
          "Konsultasi Lanjutan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. INFO CARD ATAS (Warna Cyan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.shade100, // Warna Cyan cerah
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Jika keluhan lutut tidak membaik, disarankan untuk berkonsultasi dengan tenaga medis.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
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
                color: Colors.cyanAccent.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Informasi ini bersifat rekomendasi dan tidak menggantikan pemeriksaan langsung oleh tenaga medis.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk menampilkan error snackbar
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
                      color: const Color(0xFF2D3142),
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
