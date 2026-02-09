import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class RiwayatService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Mengambil Riwayat Diagnosis User Login
  Future<List<Map<String, dynamic>>> getRiwayatSaya() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("User belum login");

      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            cedera:id_cedera (nama_cedera, solusi)
          ''')
          .eq('id_user', user.id) // Filter hanya data user ini
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }
}