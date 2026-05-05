import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class StatistikService {
  final SupabaseClient _client = SupabaseConfig.client;

  String _formatDateTimeForQuery(DateTime value) {
    // Gunakan format 'YYYY-MM-DD HH:mm:ss' agar kompatibel untuk kolom timestamp.
    final iso = value.toIso8601String().replaceFirst('T', ' ');
    return iso.replaceAll('Z', '');
  }

  // 1. Hitung Total Diagnosis (Realtime Count)
  Future<int> getTotalDiagnosis() async {
    try {
      // Menggunakan count dengan head: true agar hemat bandwidth (tidak download data)
      final response = await _client
          .from('diagnosis')
          .count(CountOption.exact); // Syntax Supabase v2 terbaru
      
      return response;
    } catch (e) {
      print("Error Total: $e");
      return 0;
    }
  }

  // 2. Ambil Cedera Terbanyak (Logika Dart)
  Future<Map<String, dynamic>?> getCederaTerbanyak() async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('id_cedera');

      if (response.isEmpty) return null;

      final frekuensiById = <String, int>{};
      for (final item in response) {
        final idCedera = item['id_cedera'];
        if (idCedera == null) continue;
        final key = idCedera.toString();
        frekuensiById[key] = (frekuensiById[key] ?? 0) + 1;
      }

      if (frekuensiById.isEmpty) return null;

      final idList = frekuensiById.keys.toList();
      final cederaResponse = await _client
          .from('cedera')
          .select('id_cedera,nama_cedera')
          .inFilter('id_cedera', idList);

      final namaById = <String, String>{};
      for (final item in cederaResponse) {
        final id = item['id_cedera']?.toString();
        if (id == null) continue;
        namaById[id] = item['nama_cedera']?.toString() ?? 'Lainnya';
      }

      final sorted = frekuensiById.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sorted.isNotEmpty) {
        final topId = sorted.first.key;
        return {
          'nama_cedera': namaById[topId] ?? 'Lainnya',
          'jumlah': sorted.first.value
        };
      }
      return null;
    } catch (e) {
      print('Error Cedera Terbanyak: $e');
      return null;
    }
  }

  // 3. Ambil Statistik Bulanan (Logika Dart)
  // Mengembalikan List berisi 12 angka (Jan-Des) untuk Grafik
  Future<List<int>> getStatistikBulanan(int tahun) async {
    try {
      // Ambil data tanggal saja untuk tahun yang dipilih
      final response = await _client
          .from('diagnosis')
          .select('tanggal_diagnosis')
          .gte('tanggal_diagnosis', '$tahun-01-01')
          .lte('tanggal_diagnosis', '$tahun-12-31');

      // Siapkan wadah 12 bulan (index 0 = Jan, index 11 = Des)
      List<int> bulanan = List.filled(12, 0);

      for (var item in response) {
        final tglString = item['tanggal_diagnosis'];
        if (tglString != null) {
          final tgl = DateTime.parse(tglString);
          // tgl.month return 1-12, kita butuh index 0-11
          if (tgl.month >= 1 && tgl.month <= 12) {
            bulanan[tgl.month - 1]++;
          }
        }
      }
      return bulanan;
    } catch (e) {
      print('Error Statistik Bulanan: $e');
      return List.filled(12, 0);
    }
  }

  // 4. Ambil 5 Riwayat Terakhir
  Future<List<Map<String, dynamic>>> getRiwayatTerbaru({int limit = 5}) async {
    try {
      final response = await _client
          .from('diagnosis')
          .select('*')
          .order('tanggal_diagnosis', ascending: false) // Pastikan nama kolom benar
          .limit(limit);

      final diagnosisRows = List<Map<String, dynamic>>.from(response);
      return await _attachRelations(diagnosisRows);
    } catch (e) {
      print('Error Riwayat: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _attachRelations(
    List<Map<String, dynamic>> diagnosisRows,
  ) async {
    if (diagnosisRows.isEmpty) return diagnosisRows;

    final userIds = diagnosisRows
        .map((e) => e['id_user'])
        .where((id) => id != null)
        .map((id) => id.toString())
        .toSet()
        .toList();

    final cederaIds = diagnosisRows
        .map((e) => e['id_cedera'])
        .where((id) => id != null)
        .map((id) => id.toString())
        .toSet()
        .toList();

    final userMap = <String, String>{};
    final cederaMap = <String, String>{};

    try {
      if (userIds.isNotEmpty) {
        final usersResponse = await _client
            .from('users')
            .select('id_user,nama_lengkap')
            .inFilter('id_user', userIds);

        for (final user in usersResponse) {
          final id = user['id_user']?.toString();
          if (id == null) continue;
          userMap[id] = user['nama_lengkap']?.toString() ?? '-';
        }
      }
    } catch (_) {
      // Abaikan kegagalan join users agar diagnosis tetap tampil.
    }

    try {
      if (cederaIds.isNotEmpty) {
        final cederaResponse = await _client
            .from('cedera')
            .select('id_cedera,nama_cedera')
            .inFilter('id_cedera', cederaIds);

        for (final cedera in cederaResponse) {
          final id = cedera['id_cedera']?.toString();
          if (id == null) continue;
          cederaMap[id] = cedera['nama_cedera']?.toString() ?? '-';
        }
      }
    } catch (_) {
      // Abaikan kegagalan join cedera agar diagnosis tetap tampil.
    }

    for (final row in diagnosisRows) {
      final idUser = row['id_user']?.toString();
      final idCedera = row['id_cedera']?.toString();

      row['users'] = {
        'nama_lengkap': idUser != null ? (userMap[idUser] ?? '-') : '-',
      };
      row['cedera'] = {
        'nama_cedera': idCedera != null ? (cederaMap[idCedera] ?? '-') : '-',
      };
    }

    return diagnosisRows;
  }

  // 5. Ambil Riwayat Berdasarkan Filter (Hari/Bulan/Tahun)
  Future<List<Map<String, dynamic>>> getRiwayatByFilter({
    required String filterType,
    required DateTime selectedDate,
    DateTime? rangeStartDate,
    DateTime? rangeEndDate,
    int limit = 500,
  }) async {
    try {
      var startOfDay = DateTime(
        (rangeStartDate ?? selectedDate).year,
        (rangeStartDate ?? selectedDate).month,
        (rangeStartDate ?? selectedDate).day,
      );
      var endOfDay = DateTime(
        (rangeEndDate ?? rangeStartDate ?? selectedDate).year,
        (rangeEndDate ?? rangeStartDate ?? selectedDate).month,
        (rangeEndDate ?? rangeStartDate ?? selectedDate).day,
      );

      if (endOfDay.isBefore(startOfDay)) {
        final temp = startOfDay;
        startOfDay = endOfDay;
        endOfDay = temp;
      }

      final startOfNextDay = endOfDay.add(const Duration(days: 1));
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final startOfNextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      final startOfYear = DateTime(selectedDate.year, 1, 1);
      final startOfNextYear = DateTime(selectedDate.year + 1, 1, 1);

      final baseQuery = _client
          .from('diagnosis')
          .select('*');

      dynamic response;
      final dayStart = _formatDateTimeForQuery(startOfDay);
      final dayEnd = _formatDateTimeForQuery(startOfNextDay);
      final monthStart = _formatDateTimeForQuery(startOfMonth);
      final monthEnd = _formatDateTimeForQuery(startOfNextMonth);
      final yearStart = _formatDateTimeForQuery(startOfYear);
      final yearEnd = _formatDateTimeForQuery(startOfNextYear);

      if (filterType == 'Hari') {
        response = await baseQuery
        .gte('tanggal_diagnosis', dayStart)
        .lt('tanggal_diagnosis', dayEnd)
            .order('tanggal_diagnosis', ascending: false)
            .limit(limit);
      } else if (filterType == 'Bulan') {
        response = await baseQuery
        .gte('tanggal_diagnosis', monthStart)
        .lt('tanggal_diagnosis', monthEnd)
            .order('tanggal_diagnosis', ascending: false)
            .limit(limit);
      } else {
        response = await baseQuery
        .gte('tanggal_diagnosis', yearStart)
        .lt('tanggal_diagnosis', yearEnd)
            .order('tanggal_diagnosis', ascending: false)
            .limit(limit);
      }

      // Fallback jika data lama belum mengisi `tanggal_diagnosis` tetapi ada `created_at`.
      if ((response as List).isEmpty) {
        if (filterType == 'Hari') {
          response = await baseQuery
          .gte('created_at', dayStart)
          .lt('created_at', dayEnd)
          .order('created_at', ascending: false)
          .limit(limit);
        } else if (filterType == 'Bulan') {
          response = await baseQuery
          .gte('created_at', monthStart)
          .lt('created_at', monthEnd)
          .order('created_at', ascending: false)
          .limit(limit);
        } else {
          response = await baseQuery
          .gte('created_at', yearStart)
          .lt('created_at', yearEnd)
          .order('created_at', ascending: false)
          .limit(limit);
        }
      }

      final diagnosisRows = List<Map<String, dynamic>>.from(response);
      return await _attachRelations(diagnosisRows);
    } catch (e) {
      print('Error Riwayat Filter: $e');
      return [];
    }
  }
}