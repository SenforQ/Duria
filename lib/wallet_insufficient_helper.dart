import 'package:flutter/material.dart';

import 'pages/wallet/wallet_recharge_page.dart';

void showInsufficientCoinsSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Not enough coins. Top up in Wallet.'),
      action: SnackBarAction(
        label: 'Wallet',
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const WalletRechargePage(),
            ),
          );
        },
      ),
    ),
  );
}
