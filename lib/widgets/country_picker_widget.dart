import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

// Stub: CountryModel (placeholder)
class CountryModel {
  final String code;
  final String name;
  final String flag;
  
  CountryModel({required this.code, required this.name, required this.flag});
  
  @override
  operator ==(Object other) => identical(this, other) || other is CountryModel && runtimeType == other.runtimeType && code == other.code;
  
  @override
  int get hashCode => code.hashCode;
}

// Stub: CountryList
class CountryList {
  static final List<CountryModel> countries = [
    CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID'),
    CountryModel(code: 'MY', name: 'Malaysia', flag: 'MY'),
    CountryModel(code: 'SG', name: 'Singapore', flag: 'SG'),
    CountryModel(code: 'PH', name: 'Philippines', flag: 'PH'),
    CountryModel(code: 'TH', name: 'Thailand', flag: 'TH'),
    CountryModel(code: 'VN', name: 'Vietnam', flag: 'VN'),
    CountryModel(code: 'JP', name: 'Japan', flag: 'JP'),
    CountryModel(code: 'KR', name: 'South Korea', flag: 'KR'),
    CountryModel(code: 'US', name: 'United States', flag: 'US'),
    CountryModel(code: 'GB', name: 'United Kingdom', flag: 'GB'),
  ];
}

// Stub: AppLocale (placeholder)
class AppLocale {
  static const String phoneNumberCountryCodeId = '+62';
  static const String phoneNumberCountryCodeMy = '+60';
  static const String phoneNumberCountryCodeSg = '+65';
  static const String phoneNumberCountryCodePh = '+63';
  static const String phoneNumberCountryCodeTh = '+66';
  static const String phoneNumberCountryCodeVn = '+84';
  static const String phoneNumberCountryCodeJp = '+81';
  static const String phoneNumberCountryCodeKr = '+82';
  static const String phoneNumberCountryCodeUs = '+1';
  static const String phoneNumberCountryCodeUk = '+44';
}

class CountryPickerButton extends StatelessWidget {
  final CountryModel selectedCountry;
  final Function(CountryModel) onCountrySelected;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CountryPickerButton({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          border: Border.all(color: borderColor ?? Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCountry.code.isEmpty)
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.grey),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CountryFlag.fromCountryCode(
                    selectedCountry.flag,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Code - tampilkan "No Selection" text jika code kosong
            Text(
              selectedCountry.code.isEmpty ? 'No Selection' : selectedCountry.code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            // Dropdown icon
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: textColor ?? Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: selectedCountry,
        onCountrySelected: onCountrySelected,
      ),
    );
  }

  /// Dapatkan kode telepon negara
  String getPhoneCountryCode(String countryKey) {
    final countryToPhoneCode = {
      'ID': AppLocale.phoneNumberCountryCodeId,
      'MY': AppLocale.phoneNumberCountryCodeMy,
      'SG': AppLocale.phoneNumberCountryCodeSg,
      'PH': AppLocale.phoneNumberCountryCodePh,
      'TH': AppLocale.phoneNumberCountryCodeTh,
      'VN': AppLocale.phoneNumberCountryCodeVn,
      'JP': AppLocale.phoneNumberCountryCodeJp,
      'KR': AppLocale.phoneNumberCountryCodeKr,
      'US': AppLocale.phoneNumberCountryCodeUs,
      'GB': AppLocale.phoneNumberCountryCodeUk,
    };
    return countryToPhoneCode[countryKey] ?? '';
  }
}

class _CountryPickerSheet extends StatelessWidget {
  final CountryModel selectedCountry;
  final Function(CountryModel) onCountrySelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Negara',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Country List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: CountryList.countries.length,
              itemBuilder: (context, index) {
                final country = CountryList.countries[index];
                final isSelected = country == selectedCountry;
                final countryName = _getCountryName(context, country);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onCountrySelected(country);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode ? Colors.blue[900] : Colors.blue[50])
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          // Flag
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CountryFlag.fromCountryCode(
                                country.flag,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Country info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  countryName,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected ? Colors.blue : null,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  country.code,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Cek tanda
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 24,
                            )
                          else
                            SizedBox(
                              width: 24,
                              child: Icon(
                                Icons.circle_outlined,
                                color: isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[300],
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(BuildContext context, CountryModel country) {
    final countryNames = {
      'ID': 'Indonesia',
      'MY': 'Malaysia',
      'SG': 'Singapore',
      'PH': 'Philippines',
      'TH': 'Thailand',
      'VN': 'Vietnam',
      'JP': 'Japan',
      'KR': 'South Korea',
      'US': 'United States',
      'GB': 'United Kingdom',
    };

    return countryNames[country.code] ?? country.code;
  }
}
