import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:uts_backend/i10n/countries.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? initialCountryCode;
  final Function(String fullPhone, String countryCode, String phoneNumber)? onChanged;
  final String? labelText;
  final String? hintText;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool enabled;
  final double? height;
  final double? fontSize;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.initialCountryCode,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.primaryColor,
    this.backgroundColor,
    this.enabled = true,
    this.height,
    this.fontSize,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late Country _selectedCountry;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCountry();
    _parseExistingPhone();
  }

  void _initializeCountry() {
    // Ambil locale dari device
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final countryCode = widget.initialCountryCode ?? deviceLocale.countryCode ?? 'ID';
    
    // Cari negara berdasarkan kode, default ke Indonesia
    _selectedCountry = cariNegaraBerdasarkanKode(countryCode) ?? 
                       countries.firstWhere((c) => c.kode == 'ID');
  }

  void _parseExistingPhone() {
    final existingPhone = widget.controller.text;
    if (existingPhone.isNotEmpty) {
      // Coba parse country code dari nomor yang ada
      for (final country in countries) {
        if (existingPhone.startsWith(country.kodeDial)) {
          setState(() {
            _selectedCountry = country;
            _phoneController.text = existingPhone.substring(country.kodeDial.length);
          });
          return;
        }
      }
      // Jika tidak ada prefix, gunakan nomor as-is
      _phoneController.text = existingPhone.replaceAll(RegExp(r'[^\d]'), '');
    }
  }

  void _updateFullPhone() {
    // Hapus leading 0 setelah kode negara (contoh: 0812 -> 812)
    String phoneNumber = _phoneController.text;
    while (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    
    // Update controller jika ada perubahan
    if (phoneNumber != _phoneController.text) {
      _phoneController.text = phoneNumber;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneNumber.length),
      );
    }
    
    final fullPhone = '${_selectedCountry.kodeDial}$phoneNumber';
    widget.controller.text = fullPhone;
    widget.onChanged?.call(fullPhone, _selectedCountry.kode, phoneNumber);
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
        onSelect: (country) {
          setState(() {
            _selectedCountry = country;
          });
          _updateFullPhone();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? const Color(0xFF009688);
    final bgColor = widget.backgroundColor ?? const Color(0xFFF5F5F5);
    final fieldHeight = widget.height ?? 56.0;
    final textSize = widget.fontSize ?? 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        Container(
          height: fieldHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // Country Selector
              InkWell(
                onTap: widget.enabled ? _showCountryPicker : null,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(20),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFlagEmoji(_selectedCountry.kode),
                        style: TextStyle(fontSize: textSize + 4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountry.kodeDial,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          fontSize: textSize,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: primaryColor,
                        size: textSize + 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Phone Input
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                    _NoLeadingZeroFormatter(), // Blokir 0 di awal
                  ],
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? '812 3456 7890',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: textSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (value) => _updateFullPhone(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFlagEmoji(String countryCode) {
    final firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final Country selectedCountry;
  final Function(Country) onSelect;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = countries;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = cariNegara(query);
    });
  }

  String _getFlagEmoji(String countryCode) {
    final firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Negara',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari negara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterCountries,
              ),
            ),
            const SizedBox(height: 8),
            // Country List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = country.kode == widget.selectedCountry.kode;
                  
                  return ListTile(
                    leading: Text(
                      _getFlagEmoji(country.kode),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.nama,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.kodeDial,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check, color: Color(0xFF009688)),
                        ],
                      ],
                    ),
                    onTap: () => widget.onSelect(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
/// Custom formatter untuk mencegah angka 0 di awal nomor telepon
/// Karena setelah kode negara (+62), nomor tidak boleh dimulai dengan 0
/// Contoh: +62 0812... salah → harus +62 812...
class _NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika input kosong, biarkan
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Hapus semua leading zeros
    String newText = newValue.text;
    while (newText.startsWith('0')) {
      newText = newText.substring(1);
    }
    
    // Jika teks berubah, kembalikan dengan cursor di akhir
    if (newText != newValue.text) {
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    
    return newValue;
  }
}