import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/supabase_client.dart';

class PenggunaService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Ambil semua pengguna (Admin + Masyarakat)
  Future<List<Map<String, dynamic>>> getAllPengguna() async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: $e');
    }
  }

  // Search pengguna
  Future<List<Map<String, dynamic>>> searchPengguna(String query) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .or('nama_lengkap.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mencari data pengguna: $e');
    }
  }

  // Total Pengguna (Admin + Masyarakat)
  Future<int> getTotalPengguna() async {
    try {
      final data = await _client.from('users').select();
      return data.length;
    } catch (e) {
      throw Exception('Gagal menghitung total pengguna: $e');
    }
  }

  // Menambah Admin
  Future<void> addPengguna({
    required String email,
    required String password,
    required String namaLengkap,
    required String role,
    String? username,
  }) async {
    try {
      final url = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/signup');
      final response = await http.post(
        url,
        headers: {
          'apikey': SupabaseConfig.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'data': {
            'nama_lengkap': namaLengkap,
            'role': role,
            'username': username,
          }
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['msg'] ?? 'Gagal mendaftar');
      }

      final resData = jsonDecode(response.body);
      final newUserId = resData['user'] != null ? resData['user']['id'] : resData['id'];
      final accessToken = resData['access_token'] ?? resData['session']?['access_token'];

      if (newUserId != null) {
        if (accessToken != null) {
          // Bypass RLS using the new user's access token
          final insertUrl = Uri.parse('${SupabaseConfig.supabaseUrl}/rest/v1/users');
          final insertRes = await http.post(
            insertUrl,
            headers: {
              'apikey': SupabaseConfig.supabaseAnonKey,
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
              'Prefer': 'resolution=merge-duplicates'
            },
            body: jsonEncode({
              'id_user': newUserId,
              'email': email,
              'nama_lengkap': namaLengkap,
              'role': role,
              'username': username,
            }),
          );

          if (insertRes.statusCode >= 400) {
            print("Gagal insert profile: ${insertRes.body}");
            throw Exception('Pengguna dibuat tapi gagal menyimpan profil.');
          }
        } else {
          // Fallback if no session was returned
          await _client.from('users').upsert({
            'id_user': newUserId,
            'email': email,
            'nama_lengkap': namaLengkap,
            'role': role,
            'username': username,
          });
        }
      }
    } catch (e) {
      throw Exception('Gagal menambah pengguna: $e');
    }
  }

  // Update Admin saja
  Future<void> updatePengguna({
    required String userId,
    required String namaLengkap,
    required String email,
    String? username,
  }) async {
    try {
      await _client
          .from('users')
          .update({
            'nama_lengkap': namaLengkap,
            'email': email,
            'username': username,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_user', userId);
    } catch (e) {
      throw Exception('Gagal update pengguna: $e');
    }
  }

  // Hapus Pengguna (auth + tabel users sekaligus)
  Future<void> deletePengguna(String userId) async {
    try {
      await _client.rpc('delete_user', params: {'user_id': userId});
    } catch (e) {
      throw Exception('Gagal hapus pengguna: $e');
    }
  }
}
