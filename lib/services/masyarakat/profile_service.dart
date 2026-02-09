import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import 'dart:io'; // Wajib import ini untuk menangani File gambar

class ProfileService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Mengambil Data Profil User Lengkap
  Future<Map<String, String>> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        return {
          'header_name': 'Pengunjung',
          'nama_asli': '-',
          'email': '-',
          'no_hp': '-',
          'joined_at': '-',
          'foto_profil': '', // Default kosong
        };
      }

      // 1. UPDATE: Tambahkan 'foto_profil' di query select
      final data = await _client
          .from('users')
          .select('nama_lengkap, username, no_telepon, created_at, email, foto_profil') 
          .eq('id_user', user.id)
          .single();

      // Logika nama
      String? dbNamaLengkap = data['nama_lengkap'];
      String? dbUsername = data['username'];
      String displayHeader = dbNamaLengkap ?? dbUsername ?? 'User';
      String realNamaLengkap = dbNamaLengkap ?? '-';

      String displayEmail = data['email'] ?? user.email ?? '-';
      String displayPhone = data['no_telepon'] ?? '-';
      String rawDate = data['created_at'] ?? DateTime.now().toIso8601String();
      
      // 2. UPDATE: Ambil URL foto profil dari database
      String fotoProfil = data['foto_profil'] ?? '';

      return {
        'header_name': displayHeader,
        'nama_asli': realNamaLengkap,
        'email': displayEmail,
        'no_hp': displayPhone,
        'joined_at': _formatDate(rawDate),
        'foto_profil': fotoProfil, // Kembalikan URL foto
      };
    } catch (e) {
      final user = _client.auth.currentUser;
      return {
        'header_name': 'User',
        'nama_asli': '-',
        'email': user?.email ?? '-',
        'no_hp': '-',
        'joined_at': '-',
        'foto_profil': '',
      };
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
      ];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return isoDate;
    }
  }

  /// Update Data Profil (Nama, No HP, & Foto)
  Future<void> updateUserProfile({
    required String namaLengap,
    required String noTelepon,
    File? imageFile, // Parameter Opsional: File Gambar
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan/belum login");

      String? imageUrl;

      // --- LOGIKA UPLOAD FOTO (Jika user memilih gambar baru) ---
      if (imageFile != null) {
        // Buat nama file unik: user_id/timestamp.ext
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        // Upload ke bucket 'avatars'
        await _client.storage.from('avatars').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true), // Timpa jika ada nama sama
        );

        // Dapatkan URL Publik agar bisa disimpan di database
        imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      }

      // --- PERSIAPAN DATA UPDATE ---
      final updates = {
        'nama_lengkap': namaLengap,
        'no_telepon': noTelepon,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Hanya masukkan foto_profil ke update query JIKA ada gambar baru
      if (imageUrl != null) {
        updates['foto_profil'] = imageUrl;
      }

      // --- EKSEKUSI UPDATE KE DATABASE ---
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id_user', user.id)
          .select(); // Penting: .select() untuk memastikan data terupdate

      if (response.isEmpty) {
        throw Exception(
          "Gagal update! Izin ditolak atau data user tidak ditemukan di database.",
        );
      }
    } catch (e) {
      throw Exception("Gagal: ${e.toString()}");
    }
  }
}