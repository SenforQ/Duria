import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_constants.dart';

class ProfileStorageService {
  ProfileStorageService._();
  static final ProfileStorageService instance = ProfileStorageService._();

  static const String _keyNickname = 'profile_nickname';
  static const String _keySignature = 'profile_signature';
  static const String _keyAvatarRelativePath = 'profile_avatar_relative_path';

  Future<String> getDisplayNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname) ?? AppConstants.appDisplayName;
  }

  Future<String> getSignature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySignature) ?? '';
  }

  Future<String?> getAvatarRelativePath() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_keyAvatarRelativePath);
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Future<File?> resolveAvatarFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, relativePath));
    if (await file.exists()) return file;
    return null;
  }

  Future<String> savePickedImageToAppDocuments(String pickedFilePath) async {
    final root = await getApplicationDocumentsDirectory();
    final relative =
        'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File(p.join(root.path, relative));
    await dest.parent.create(recursive: true);
    await File(pickedFilePath).copy(dest.path);
    return relative;
  }

  Future<void> saveProfile({
    required String nickname,
    required String signature,
    required String? avatarRelativePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, nickname);
    await prefs.setString(_keySignature, signature);
    if (avatarRelativePath == null || avatarRelativePath.isEmpty) {
      await prefs.remove(_keyAvatarRelativePath);
    } else {
      await prefs.setString(_keyAvatarRelativePath, avatarRelativePath);
    }
  }
}
