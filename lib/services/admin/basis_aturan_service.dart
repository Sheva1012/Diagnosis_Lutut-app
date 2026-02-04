import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart'; // Pastikan path ke config benar

class BasisAturanService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Ambil semua data dengan Join ke Gejala & Cedera
  Future<List<Map<String, dynamic>>> getAllBasisAturan() async {
    try {
      // PERBAIKAN: Nama tabel 'aturan', kolom 'bobot_cf_pakar'
      final response = await _client
          .from('aturan') 
          .select('''
            id_aturan,
            bobot_cf_pakar,
            gejala:id_gejala(id_gejala, kode_gejala, nama_gejala),
            cedera:id_cedera(id_cedera, kode_cedera, nama_cedera)
          ''')
          .order('id_aturan', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data basis aturan: $e');
    }
  }

  // Filter berdasarkan Cedera
  Future<List<Map<String, dynamic>>> getBasisAturanByCedera(int cederaId) async {
    try {
      final response = await _client
          .from('aturan')
          .select('''
            *,
            gejala:id_gejala(id_gejala, kode_gejala, nama_gejala),
            cedera:id_cedera(id_cedera, kode_cedera, nama_cedera)
          ''')
          .eq('id_cedera', cederaId)
          .order('id_aturan', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data basis aturan: $e');
    }
  }

  // Tambah Data
  Future<void> addBasisAturan(int gejalaId, int cederaId, double bobot) async {
    try {
      await _client.from('aturan').insert({
        'id_gejala': gejalaId,
        'id_cedera': cederaId,
        'bobot_cf_pakar': bobot, // PERBAIKAN: Nama kolom
      });
    } catch (e) {
      throw Exception('Gagal menambah basis aturan: $e');
    }
  }

  // Update Data
  Future<void> updateBasisAturan(int id, int gejalaId, int cederaId, double bobot) async {
    try {
      await _client.from('aturan').update({
        'id_gejala': gejalaId,
        'id_cedera': cederaId,
        'bobot_cf_pakar': bobot, // PERBAIKAN: Nama kolom
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_aturan', id);
    } catch (e) {
      throw Exception('Gagal mengupdate basis aturan: $e');
    }
  }

  // Hapus Data
  Future<void> deleteBasisAturan(int id) async {
    try {
      await _client.from('aturan').delete().eq('id_aturan', id);
    } catch (e) {
      throw Exception('Gagal menghapus basis aturan: $e');
    }
  }
}