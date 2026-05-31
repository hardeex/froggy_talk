import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mock_api_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/wallet_repository.dart';

// Singleton mock API data source — acts as the in-memory "database"
final mockApiProvider = Provider<MockApiDataSource>(
  (_) => MockApiDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(mockApiProvider)),
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(ref.watch(mockApiProvider)),
);
