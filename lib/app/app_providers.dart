import 'package:core_package/core_package.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/data/demo_update_check_service.dart';

/// The connectivity service used by [AppConnectivityBanner] at the app
/// root. Kept here (rather than in `features/auth/`) since it's a
/// cross-cutting, app-wide concern, not specific to any one feature.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityServiceImpl();
});

/// This app's feature flags — the single place that decides which of
/// `core_package`'s optional gated features are actually turned on.
/// `enableBiometricLock` defaults off since it needs biometrics
/// enrolled on the test device to demo cleanly; the others are on so
/// their wiring is visibly exercised out of the box.
final featureFlagsProvider = Provider<AppFeatureFlags>((ref) {
  return const AppFeatureFlags(
    enableIdleTimeout: true,
    enableBiometricLock: true,
    enableForceUpdateCheck: true,
    enableLocalization: false,
  );
});

/// The biometric/PIN authentication service used by
/// [BiometricLockGate].
final biometricLockServiceProvider = Provider<BiometricLockService>((ref) {
  return BiometricLockServiceImpl();
});

/// The update-check service used by [UpdateRequiredGate].
/// [DemoUpdateCheckServiceImpl] always reports "up to date" — replace
/// it once a real backend/remote-config source exists.
final updateCheckServiceProvider = Provider<UpdateCheckService>((ref) {
  return DemoUpdateCheckServiceImpl();
});
