class Country {
  final String kode;      // misal: 'ID'
  final String nama;      // misal: 'Indonesia'
  final String kodeDial;  // misal: '+62'

  const Country({
    required this.kode,
    required this.nama,
    required this.kodeDial,
  });

  Map<String, dynamic> toMap() {
    return {
      'kode': kode,
      'nama': nama,
      'kodeDial': kodeDial,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      kode: map['kode'] ?? map['code'] ?? '',
      nama: map['nama'] ?? map['name'] ?? '',
      kodeDial: map['kodeDial'] ?? map['dialCode'] ?? '',
    );
  }
}

final List<Country> countries = [
  Country(kode: 'ID', nama: 'Indonesia', kodeDial: '+62'),
  Country(kode: 'SG', nama: 'Singapura', kodeDial: '+65'),
  Country(kode: 'MY', nama: 'Malaysia', kodeDial: '+60'),
  Country(kode: 'TH', nama: 'Thailand', kodeDial: '+66'),
  Country(kode: 'PH', nama: 'Filipina', kodeDial: '+63'),
  Country(kode: 'VN', nama: 'Vietnam', kodeDial: '+84'),
  Country(kode: 'BD', nama: 'Bangladesh', kodeDial: '+880'),
  Country(kode: 'IN', nama: 'India', kodeDial: '+91'),
  Country(kode: 'US', nama: 'Amerika Serikat', kodeDial: '+1'),
  Country(kode: 'GB', nama: 'Inggris', kodeDial: '+44'),
  Country(kode: 'AU', nama: 'Australia', kodeDial: '+61'),
  Country(kode: 'CA', nama: 'Kanada', kodeDial: '+1'),
  Country(kode: 'JP', nama: 'Jepang', kodeDial: '+81'),
  Country(kode: 'CN', nama: 'China', kodeDial: '+86'),
  Country(kode: 'KR', nama: 'Korea Selatan', kodeDial: '+82'),
  Country(kode: 'BR', nama: 'Brasil', kodeDial: '+55'),
  Country(kode: 'MX', nama: 'Mexico', kodeDial: '+52'),
  Country(kode: 'DE', nama: 'Jerman', kodeDial: '+49'),
  Country(kode: 'FR', nama: 'Prancis', kodeDial: '+33'),
  Country(kode: 'AE', nama: 'Uni Emirat Arab', kodeDial: '+971'),
];

// Cari negara berdasarkan kode
Country? cariNegaraBerdasarkanKode(String kode) {
  try {
    return countries.firstWhere((c) => c.kode == kode);
  } catch (e) {
    return null;
  }
}

// Cari negara berdasarkan kode dial
Country? cariNegaraBerdasarkanKodeDial(String kodeDial) {
  try {
    return countries.firstWhere((c) => c.kodeDial == kodeDial);
  } catch (e) {
    return null;
  }
}

// Cari negara
List<Country> cariNegara(String kueri) {
  if (kueri.isEmpty) return countries;
  final kueriKecil = kueri.toLowerCase();
  return countries
      .where((negara) =>
          negara.nama.toLowerCase().contains(kueriKecil) ||
          negara.kode.toLowerCase().contains(kueriKecil) ||
          negara.kodeDial.contains(kueri))
      .toList();
}
