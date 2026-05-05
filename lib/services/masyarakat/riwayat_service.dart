import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class RiwayatService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getRiwayatSaya() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("User tidak login.");

      // PERBAIKAN DI SINI:
      // Hapus 'solusi' dan ganti dengan relasi ke 'penanganan'
      final response = await _client
          .from('diagnosis')
          .select('''
            *,
            cedera:id_cedera (
              nama_cedera,
              penanganan (
                penanganan_awal,
                penanganan_lanjutan
              )
            )
          ''')
          .eq('id_user', user.id)
          .order('tanggal_diagnosis', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }
}