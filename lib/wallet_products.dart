import 'models/wallet_coin_product.dart';

class WalletProducts {
  WalletProducts._();

  static const List<WalletCoinProduct> products = [
    WalletCoinProduct(
      productId: 'Coin_Duria_0',
      coins: 32,
      price: 0.99,
      priceText: r'$0.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_1',
      coins: 60,
      price: 1.99,
      priceText: r'$1.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_2',
      coins: 96,
      price: 2.99,
      priceText: r'$2.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_4',
      coins: 155,
      price: 4.99,
      priceText: r'$4.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_5',
      coins: 189,
      price: 5.99,
      priceText: r'$5.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_9',
      coins: 359,
      price: 9.99,
      priceText: r'$9.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_19',
      coins: 729,
      price: 19.99,
      priceText: r'$19.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_49',
      coins: 1869,
      price: 49.99,
      priceText: r'$49.99',
    ),
    WalletCoinProduct(
      productId: 'Coin_Duria_99',
      coins: 3799,
      price: 99.99,
      priceText: r'$99.99',
    ),
  ];

  static WalletCoinProduct? findByProductId(String productId) {
    for (final p in products) {
      if (p.productId == productId) return p;
    }
    return null;
  }
}
