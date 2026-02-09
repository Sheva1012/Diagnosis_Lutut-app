import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/daftarcedera_service.dart';

class DaftarCederaMasyarakat extends StatefulWidget {
  const DaftarCederaMasyarakat({super.key});

  @override
  State<DaftarCederaMasyarakat> createState() => _DaftarCederaMasyarakatState();
}

class _DaftarCederaMasyarakatState extends State<DaftarCederaMasyarakat> {
  final DaftarCederaService _service = DaftarCederaService();
  
  List<Map<String, dynamic>> _daftarCedera = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _service.getDaftarCedera();
      if (mounted) {
        setState(() {
          _daftarCedera = data;
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
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Daftar Cedera",
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 10),
            Text(_errorMessage, style: GoogleFonts.poppins()),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = "";
                });
                _fetchData();
              },
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    if (_daftarCedera.isEmpty) {
      return Center(
        child: Text("Belum ada data cedera.", style: GoogleFonts.poppins()),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _daftarCedera.length,
      itemBuilder: (context, index) {
        final cedera = _daftarCedera[index];
        return _buildCederaCard(cedera);
      },
    );
  }

  Widget _buildCederaCard(Map<String, dynamic> cedera) {
    // 1. Ambil Nama Cedera
    final String nama = cedera['nama_cedera'] ?? 'Nama Cedera';
    
    // 2. AMBIL DETAIL DARI KOLOM 'deskripsi' (SESUAI GAMBAR DB ANDA)
    final String detail = cedera['deskripsi'] ?? 'Tidak ada deskripsi.';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Placeholder (Kotak dengan silang/icon)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey.shade400),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nama Cedera
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Detail Cedera (Dari kolom deskripsi)
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              children: [
                TextSpan(
                  text: "Detail Cedera : ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}