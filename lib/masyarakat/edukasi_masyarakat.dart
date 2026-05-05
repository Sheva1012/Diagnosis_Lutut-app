import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/edukasi_service.dart';

class EdukasiMasyarakat extends StatefulWidget {
  const EdukasiMasyarakat({super.key});

  @override
  State<EdukasiMasyarakat> createState() => _EdukasiMasyarakatState();
}

class _EdukasiMasyarakatState extends State<EdukasiMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _primary = Color(0xFF2F6FDB);
  static const Color _soft = Color(0xFFE7F0FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Edukasi Cedera Lutut",
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
        child: _isLoading
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
                          color: _primary
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kenali Cedera Lutut",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Informasi umum untuk menjaga\nkesehatan lutut Anda",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _muted,
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
                      color: _soft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Text(
                      "Informasi ini bersifat edukatif dan tidak menggantikan pemeriksaan tenaga medis.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ],
                ),
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
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.05),
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
              color: _ink,
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
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['content'],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _muted,
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