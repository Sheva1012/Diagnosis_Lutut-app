import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart'; // Pastikan path ini sesuai dengan struktur folder Anda

class DiagnosisService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Ambil semua diagnosis dengan info user dan cedera
  Future<List<Map<String, dynamic>>> getAllDiagnosis() async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            user:id_user (id_user, nama_lengkap, email, username),
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data diagnosis: $e');
    }
  }

  // Ambil diagnosis terbaru (limit)
  Future<List<Map<String, dynamic>>> getRecentDiagnosis({int limit = 10}) async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            user:id_user (id_user, nama_lengkap, email, username),
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data diagnosis terbaru: $e');
    }
  }

  // Ambil diagnosis berdasarkan rentang tanggal
  Future<List<Map<String, dynamic>>> getDiagnosisByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            user:id_user (id_user, nama_lengkap, email, username),
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data diagnosis: $e');
    }
  }

  // Ambil detail diagnosis (beserta gejala)
  Future<List<Map<String, dynamic>>> getDiagnosisDetails(int diagnosisId) async {
    try {
      final response = await _client
          .from('detail_diagnosis')
          .select('''
            *,
            gejala:id_gejala (id_gejala, kode_gejala, nama_gejala)
          ''')
          .eq('id_diagnosis', diagnosisId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail diagnosis: $e');
    }
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  // Hitung total diagnosis (Menggunakan .count() untuk versi terbaru)
  Future<int> getTotalDiagnosis() async {
    try {
      // Langsung panggil .count(), hasilnya integer
      final count = await _client
          .from('diagnosis')
          .count();
      return count;
    } catch (e) {
      throw Exception('Gagal menghitung total diagnosis: $e');
    }
  }

  // Ambil cedera terbanyak (RPC)
  Future<Map<String, dynamic>?> getMostCommonCedera() async {
    try {
      final response = await _client.rpc('get_most_common_cedera');
      
      // Casting respon RPC agar aman
      final data = response as List<dynamic>; 
      
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil cedera terbanyak: $e');
    }
  }

  // Ambil statistik diagnosis per bulan (RPC)
  Future<List<Map<String, dynamic>>> getDiagnosisStatsByMonth(int year) async {
    try {
      final response = await _client.rpc('get_diagnosis_stats_by_month', 
        params: {'p_year': year});
        
      // Casting respon RPC agar aman
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      throw Exception('Gagal mengambil statistik diagnosis: $e');
    }
  }

  // Ambil riwayat diagnosis berdasarkan user
  Future<List<Map<String, dynamic>>> getDiagnosisByUser(String userId) async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          .eq('id_user', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil riwayat diagnosis: $e');
    }
  }
}