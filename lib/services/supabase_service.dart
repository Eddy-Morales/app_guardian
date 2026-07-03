import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Debe ser 'static' y retornar 'SupabaseClient'
  static SupabaseClient get client => Supabase.instance.client;
}