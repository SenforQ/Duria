import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_constants.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({super.key});

  @override
  State<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(AppConstants.userAgreementUrl));
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final webHeight = screenH - padding.top - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Agreement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: webHeight,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
