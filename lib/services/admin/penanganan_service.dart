import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart';

class PenangananService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all data
  Future<List<Map<String, dynamic>>> getAllPenanganan() async {
    try {
      final response = await _client
          .from('penanganan')
          .select('''
            *,
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          .order('id_penanganan', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data penanganan: $e');
    }
  }

  // Search data
  Future<List<Map<String, dynamic>>> searchPenanganan(String query) async {
    try {
      final response = await _client
          .from('penanganan')
          .select('''
            *,
            cedera:id_cedera (id_cedera, kode_cedera, nama_cedera)
          ''')
          // Mencari di kedua kolom penanganan
          .or('penanganan_awal.ilike.%$query%,penanganan_lanjutan.ilike.%$query%')
          .order('id_penanganan', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mencari data penanganan: $e');
    }
  }

  // Add data (Sesuai kolom baru)
  Future<void> addPenanganan(int cederaId, String awal, String lanjutan) async {
    try {
      await _client.from('penanganan').insert({
        'id_cedera': cederaId,
        'penanganan_awal': awal,
        'penanganan_lanjutan': lanjutan,
      });
    } catch (e) {
      throw Exception('Gagal menambah penanganan: $e');
    }
  }

  // Update data (Sesuai kolom baru)
  Future<void> updatePenanganan(int id, int cederaId, String awal, String lanjutan) async {
    try {
      await _client.from('penanganan').update({
        'id_cedera': cederaId,
        'penanganan_awal': awal,
        'penanganan_lanjutan': lanjutan,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_penanganan', id);
    } catch (e) {
      throw Exception('Gagal mengupdate penanganan: $e');
    }
  }

  // Delete data
  Future<void> deletePenanganan(int id) async {
    try {
      await _client.from('penanganan').delete().eq('id_penanganan', id);
    } catch (e) {
      throw Exception('Gagal menghapus penanganan: $e');
    }
  }
}