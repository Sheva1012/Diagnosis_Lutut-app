import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';

// Import Screen Tujuan Navigasi
import 'admin_kelola_gejala.dart';
import 'admin_kelola_cedera.dart';
import 'admin_kelola_pengguna.dart';
import 'admin_laporan_statistik.dart';

// Import Services
import '../services/admin/pengguna_service.dart';
import '../services/admin/gejala_service.dart';
import '../services/admin/cedera_service.dart';
import '../services/admin/statistik_service.dart'; // Gunakan statistik service untuk diagnosis

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Inisialisasi Services
  final PenggunaService _penggunaService = PenggunaService();
  final GejalaService _gejalaService = GejalaService();
  final CederaService _cederaService = CederaService();
  final StatistikService _statistikService = StatistikService();

  // Variabel Data Statistik
  int _totalPengguna = 0;
  int _totalDiagnosis = 0;
  int _totalGejala = 0;
  int _totalCedera = 0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fungsi Memuat Semua Data Secara Bersamaan
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Jalankan semua request count secara paralel agar cepat
      final results = await Future.wait([
        _penggunaService.getTotalPengguna(),    // Index 0
        _statistikService.getTotalDiagnosis(),  // Index 1
        _gejalaService.getTotalGejala(),        // Index 2
        _cederaService.getTotalCedera(),        // Index 3
      ]);

      if (mounted) {
        setState(() {
          _totalPengguna = results[0];
          _totalDiagnosis = results[1];
          _totalGejala = results[2];
          _totalCedera = results[3];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Tampilkan error jika gagal, tapi jangan stop loading agar UI tetap muncul (dengan nilai 0)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  // Widget Kartu Statistik
  Widget _card(BuildContext context, String title, String value, IconData icon, Color iconColor, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination)).then((_) {
            // Refresh data saat kembali dari halaman lain
            _loadDashboardData();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        // PERBAIKAN: Gunakan SingleChildScrollView dan Padding agar tidak overflow
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 16), // Tambah jarak
              Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AdminSidebar(activePage: 'dashboard'),
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData, // Fitur tarik untuk refresh
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat Datang, Admin",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sistem Pakar Diagnosis Cedera Lutut",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text("Ringkasan Data", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Grid Stats
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      shrinkWrap: true, // Agar bisa di dalam SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // PERBAIKAN: Ubah childAspectRatio agar kartu lebih tinggi
                      childAspectRatio: 1.1, 
                      children: [
                        _card(
                          context, 
                          "Total Pengguna", 
                          _totalPengguna.toString(), 
                          Icons.people, 
                          Colors.blue, 
                          const AdminKelolaPengguna()
                        ),
                        _card(
                          context, 
                          "Total Diagnosis", 
                          _totalDiagnosis.toString(), 
                          Icons.medical_services, 
                          Colors.green, 
                          const AdminLaporanStatistik()
                        ),
                        _card(
                          context, 
                          "Total Gejala", 
                          _totalGejala.toString(), 
                          Icons.coronavirus, 
                          Colors.orange, 
                          const AdminKelolaGejala()
                        ),
                        _card(
                          context, 
                          "Total Cedera", 
                          _totalCedera.toString(), 
                          Icons.healing, 
                          Colors.red, 
                          const AdminKelolaCedera()
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}