/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/network_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/brightness_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/providers/tv_inputs_service.dart';
import 'package:flauncher/providers/notifications_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/providers/weather_service.dart';
import 'package:flauncher/providers/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'flauncher_app.dart';
import 'widgets/startup_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Caché de imágenes acotada para TV box de 1 GB: 5 imágenes y 25 MB.
  // Las imágenes visibles siguen vivas aunque salgan de la caché; las que se
  // vuelven a mostrar (banners, fondos) se decodifican de nuevo.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 5;

  // Global Error Boundary & Crash Protection
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLauncher Error Boundary: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('FLauncher Platform Error Boundary: $error');
    return true; // handled, don't crash process
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F0F0F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Se produjo un error',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  };

  _deferFirstFrameUntilSplashDecoded();
  runApp(const _BootstrapApp());
}

/// Retiene el primer frame de Flutter hasta que la imagen del splash está
/// decodificada. Mientras tanto Android sigue mostrando el splash nativo
/// (mismo archivo), así no aparece un frame negro ni un segundo salto.
/// Límite de 1,5 s para no bloquear nunca el arranque.
void _deferFirstFrameUntilSplashDecoded() {
  final binding = WidgetsBinding.instance;
  binding.deferFirstFrame();
  var released = false;
  void release() {
    if (released) return;
    released = true;
    binding.allowFirstFrame();
  }

  final stream = StartupSplash.image.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, __) {
      stream.removeListener(listener);
      release();
    },
    onError: (_, __) {
      stream.removeListener(listener);
      release();
    },
  );
  stream.addListener(listener);
  Timer(const Duration(milliseconds: 1500), release);
}

class _BootstrapData {
  final SharedPreferences sharedPreferences;
  final FLauncherChannel fLauncherChannel;
  final FLauncherDatabase fLauncherDatabase;

  const _BootstrapData({
    required this.sharedPreferences,
    required this.fLauncherChannel,
    required this.fLauncherDatabase,
  });
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<_BootstrapData> _bootstrapFuture = _initialize()
      .timeout(const Duration(seconds: 30));

  Future<_BootstrapData> _initialize() async {
    // Keep the official splash visible long enough to be perceived on a cold
    // Android TV start, without delaying resumes from an already running task.
    final minimumSplash = Future<void>.delayed(const Duration(milliseconds: 1200));
    await initializeDateFormatting();
    final sharedPreferences = await SharedPreferences.getInstance();
    final fLauncherChannel = FLauncherChannel();
    final fLauncherDatabase = FLauncherDatabase(connect());

    await minimumSplash;

    return _BootstrapData(
      sharedPreferences: sharedPreferences,
      fLauncherChannel: fLauncherChannel,
      fLauncherDatabase: fLauncherDatabase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: StartupSplash(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          debugPrint('CLICK TV LAUNCHER: error de inicio: ${snapshot.error}');
          return _StartupErrorApp(onRetry: () {
            setState(() {
              _bootstrapFuture = _initialize().timeout(const Duration(seconds: 30));
            });
          });
        }

        final bootstrap = snapshot.data!;
        _releaseSplashImage();
        return _buildLauncher(bootstrap);
      },
    );
  }

  bool _splashReleased = false;

  // Libera la imagen del splash (~8 MB decodificada) en cuanto se muestra el
  // launcher; en equipos de 1 GB no conviene mantenerla en la caché.
  void _releaseSplashImage() {
    if (_splashReleased) return;
    _splashReleased = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupSplash.image.evict();
    });
  }

  Widget _buildLauncher(_BootstrapData bootstrap) {
    final sharedPreferences = bootstrap.sharedPreferences;
    final fLauncherChannel = bootstrap.fLauncherChannel;
    final fLauncherDatabase = bootstrap.fLauncherDatabase;

    return MultiProvider(
      providers: [
        Provider<BackupService>(
          create: (_) => BackupService(fLauncherDatabase, sharedPreferences),
        ),
        ChangeNotifierProvider(
            create: (_) => SettingsService(sharedPreferences),
            lazy: false),
        ChangeNotifierProvider(create: (_) => AppsService(fLauncherChannel, fLauncherDatabase)),
        ChangeNotifierProvider(create: (_) => LauncherState()),
        ChangeNotifierProvider(create: (_) => NetworkService(fLauncherChannel)),
        ChangeNotifierProvider(
            create: (context) {
              SettingsService settingsService = Provider.of(context, listen: false);
              return WallpaperService(fLauncherChannel, settingsService);
            }
        ),
        ChangeNotifierProvider(
            create: (_) => BrightnessService(sharedPreferences),
            lazy: false),
        ChangeNotifierProvider(create: (_) => TvInputsService(fLauncherChannel)),
        ChangeNotifierProvider(create: (_) => NotificationsService(fLauncherChannel)),
        ChangeNotifierProvider(create: (_) => WatchNextService(fLauncherChannel)),
        ChangeNotifierProvider(create: (_) => WeatherService(fLauncherChannel)),
      ],
      child: FLauncherApp(),
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  final VoidCallback onRetry;
  const _StartupErrorApp({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo iniciar CLICK TV LAUNCHER.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                autofocus: true,
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
