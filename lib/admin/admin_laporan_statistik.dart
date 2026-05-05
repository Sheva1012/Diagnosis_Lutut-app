import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';
import 'admin_pagination.dart';
import '../services/admin/statistik_service.dart';

class AdminLaporanStatistik extends StatefulWidget {
  const AdminLaporanStatistik({Key? key}) : super(key: key);

  @override
  State<AdminLaporanStatistik> createState() => _AdminLaporanStatistikState();
}

class _AdminLaporanStatistikState extends State<AdminLaporanStatistik> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final StatistikService _statistikService = StatistikService();

  bool _isLoading = true;
  
  // Filter State
  String _filterType = 'Tahun'; // 'Hari', 'Bulan', 'Tahun'
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Data Statistik
  int _totalDiagnosis = 0;
  String _cederaTerbanyak = '-';
  List<FlSpot> _chartSpots = [];
  List<String> _chartLabels = const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  List<Map<String, dynamic>> _filteredRiwayatList = []; // Data yang ditampilkan
  double _maxChartY = 5.0;
  double _maxChartX = 11.0;

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _loadDataByFilter();
  }

  Future<void> _loadDataByFilter() async {
    setState(() => _isLoading = true);
    try {
      var riwayat = await _statistikService.getRiwayatByFilter(
        filterType: _filterType,
        selectedDate: _selectedDate,
        rangeStartDate: _selectedStartDate,
        rangeEndDate: _selectedEndDate,
        limit: 1000,
      );

      // Fallback lokal jika hasil query filter kosong, untuk menghindari mismatch format timestamp.
      if (riwayat.isEmpty) {
        final allRiwayat = await _statistikService.getRiwayatTerbaru(limit: 5000);
        riwayat = allRiwayat.where((item) {
          final dt = _getItemDate(item);
          return dt != null && _isInSelectedPeriod(dt);
        }).toList();
      }

      if (mounted) {
        setState(() {
          _totalDiagnosis = riwayat.length;
          _cederaTerbanyak = _getTopCedera(riwayat);
          _filteredRiwayatList = riwayat;
          _updateChartData(riwayat);
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (e) {
      print("Error Load Data: $e");
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Gagal memuat data: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      setState(() => _isLoading = false);
    }
  }

  bool _isInSelectedPeriod(DateTime dt) {
    if (_filterType == 'Hari') {
      final day = _startOfDate(dt);
      final start = _hariStart;
      final end = _hariEnd;
      return !day.isBefore(start) && !day.isAfter(end);
    }
    if (_filterType == 'Bulan') {
      return dt.year == _selectedDate.year && dt.month == _selectedDate.month;
    }
    return dt.year == _selectedDate.year;
  }

  DateTime _startOfDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime get _hariStart => _startOfDate(_selectedStartDate ?? _selectedDate);

  DateTime get _hariEnd => _startOfDate(_selectedEndDate ?? _selectedDate);

  DateTime? _parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is DateTime) return rawDate.toLocal();
    if (rawDate is String) return DateTime.tryParse(rawDate)?.toLocal();
    return null;
  }

  DateTime? _getItemDate(Map<String, dynamic> item, {bool preferCreatedAt = false}) {
    final createdAt = _parseDate(item['created_at']);
    final tanggalDiagnosis = _parseDate(item['tanggal_diagnosis']);
    return preferCreatedAt ? (createdAt ?? tanggalDiagnosis) : (tanggalDiagnosis ?? createdAt);
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _getTopCedera(List<Map<String, dynamic>> riwayat) {
    if (riwayat.isEmpty) return 'Belum ada data';

    final frekuensi = <String, int>{};
    for (final item in riwayat) {
      final cedera = item['cedera'];
      final nama = cedera is Map ? (cedera['nama_cedera']?.toString() ?? 'Lainnya') : 'Lainnya';
      frekuensi[nama] = (frekuensi[nama] ?? 0) + 1;
    }

    final sorted = frekuensi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.isEmpty ? 'Belum ada data' : sorted.first.key;
  }

  void _updateChartData(List<Map<String, dynamic>> riwayat) {
    List<int> buckets;
    List<String> labels;

    if (_filterType == 'Hari') {
      final start = _hariStart;
      final end = _hariEnd;
      final totalDays = end.difference(start).inDays + 1;

      buckets = List.filled(totalDays, 0);
      labels = List.generate(
        totalDays,
        (i) => DateFormat('dd/MM').format(start.add(Duration(days: i))),
      );

      for (final item in riwayat) {
        final dt = _getItemDate(item);
        if (dt != null) {
          final day = _startOfDate(dt);
          if (!day.isBefore(start) && !day.isAfter(end)) {
            final index = day.difference(start).inDays;
            buckets[index] = buckets[index] + 1;
          }
        }
      }
    } else if (_filterType == 'Bulan') {
      final totalDays = _daysInMonth(_selectedDate);
      buckets = List.filled(totalDays, 0);
      labels = List.generate(totalDays, (i) => (i + 1).toString());
      for (final item in riwayat) {
        final dt = _getItemDate(item);
        if (dt != null && dt.year == _selectedDate.year && dt.month == _selectedDate.month) {
          buckets[dt.day - 1] = buckets[dt.day - 1] + 1;
        }
      }
    } else {
      buckets = List.filled(12, 0);
      labels = const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      for (final item in riwayat) {
        final dt = _getItemDate(item);
        if (dt != null && dt.year == _selectedDate.year) {
          buckets[dt.month - 1] = buckets[dt.month - 1] + 1;
        }
      }
    }

    final spots = <FlSpot>[];
    double maxVal = 0;
    for (int i = 0; i < buckets.length; i++) {
      final y = buckets[i].toDouble();
      if (y > maxVal) maxVal = y;
      spots.add(FlSpot(i.toDouble(), y));
    }

    _chartSpots = spots;
    _chartLabels = labels;
    _maxChartX = labels.isEmpty ? 1.0 : (labels.length - 1).toDouble();
    _maxChartY = maxVal == 0 ? 5.0 : maxVal + (maxVal * 0.2);
  }

  int _getChartLabelStep() {
    final len = _chartLabels.length;
    if (len <= 12) return 1;
    if (len <= 24) return 2;
    if (len <= 60) return 5;
    if (len <= 120) return 10;
    return 15;
  }

  String _getChartTitle() {
    if (_filterType == 'Hari') {
      final start = _hariStart;
      final end = _hariEnd;
      if (start == end) {
        return 'Grafik Diagnosis Harian (${DateFormat('dd MMM yyyy', 'id_ID').format(start)})';
      }
      return 'Grafik Diagnosis Harian (${DateFormat('dd MMM yyyy', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)})';
    }
    if (_filterType == 'Bulan') {
      return 'Grafik Diagnosis Bulanan (${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)})';
    }
    return 'Grafik Diagnosis Tahunan (${_selectedDate.year})';
  }

  // --- BAGIAN UI & DIALOG (Sama seperti sebelumnya) ---

  Future<void> _showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilih Tipe Filter", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.today, color: AdminTheme.primary),
                title: const Text("Harian (Rentang Tanggal)"),
                onTap: () {
                  Navigator.pop(context);
                  _selectDateRange();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month, color: AdminTheme.accent),
                title: const Text("Bulanan"),
                onTap: () {
                  Navigator.pop(context);
                  _selectMonth(); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AdminTheme.primaryDark),
                title: const Text("Tahunan"),
                onTap: () {
                  Navigator.pop(context);
                  _selectYear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange initialRange = DateTimeRange(
      start: _selectedStartDate ?? _selectedDate,
      end: _selectedEndDate ?? _selectedDate,
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = _startOfDate(picked.start);
        _selectedEndDate = _startOfDate(picked.end);
        _selectedDate = _selectedStartDate!;
        _filterType = 'Hari';
      });
      _loadDataByFilter();
    }
  }

  Future<void> _selectYear() async {
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
              lastDate: DateTime(2030),
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);
                setState(() {
                  _selectedDate = dateTime;
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                  _filterType = 'Tahun';
                });
                _loadDataByFilter();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectMonth() async {
    int selectedMonth = _selectedDate.month;
    int selectedYear = _selectedDate.year;

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
                    items: List.generate(10, (index) => 2020 + index).map((year) {
                      return DropdownMenuItem(value: year, child: Text(year.toString()));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedYear = val!),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (index) {
                      return ChoiceChip(
                        label: Text(DateFormat('MMM').format(DateTime(0, index + 1))),
                        selected: selectedMonth == index + 1,
                        onSelected: (bool selected) {
                          setDialogState(() => selectedMonth = index + 1);
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedDate = DateTime(selectedYear, selectedMonth);
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                      _filterType = 'Bulan';
                    });
                    _loadDataByFilter();
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

  String _getFilterLabel() {
    if (_filterType == 'Hari') {
      final start = _hariStart;
      final end = _hariEnd;

      if (start == end) {
        return DateFormat('dd MMMM yyyy', 'id_ID').format(start);
      }

      return '${DateFormat('dd MMM yyyy', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)}';
    } else if (_filterType == 'Bulan') {
      return DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
    } else {
      return _selectedDate.year.toString();
    }
  }

  String _formatDate(dynamic rawDate) {
    try {
      final dt = _parseDate(rawDate);
      if (dt == null) return "-";
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  Future<Uint8List> _buildPdfBytes() async {
    final pdf = pw.Document();
    final generatedAt = DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now());

    final tableRows = _filteredRiwayatList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;

      final nama = item['users'] != null ? item['users']['nama_lengkap'] : 'User Hapus';
      final hasil = item['cedera'] != null ? item['cedera']['nama_cedera'] : '-';
      final tglRaw = item['tanggal_diagnosis'] ?? item['created_at'];
      final tgl = _formatDate(tglRaw);
      final cfVal = item['persentase_cf'] ?? item['nilai_cf'] ?? 0;

      String cfText;
      if (cfVal is num) {
        cfText = cfVal.toStringAsFixed(2);
      } else {
        cfText = cfVal.toString();
      }

      return [
        '$index',
        tgl,
        nama.toString(),
        hasil.toString(),
        cfText,
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Laporan & Statistik Diagnosis',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Filter: $_filterType'),
          pw.Text('Periode: ${_getFilterLabel()}'),
          pw.Text('Dibuat: $generatedAt'),
          pw.SizedBox(height: 12),
          pw.Text('Total Diagnosis: $_totalDiagnosis'),
          pw.Text('Cedera Terbanyak: $_cederaTerbanyak'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Riwayat Diagnosis',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (tableRows.isEmpty)
            pw.Text('Tidak ada data untuk filter ini')
          else
            pw.Table.fromTextArray(
              headers: const ['No', 'Tanggal', 'Nama', 'Hasil', 'CF'],
              data: tableRows,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColor(0.92, 0.92, 0.92)),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadPdf() async {
    try {
      final bytes = await _buildPdfBytes();
      final fileName = 'laporan_statistik_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
          msg: 'Gagal membuat PDF: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Laporan & Statistik',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AdminTheme.appBarGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'laporan'),
      backgroundColor: AdminTheme.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadPdf,
        backgroundColor: AdminTheme.primary,
        child: const Icon(Icons.download, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AdminTheme.primary,
        onRefresh: _loadDataByFilter,
        child: _isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator(color: AdminTheme.primary)),
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
            // TOMBOL FILTER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: _showFilterDialog, 
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AdminTheme.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AdminTheme.stroke),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Filter: $_filterType", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
                          Text(_getFilterLabel(), style: GoogleFonts.poppins(color: AdminTheme.ink, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.filter_list, color: AdminTheme.primary, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // STAT CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Total Diagnosis', '$_totalDiagnosis', AdminTheme.primarySoft)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Cedera Terbanyak', _cederaTerbanyak, const Color(0xFFFFEFE6))),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // GRAFIK
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getChartTitle(),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AdminTheme.ink),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: _getChartLabelStep().toDouble(),
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                final step = _getChartLabelStep();
                                if (idx < 0 || idx >= _chartLabels.length || idx.toDouble() != val) {
                                  return const SizedBox.shrink();
                                }
                                if (idx % step != 0 && idx != _chartLabels.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                return Text(_chartLabels[idx], style: GoogleFonts.poppins(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey), left: BorderSide(color: Colors.grey))),
                        minX: 0,
                        maxX: _maxChartX,
                        minY: 0,
                        maxY: _maxChartY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartSpots,
                            isCurved: true,
                            color: AdminTheme.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: true), // Show dot agar jelas
                            belowBarData: BarAreaData(show: true, color: AdminTheme.primary.withOpacity(0.12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABEL DATA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.stroke),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Text(
                      'Riwayat Diagnosis',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.ink,
                      ),
                    ),
                  ),

                  // Header Tabel
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AdminTheme.headerLight, AdminTheme.headerDark],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildHeaderCell('No', 1),
                          _buildDivider(),
                          _buildHeaderCell('Tanggal', 2),
                          _buildDivider(),
                          _buildHeaderCell('Nama', 3),
                          _buildDivider(),
                          _buildHeaderCell('Hasil', 3),
                          _buildDivider(),
                          _buildHeaderCell('CF', 2),
                        ],
                      ),
                    ),
                  ),
                  // Isi Tabel
                  if (_filteredRiwayatList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Tidak ada data untuk filter ini", style: GoogleFonts.poppins(color: Colors.grey[600])),
                    )
                  else
                    ...() {
                      final paginatedList = getPaginatedList(_filteredRiwayatList, _currentPage, _rowsPerPage);
                      final startIndex = (_currentPage - 1) * _rowsPerPage;
                      return paginatedList.asMap().entries.map((entry) {
                        final idx = startIndex + entry.key + 1;
                        final item = entry.value;
                        
                        // Handle data relasi Supabase (nested map)
                        final nama = item['users'] != null ? item['users']['nama_lengkap'] : 'User Hapus';
                        final hasil = item['cedera'] != null ? item['cedera']['nama_cedera'] : '-';
                        
                        // Tanggal bisa 'tanggal_diagnosis' atau 'created_at' tergantung service
                        final tglRaw = item['tanggal_diagnosis'] ?? item['created_at'];
                        final tgl = _formatDate(tglRaw);
                        
                        // Nilai CF (bisa 'nilai_cf', 'persentase_cf', atau 'persentase')
                        final cfVal = item['persentase_cf'] ?? item['nilai_cf'] ?? 0;
                        final cf = "$cfVal%";

                        final rowColor = entry.key.isEven ? Colors.white : AdminTheme.rowAlt;
                        return Container(
                          decoration: BoxDecoration(
                            color: rowColor,
                            border: Border(
                              bottom: BorderSide(color: AdminTheme.stroke),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _buildDataCell('$idx', 1, TextAlign.center),
                                _buildDivider(),
                                _buildDataCell(tgl, 2, TextAlign.center),
                                _buildDivider(),
                                _buildDataCell(nama, 3, TextAlign.left),
                                _buildDivider(),
                                _buildDataCell(hasil, 3, TextAlign.left),
                                _buildDivider(),
                                _buildDataCell(cf, 2, TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                    }(),
                  // Pagination controls
                  AdminPagination(
                    currentPage: _currentPage,
                    totalPages: calculateTotalPages(_filteredRiwayatList.length, _rowsPerPage),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminTheme.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8A6E5B)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AdminTheme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, int flex, TextAlign align) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(
          text,
          textAlign: align,
          style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.ink),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, color: AdminTheme.stroke);
}