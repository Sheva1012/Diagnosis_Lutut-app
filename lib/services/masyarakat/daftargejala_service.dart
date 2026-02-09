import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart'; // Sesuaikan path config Anda

class DaftarGejalaService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Mengambil semua data dari tabel 'gejala'
  Future<List<Map<String, dynamic>>> getDaftarGejala() async {
    try {
      final response = await _client
          .from('gejala') // Pastikan nama tabel di Supabase adalah 'gejala'
          .select()
          .order('id_gejala', ascending: true); 

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data gejala: $e');
    }
  }
}