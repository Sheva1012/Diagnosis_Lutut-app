import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BantuanMasyarakat extends StatelessWidget {
  const BantuanMasyarakat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background abu sangat muda
      appBar: AppBar(
        title: Text(
          "Bantuan & Tentang",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER LOGO APLIKASI ---
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Icon(Icons.health_and_safety, size: 40, color: Colors.blue.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sistem Pakar Lutut",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142)),
                  ),
                  Text(
                    "Versi 1.0.0",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- SECTION 1: FAQ (PERTANYAAN UMUM) ---
            _buildSectionTitle("Pertanyaan Umum"),
            const SizedBox(height: 10),

            _buildFAQItem(
              "Bagaimana cara melakukan diagnosis?",
              "Masuk ke halaman Beranda, lalu tekan tombol 'Mulai Diagnosis'. Jawab serangkaian pertanyaan mengenai gejala yang Anda alami hingga selesai.",
            ),
            _buildFAQItem(
              "Apakah hasil diagnosis ini akurat?",
              "Sistem ini menggunakan metode Certainty Factor berdasarkan pengetahuan pakar. Namun, hasil ini hanya sebagai rujukan awal dan TIDAK menggantikan diagnosis dokter secara langsung.",
            ),
            _buildFAQItem(
              "Bagaimana cara mengubah data profil?",
              "Pergi ke menu 'Profil' di navigasi bawah, lalu pilih menu 'Edit Profil'. Anda dapat mengubah Nama Lengkap dan Nomor HP.",
            ),
            _buildFAQItem(
              "Aplikasi mengalami error/blank?",
              "Pastikan koneksi internet Anda stabil. Jika masalah berlanjut, coba tutup aplikasi dan buka kembali, atau hubungi admin.",
            ),

            const SizedBox(height: 25),

            // --- SECTION 2: TENTANG APLIKASI ---
            _buildSectionTitle("Tentang Aplikasi"),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deskripsi",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Aplikasi ini dirancang untuk membantu masyarakat mendeteksi dini jenis cedera lutut berdasarkan gejala yang dirasakan. Aplikasi ini juga menyediakan informasi edukasi dan rekomendasi penanganan awal.",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const Divider(height: 30),
                  Text(
                    "Dikembangkan Oleh",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Mahasiswa Manajemen Informatika Politeknik Negeri Malang",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer Copyright
            Text(
              "© 2025 Sistem Pakar Lutut. All Rights Reserved.",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Judul Section
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3142),
        ),
      ),
    );
  }

  // Widget Item FAQ (Accordion)
  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}