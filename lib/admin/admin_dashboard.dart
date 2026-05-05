import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';

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
  String _username = "Admin";
  
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
      final userId = Supabase.instance.client.auth.currentUser?.id;
      String fetchedUsername = "Admin";
      
      if (userId != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('username')
            .eq('id_user', userId)
            .maybeSingle();
        
        if (userData != null && userData['username'] != null && userData['username'].toString().isNotEmpty) {
          fetchedUsername = userData['username'];
        }
      }

      // Jalankan semua request count secara paralel agar cepat
      final results = await Future.wait([
        _penggunaService.getTotalPengguna(),    // Index 0
        _statistikService.getTotalDiagnosis(),  // Index 1
        _gejalaService.getTotalGejala(),        // Index 2
        _cederaService.getTotalCedera(),        // Index 3
      ]);

      if (mounted) {
        setState(() {
          _username = fetchedUsername;
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
        Fluttertoast.showToast(
          msg: 'Gagal memuat data: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 16), // Tambah jarak
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF8A6E5B),
                ),
              ),
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
        title: Text("Dashboard", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AdminTheme.appBarGradient),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'dashboard'),
      backgroundColor: AdminTheme.bg,
      body: RefreshIndicator(
        color: AdminTheme.primary,
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
                    colors: [AdminTheme.primaryDark, AdminTheme.primary],
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
                      "Selamat Datang, $_username",
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
              
              Text(
                "Ringkasan Data",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.ink,
                ),
              ),
              const SizedBox(height: 16),

              // Grid Stats
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AdminTheme.primary),
                    )
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
                          AdminTheme.primary,
                          const AdminKelolaPengguna()
                        ),
                        _card(
                          context, 
                          "Total Diagnosis", 
                          _totalDiagnosis.toString(), 
                          Icons.medical_services, 
                          AdminTheme.accent,
                          const AdminLaporanStatistik()
                        ),
                        _card(
                          context, 
                          "Total Gejala", 
                          _totalGejala.toString(), 
                          Icons.coronavirus, 
                          const Color(0xFFD9895B),
                          const AdminKelolaGejala()
                        ),
                        _card(
                          context, 
                          "Total Cedera", 
                          _totalCedera.toString(), 
                          Icons.healing, 
                          AdminTheme.danger,
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