import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/masyarakat/riwayat_service.dart';
import 'hasil_diagnosis_masyarakat.dart'; 

class RiwayatMasyarakat extends StatefulWidget {
  const RiwayatMasyarakat({super.key});

  @override
  State<RiwayatMasyarakat> createState() => _RiwayatMasyarakatState();
}

class _RiwayatMasyarakatState extends State<RiwayatMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _primary = Color(0xFF2F6FDB);
  static const Color _soft = Color(0xFFE7F0FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  final RiwayatService _service = RiwayatService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allData = []; // Data asli dari DB
  List<Map<String, dynamic>> _filteredData =
      []; // Data yang ditampilkan (hasil filter)
  bool _isLoading = true;
  String _filterType = 'Semua';
  DateTime? _selectedDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _selectedMonth;
  int? _selectedYear;

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
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        Fluttertoast.showToast(
          msg: "Terjadi kesalahan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      }
    }
  }

  DateTime _startOfDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime? _parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is DateTime) return rawDate.toLocal();
    if (rawDate is String) return DateTime.tryParse(rawDate)?.toLocal();
    return null;
  }

  DateTime? _getItemDate(Map<String, dynamic> item) {
    final tanggalDiagnosis = _parseDate(item['tanggal_diagnosis']);
    final createdAt = _parseDate(item['created_at']);
    return tanggalDiagnosis ?? createdAt;
  }

  bool _matchesDateFilter(DateTime? itemDate) {
    if (_filterType == 'Semua') return true;
    if (itemDate == null) return false;

    final normalizedItemDate = _startOfDate(itemDate);

    if (_filterType == 'Tanggal') {
      if (_selectedStartDate != null && _selectedEndDate != null) {
        var start = _startOfDate(_selectedStartDate!);
        var end = _startOfDate(_selectedEndDate!);

        if (end.isBefore(start)) {
          final temp = start;
          start = end;
          end = temp;
        }

        return !normalizedItemDate.isBefore(start) &&
            !normalizedItemDate.isAfter(end);
      }

      if (_selectedDate == null) return true;
      final selected = _startOfDate(_selectedDate!);
      return normalizedItemDate == selected;
    }

    if (_filterType == 'Bulan') {
      if (_selectedMonth == null) return true;
      return itemDate.year == _selectedMonth!.year &&
          itemDate.month == _selectedMonth!.month;
    }

    if (_filterType == 'Tahun') {
      if (_selectedYear == null) return true;
      return itemDate.year == _selectedYear;
    }

    return true;
  }

  // Fungsi Filter Gabungan (Search + Periode)
  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredData = _allData.where((item) {
        // 1. Cek Nama Cedera (Search)
        final cedera = item['cedera'] ?? {};
        final namaCedera = (cedera['nama_cedera'] ?? '')
            .toString()
            .toLowerCase();
        bool matchesSearch = namaCedera.contains(query);

        // 2. Cek Periode (Tanggal / Bulan / Tahun)
        final itemDate = _getItemDate(item);
        final matchesDate = _matchesDateFilter(itemDate);

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  Future<void> _showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pilih Filter Riwayat",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.today, color: Colors.blue),
                title: const Text("Tanggal"),
                onTap: () {
                  Navigator.pop(context);
                  _selectDateRange();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_view_month,
                  color: Colors.green,
                ),
                title: const Text("Bulan"),
                onTap: () {
                  Navigator.pop(context);
                  _selectMonth();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: const Text("Tahun"),
                onTap: () {
                  Navigator.pop(context);
                  _selectYear();
                },
              ),
              if (_filterType != 'Semua')
                ListTile(
                  leading: const Icon(Icons.clear, color: Colors.redAccent),
                  title: const Text("Reset Filter"),
                  onTap: () {
                    Navigator.pop(context);
                    _clearFilter();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final initial = _startOfDate(_selectedStartDate ?? _selectedDate ?? DateTime.now());
    final initialEnd = _startOfDate(_selectedEndDate ?? _selectedDate ?? initial);
    final initialRange = DateTimeRange(
      start: initial,
      end: initialEnd.isBefore(initial) ? initial : initialEnd,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = _startOfDate(picked.start);
      final end = _startOfDate(picked.end);
      setState(() {
        _selectedStartDate = start;
        _selectedEndDate = end;
        _selectedDate = start;
        _selectedMonth = null;
        _selectedYear = null;
        _filterType = 'Tanggal';
      });
      _filterData();
    }
  }

  Future<void> _selectYear() async {
    final selectedDate = _selectedDate ?? DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Tahun"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              selectedDate: DateTime(selectedDate.year),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);
                setState(() {
                  _selectedYear = dateTime.year;
                  _selectedDate = DateTime(dateTime.year, 1, 1);
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                  _selectedMonth = null;
                  _filterType = 'Tahun';
                });
                _filterData();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    int selectedMonth = (_selectedMonth ?? _selectedDate ?? now).month;
    int selectedYear = (_selectedMonth ?? _selectedDate ?? now).year;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Pilih Bulan & Tahun"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      now.year - 2019,
                      (index) => 2020 + index,
                    ).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedYear = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (index) {
                      return ChoiceChip(
                        label: Text(
                          DateFormat('MMM', 'id_ID').format(
                            DateTime(0, index + 1),
                          ),
                        ),
                        selected: selectedMonth == index + 1,
                        onSelected: (bool selected) {
                          if (selected) {
                            setDialogState(() => selectedMonth = index + 1);
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedMonth = DateTime(selectedYear, selectedMonth, 1);
                      _selectedDate = _selectedMonth;
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                      _selectedYear = null;
                      _filterType = 'Bulan';
                    });
                    _filterData();
                  },
                  child: const Text("Pilih"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearFilter() {
    setState(() {
      _filterType = 'Semua';
      _selectedDate = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedMonth = null;
      _selectedYear = null;
    });
    _filterData();
  }

  String _getFilterLabel() {
    if (_filterType == 'Tanggal' &&
        _selectedStartDate != null &&
        _selectedEndDate != null) {
      if (_startOfDate(_selectedStartDate!) == _startOfDate(_selectedEndDate!)) {
        return DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
      }
      return '${DateFormat('dd/MM').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}';
    }

    if (_filterType == 'Tanggal' && _selectedDate != null) {
      return DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }

    if (_filterType == 'Bulan' && _selectedMonth != null) {
      return DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth!);
    }

    if (_filterType == 'Tahun' && _selectedYear != null) {
      return _selectedYear.toString();
    }

    return 'Semua tanggal';
  }

  // Helper Format Tanggal
  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMMM yyyy - HH:mm', 'id_ID').format(dt);
    } catch (e) {
      try {
        final dt = DateTime.parse(isoString);
        return DateFormat('dd MMM yyyy - HH:mm').format(dt);
      } catch (e2) {
        return isoString;
      }
    }
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

  Widget _buildCederaImage(String? imageAsset) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: imageAsset == null
          ? Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 26,
                color: _muted,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 26,
                      color: _muted,
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Riwayat Diagnosis",
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
        child: Column(
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
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _ink.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterData(),
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Cari hasil diagnosis...",
                        hintStyle: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: _muted,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tombol Filter
                InkWell(
                  onTap: _showFilterDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _filterType == 'Semua' ? _soft : const Color(0xFFDCE8FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _ink.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _filterType == 'Semua'
                              ? Icons.filter_alt_outlined
                              : Icons.filter_alt,
                          color: _ink,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 90),
                          child: Text(
                            _filterType == 'Semua' ? 'Filter' : _getFilterLabel(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                        ),
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
                        Icon(
                          Icons.history_toggle_off,
                          size: 60,
                          color: _border,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada riwayat ditemukan",
                          style: GoogleFonts.poppins(color: _muted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    itemCount: _filteredData.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];

                      // --- EKSTRAKSI DATA UNTUK DIKIRIM KE HALAMAN HASIL ---
                      final cedera = item['cedera'] ?? {};
                      final String namaCedera =
                          cedera['nama_cedera'] ?? 'Tidak Teridentifikasi';

                        final String? imageAsset =
                          _resolveCederaImageAsset(namaCedera);

                      // Pastikan mengambil nama kolom yang benar sesuai DB (biasanya persentase_cf)
                      final double persentase =
                          (item['persentase_cf'] ?? item['persentase'] ?? 0)
                              .toDouble();
                      final double nilaiCf = (item['nilai_cf_final'] ?? 0)
                          .toDouble();
                      final String tingkatKepastian =
                          item['tingkat_kepastian'] ?? '-';
                      final String tanggal =
                          item['tanggal_diagnosis'] ?? item['created_at'] ?? '';

                      // Ambil penanganan awal & lanjut
                      final listPenanganan =
                          cedera['penanganan'] as List<dynamic>?;
                      String pAwal = "- Belum ada data penanganan awal.";
                      String pLanjut = "- Belum ada data penanganan lanjut.";

                      if (listPenanganan != null && listPenanganan.isNotEmpty) {
                        pAwal = listPenanganan[0]['penanganan_awal'] ?? "-";
                        pLanjut =
                            listPenanganan[0]['penanganan_lanjutan'] ?? "-";
                      }
                      // ---------------------------------------------------

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          // NAVIGASI KETIKA CARD DIKLIK
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HasilDiagnosisMasyarakat(
                                  namaCedera: namaCedera,
                                  penangananAwal: pAwal,
                                  penangananLanjut: pLanjut,
                                  persentase: persentase,
                                  nilaiCf: nilaiCf,
                                  tingkatKepastian: tingkatKepastian,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(
                                  color: _ink.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Gambar/Icon
                                _buildCederaImage(imageAsset),
                                const SizedBox(width: 16),

                                // 2. Info Tengah
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        namaCedera,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(tanggal),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _muted,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Progress Bar Nilai CF
                                      Row(
                                        children: [
                                          Text(
                                            "Nilai CF:",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: persentase / 100,
                                                minHeight: 8,
                                                backgroundColor: _border,
                                                color: _primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${persentase.toInt()}%",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // 3. Icon Panah Kanan
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 8,
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
