import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_backend/services/account_manager.dart';
import 'package:uts_backend/services/coupon_service.dart';
import 'package:uts_backend/services/reward_service.dart';
import 'package:uts_backend/providers/auth_provider.dart';
import 'package:uts_backend/pages/forget_password.dart';
import 'package:uts_backend/pages/kupon_saya_page.dart';
import 'package:uts_backend/pages/login/login_page.dart';
import 'package:uts_backend/pages/reward_page.dart';
import 'package:uts_backend/widgets/phone_input_field.dart';
import 'package:uts_backend/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_backend/providers/theme_provider.dart';
import 'dart:convert';

class Profil extends StatefulWidget {
  final int id;
  const Profil({super.key, required this.id});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {

  final AccountManager _accountManager = AccountManager();
  
  String? name;
  String? password;
  String? email;
  String? nohp;
  String? levelSkill;
  String? photoUrl; 
  bool _isLoading = true;
  bool _isSaving = false; 
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImageBytes;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Level skill
  final List<String> _levelOptions = ['Beginner', 'Intermediate', 'Advanced', 'Pro'];

  int bookCourtCount = 12;
  int sparringCount = 8;
  int mabarCount = 15;

  Future<void> _fastInit() async {
    Uint8List? localImageBytes;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imageData = prefs.getString('profile_image_${widget.id}');
      if (imageData != null && imageData.isNotEmpty) {
        localImageBytes = base64Decode(imageData);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading local image: $e');
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser != null) {
      setState(() {
        if (localImageBytes != null) {
          _profileImageBytes = localImageBytes;
        }
        name = firebaseUser.displayName ?? 'User';
        email = firebaseUser.email ?? '-';
        if (localImageBytes == null) {
          photoUrl = firebaseUser.photoURL;
        }
        _isLoading = false;
      });
      await _fetchFirestoreData();
    } else {
      if (localImageBytes != null) {
        setState(() {
          _profileImageBytes = localImageBytes;
        });
      }
      await _fetchFirestoreData();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fetch data dari Firestore (background)
  Future<void> _fetchFirestoreData() async {
    try {
      var data = await _accountManager.getUserProfile(widget.id);
      
      if (data != null && mounted) {
        setState(() {
          name = data["name"]?.toString() ?? name;
          password = data["password"]?.toString() ?? "";
          email = data["email"]?.toString() ?? email;
          nohp = data["phone"]?.toString() ?? "Nomor tidak tersedia";
          levelSkill = data["level_skill"]?.toString() ?? "Beginner";
          if (_profileImageBytes == null) {
            if (data["photo_url"] != null && data["photo_url"].toString().isNotEmpty) {
              photoUrl = data["photo_url"].toString();
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching Firestore data: $e');
    }
  }



  /// Edit Telepon dengan PhoneInputField
  void _editPhoneDialog(ThemeProvider themeProvider) {
    _phoneController.text = nohp ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Ubah Nomor Telepon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih kode negara dan masukkan nomor telepon',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              
              PhoneInputField(
                controller: _phoneController,
                primaryColor: const Color.fromRGBO(21, 116, 42, 1),
                height: 52,
                fontSize: 15,
                onChanged: (fullPhone, countryCode, phoneNumber) {
                  // Phone sudah ter-update di controller
                },
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _savePhone(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(21, 116, 42, 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// OPTIMISTIC: Save phone - update UI dulu
  Future<void> _savePhone(BuildContext dialogContext) async {
    final newPhone = _phoneController.text.trim();
    
    if (newPhone.isEmpty) {
      _showMessage('Nomor telepon tidak boleh kosong', Colors.orange);
      return;
    }

    final oldPhone = nohp;
    
    // INSTANT: Update UI & close dialog
    setState(() => nohp = newPhone);
    Navigator.pop(dialogContext);
    _showMessage('Menyimpan...', Colors.blue);

    // BACKGROUND: Sync ke Firestore
    _accountManager.updateProfile(
      userId: widget.id,
      phone: newPhone,
    ).then((result) {
      if (mounted) {
        if (result['success'] == true) {
          _showMessage('Tersimpan!', Colors.green);
        } else {
          // Rollback jika gagal
          setState(() => nohp = oldPhone);
          _showMessage(result['message'] ?? 'Gagal', Colors.red);
        }
      }
    });
  }

  /// Edit Level Skill dengan dropdown
  void _editlevelDialog(ThemeProvider themeProvider) {
    String? selectedLevel = levelSkill;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Pilih Level Skill',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih level kemampuan bermain badminton kamu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Level options
                ...List.generate(_levelOptions.length, (index) {
                  final level = _levelOptions[index];
                  final isSelected = selectedLevel == level;
                  
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => selectedLevel = level);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color.fromRGBO(21, 116, 42, 0.1) 
                            : (themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color.fromRGBO(21, 116, 42, 1) 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getLevelIcon(level),
                            color: isSelected 
                                ? const Color.fromRGBO(21, 116, 42, 1) 
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                        ? const Color.fromRGBO(21, 116, 42, 1)
                                        : (themeProvider.isDarkMode ? Colors.white : Colors.black87),
                                  ),
                                ),
                                Text(
                                  _getLevelDescription(level),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color.fromRGBO(21, 116, 42, 1),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveLevel(context, selectedLevel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(21, 116, 42, 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'Beginner': return Icons.emoji_events_outlined;
      case 'Intermediate': return Icons.emoji_events;
      case 'Advanced': return Icons.military_tech;
      case 'Pro': return Icons.workspace_premium;
      default: return Icons.emoji_events_outlined;
    }
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'Beginner': return 'Baru mulai belajar bermain badminton';
      case 'Intermediate': return 'Sudah bisa bermain dengan cukup baik';
      case 'Advanced': return 'Mahir bermain dan sering menang';
      case 'Pro': return 'Pemain profesional atau sangat berpengalaman';
      default: return '';
    }
  }

  /// Save level - update UI dulu
  Future<void> _saveLevel(BuildContext dialogContext, String newLevel) async {
    final oldLevel = levelSkill;
    
    // INSTANT: Update UI & close dialog
    setState(() => levelSkill = newLevel);
    Navigator.pop(dialogContext);
    _showMessage('Menyimpan...', Colors.blue);

    // BACKGROUND: Sync ke Firestore
    _accountManager.updateProfile(
      userId: widget.id,
      levelSkill: newLevel,
    ).then((result) {
      if (mounted) {
        if (result['success'] == true) {
          _showMessage('Tersimpan!', Colors.green);
        } else {
          // Rollback jika gagal
          setState(() => levelSkill = oldLevel);
          _showMessage(result['message'] ?? 'Gagal', Colors.red);
        }
      }
    });
  }

  /// Edit Nama
  void _showEditNameDialog(ThemeProvider themeProvider) {
    _nameController.text = name ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Ubah Nama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama baru',
                  prefixIcon: const Icon(Icons.person, color: Color.fromRGBO(21, 116, 42, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(21, 116, 42, 1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _saveName(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(21, 116, 42, 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// OPTIMISTIC: Save name - update UI dulu
  Future<void> _saveName(BuildContext dialogContext) async {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      _showMessage('Nama tidak boleh kosong', Colors.orange);
      return;
    }

    final oldName = name;
    
    setState(() => name = newName);
    Navigator.pop(dialogContext);
    _showMessage('Menyimpan...', Colors.blue);
    _accountManager.updateProfile(
      userId: widget.id,
      name: newName,
    ).then((result) {
      if (mounted) {
        if (result['success'] == true) {
          _showMessage('Tersimpan!', Colors.green);
        } else {
          setState(() => name = oldName);
          _showMessage(result['message'] ?? 'Gagal', Colors.red);
        }
      }
    });
  }

  Future<void> _saveProfileImage(Uint8List bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String imageData = base64Encode(bytes);
      await prefs.setString('profile_image_${widget.id}', imageData);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving image: $e');
    }
  }

  Widget _buildProfileImage(ThemeProvider themeProvider) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipOval(child: _getImageWidget(themeProvider)),
    );
  }

  Widget _getImageWidget(ThemeProvider themeProvider) {
    // 1. Prioritas: Foto dari local storage (yang di-upload user)
    if (_profileImageBytes != null) {
      return Image.memory(
        _profileImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar(themeProvider);
        },
      );
    }

    // 2. Foto dari file lokal
    if (_profileImage != null) {
      return Image.file(
        _profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar(themeProvider);
        },
      );
    }

    // 3. Foto dari URL atau base64 (Firestore/Google)
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Check if it's base64 data
      if (photoUrl!.startsWith('data:image')) {
        try {
          // Extract base64 part
          final base64String = photoUrl!.split(',').last;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) debugPrint('Error loading base64 image: $error');
              return _defaultAvatar(themeProvider);
            },
          );
        } catch (e) {
          if (kDebugMode) debugPrint('Error decoding base64: $e');
          return _defaultAvatar(themeProvider);
        }
      }
      
      // Regular URL (Google photo, etc)
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) debugPrint('Error loading network image: $error');
          return _defaultAvatar(themeProvider);
        },
      );
    }

    // 4. Default avatar
    return _defaultAvatar(themeProvider);
  }

  void _showEditPhotoDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opsi Galeri
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(21, 116, 42, 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Pilih foto dari galeri',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              
              const SizedBox(height: 8),
              
              // Opsi Kamera
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  'Ambil Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Ambil foto dengan kamera',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              
              // Hapus foto jika ada
              if (_profileImageBytes != null || (photoUrl != null && photoUrl!.isNotEmpty)) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Gunakan foto default',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
              ],
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,  // Reduced for Firestore base64
      maxHeight: 200,
      imageQuality: 50,  // Compressed more
    );
    if (image != null) {
      await _processAndSaveImage(image);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 200,  
      maxHeight: 200,
      imageQuality: 50,  
    );
    if (image != null) {
      await _processAndSaveImage(image);
    }
  }

  Future<void> _processAndSaveImage(XFile image) async {
    try {
      Uint8List bytes = await image.readAsBytes();
      if (kDebugMode) debugPrint('Image size: ${bytes.length} bytes');

      // INSTANT: Update UI langsung (optimistic)
      setState(() {
        _profileImageBytes = bytes;
        _isSaving = true;
      });
      _showMessage('Menyimpan foto...', Colors.blue);

      // BACKGROUND: Simpan ke local storage
      _saveProfileImage(bytes); // Fire and forget

      // BACKGROUND: Sync ke Firestore
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      _accountManager.updateProfile(
        userId: widget.id,
        photoUrl: base64Image,
      ).then((result) {
        if (mounted) {
          setState(() {
            photoUrl = base64Image;
            _isSaving = false;
          });
          if (result['success'] == true) {
            _showMessage('Foto tersimpan!', Colors.green);
          } else {
            _showMessage('Foto lokal OK, sync pending', Colors.orange);
          }
        }
      });
    } catch (e) {
      setState(() => _isSaving = false);
      _showMessage('Gagal: $e', Colors.red);
    }
  }

  Future<void> _removePhoto() async {
    final oldBytes = _profileImageBytes;
    final oldUrl = photoUrl;
    
    setState(() {
      _profileImageBytes = null;
      photoUrl = null;
      _isSaving = true;
    });
    _showMessage('Menghapus foto...', Colors.blue);
    
    try {
      // BACKGROUND: Hapus dari local storage (fire and forget)
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('profile_image_${widget.id}');
      });

      // BACKGROUND: Update Firestore
      _accountManager.updateProfile(
        userId: widget.id,
        photoUrl: '',
      ).then((result) {
        if (mounted) {
          setState(() => _isSaving = false);
          if (result['success'] == true) {
            _showMessage('Foto dihapus!', Colors.green);
          }
        }
      });

      setState(() => _isSaving = false);
    } catch (e) {
      setState(() {
        _profileImageBytes = oldBytes;
        photoUrl = oldUrl;
        _isSaving = false;
      });
      _showMessage('Gagal: $e', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500), 
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fastInit(); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return const ProfileSkeleton();
    }

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black87 : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                backgroundColor: Color.fromRGBO(21, 116, 42, 1),
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                snap: false,
                stretch: true,
                forceElevated: innerBoxIsScrolled,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final top = constraints.biggest.height;
                      final collapsed = top <= kToolbarHeight + 20;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: collapsed ? 1.0 : 0.0,
                        child: const Text(
                          'Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(21, 116, 42, 1),
                          Color.fromRGBO(21, 116, 42, 1),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Stack(
                              children: [
                                _buildProfileImage(themeProvider),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showEditPhotoDialog,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(21, 116, 42, 1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Nama dengan tombol edit
                            GestureDetector(
                              onTap: () => _showEditNameDialog(themeProvider),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            return CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 16),
                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 16),
                    //   padding: EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: themeProvider.isDarkMode
                    //         ? Colors.grey[850]
                    //         : Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black12,
                    //         blurRadius: 8,
                    //         offset: Offset(0, 2),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       _statItem('Book Court', bookCourtCount),
                    //       _statItem('Sparring', sparringCount),
                    //       _statItem('Main Bareng', mabarCount),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: 16),

                    // === REWARD PROMO SECTION (only show if user hasn't won prize yet) ===
                    FutureBuilder<RewardData>(
                      future: RewardService().getRewardData(widget.id.toString()),
                      builder: (context, snapshot) {
                        // Hanya tampil jika belum dapat hadiah
                        if (snapshot.hasData && !snapshot.data!.hasPrize) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RewardPage(userId: widget.id),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color.fromARGB(255, 3, 77, 1),
                                    const Color.fromARGB(255, 1, 128, 50),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withAlpha(13),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dapatkan Diskon 2%!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tonton iklan 5 hari untuk promo',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(180),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        // Jika sudah dapat hadiah, tampilkan info event selesai
                        else if (snapshot.hasData && snapshot.data!.hasPrize) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFE5B4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFFFC107), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFFFBC02D), size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Event Selesai! ✨',
                                        style: TextStyle(
                                          color: Color(0xFF856404),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tunggu tantangan berikutnya 🎉',
                                        style: TextStyle(
                                          color: Color(0xFF856404),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(height:10),
                    _sectionHeader('Info Pribadi', themeProvider),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email - tidak bisa diedit
                          _infoItem(
                            Icons.email,
                            'Email',
                            email ?? '-',
                            themeProvider,
                          ),
                          // Telepon - bisa diedit
                          _editableInfoItem(
                            Icons.phone,
                            'Telepon',
                            nohp ?? 'Belum diatur',
                            themeProvider,
                            onEdit: () => _editPhoneDialog(themeProvider),
                          ),
                          // Level - bisa diedit
                          _editableInfoItem(
                            Icons.emoji_events,
                            'Level',
                            levelSkill ?? 'Beginner',
                            themeProvider,
                            onEdit: () => _editlevelDialog(themeProvider),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    _sectionHeader('Aktivitas Terbaru', themeProvider),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _aktivitas(
                            'GOR Bung Tomo',
                            '07:00 - 09:00 • Lapangan A',
                            'Main Bareng',
                            themeProvider,
                          ),
                          _aktivitas(
                            'Sparring dengan Rian',
                            '20:00 - 22:00 • GOR Merdeka',
                            'Sparring',
                            themeProvider,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Section Kupon Saya
                    _sectionHeader('Kupon & Promo', themeProvider),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _BuildItemWithBadge(
                            'Kupon Saya',
                            Icons.local_offer,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KuponSayaPage(
                                    userId: widget.id.toString(),
                                  ),
                                ),
                              );
                            },
                            themeProvider,
                            widget.id.toString(),
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _BuildItem(
                            'Tantangan 5 Hari',
                            Icons.card_giftcard,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RewardPage(
                                    userId: widget.id,
                                  ),
                                ),
                              );
                            },
                            themeProvider,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    _sectionHeader('Pengaturan', themeProvider),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.contrast,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  themeProvider.isDarkMode
                                      ? 'Light Mode'
                                      : 'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme(value);
                                },
                                activeColor: Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    _sectionHeader('Keamanan Akun', themeProvider),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _BuildItem('Ubah Password', Icons.lock, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HalamanAturUlangPassword(email: ''),
                              ),
                            );
                          }, themeProvider),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _showLogoutDialog(context, authProvider),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _defaultAvatar(ThemeProvider themeProvider) {
    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Text(
          (name != null && name!.isNotEmpty)
              ? (name!.length > 2 ? name!.substring(0, 2) : name!)
              : 'US',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget _statItem(String title, int count) {
  //   return Column(
  //     children: [
  //       Text(
  //         count.toString(),
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //           color: Color.fromRGBO(21, 116, 42, 1),
  //         ),
  //       ),
  //       SizedBox(height: 4),
  //       Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
  //     ],
  //   );
  // }

  Widget _sectionHeader(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4CAF50), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Info item yang bisa di-edit dengan tombol edit
  Widget _editableInfoItem(
    IconData icon,
    String title,
    String value,
    ThemeProvider themeProvider, {
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Edit
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(21, 116, 42, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: const Color.fromRGBO(21, 116, 42, 1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(21, 116, 42, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aktivitas(
    String title,
    String time,
    String type,
    ThemeProvider themeProvider,
  ) {
    Color typeColor = type == 'Main Bareng'
        ? Color(0xFFFF9800)
        : Color(0xFF2196F3);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withAlpha(11),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BuildItem(
    String title,
    IconData icon,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF4CAF50), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// Build item dengan badge jumlah kupon
  Widget _BuildItemWithBadge(
    String title,
    IconData icon,
    VoidCallback onTap,
    ThemeProvider themeProvider,
    String userId,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
            // Badge jumlah kupon
            FutureBuilder<int>(
              future: KuponService().getAvailableCouponCount(userId),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) {
                  return Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]);
                }
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Apakah Anda yakin ingin logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            authProvider.logout();
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
