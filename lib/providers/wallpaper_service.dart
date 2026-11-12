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

import 'dart:io';
import 'dart:async';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Fondos de Ecuador (Wikimedia Commons, 3840x2160). Créditos en
/// assets/fondos/ecuador/CREDITOS.md. Se agrupan por momento del día.
const Map<String, List<String>> ecuadorWallpaperSets = {
  'manana': [
    'assets/fondos/ecuador/manana-1-chimborazo.jpg',
    'assets/fondos/ecuador/manana-2-mitad-del-mundo.jpg',
    'assets/fondos/ecuador/manana-3-cotopaxi-quilotoa.jpg',
  ],
  'tarde': [
    'assets/fondos/ecuador/tarde-1-piquero-galapagos.jpg',
    'assets/fondos/ecuador/tarde-2-albatros.jpg',
    'assets/fondos/ecuador/tarde-3-paisaje-ecuador.jpg',
  ],
  'noche': [
    'assets/fondos/ecuador/noche-1-rana.jpg',
    'assets/fondos/ecuador/noche-2-san-francisco.jpg',
    'assets/fondos/ecuador/noche-3-la-compania.jpg',
  ],
};

/// Momento del día: mañana 06-12, tarde 12-18, noche 18-06.
String ecuadorMoodFor(DateTime now) {
  if (now.hour >= 6 && now.hour < 12) return 'manana';
  if (now.hour >= 12 && now.hour < 18) return 'tarde';
  return 'noche';
}

/// Imagen del momento actual. Cambia cada hora dentro del mismo momento.
String ecuadorAssetFor(DateTime now) {
  final list = ecuadorWallpaperSets[ecuadorMoodFor(now)]!;
  final index = (now.millisecondsSinceEpoch ~/ Duration.millisecondsPerHour) % list.length;
  return list[index];
}

/// Subtítulo de cada foto de Ecuador, por nombre de archivo.
const Map<String, String> ecuadorCaptions = {
  'manana-1-chimborazo.jpg': 'Chimborazo',
  'manana-2-mitad-del-mundo.jpg': 'Mitad del Mundo',
  'manana-3-cotopaxi-quilotoa.jpg': 'Cotopaxi y Quilotoa',
  'tarde-1-piquero-galapagos.jpg': 'Piquero de Galápagos',
  'tarde-2-albatros.jpg': 'Albatros de Galápagos',
  'tarde-3-paisaje-ecuador.jpg': 'Paisaje de Ecuador',
  'noche-1-rana.jpg': 'Rana del Bosque Guardián',
  'noche-2-san-francisco.jpg': 'San Francisco',
  'noche-3-la-compania.jpg': 'La Compañía',
};

class WallpaperService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService _settingsService;

  late File _wallpaperFile;
  late File _wallpaperDayFile;
  late File _wallpaperNightFile;
  Timer? _timer;

  ImageProvider? _wallpaper;
  int _version = 0;
  int _updateWallpaperCallCount = 0;

  ImageProvider?  get wallpaper     => _wallpaper;
  int             get version       => _version;

  String? _caption;
  /// Subtítulo de la foto actual; null si el fondo no es del set de Ecuador.
  String? get caption => _caption;

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
        (gradient) => gradient.uuid == _settingsService.gradientUuid,
        orElse: () => FLauncherGradients.pitchBlack,
      );

  WallpaperService(this._fLauncherChannel, this._settingsService) :
    _wallpaper = null
  {
    _settingsService.addListener(_onSettingsChanged);
    _init();
  }

  bool _lastRotating = false;

  /// Hay que refrescar cada minuto si el fondo depende de la hora.
  bool get _isRotatingEnabled =>
      _settingsService.timeBasedWallpaperEnabled || _settingsService.ecuadorWallpaperEnabled;

  void _onSettingsChanged() {
    final rotating = _isRotatingEnabled;
    if (rotating != _lastRotating) {
      _lastRotating = rotating;
      _updateTimerState();
    }
    _updateWallpaper();
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _wallpaperFile = File("${directory.path}/wallpaper");
    _wallpaperDayFile = File("${directory.path}/wallpaper_day");
    _wallpaperNightFile = File("${directory.path}/wallpaper_night");

    _lastRotating = _isRotatingEnabled;
    await _updateWallpaper();
    _updateTimerState();
  }

  void _updateTimerState() {
    final enabled = _isRotatingEnabled;
    if (enabled && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateWallpaper());
    } else if (!enabled && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _updateWallpaper({bool force = false}) async {
    final callId = ++_updateWallpaperCallCount;
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    ImageProvider? newWallpaper;
    String? newCaption;

    if (_settingsService.ecuadorWallpaperEnabled) {
      final assetPath = ecuadorAssetFor(now);
      newWallpaper = AssetImage(assetPath);
      newCaption = ecuadorCaptions[assetPath.split('/').last];
    } else if (enabled) {
      if (isDay && await _wallpaperDayFile.exists()) {
        newWallpaper = FileImage(_wallpaperDayFile);
      } else if (!isDay && await _wallpaperNightFile.exists()) {
        newWallpaper = FileImage(_wallpaperNightFile);
      } else if (await _wallpaperFile.exists()) {
        newWallpaper = FileImage(_wallpaperFile); // Fallback
      }
    } else {
      if (await _wallpaperFile.exists()) {
        newWallpaper = FileImage(_wallpaperFile);
      }
    }

    if (callId == _updateWallpaperCallCount) {
      if (_wallpaper != newWallpaper || _caption != newCaption || force) {
        _wallpaper = newWallpaper;
        _caption = newCaption;
        notifyListeners();
      }
    }
  }

  Future<void> pickWallpaper() async {
    await _pickAndSave(_wallpaperFile);
  }

  Future<void> pickWallpaperDay() async {
    await _pickAndSave(_wallpaperDayFile);
  }

  Future<void> pickWallpaperNight() async {
    await _pickAndSave(_wallpaperNightFile);
  }

  Future<void> _pickAndSave(File targetFile) async {
    if (!await _fLauncherChannel.checkForGetContentAvailability()) {
      throw NoFileExplorerException();
    }

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Use stream for memory efficiency
      final readStream = pickedFile.openRead();
      final writeStream = targetFile.openWrite();
      await readStream.cast<List<int>>().pipe(writeStream);

      // Evict from cache to ensure UI updates
      await FileImage(targetFile).evict();

      _version++;
      await _updateWallpaper(force: true);
    }
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    if (await _wallpaperFile.exists()) {
      await _wallpaperFile.delete();
    }

    _settingsService.setGradientUuid(fLauncherGradient.uuid);
    notifyListeners();
  }
}

class NoFileExplorerException implements Exception {}
