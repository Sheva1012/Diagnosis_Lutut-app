import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://hxuygiujxqcjfnsrlyto.supabase.co';

  static const String supabaseAnonKey =
      'sb_publishable_yLJ-nrgDmjskOt0iS85Y4Q_qTRDJGA9';

  static SupabaseClient get client => Supabase.instance.client;
}
