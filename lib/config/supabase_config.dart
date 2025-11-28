class SupabaseConfig {
  // Adicione suas credenciais do Supabase aqui
  // Você pode obté-las em https://app.supabase.com
  
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Tabelas do banco de dados
  static const String usersTable = 'users';
  static const String devocionaisTable = 'devocionais';
  static const String oracoesTable = 'oracoes';
  static const String comunidadeTable = 'comunidade';
  
  // Buckets de storage
  static const String audiosBucket = 'audios';
  static const String imagensBucket = 'imagens';
}
