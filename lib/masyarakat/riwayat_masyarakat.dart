import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl untuk format tanggal
import '../services/masyarakat/riwayat_service.dart';

class RiwayatMasyarakat extends StatefulWidget {
  const RiwayatMasyarakat({super.key});

  @override
  State<RiwayatMasyarakat> createState() => _RiwayatMasyarakatState();
}

class _RiwayatMasyarakatState extends State<RiwayatMasyarakat> {
  final RiwayatService _service = RiwayatService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allData = []; // Data asli dari DB
  List<Map<String, dynamic>> _filteredData = []; // Data yang ditampilkan (hasil filter)
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.getRiwayatSaya();
      if (mounted) {
        setState(() {
          _allData = data;
          _filteredData = data; // Awalnya tampilkan semua
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Fungsi Filter Gabungan (Search + Tanggal)
  void _filterData() {
    String query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredData = _allData.where((item) {
        // 1. Cek Nama Cedera (Search)
        final cedera = item['cedera'] ?? {};
        final namaCedera = (cedera['nama_cedera'] ?? '').toString().toLowerCase();
        bool matchesSearch = namaCedera.contains(query);

        // 2. Cek Tanggal (Date Picker)
        bool matchesDate = true;
        if (_selectedDate != null) {
          DateTime itemDate = DateTime.parse(item['created_at']);
          matchesDate = itemDate.year == _selectedDate!.year &&
              itemDate.month == _selectedDate!.month &&
              itemDate.day == _selectedDate!.day;
        }

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  // Fungsi Pilih Tanggal
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade500),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterData(); // Jalankan filter
    }
  }

  // Reset Filter Tanggal
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _filterData();
  }

  // Helper Format Tanggal (Contoh: 12 Desember 2025 - 09:30)
  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMMM yyyy - HH:mm', 'id_ID').format(dt); 
      // NOTE: Tambahkan parameter 'id_ID' jika ingin Bahasa Indonesia, 
      // pastikan initializeDateFormatting() dipanggil di main.dart atau hapus parameter itu.
      // Jika error locale, ganti jadi: DateFormat('dd MMM yyyy - HH:mm').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Riwayat Diagnosis",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ================= SEARCH & FILTER =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterData(),
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Cari hasil diagnosis...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Tombol Filter Tanggal (Warna Cyan Sesuai Wireframe)
                InkWell(
                  onTap: _selectedDate == null ? _pickDate : _clearDateFilter,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _selectedDate == null ? Colors.cyanAccent.shade400 : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedDate == null ? Icons.calendar_today_rounded : Icons.close,
                          color: Colors.black87, 
                          size: 18,
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd/MM').format(_selectedDate!),
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ] else ...[
                          const SizedBox(width: 6),
                          Text(
                            "Filter",
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST DATA =================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text("Tidak ada riwayat ditemukan", style: GoogleFonts.poppins(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        itemCount: _filteredData.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = _filteredData[index];
                          final cedera = item['cedera'] ?? {};
                          final String namaCedera = cedera['nama_cedera'] ?? 'Tidak Teridentifikasi';
                          final double persentase = (item['persentase'] ?? 0).toDouble();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Gambar/Icon (Kotak Silang sesuai wireframe)
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black87, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Membuat efek silang (placeholder image)
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: CrossPainter(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // 2. Info Tengah
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Nama Cedera (Judul)
                                      Text(
                                        namaCedera,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2D3142),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Tanggal
                                      Text(
                                        _formatDateTime(item['created_at']),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Progress Bar Nilai CF
                                      Row(
                                        children: [
                                          Text(
                                            "Nilai CF:",
                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: persentase / 100, // Konversi 85 -> 0.85
                                                minHeight: 8,
                                                backgroundColor: Colors.grey.shade200,
                                                color: Colors.blue.shade600, // Warna Biru
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${persentase.toInt()}%",
                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // 3. Icon Panah Kanan
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 8),
                                  child: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk membuat kotak silang (X) seperti di wireframe
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Garis diagonal 1
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    // Garis diagonal 2
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}