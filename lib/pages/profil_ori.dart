import 'package:flutter/material.dart';
import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/database/providers/provider.dart';
import 'package:uts_backend/pages/forgot_password.dart';
import 'package:uts_backend/pages/login.dart';
import 'package:uts_backend/widgets/aktivitypage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Profil extends StatefulWidget {
  final int id;
  Profil({super.key, required this.id});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  ApiService user = ApiService();
  String? name;
  String? password;
  String? email;
  String? nohp;
  String? levelSkill;
  bool _isLoading = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImageBytes;

  int bookCourtCount = 12;
  int sparringCount = 8;
  int mabarCount = 15;

  initUser(int id) async {
    try {
      var data = await user.getUserById(id);

      print('Data type: ${data.runtimeType}');
      print('Data keys: ${data.keys}');
      print('Full response: $data');

      if (data['success'] == true && data['user'] != null) {
        Map<String, dynamic> userData = data['user'];

        print('User data found: ${userData['name']}');

        setState(() {
          name = userData["name"]?.toString() ?? "Nama tidak tersedia";
          password = userData["password"]?.toString() ?? "";
          email = userData["email"]?.toString() ?? "Email tidak tersedia";
          nohp = userData["phone"]?.toString() ?? "Nomor tidak tersedia";
          levelSkill = userData["level_skill"]?.toString() ?? "Beginner";
          _isLoading = false;
        });
      } else {
        print(' API Error: ${data['message']}');
        setState(() {
          name = "Error: ${data['message'] ?? 'pesan error'}";
          email = "-";
          nohp = "-";
          levelSkill = "-";
          _isLoading = false;
        });
      }
    } catch (e) {
      print(' initUser Error: $e');
      setState(() {
        name = "koneksi eror";
        email = "-";
        nohp = "-";
        levelSkill = "-";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imageData = prefs.getString('profile_image_${widget.id}');

      if (imageData != null && imageData.isNotEmpty) {
        final bytes = base64Decode(imageData);
        setState(() {
          _profileImageBytes = bytes;
        });
        print(' Gambar profil load dari local storage');
      }
    } catch (e) {
      print(' eror loading image dari storage: $e');
    }
  }

  Future<void> _saveProfileImage(Uint8List bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String imageData = base64Encode(bytes);
      await prefs.setString('profile_image_${widget.id}', imageData);
      print('💾 Gambar profil disimpan ke local storage');
    } catch (e) {
      print(' eror save image di storage: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
    );

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();

      await _saveProfileImage(bytes);

      String imageUrl = "user_${widget.id}_profile";
      await user.uploadProfileImage(widget.id, imageUrl);

      setState(() {
        _profileImageBytes = bytes;
      });

      _showMessage('Foto diubah!', Colors.green);
    }
  }

  Widget _buildProfileImage() {
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
      child: ClipOval(child: _getImageWidget()),
    );
  }

  Widget _getImageWidget() {
    if (_profileImageBytes != null) {
      return Image.memory(
        _profileImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar();
        },
      );
    }

    if (_profileImage != null) {
      return Image.file(
        _profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar();
        },
      );
    }

    return _defaultAvatar();
  }

  void _showEditPhotoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ubahh Foto profile'),
        content: const Text('Pilih sumber foto'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: const Text('Dari Galeri'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileImage();
  }

  Future<void> _initializeData() async {
    await initUser(widget.id);

    if (kIsWeb) {
      await _loadProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(21, 116, 42, 1),),

              ),
              SizedBox(height: 20),
              Text(
                'Loading profile...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                                _buildProfileImage(),
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
                            Text(
                              name ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('Book Court', bookCourtCount),
                          _statItem('Sparring', sparringCount),
                          _statItem('Main Bareng', mabarCount),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityPage(),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aktivitas Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    _sectionHeader('Info Pribadi'),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          _infoItem(Icons.email, 'Email', email ?? '-'),
                          _infoItem(Icons.phone, 'Telepon', nohp ?? '-'),
                          _infoItem(
                            Icons.emoji_events,
                            'Level',
                            levelSkill ?? '-',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Aktivitasnye
                    _sectionHeader('Aktivitas Terbaru'),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _aktivitas(
                            'GOR Bung Tomo',
                            '07:00 - 09:00 • Lapangan A',
                            'Main Bareng',
                          ),
                          _aktivitas(
                            'Sparring dengan Rian',
                            '20:00 - 22:00 • GOR Merdeka',
                            'Sparring',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Keamanan Akunnye
                    _sectionHeader('Keamanan Akun'),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          _buildSecurityItem('Ubah Password', Icons.lock, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Logout
                    Container(
                      margin: EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _showLogoutDialog(context, authProvider);
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Text(
          (name != null && name!.isNotEmpty)
              ? (name!.length > 2 ? name!.substring(0, 2) : name!)
              : 'US',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _statItem(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:Color.fromRGBO(21, 116, 42, 1) ,
          ),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
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
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aktivitas(String title, String time, String type) {
    Color typeColor = type == 'Main Bareng'
        ? Color(0xFFFF9800)
        : Color(0xFF2196F3);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: Colors.black87,
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
              color: typeColor.withValues(alpha: 30),
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

  Widget _buildSecurityItem(String title, IconData icon, VoidCallback onTap) {
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
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
