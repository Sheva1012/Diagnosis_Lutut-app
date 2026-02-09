import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class DiagnosisService {
  final SupabaseClient _client = SupabaseConfig.client;

  // 1. Ambil Pertanyaan (Gejala)
  Future<List<Map<String, dynamic>>> getPertanyaanGejala() async {
    try {
      final response = await _client
          .from('gejala')
          .select()
          .order('id_gejala', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat pertanyaan: $e');
    }
  }

  // 2. Ambil Aturan Pakar (PERBAIKAN NAMA KOLOM DI SINI)
  Future<List<Map<String, dynamic>>> getAturanPakar() async {
    try {
      final response = await _client.from('aturan').select('''
        *,
        cedera:id_cedera (
          id_cedera,
          nama_cedera,
          penanganan (
            penanganan_awal,
            penanganan_lanjutan  
          )
        )
      '''); // ^^^ Pastikan pakai 'penanganan_lanjutan'
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat aturan pakar: $e');
    }
  }

  // 3. Simpan Hasil Diagnosis (Tetap sama)
  Future<void> saveDiagnosis({
    required int idCedera,
    required double nilaiCfFinal,
    required double persentase,
    required String tingkatKepastian,
    required List<Map<String, dynamic>> detailJawaban,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      // Insert Header
      final diagnosisData = await _client
          .from('diagnosis')
          .insert({
            'id_user': user.id,
            'id_cedera': idCedera,
            'nilai_cf_final': nilaiCfFinal,
            'persentase_cf': persentase,
            'tingkat_kepastian': tingkatKepastian,
            'tanggal_diagnosis': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final int idDiagnosis = diagnosisData['id_diagnosis'];

      // Insert Detail
      final List<Map<String, dynamic>> details = detailJawaban.map((item) {
        return {
          'id_diagnosis': idDiagnosis,
          'id_gejala': item['id_gejala'],
          'jawaban_user': item['label'], 
          'nilai_cf_user': item['cf_user'],
          // 'nilai_cf_gejala': item['cf_hasil_kali'], // Opsional jika kolom ada
        };
      }).toList();

      if (details.isNotEmpty) {
        await _client.from('detail_diagnosis').insert(details);
      }
    } catch (e) {
      throw Exception('Gagal menyimpan diagnosis: $e');
    }
  }
}