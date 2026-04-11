// TransactionLocalDataSource tidak lagi digunakan karena aplikasi migrasi ke Supabase.
// File dipertahankan agar tidak ada broken imports.
// Lihat SupabaseDataSource untuk implementasi aktif.

abstract class TransactionLocalDataSource {}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {}
