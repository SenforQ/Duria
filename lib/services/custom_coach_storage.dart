import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCoachRecord {
  CustomCoachRecord({
    required this.id,
    required this.nickname,
    required this.tagline,
    required this.skills,
    required this.avatarRelativePath,
    this.galleryRelativePaths = const <String>[],
    this.videoRelativePath,
  });

  final String id;
  final String nickname;
  final String tagline;
  final List<String> skills;
  final String avatarRelativePath;
  final List<String> galleryRelativePaths;
  final String? videoRelativePath;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nickname': nickname,
        'tagline': tagline,
        'skills': skills,
        'avatarRelativePath': avatarRelativePath,
        'galleryRelativePaths': galleryRelativePaths,
        'videoRelativePath': videoRelativePath,
      };

  static CustomCoachRecord fromJson(Map<String, dynamic> j) {
    return CustomCoachRecord(
      id: j['id'] as String,
      nickname: j['nickname'] as String,
      tagline: j['tagline'] as String? ?? '',
      skills: List<String>.from(j['skills'] as List<dynamic>? ?? <dynamic>[]),
      avatarRelativePath: j['avatarRelativePath'] as String,
      galleryRelativePaths:
          List<String>.from(j['galleryRelativePaths'] as List<dynamic>? ?? <dynamic>[]),
      videoRelativePath: j['videoRelativePath'] as String?,
    );
  }

  File resolveAvatar(Directory doc) => File(p.join(doc.path, avatarRelativePath));

  List<File> resolveGallery(Directory doc) =>
      galleryRelativePaths.map((e) => File(p.join(doc.path, e))).toList();

  File? resolveVideo(Directory doc) =>
      videoRelativePath == null ? null : File(p.join(doc.path, videoRelativePath!));
}

class CustomCoachStorage {
  CustomCoachStorage._();
  static final CustomCoachStorage instance = CustomCoachStorage._();

  static const String _key = 'custom_coaches_json_v1';
  static const String _subDir = 'custom_coaches_media';

  Future<Directory> mediaDir() async {
    final root = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(root.path, _subDir));
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  Future<List<CustomCoachRecord>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <CustomCoachRecord>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CustomCoachRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<CustomCoachRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(records.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> add(CustomCoachRecord record) async {
    final all = await loadAll();
    all.add(record);
    await saveAll(all);
  }

  Future<String> copyIntoMediaDir(File source, String destName) async {
    final dir = await mediaDir();
    final dest = File(p.join(dir.path, destName));
    await source.copy(dest.path);
    return p.join(_subDir, destName);
  }
}
