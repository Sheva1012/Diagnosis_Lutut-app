import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart';

class CederaService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all cedera
  Future<List<Map<String, dynamic>>> getAllCedera() async {
    try {
      final response = await _client
          .from('cedera')
          .select()
          .order('kode_cedera', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data cedera: $e');
    }
  }

  // Search cedera (Update: tambahkan pencarian penyebab)
  Future<List<Map<String, dynamic>>> searchCedera(String query) async {
    try {
      final response = await _client
          .from('cedera')
          .select()
          .or('kode_cedera.ilike.%$query%,nama_cedera.ilike.%$query%,deskripsi.ilike.%$query%,penyebab.ilike.%$query%')
          .order('kode_cedera', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mencari data cedera: $e');
    }
  }

  // Add cedera (Update: tambahkan parameter penyebab)
  Future<void> addCedera(String kode, String nama, String deskripsi, String penyebab) async {
    try {
      await _client.from('cedera').insert({
        'kode_cedera': kode,
        'nama_cedera': nama,
        'deskripsi': deskripsi,
        'penyebab': penyebab, // Field baru
      });
    } catch (e) {
      throw Exception('Gagal menambah cedera: $e');
    }
  }

  // Update cedera (Update: tambahkan parameter penyebab)
  Future<void> updateCedera(int id, String kode, String nama, String deskripsi, String penyebab) async {
    try {
      await _client.from('cedera').update({
        'kode_cedera': kode,
        'nama_cedera': nama,
        'deskripsi': deskripsi,
        'penyebab': penyebab, // Field baru
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_cedera', id);
    } catch (e) {
      throw Exception('Gagal mengupdate cedera: $e');
    }
  }

  // Delete cedera
  Future<void> deleteCedera(int id) async {
    try {
      await _client.from('cedera').delete().eq('id_cedera', id);
    } catch (e) {
      throw Exception('Gagal menghapus cedera: $e');
    }
  }

  // Get total count
  Future<int> getTotalCedera() async {
    try {
      final count = await _client.from('cedera').count();
      return count;
    } catch (e) {
      throw Exception('Gagal menghitung total cedera: $e');
    }
  }
}