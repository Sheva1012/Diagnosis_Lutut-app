import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/daftarcedera_service.dart';

class DaftarCederaMasyarakat extends StatefulWidget {
  const DaftarCederaMasyarakat({super.key});

  @override
  State<DaftarCederaMasyarakat> createState() => _DaftarCederaMasyarakatState();
}

class _DaftarCederaMasyarakatState extends State<DaftarCederaMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _teal = Color(0xFF2F6FDB);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  final DaftarCederaService _service = DaftarCederaService();
  
  List<Map<String, dynamic>> _daftarCedera = [];
  bool _isLoading = true;
  String _errorMessage = "";

  static const Map<String, String> _imageByCederaKeyword = {
    'acl': 'assets/images/ACL.jpg',
    'pcl': 'assets/images/PCL.jpg',
    'mcl': 'assets/images/MCL.jpg',
    'lcl': 'assets/images/LCL.jpg',
    'meniscus': 'assets/images/MENISCUS.jpg',
    'meniskus': 'assets/images/MENISCUS.jpg',
  };

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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Daftar Cedera",
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

    final String? imageAsset = _resolveCederaImageAsset(nama);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCederaImage(imageAsset, title: nama),
          
          const SizedBox(height: 16),
          
          // Nama Cedera
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Detail Cedera (Dari kolom deskripsi)
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 13, color: _muted, height: 1.5),
              children: [
                TextSpan(
                  text: "Detail Cedera : ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _teal),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveCederaImageAsset(String namaCedera) {
    final normalized = namaCedera.toLowerCase();

    for (final entry in _imageByCederaKeyword.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  Widget _buildCederaImage(String? imageAsset, {required String title}) {
    final imageWidget = Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: imageAsset == null
          ? Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 50,
                color: _muted,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                      color: _muted,
                    ),
                  );
                },
              ),
            ),
    );

    if (imageAsset == null) {
      return imageWidget;
    }

    return InkWell(
      onTap: () => _showImagePopup(imageAsset, title: title),
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  void _showImagePopup(String imageAsset, {required String title}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final screenSize = MediaQuery.of(dialogContext).size;
        final double maxByWidth = screenSize.width - 72.0;
        final double maxByHeight = screenSize.height - 220.0;
        final double boxSize = math
            .max(
              200.0,
              math.min(
                maxByWidth,
                maxByHeight,
              ),
            )
            .toDouble();
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: boxSize,
                      height: boxSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}