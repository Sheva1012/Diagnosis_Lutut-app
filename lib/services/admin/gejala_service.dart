import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart'; 

class GejalaService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Ambil semua gejala
  Future<List<Map<String, dynamic>>> getAllGejala() async {
    try {
      final response = await _client
          .from('gejala')
          .select()
          .order('kode_gejala', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data gejala: $e');
    }
  }

  // Cari gejala (Update: Bisa cari berdasarkan pertanyaan juga)
  Future<List<Map<String, dynamic>>> searchGejala(String query) async {
    try {
      final response = await _client
          .from('gejala')
          .select()
          .or('kode_gejala.ilike.%$query%,nama_gejala.ilike.%$query%,pertanyaan.ilike.%$query%')
          .order('kode_gejala', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mencari data gejala: $e');
    }
  }

  // Tambah gejala (Update: Tambah parameter pertanyaan)
  Future<void> addGejala(String kode, String nama, String pertanyaan) async {
    try {
      await _client.from('gejala').insert({
        'kode_gejala': kode,
        'nama_gejala': nama,
        'pertanyaan': pertanyaan, // Field baru
      });
    } catch (e) {
      throw Exception('Gagal menambah gejala: $e');
    }
  }

  // Update gejala (Update: Tambah parameter pertanyaan)
  Future<void> updateGejala(int id, String kode, String nama, String pertanyaan) async {
    try {
      await _client.from('gejala').update({
        'kode_gejala': kode,
        'nama_gejala': nama,
        'pertanyaan': pertanyaan, // Field baru
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_gejala', id);
    } catch (e) {
      throw Exception('Gagal mengupdate gejala: $e');
    }
  }

  // Hapus gejala
  Future<void> deleteGejala(int id) async {
    try {
      await _client.from('gejala').delete().eq('id_gejala', id);
    } catch (e) {
      throw Exception('Gagal menghapus gejala: $e');
    }
  }

  // Hitung total gejala
  Future<int> getTotalGejala() async {
    try {
      final count = await _client.from('gejala').count();
      return count;
    } catch (e) {
      throw Exception('Gagal menghitung total gejala: $e');
    }
  }
}