import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart'; // Pastikan path ke config benar

class DaftarCederaService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Mengambil semua data dari tabel 'cedera'
  Future<List<Map<String, dynamic>>> getDaftarCedera() async {
    try {
      final response = await _client
          .from('cedera') // Pastikan nama tabel di Supabase adalah 'cedera'
          .select()
          .order('id_cedera', ascending: true); // Urutkan berdasarkan ID

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data cedera: $e');
    }
  }
}