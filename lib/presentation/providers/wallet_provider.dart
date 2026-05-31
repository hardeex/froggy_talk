import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallet.dart';
import '../../data/models/wallet_activity.dart';
import '../../data/models/requests.dart';
import '../../core/errors/app_exception.dart';
import 'core_providers.dart';

// ── Wallet State ─────────────────────────────────────────────────────────────

class WalletState {
  const WalletState({
    this.wallet,
    this.activities = const [],
    this.isLoading = false,
    this.isTopUpLoading = false,
    this.error,
    this.topUpResult,
  });

  final Wallet? wallet;
  final List<WalletActivity> activities;
  final bool isLoading;
  final bool isTopUpLoading;
  final AppException? error;
  final TopUpResult? topUpResult;

  WalletState copyWith({
    Wallet? wallet,
    List<WalletActivity>? activities,
    bool? isLoading,
    bool? isTopUpLoading,
    AppException? error,
    TopUpResult? topUpResult,
    bool clearError = false,
    bool clearTopUpResult = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isTopUpLoading: isTopUpLoading ?? this.isTopUpLoading,
      error: clearError ? null : (error ?? this.error),
      topUpResult:
          clearTopUpResult ? null : (topUpResult ?? this.topUpResult),
    );
  }
}

enum TopUpResult { success, failed }

// ── Wallet Notifier ───────────────────────────────────────────────────────────

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final results = await Future.wait([
        repo.getWallet(),
        repo.getActivity(),
      ]);
      state = WalletState(
        wallet: results[0] as Wallet,
        activities: results[1] as List<WalletActivity>,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: const UnknownException(),
      );
    }
  }

  Future<TopUpResult> topUp(TopupRequest request) async {
    state = state.copyWith(
      isTopUpLoading: true,
      clearError: true,
      clearTopUpResult: true,
    );
    try {
      final result =
          await ref.read(walletRepositoryProvider).topUp(request);

      final isSuccess = result.activity.status == ActivityStatus.success;
      final topUpResult =
          isSuccess ? TopUpResult.success : TopUpResult.failed;

      state = state.copyWith(
        isTopUpLoading: false,
        wallet: result.wallet,
        activities: [result.activity, ...state.activities],
        topUpResult: topUpResult,
      );

      return topUpResult;
    } on AppException catch (e) {
      state = state.copyWith(
        isTopUpLoading: false,
        error: e,
        topUpResult: TopUpResult.failed,
      );
      return TopUpResult.failed;
    } catch (_) {
      state = state.copyWith(
        isTopUpLoading: false,
        error: const UnknownException(),
        topUpResult: TopUpResult.failed,
      );
      return TopUpResult.failed;
    }
  }

  void clearTopUpResult() => state = state.copyWith(clearTopUpResult: true);
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
