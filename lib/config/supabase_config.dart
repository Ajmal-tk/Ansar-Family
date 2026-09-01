/// Supabase configuration constants for Ansar Family
/// Replace placeholder values with your exact Supabase project URL & Anon API Key.
class SupabaseConfig {

  // YOUR SUPABASE URL & ANON KEY
  // static const String supabaseUrl = String.fromEnvironment(
  //   'SUPABASE_URL',
  //   defaultValue: 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co',
  // );

  static const String supabaseUrl = String.fromEnvironment(
     'SUPABASE_URL',
     defaultValue: 'https://vwuemjomullnhfmkkwws.supabase.co',
   );

  static const String supabaseAnonKey = String.fromEnvironment(
  //  'SUPABASE_ANON_KEY',
  //  defaultValue: 'YOUR_SUPABASE_ANON_KEY',
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_hrCyK0lXFe5aLHZwimnRcg_rF7LXPo_',
  );

  /// Check if valid credentials are model defaults or real keys
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');
  }
}

