import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl di pubspec.yaml
import 'admin_sidebar.dart';
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

  // Data Statistik
  int _totalDiagnosis = 0;
  String _cederaTerbanyak = '-';
  List<FlSpot> _chartSpots = [];
  List<Map<String, dynamic>> _riwayatList = []; // Data Asli dari DB
  List<Map<String, dynamic>> _filteredRiwayatList = []; // Data yang ditampilkan
  double _maxChartY = 5.0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final total = await _statistikService.getTotalDiagnosis();
      final topCederaData = await _statistikService.getCederaTerbanyak();
      final topCederaName = topCederaData != null ? topCederaData['nama_cedera'] : 'Belum ada data';
      
      // Ambil Statistik Grafik (Default Tahun ini)
      final statsBulanan = await _statistikService.getStatistikBulanan(_selectedDate.year);
      _generateChartData(statsBulanan);

      // Ambil Riwayat (Ambil lebih banyak untuk difilter lokal)
      final riwayat = await _statistikService.getRiwayatTerbaru(limit: 100);

      if (mounted) {
        setState(() {
          _totalDiagnosis = total;
          _cederaTerbanyak = topCederaName;
          _riwayatList = riwayat;
          _applyFilter(); // Terapkan filter awal
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  // Logika Filter Data Tabel
  void _applyFilter() {
    setState(() {
      _filteredRiwayatList = _riwayatList.where((item) {
        if (item['created_at'] == null) return false;
        DateTime itemDate = DateTime.parse(item['created_at']);

        if (_filterType == 'Hari') {
          return itemDate.year == _selectedDate.year && 
                 itemDate.month == _selectedDate.month && 
                 itemDate.day == _selectedDate.day;
        } else if (_filterType == 'Bulan') {
          return itemDate.year == _selectedDate.year && 
                 itemDate.month == _selectedDate.month;
        } else { // Tahun
          return itemDate.year == _selectedDate.year;
        }
      }).toList();
    });
  }

  void _generateChartData(List<Map<String, dynamic>> data) {
    List<double> monthlyCounts = List.filled(12, 0.0);
    double maxVal = 0;

    for (var item in data) {
      int month = (item['month'] as num).toInt(); 
      double total = (item['total_count'] as num).toDouble();
      if (month >= 1 && month <= 12) {
        monthlyCounts[month - 1] = total;
        if (total > maxVal) maxVal = total;
      }
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < 12; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyCounts[i]));
    }

    setState(() {
      _chartSpots = spots;
      _maxChartY = maxVal == 0 ? 5.0 : maxVal * 1.2;
    });
  }

  // Dialog Pilih Filter
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
                leading: const Icon(Icons.today, color: Colors.blue),
                title: const Text("Harian (Tanggal)"),
                onTap: () {
                  Navigator.pop(context);
                  _selectDate(DatePickerMode.day);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month, color: Colors.green),
                title: const Text("Bulanan"),
                onTap: () {
                  Navigator.pop(context);
                  _selectMonth(); // Custom month picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
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

  Future<void> _selectDate(DatePickerMode mode) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: mode,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filterType = 'Hari';
        _applyFilter();
      });
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
                  _filterType = 'Tahun';
                  _loadAllData(); // Reload grafik tahunan
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Simple Month Picker Dialog
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
                      _filterType = 'Bulan';
                      _applyFilter();
                    });
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
      return DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
    } else if (_filterType == 'Bulan') {
      return DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
    } else {
      return _selectedDate.year.toString();
    }
  }

  // Format Tanggal untuk Tabel
  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        title: Text(
          'Laporan & Statistik',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'laporan'),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.download, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Column(
          children: [
            // TOMBOL FILTER TANGGAL
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: _showFilterDialog, // Buka Dialog Pilihan
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Filter: $_filterType", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          Text(_getFilterLabel(), style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.filter_list, color: Color(0xFF1E88E5), size: 24),
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
                  Expanded(child: _buildStatCard('Total Diagnosis', '$_totalDiagnosis', Colors.blue[50]!)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Cedera Terbanyak', _cederaTerbanyak, Colors.green[50]!)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // GRAFIK (Hanya muncul jika filter Tahun untuk akurasi, atau tetap muncul)
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
                  Text('Grafik Diagnosis (${_selectedDate.year})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
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
                              interval: 1,
                              getTitlesWidget: (val, meta) {
                                const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                                if (val.toInt() >= 0 && val.toInt() < 12) {
                                  return Text(months[val.toInt()], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey), left: BorderSide(color: Colors.grey))),
                        minX: 0, maxX: 11, minY: 0, maxY: _maxChartY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartSpots,
                            isCurved: true,
                            color: const Color(0xFF1E88E5),
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF1E88E5).withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABEL RIWAYAT (Filtered)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                    child: Row(
                      children: [
                        _buildHeaderCell('No', 1),
                        _buildHeaderCell('Tanggal', 2),
                        _buildHeaderCell('Nama', 3),
                        _buildHeaderCell('Hasil', 3),
                        _buildHeaderCell('CF', 2),
                      ],
                    ),
                  ),
                  if (_filteredRiwayatList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Tidak ada data untuk filter ini", style: TextStyle(color: Colors.grey[600])),
                    )
                  else
                    ..._filteredRiwayatList.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final item = entry.value;
                      final nama = item['users']?['nama_lengkap'] ?? 'Anonim';
                      final hasil = item['cedera']?['nama_cedera'] ?? '-';
                      final tgl = _formatDate(item['created_at']);
                      final cf = item['nilai_cf']?.toString() ?? '0';

                      return Container(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Row(
                          children: [
                            _buildDataCell('$idx', 1, TextAlign.center),
                            _buildDataCell(tgl, 2, TextAlign.center),
                            _buildDataCell(nama, 3, TextAlign.left),
                            _buildDataCell(hasil, 3, TextAlign.left),
                            _buildDataCell(cf, 2, TextAlign.center),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(flex: flex, child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)));
  }

  Widget _buildDataCell(String text, int flex, TextAlign align) {
    return Expanded(flex: flex, child: Text(text, textAlign: align, style: GoogleFonts.poppins(fontSize: 12)));
  }
}