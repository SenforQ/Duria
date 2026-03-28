import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../app_constants.dart';
import '../../services/profile_storage_service.dart';
import '../../services/wallet_service.dart';
import '../wallet/wallet_recharge_page.dart';
import 'about_me_page.dart';
import 'editor_page.dart';
import 'feedback_page.dart';
import 'privacy_policy_page.dart';
import 'user_agreement_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileStorageService _storage = ProfileStorageService.instance;

  String _nickname = AppConstants.appDisplayName;
  File? _avatarFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WalletService.instance.addListener(_onWalletChanged);
    _load();
  }

  @override
  void dispose() {
    WalletService.instance.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final nickname = await _storage.getDisplayNickname();
    final rel = await _storage.getAvatarRelativePath();
    File? file;
    if (rel != null) {
      file = await _storage.resolveAvatarFile(rel);
    }
    if (!mounted) return;
    setState(() {
      _nickname = nickname;
      _avatarFile = file;
      _loading = false;
    });
  }

  Future<void> _onRateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  Future<void> _openFeedback() async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const FeedbackPage(),
      ),
    );
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your feedback has been submitted successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _openEditor() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const EditorPage(),
      ),
    );
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _openPrivacy() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  Future<void> _openUserAgreement() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const UserAgreementPage(),
      ),
    );
  }

  Future<void> _openAbout() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const AboutMePage(),
      ),
    );
  }

  Future<void> _openWallet() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => const WalletRechargePage(),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _buildAvatar() {
    final file = _avatarFile;
    if (file != null) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(file),
      );
    }
    return const CircleAvatar(
      radius: 40,
      backgroundImage: AssetImage(AppConstants.assetDefaultAvatar),
    );
  }

  Widget _sectionCard({
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _walletRow() {
    final balance = WalletService.instance.balance;
    return InkWell(
      onTap: _openWallet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'coins',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 56, color: Colors.grey[200]),
      ],
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
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nickname,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionCard(
              children: [
                _walletRow(),
              ],
            ),
            _sectionCard(
              children: [
                _row(
                  icon: Icons.edit_outlined,
                  label: 'Edit Information',
                  onTap: _openEditor,
                  showDivider: false,
                ),
              ],
            ),
            _sectionCard(
              children: [
                _row(
                  icon: Icons.star_outline,
                  label: 'Rate App',
                  onTap: _onRateApp,
                ),
                _row(
                  icon: Icons.feedback_outlined,
                  label: 'Feedback',
                  onTap: _openFeedback,
                  showDivider: false,
                ),
              ],
            ),
            _sectionCard(
              children: [
                _row(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: _openPrivacy,
                ),
                _row(
                  icon: Icons.description_outlined,
                  label: 'User Agreement',
                  onTap: _openUserAgreement,
                ),
                _row(
                  icon: Icons.info_outline,
                  label: 'About Me',
                  onTap: _openAbout,
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
