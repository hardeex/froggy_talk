import '../datasources/mock_api_datasource.dart';
import '../models/wallet.dart';
import '../models/wallet_activity.dart';
import '../models/requests.dart';

abstract interface class WalletRepository {
  Future<Wallet> getWallet();
  Future<List<WalletActivity>> getActivity();
  Future<({Wallet wallet, WalletActivity activity})> topUp(TopupRequest req);
}

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._api);
  final MockApiDataSource _api;

  @override
  Future<Wallet> getWallet() => _api.getWallet();

  @override
  Future<List<WalletActivity>> getActivity() => _api.getWalletActivity();

  @override
  Future<({Wallet wallet, WalletActivity activity})> topUp(TopupRequest req) =>
      _api.topUp(req);
}
