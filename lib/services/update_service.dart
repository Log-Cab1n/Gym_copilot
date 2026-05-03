import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

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

  final _shorebird = ShorebirdCodePush();

  UpdateService._init();

  bool get isSupported => !kIsWeb && !Platform.isLinux && !Platform.isWindows;

  Future<void> checkForUpdate() async {
    if (!isSupported) return;
    
    try {
      statusNotifier.value = UpdateStatus.checking;
      
      // 检查是否有可用更新
      final isUpdateAvailable = await _shorebird.isNewPatchAvailableForDownload();
      
      if (isUpdateAvailable) {
        statusNotifier.value = UpdateStatus.updateAvailable;
      } else {
        statusNotifier.value = UpdateStatus.upToDate;
      }
    } catch (e) {
      debugPrint('检查更新失败: $e');
      statusNotifier.value = UpdateStatus.error;
    }
  }

  Future<bool> downloadUpdate() async {
    if (!isSupported) return false;
    
    try {
      statusNotifier.value = UpdateStatus.downloading;
      
      // Shorebird 会自动在后台下载更新
      // 这里我们只需要检查更新是否已经下载完成
      final isReady = await _shorebird.isNewPatchReadyToInstall();
      
      if (isReady) {
        statusNotifier.value = UpdateStatus.ready;
        isNewPatchReady.value = true;
        return true;
      }
      
      // 如果没有自动下载，尝试手动下载
      await _shorebird.downloadUpdateIfAvailable();
      
      // 再次检查
      final isReadyAfterDownload = await _shorebird.isNewPatchReadyToInstall();
      if (isReadyAfterDownload) {
        statusNotifier.value = UpdateStatus.ready;
        isNewPatchReady.value = true;
        return true;
      }
      
      statusNotifier.value = UpdateStatus.upToDate;
      return false;
    } catch (e) {
      debugPrint('下载更新失败: $e');
      statusNotifier.value = UpdateStatus.error;
      return false;
    }
  }

  Future<int?> get currentPatchVersion async {
    if (!isSupported) return null;
    try {
      return await _shorebird.currentPatchNumber();
    } catch (e) {
      debugPrint('获取当前补丁版本失败: $e');
      return null;
    }
  }

  Future<String> get currentVersion async {
    final packageInfo = await PackageInfo.fromPlatform();
    final patchVersion = await currentPatchVersion;
    if (patchVersion != null && patchVersion > 0) {
      return '${packageInfo.version}+$patchVersion';
    }
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  Future<int?> get nextPatchVersion async {
    if (!isSupported) return null;
    try {
      return await _shorebird.nextPatchNumber();
    } catch (e) {
      debugPrint('获取下一补丁版本失败: $e');
      return null;
    }
  }

  Future<void> checkAndUpdateOnStartup() async {
    if (!isSupported) {
      debugPrint('热更新不支持当前平台');
      return;
    }
    
    try {
      debugPrint('正在检查 Shorebird 热更新...');
      
      // 检查是否有已下载但未安装的更新
      final isReady = await _shorebird.isNewPatchReadyToInstall();
      if (isReady) {
        debugPrint('发现已下载的补丁，准备安装...');
        isNewPatchReady.value = true;
        statusNotifier.value = UpdateStatus.ready;
        return;
      }
      
      // 检查是否有可用更新
      final isUpdateAvailable = await _shorebird.isNewPatchAvailableForDownload();
      if (isUpdateAvailable) {
        debugPrint('发现新补丁可用');
        statusNotifier.value = UpdateStatus.updateAvailable;
      } else {
        final currentPatch = await currentPatchVersion;
        debugPrint('已是最新版本 (补丁 #$currentPatch)');
        statusNotifier.value = UpdateStatus.upToDate;
      }
    } catch (e) {
      debugPrint('检查 Shorebird 更新失败: $e');
      statusNotifier.value = UpdateStatus.error;
    }
  }
}
