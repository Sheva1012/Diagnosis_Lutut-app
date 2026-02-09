import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/edukasi_service.dart';

class EdukasiMasyarakat extends StatefulWidget {
  const EdukasiMasyarakat({super.key});

  @override
  State<EdukasiMasyarakat> createState() => _EdukasiMasyarakatState();
}

class _EdukasiMasyarakatState extends State<EdukasiMasyarakat> {
  final EdukasiService _service = EdukasiService();
  List<Map<String, dynamic>> _dataEdukasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getEdukasiList();
    if (mounted) {
      setState(() {
        _dataEdukasi = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Edukasi Cedera Lutut",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // HEADER GAMBAR & JUDUL
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.health_and_safety_outlined, 
                          size: 80, 
                          color: Colors.blue.shade300
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kenali Cedera Lutut",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Informasi umum untuk menjaga\nkesehatan lutut Anda",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // LIST ITEM (ACCORDION)
                  ..._dataEdukasi.map((item) => _buildEdukasiItem(item)),

                  const SizedBox(height: 20),

                  // DISCLAIMER BAWAH
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Informasi ini bersifat edukatif dan tidak menggantikan pemeriksaan tenaga medis.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEdukasiItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        // Menghilangkan garis border bawaan ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], color: item['color']),
          ),
          title: Text(
            item['title'],
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          // ISI KONTEN KETIKA DIKLIK
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['content'],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.6, // Spasi antar baris biar enak dibaca
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}