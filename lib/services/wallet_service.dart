import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallet_coin_product.dart';
import '../wallet_products.dart';

class WalletService extends ChangeNotifier {
  WalletService._();
  static final WalletService instance = WalletService._();

  static const int freeCustomCoachCount = 3;
  static const int customCoachOverQuotaCost = 30;
  static const int aiChatMessageCost = 1;
  static const int freeUserTrainingPlanCount = 5;
  static const int trainingPlanOverQuotaCost = 10;

  static const String _keyBalance = 'wallet_coin_balance';
  static const String _keyLedger = 'wallet_purchase_ledger_v1';

  final InAppPurchase _iap = InAppPurchase.instance;

  int _balance = 0;
  int get balance => _balance;

  final Set<String> _ledger = <String>{};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_keyBalance) ?? 0;
    _ledger.addAll(prefs.getStringList(_keyLedger) ?? []);
    notifyListeners();

    final available = await _iap.isAvailable();
    if (!available) {
      if (kDebugMode) {
        debugPrint('WalletService: In-app purchase not available');
      }
      return;
    }

    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSub = null,
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('WalletService purchase stream error: $e');
        }
      },
    );
  }

  Future<void> _persistBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalance, _balance);
    notifyListeners();
  }

  Future<void> _persistLedger() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyLedger, _ledger.toList());
  }

  String _ledgerKey(PurchaseDetails purchase) {
    final id = purchase.purchaseID;
    if (id != null && id.isNotEmpty) return id;
    final date = purchase.transactionDate;
    return '${purchase.productID}_$date';
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handleOnePurchase(purchase);
    }
  }

  Future<void> _handleOnePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }

    if (purchase.status == PurchaseStatus.canceled) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }

    final key = _ledgerKey(purchase);
    if (_ledger.contains(key)) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }

    final WalletCoinProduct? coinProduct =
        WalletProducts.findByProductId(purchase.productID);
    if (coinProduct != null) {
      _balance += coinProduct.coins;
      _ledger.add(key);
      await _persistBalance();
      await _persistLedger();
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
    notifyListeners();
  }

  Future<ProductDetailsResponse> queryProducts() async {
    final ids = WalletProducts.products.map((e) => e.productId).toSet();
    return _iap.queryProductDetails(ids);
  }

  Future<bool> purchaseConsumable(ProductDetails productDetails) async {
    final param = PurchaseParam(productDetails: productDetails);
    return _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<bool> trySpendCoins(int amount) async {
    await init();
    if (amount <= 0) {
      return true;
    }
    if (_balance < amount) {
      return false;
    }
    _balance -= amount;
    await _persistBalance();
    return true;
  }

  Future<void> addCoins(int amount) async {
    await init();
    if (amount <= 0) {
      return;
    }
    _balance += amount;
    await _persistBalance();
  }
}
