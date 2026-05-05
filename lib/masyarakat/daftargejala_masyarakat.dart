import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/daftargejala_service.dart';

class DaftarGejalaMasyarakat extends StatefulWidget {
  const DaftarGejalaMasyarakat({super.key});

  @override
  State<DaftarGejalaMasyarakat> createState() => _DaftarGejalaMasyarakatState();
}

class _DaftarGejalaMasyarakatState extends State<DaftarGejalaMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  final DaftarGejalaService _service = DaftarGejalaService();
  
  List<Map<String, dynamic>> _daftarGejala = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _service.getDaftarGejala();
      if (mounted) {
        setState(() {
          _daftarGejala = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data. Periksa koneksi internet.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Daftar Gejala",
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: GoogleFonts.poppins(color: _muted),
        ),
      );
    }

    if (_daftarGejala.isEmpty) {
      return Center(
        child: Text(
          "Belum ada data gejala.",
          style: GoogleFonts.poppins(color: _muted),
        ),
      );
    }

    // LIST VIEW SESUAI SKETSA
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _daftarGejala.length,
      itemBuilder: (context, index) {
        final gejala = _daftarGejala[index];
        // Pastikan nama kolom di DB Anda 'nama_gejala' atau sesuaikan
        final String namaGejala = gejala['nama_gejala'] ?? 'Gejala';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _ink.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            namaGejala,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        );
      },
    );
  }
}