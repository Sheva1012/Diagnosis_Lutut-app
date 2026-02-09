import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HasilDiagnosisMasyarakat extends StatelessWidget {
  final String namaCedera;
  final String penangananAwal;   // Parameter Baru
  final String penangananLanjut; // Parameter Baru
  final double persentase;
  final double nilaiCf;
  final String tingkatKepastian;

  const HasilDiagnosisMasyarakat({
    super.key,
    required this.namaCedera,
    required this.penangananAwal,
    required this.penangananLanjut,
    required this.persentase,
    required this.nilaiCf,
    required this.tingkatKepastian,
  });

  // Helper untuk memecah text jadi list poin
  List<String> _parsePoin(String text) {
    if (text.trim().isEmpty || text == '-') return [];
    return text.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAwal = _parsePoin(penangananAwal);
    final listLanjut = _parsePoin(penangananLanjut);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Hasil Diagnosis",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ================= KARTU HASIL =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Icon(Icons.health_and_safety_outlined, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    "Kemungkinan Cedera",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    namaCedera,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF2D3142)
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Badge Persentase
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$tingkatKepastian (${persentase.toStringAsFixed(0)}%)",
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        color: Colors.white, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Judul Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saran Penanganan",
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF2D3142)
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ================= 1. PENANGANAN AWAL =================
            _buildPenangananCard(
              title: "Penanganan Awal (Pertolongan Pertama)",
              icon: Icons.medical_services_outlined,
              colorTheme: Colors.green,
              items: listAwal,
              emptyText: "Tidak ada penanganan awal khusus.",
            ),

            const SizedBox(height: 16),

            // ================= 2. PENANGANAN LANJUT =================
            _buildPenangananCard(
              title: "Penanganan Lanjut / Medis",
              icon: Icons.local_hospital_outlined,
              colorTheme: Colors.orange,
              items: listLanjut,
              emptyText: "Segera konsultasikan ke dokter untuk penanganan lebih lanjut.",
            ),

            const SizedBox(height: 30),

            // ================= DISCLAIMER =================
            Text(
              "Catatan: Hasil ini hanya prediksi sistem pakar. Segera hubungi dokter spesialis ortopedi untuk diagnosis medis yang akurat.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Selesai", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Penanganan
  Widget _buildPenangananCard({
    required String title,
    required IconData icon,
    required Color colorTheme,
    required List<String> items,
    required String emptyText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorTheme, size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              emptyText,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            )
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 6, color: colorTheme),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800, height: 1.5),
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }
}