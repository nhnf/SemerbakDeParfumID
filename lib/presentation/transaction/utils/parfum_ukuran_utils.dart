/// Opsi ukuran parfum yang tersedia
class UkuranOption {
  final String value; // nilai yang disimpan, misal "6ML"
  final String label; // label tampil, misal "6 ML"

  const UkuranOption({required this.value, required this.label});
}

const List<UkuranOption> ukuranList = [
  UkuranOption(value: '6ML', label: '6 ML'),
  UkuranOption(value: '10ML', label: '10 ML'),
  UkuranOption(value: '20ML', label: '20 ML'),
  UkuranOption(value: '30ML BB', label: '30 ML BB'),
  UkuranOption(value: '30ML BK', label: '30 ML BK'),
  UkuranOption(value: '50ML', label: '50 ML'),
  UkuranOption(value: '100ML', label: '100 ML'),
];

/// Opsi kualitas parfum
class KualitasOption {
  final String value;
  final String label;

  const KualitasOption({required this.value, required this.label});
}

const List<KualitasOption> kualitasList = [
  KualitasOption(value: '1:2', label: '1:2'),
  KualitasOption(value: '1:1', label: '1:1'),
  KualitasOption(value: '2:1', label: '2:1'),
];

/// Kategori bahan baku
const List<String> kategoriBahanList = [
  'Botol',
  'Alkohol',
  'Bibit Parfum',
  'Lainnya'
];
