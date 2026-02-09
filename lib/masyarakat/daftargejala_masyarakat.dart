import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/daftargejala_service.dart';

class DaftarGejalaMasyarakat extends StatefulWidget {
  const DaftarGejalaMasyarakat({super.key});

  @override
  State<DaftarGejalaMasyarakat> createState() => _DaftarGejalaMasyarakatState();
}

class _DaftarGejalaMasyarakatState extends State<DaftarGejalaMasyarakat> {
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
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text(
          "Daftar Gejala",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: GoogleFonts.poppins()));
    }

    if (_daftarGejala.isEmpty) {
      return Center(child: Text("Belum ada data gejala.", style: GoogleFonts.poppins()));
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
            color: Colors.grey.shade200, // Warna kotak abu-abu muda sesuai sketsa
            borderRadius: BorderRadius.circular(8), // Sudut sedikit membulat
          ),
          child: Text(
            namaGejala,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }
}