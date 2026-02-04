import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart';

class StatistikService {
  final SupabaseClient _client = SupabaseConfig.client;

  // 1. Hitung Total Diagnosis
  Future<int> getTotalDiagnosis() async {
    try {
      // Menggunakan .count() (Supabase v2)
      final count = await _client.from('diagnosis').count();
      return count;
    } catch (e) {
      return 0;
    }
  }

  // 2. Ambil Cedera Terbanyak (Menggunakan RPC Database)
  Future<Map<String, dynamic>?> getCederaTerbanyak() async {
    try {
      final response = await _client.rpc('get_most_common_cedera');
      
      // Konversi hasil ke List agar aman
      final data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }
      return null;
    } catch (e) {
      print('Error Cedera Terbanyak: $e');
      return null;
    }
  }

  // 3. Ambil Statistik Bulanan (Untuk Grafik)
  Future<List<Map<String, dynamic>>> getStatistikBulanan(int tahun) async {
    try {
      final response = await _client.rpc('get_diagnosis_stats_by_month', params: {
        'p_year': tahun
      });
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      print('Error Statistik Bulanan: $e');
      return [];
    }
  }

  // 4. Ambil 5 Riwayat Terakhir
  Future<List<Map<String, dynamic>>> getRiwayatTerbaru({int limit = 5}) async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('''
            id_diagnosis,
            created_at,
            nilai_cf,
            users:id_user(nama_lengkap), 
            cedera:id_cedera(nama_cedera)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error Riwayat: $e');
      return [];
    }
  }
}