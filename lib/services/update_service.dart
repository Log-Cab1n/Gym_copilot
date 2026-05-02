import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum UpdateStatus {
  checking,
  upToDate,
  updateAvailable,
  downloading,
  ready,
  error,
}

class UpdateService {
  static final UpdateService instance = UpdateService._init();

  static final ValueNotifier<UpdateStatus> statusNotifier =
      ValueNotifier(UpdateStatus.upToDate);

  static final ValueNotifier<bool> isNewPatchReady =
      ValueNotifier(false);

  UpdateService._init();

  bool get isSupported => !kIsWeb && !Platform.isLinux && !Platform.isWindows;

  Future<void> checkForUpdate() async {
    if (!isSupported) return;
    statusNotifier.value = UpdateStatus.upToDate;
  }

  Future<bool> downloadUpdate() async {
    if (!isSupported) return false;
    statusNotifier.value = UpdateStatus.upToDate;
    return true;
  }

  Future<int?> get currentPatchVersion async {
    if (!isSupported) return null;
    return null;
  }

  Future<int?> get nextPatchVersion async {
    if (!isSupported) return null;
    return null;
  }

  Future<void> checkAndUpdateOnStartup() async {
    debugPrint('Update service initialized (shorebird disabled)');
  }
}
