import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Dari galeri + izin otomatis
  static Future<File?> pickImage(BuildContext context) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Izin galeri ditolak permanen"),
          action: SnackBarAction(
            label: "Buka Pengaturan",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return null;
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin akses galeri diperlukan")),
      );
      return null;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  // DARI KAMERA + izin kamera otomatis (BONUS KEREN)
  static Future<File?> takePhoto(BuildContext context) async {
    var status = await Permission.camera.request();

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Izin kamera ditolak permanen"),
          action: SnackBarAction(
            label: "Buka Pengaturan",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return null;
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin kamera diperlukan")),
      );
      return null;
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    return photo != null ? File(photo.path) : null;
  }
}