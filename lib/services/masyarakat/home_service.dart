import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart'; // Pastikan path ke config benar

class HomeService {
  // Menggunakan Client dari SupabaseConfig
  final SupabaseClient _client = SupabaseConfig.client;

  /// Mengambil Username User yang sedang login
  Future<String> getCurrentUserName() async {
    try {
      final user = _client.auth.currentUser;
      
      // Jika tidak ada user login, kembalikan default
      if (user == null) return "Pengunjung";

      // Query ke tabel 'users' mengambil kolom 'username'
      final data = await _client
          .from('users')
          .select('username') // KITA UBAH DISINI: Ambil 'username' saja
          .eq('id_user', user.id)
          .single();

      // Kembalikan username. Jika null, pakai "User"
      return data['username'] ?? "User";
    } catch (e) {
      return "User"; 
    }
  }
}