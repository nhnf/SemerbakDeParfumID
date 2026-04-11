// DatabaseHelper tidak lagi digunakan karena aplikasi sudah migrasi ke Supabase.
// File ini dipertahankan agar sqflite tidak menyebabkan error build,
// namun tidak diinstansiasi di mana pun dalam aplikasi.
//
// Jika ingin menghapus sqflite sepenuhnya nanti, hapus juga package
// sqflite, sqflite_common_ffi, dan path dari pubspec.yaml.

class DatabaseHelper {
  // Tidak digunakan - lihat SupabaseDataSource untuk implementasi aktif
}
