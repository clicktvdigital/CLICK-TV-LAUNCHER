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


import 'package:flauncher/actions.dart';
import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/launcher_alternative_view.dart';
import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/widgets/continue_watching_row.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/l10n/app_localizations.dart';

import 'models/category.dart';

class FLauncher extends StatefulWidget {
  const FLauncher({super.key});

  @override
  State<FLauncher> createState() => _FLauncherState();
}

class _FLauncherState extends State<FLauncher> {
  final GlobalKey<FocusAwareAppBarState> _appBarKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Actions(
    actions: <Type, Action<Intent>>{
      MoveFocusToSettingsIntent: CallbackAction<MoveFocusToSettingsIntent>(
        onInvoke: (_) => _appBarKey.currentState?.focusSettings(),
      ),
    },
    child: FocusTraversalGroup(
      policy: RowByRowTraversalPolicy(),
      child: Stack(
        children: [
          RepaintBoundary(
            child: Consumer<WallpaperService>(
              builder: (_, wallpaperService, __) => _wallpaper(context, wallpaperService)
            ),
          ),
          Consumer<LauncherState>(
            builder: (_, state, child) => Visibility(
              child: child!,
              replacement: const Center(
                child: AlternativeLauncherView()
              ),
              visible: state.launcherVisible
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: FocusAwareAppBar(key: _appBarKey),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Consumer<AppsService>(
                  builder: (context, appsService, _) {
                    if (appsService.initialized) {
                      return Consumer2<WatchNextService, SettingsService>(
                        builder: (context, watchNext, settings, _) {
                          final hiddenProgramIds = settings.hiddenWatchNextProgramIds;
                          final hiddenPackages = settings.hiddenWatchNextPackages;

                          // Only reserve a section when at least one card can appear.
                          final hasVisiblePrograms = watchNext.hasPermission &&
                              watchNext.programs.any((program) =>
                                  !hiddenProgramIds.contains(program.id.toString()) &&
                                  !hiddenPackages.contains(program.packageName) &&
                                  !appsService.applications.any((app) =>
                                      app.packageName == program.packageName && app.hidden));

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sections(
                                  appsService.launcherSections,
                                  continueWatchingActive:
                                      settings.showContinueWatching && hasVisiblePrograms,
                                  continueWatchingOrder: settings.continueWatchingOrder,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    else {
                      return _emptyState(context);
                    }
                  }
                )
              )
            )
          )
        ]
      )
    ),
  );

  Widget _sections(
    List<LauncherSection> sections, {
    bool continueWatchingActive = false,
    int continueWatchingOrder = 0,
  }) {
    List<Widget> children = [];
    bool firstCategoryFound = false;
    bool cwInserted = false;

    int sectionIdx = 0;
    for (var section in sections) {
      if (continueWatchingActive && !cwInserted && sectionIdx == continueWatchingOrder) {
        final bool isFirstSection = !firstCategoryFound;
        children.add(ContinueWatchingRow(isFirstSection: isFirstSection));
        cwInserted = true;
        firstCategoryFound = true;
      }

      final Key sectionKey = Key(section.id.toString());

      if (section is LauncherSpacer) {
        children.add(SizedBox(key: sectionKey, height: section.height.toDouble()));
        sectionIdx++;
        continue;
      }

      Category category = section as Category;
      Widget categoryWidget;

      // Only a category with applications can claim initial focus.
      // Empty categories must not block the next available app.
      bool isFirstSection = !firstCategoryFound;
      if (isFirstSection && category.applications.isNotEmpty) {
        firstCategoryFound = true;
      }

      switch (category.type) {
        case CategoryType.row:
          categoryWidget = CategoryRow(
              key: sectionKey,
              category: category,
              applications: category.applications,
              isFirstSection: isFirstSection
          );
          break;
        case CategoryType.grid:
          categoryWidget = AppsGrid(
              key: sectionKey,
              category: category,
              applications: category.applications,
              isFirstSection: isFirstSection
          );
          break;
      }

      children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: categoryWidget
      ));
      sectionIdx++;
    }

    if (continueWatchingActive && !cwInserted) {
      final bool isFirstSection = !firstCategoryFound;
      children.add(ContinueWatchingRow(isFirstSection: isFirstSection));
      cwInserted = true;
      firstCategoryFound = true;
    }

    return Column(children: children);
  }

  Widget _wallpaper(BuildContext context, WallpaperService wallpaperService) {
    Widget background;
    if (wallpaperService.wallpaper != null) {
      final physicalSize = MediaQuery.sizeOf(context);
      final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
      background = Image(
        // Decodifica a la resolución física de la pantalla: 4K en TV 4K y
        // 1080p en TV Box, sin reservar memoria de más en equipos antiguos.
        image: ResizeImage.resizeIfNeeded(
          (physicalSize.width * devicePixelRatio).round(),
          null,
          wallpaperService.wallpaper!,
        ),
        key: Key("background_${wallpaperService.version}"),
        fit: BoxFit.cover,
        height: physicalSize.height,
        width: physicalSize.width
      );
    }
    else {
      background = Container(key: const Key("background"), decoration: BoxDecoration(gradient: wallpaperService.gradient.gradient));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.15),
                Colors.black.withOpacity(0.45),
              ],
            ),
          ),
        ),
        if (wallpaperService.caption != null)
          Positioned(
            left: 48,
            bottom: 24,
            child: Text(
              wallpaperService.caption!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.5,
                shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    final appsService = context.watch<AppsService>();
    if (appsService.initializationError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudieron cargar las aplicaciones.'),
            const SizedBox(height: 16),
            ElevatedButton(
              autofocus: true,
              onPressed: appsService.retryInitialization,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.loading, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
