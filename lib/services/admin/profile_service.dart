import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔥 GET PROFILE
  Future<Map<String, String>> getProfile() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        return {
          'nama_lengkap': '',
          'username': '',
          'email': '',
          'no_hp': '-',
          'joined_at': '-',
          'foto': '',
        };
      }

      final data = await _client
          .from('users')
          .select(
            'nama_lengkap, username, no_telepon, created_at, email, foto_profil',
          )
          .eq('id_user', user.id)
          .maybeSingle();

      if (data == null) {
        return {
          'nama_lengkap': '',
          'username': '',
          'email': user.email ?? '',
          'no_hp': '-',
          'joined_at': '-',
          'foto': '',
        };
      }

      return {
        'nama_lengkap':
            (data['nama_lengkap'] != null &&
                data['nama_lengkap'].toString().isNotEmpty)
            ? data['nama_lengkap']
            : (data['username'] ?? ''),

        'username': data['username'] ?? '',

        'email': data['email'] ?? user.email ?? '',

        'no_hp':
            (data['no_telepon'] != null &&
                data['no_telepon'].toString().isNotEmpty)
            ? data['no_telepon']
            : '-',

        'joined_at': _formatDate(data['created_at']),

        'foto': data['foto_profil'] ?? '',
      };
    } catch (e) {
      return {
        'nama_lengkap': '',
        'username': '',
        'email': '',
        'no_hp': '-',
        'joined_at': '-',
        'foto': '',
      };
    }
  }

  /// 🔥 UPDATE PROFILE
  Future<void> updateProfile({
    required String username,
    required String nama,
    required String noHp,
    File? imageFile,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      String? imageUrl;

      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _client.storage
            .from('avatars')
            .upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      }

      final updates = {
        'username': username,
        'nama_lengkap': nama,
        'no_telepon': noHp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        updates['foto_profil'] = imageUrl;
      }

      final response = await _client
          .from('users')
          .update(updates)
          .eq('id_user', user.id)
          .select();

      if (response.isEmpty) {
        throw Exception("Update gagal (cek RLS / data)");
      }
    } catch (e) {
      throw Exception("Gagal update profil: ${e.toString()}");
    }
  }

  /// 🔥 FORMAT TANGGAL
  String _formatDate(String? isoDate) {
    try {
      if (isoDate == null || isoDate.isEmpty) return "-";

      final dt = DateTime.parse(isoDate);

      const months = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
      ];

      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
