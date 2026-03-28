import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_constants.dart';
import '../../services/profile_storage_service.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final ProfileStorageService _storage = ProfileStorageService.instance;

  String? _avatarRelativePath;
  File? _avatarFile;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final nickname = await _storage.getDisplayNickname();
    final signature = await _storage.getSignature();
    final rel = await _storage.getAvatarRelativePath();
    File? file;
    if (rel != null) {
      file = await _storage.resolveAvatarFile(rel);
    }
    if (!mounted) return;
    setState(() {
      _nicknameController.text = nickname;
      _signatureController.text = signature;
      _avatarRelativePath = rel;
      _avatarFile = file;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final rel = await _storage.savePickedImageToAppDocuments(x.path);
    final file = await _storage.resolveAvatarFile(rel);
    if (!mounted) return;
    setState(() {
      _avatarRelativePath = rel;
      _avatarFile = file;
    });
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    await _storage.saveProfile(
      nickname: _nicknameController.text.trim().isEmpty
          ? AppConstants.appDisplayName
          : _nicknameController.text.trim(),
      signature: _signatureController.text,
      avatarRelativePath: _avatarRelativePath,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  Widget _buildAvatar() {
    final file = _avatarFile;
    if (file != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: FileImage(file),
      );
    }
    return const CircleAvatar(
      radius: 48,
      backgroundImage: AssetImage(AppConstants.assetDefaultAvatar),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildAvatar(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickAvatar,
                      child: const Text('Choose profile photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nickname',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Nickname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Signature',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _signatureController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'A short bio or signature',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              if (_avatarRelativePath != null) ...[
                const SizedBox(height: 12),
                SelectableText(
                  'Saved avatar relative path: $_avatarRelativePath',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _onSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          if (_saving)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
