# Graph Report - CLICK-TV-LAUNCHER  (2026-11-13)

## Corpus Check
- 224 files · ~136,002 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 39 file(s) not represented in the graph (top: .xml 15, .arb 14, (none) 6)

## Summary
- 5571 nodes · 7727 edges · 160 communities (117 shown, 43 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 36 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `551bfb90`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_localizations.dart
- app_localizations_es.dart
- app_localizations_ar.dart
- app_localizations_de.dart
- app_localizations_en.dart
- app_localizations_fr.dart
- app_localizations_hi.dart
- app_localizations_it.dart
- app_localizations_ja.dart
- app_localizations_ko.dart
- app_localizations_pt.dart
- app_localizations_ru.dart
- app_localizations_tr.dart
- app_localizations_uk.dart
- app_localizations_zh.dart
- settings_service.dart
- MainActivity
- apps_service.dart
- backup_service.dart
- package:flutter_test/flutter_test.dart
- database.dart
- flauncher_test.dart
- flauncher_channel.dart
- static const String
- database.drift.dart
- CONTINUAR AQUI
- launcher_section_panel_page.dart
- settings_panel.dart
- main.dart
- ClockScreensaverService
- donate_dialog.dart
- MainActivity
- package:provider/provider.dart
- notifications_service.dart
- with
- applications_panel_page.dart
- android.content.Intent
- LauncherNotificationListenerService
- dart:async
- app_card.dart
- weather_data.dart
- wallpaper_service_test.dart
- date_time_widget.dart
- mocks.dart
- continue_watching_row.dart
- SettingsService
- watch_next_info_panel.dart
- java.util.Map
- category.dart
- with
- package:flutter/material.dart
- focus_aware_app_bar.dart
- LauncherState
- weather_service.dart
- custom_traversal_policy.dart
- brightness_service.dart
- android.os.Handler
- network_service.dart
- wallpaper_service.dart
- focus_keyboard_listener.dart
- wallpaper_panel_page.dart
- ltvL/NetworkEventStreamHandler.java
- with
- State
- StatelessWidget
- tv_assistant_page.dart
- launcher_state.dart
- watch_next_service.dart
- application_info_panel.dart
- build
- gradients.dart
- side_panel_dialog.dart
- Non-TV Apps row
- notifications_settings_page.dart
- donate_dialog_test.dart
- intent
- category_title_test.dart
- AppLocalizations
- Override
- continue_watching_row_test.dart
- launcher_sections_panel_page.dart
- App context menu (SmartTube)
- dependencies
- builders
- flauncher.dart
- LauncherAppsEventStreamHandler
- accent_color_page.dart
- continue_watching_card_size_page.dart
- continue_watching_max_items_page.dart
- android.os.UserHandle
- general_settings_page.dart
- AppsService
- generate_release_notes.py
- screensaver_clock_style_page.dart
- android.content.Context
- dev_dependencies
- network_widget.dart
- androidx.annotation.RequiresApi
- themes_page.dart
- app.dart
- WeatherReceiverTest
- focusable_settings_tile.dart
- rename_category_dialog.dart
- pubspec.yaml
- Release notes v2026.09.15
- Full Store Description
- tv_input.dart
- AppCategory
- Sections Panel
- display_settings_page.dart
- app_card_keys.dart
- Table
- ../models/category.dart
- build
- flutter_icons
- analysis_options.yaml
- accessibility_page_test.dart
- CLICK TV Digital logo
- Settings panel
- banner_dark.svg
- CLICK TV Digital banner
- click_tv_splash.png
- back_button_actions.dart
- LTvLauncher light banner
- DonateDialog
- flutter_localizations
- Changelog 4100
- Changelog 6101
- Changelog 8103
- Changelog 8104
- Changelog 8105
- Changelog 8106
- Changelog 8108
- Changelog 8109
- Changelog 8110
- Changelog 8111
- Changelog 8112
- Short Store Description
- interface_settings_page.dart
- Estado del proyecto: CLICK TV Launcher y Alerta EC
- NetworkChangeReceiver
- NetworkChangeReceiver
- weather_service_test.dart
- dart:io
- Avisos de terceros
- debloat.sh
- set-home.sh
- Créditos de los fondos de Ecuador

## God Nodes (most connected - your core abstractions)
1. `AppsService` - 65 edges
2. `MainActivity` - 63 edges
3. `MainActivity` - 59 edges
4. `SettingsService` - 51 edges
5. `LauncherState` - 25 edges
6. `AppLocalizations` - 20 edges
7. `dependencies` - 17 edges
8. `WeatherOverlay` - 15 edges
9. `ClockScreensaverService` - 15 edges
10. `ClockScreensaverService` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Year.month.monthly-release versioning scheme` --conceptually_related_to--> `Release notes v2026.08.10`  [INFERRED]
  CHANGELOG.md → docs/releasenote/release_notes_v2026.08.10.md
- `MockFlauncherChannel` --implements--> `FLauncherChannel`  [EXTRACTED]
  test/network_service_debug_test.dart → lib/flauncher_channel.dart
- `_StartupChannel` --inherits--> `FLauncherChannel`  [EXTRACTED]
  test/providers/apps_service_startup_test.dart → lib/flauncher_channel.dart
- `Ten configured donation methods` --shares_data_with--> `Voluntary donation suggestions`  [INFERRED]
  docs/CONTINUAR_AQUI.md → README.md
- `Termux with fish and adb workflow` --conceptually_related_to--> `M201 test device (API 22, ARMv7)`  [INFERRED]
  README.md → docs/PRUEBAS_ANDROID_TV.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Continue Watching row changes across releases** — fastlane_metadata_android_en_us_changelogs_8103, fastlane_metadata_android_en_us_changelogs_8108, fastlane_metadata_android_en_us_changelogs_8109, fastlane_metadata_android_en_us_changelogs_8110, fastlane_metadata_android_en_us_changelogs_8111, fastlane_metadata_android_en_us_changelogs_8112 [EXTRACTED 1.00]
- **SmartTube context menu actions** — docs_images_screenshot_4_add_to_category, docs_images_screenshot_4_reorder, docs_images_screenshot_4_open, docs_images_screenshot_4_remove_from_fav, docs_images_screenshot_4_hide, docs_images_screenshot_4_remove_from_favorites, docs_images_screenshot_4_application_info, docs_images_screenshot_4_uninstall [EXTRACTED 1.00]
- **Donation flow across README, status doc and donation dialog** — readme_donation_suggestions, docs_continuar_aqui_donation_methods, docs_donaciones_android_tv_two_panel_dialog, docs_donaciones_android_tv_dialog_test [INFERRED 0.75]
- **Launcher home screen rows** — docs_images_screenshot_1_favorites_row, docs_images_screenshot_1_tv_apps_row, docs_images_screenshot_1_non_tv_apps_row, docs_images_screenshot_1_status_bar [INFERRED 0.75]
- **Remote control navigation and its validation** — readme_remote_control_navigation, docs_pruebas_android_tv_remote_key_checks, docs_donaciones_android_tv_dpad_navigation, docs_continuar_aqui_physical_tv_checks [INFERRED 0.75]
- **Startup and section-persistence stability fixes** — docs_releasenote_release_notes_v2026_09_15_null_sort_loading_fix, docs_releasenote_release_notes_v2026_09_15_android_7_1_fix, docs_releasenote_release_notes_v2026_09_15_orphan_prevention_on_delete, docs_releasenote_release_notes_v2026_10_03_preserve_section_removals [INFERRED 0.75]

## Communities (160 total, 43 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.01
Nodes (174): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+166 more)

### Community 1 - "app_localizations_es.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 2 - "app_localizations_ar.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 3 - "app_localizations_de.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 4 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 5 - "app_localizations_fr.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 6 - "app_localizations_hi.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 7 - "app_localizations_it.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 8 - "app_localizations_ja.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 9 - "app_localizations_ko.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 10 - "app_localizations_pt.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 11 - "app_localizations_ru.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 12 - "app_localizations_tr.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 13 - "app_localizations_uk.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 14 - "app_localizations_zh.dart"
Cohesion: 0.01
Nodes (166): aboutFlauncher, accentColor, accessibility, addCategory, addSection, alertaEcWeatherDataHint, alphabetical, appCardHighlightAnimation (+158 more)

### Community 15 - "settings_service.dart"
Cohesion: 0.01
Nodes (151): ACCENT_COLOR_AMBER, ACCENT_COLOR_BLUE, ACCENT_COLOR_CYAN, ACCENT_COLOR_GREEN, ACCENT_COLOR_ICE_BLUE, ACCENT_COLOR_INDIGO, ACCENT_COLOR_LIME, ACCENT_COLOR_ORANGE (+143 more)

### Community 16 - "MainActivity"
Cohesion: 0.05
Nodes (6): MainActivity, EventChannel.StreamHandler, EventChannel.StreamHandler, EventChannel.StreamHandler, ContentObserver, NetworkUsageApi23

### Community 17 - "apps_service.dart"
Cohesion: 0.03
Nodes (75): addAllToCategory, addCategory, addSpacer, addToCategory, addToFavorites, _applications, _assignCategoriesForNewApps, autoPopulateCategory (+67 more)

### Community 18 - "backup_service.dart"
Cohesion: 0.05
Nodes (29): FLauncherDatabase, BackupFileEntry, _database, exportBackup, file, getBackupDirectory, getBackupFile, getBackupFiles (+21 more)

### Community 19 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.05
Nodes (40): localizedCategoryTitle, main, main, main, addNetworkChangedListener, checkUsageStatsPermission, getActiveNetworkInformation, main (+32 more)

### Community 20 - "database.dart"
Cohesion: 0.03
Nodes (38): connect, appPackageName, categoryId, columnsCount, height, hidden, id, lastLaunchedAt (+30 more)

### Community 21 - "flauncher_test.dart"
Cohesion: 0.05
Nodes (31): appCardFinder, appsService, false, focusNode, getFocusNodeForApp, getSettingsFocusNode, inkWell, inkWellFinder (+23 more)

### Community 22 - "flauncher_channel.dart"
Cohesion: 0.04
Nodes (53): addAppsChangedListener, addNetworkChangedListener, addNotificationsChangedListener, addWatchNextChangedListener, addWeatherChangedListener, _appsEventChannel, checkAccessibilityPermission, checkForGetContentAvailability (+45 more)

### Community 23 - "static const String"
Cohesion: 0.07
Nodes (21): AppLanguagePage, build, _radioTile, routeName, BackButtonActionPage, build, _radioTile, routeName (+13 more)

### Community 24 - "database.drift.dart"
Cohesion: 0.04
Nodes (50): _, actualTableName, _alias, aliasedName, allSchemaEntities, allTables, _appPackageNameMeta, appsCategoriesRefs (+42 more)

### Community 25 - "CONTINUAR AQUI"
Cohesion: 0.05
Nodes (42): CHANGELOG, Configurable back button action in launcher, Hide application category titles, Customizable date widget format, Removal of Firebase analytics and crashlytics, Flutter upgrade from 3.7.5 to 3.24.5, Network status next to date widget, Spanish translation (+34 more)

### Community 26 - "launcher_section_panel_page.dart"
Cohesion: 0.05
Nodes (40): category, _categorySort, _categoryType, _changed, ChangeNotifier, _columnsCount, createState, _creating (+32 more)

### Community 27 - "settings_panel.dart"
Cohesion: 0.05
Nodes (21): build, createState, _FastPageRoute, initialRoute, _navigatorKey, routeName, SettingsPanelPage, getAll (+13 more)

### Community 28 - "main.dart"
Cohesion: 0.05
Nodes (29): _BootstrapData, _bootstrapFuture, build, _buildLauncher, createState, fLauncherChannel, fLauncherDatabase, _initialize (+21 more)

### Community 30 - "donate_dialog.dart"
Cohesion: 0.04
Nodes (45): _accionesYDatos, _ampliarNode, _aporteNodes, _aporteSeleccionado, _aportesUnicos, _avisoSeguridad, _botonMetodo, build (+37 more)

### Community 33 - "package:provider/provider.dart"
Cohesion: 0.05
Nodes (27): AppImageType, Icon, build, DailyDataUsageWidget, _formatBytes, build, _buildClock, main (+19 more)

### Community 34 - "notifications_service.dart"
Cohesion: 0.05
Nodes (41): _blockedPackages, blockPackage, _callCount, _channel, checkOverlayPermission, checkPermission, didChangeAppLifecycleState, dismiss (+33 more)

### Community 35 - "with"
Cohesion: 0.05
Nodes (39): runs-on, steps, GH_TOKEN, GITHUB_TOKEN, KEY_ALIAS, KEY_PASSWORD, KEYSTORE_BASE64, KEYSTORE_FILE (+31 more)

### Community 36 - "applications_panel_page.dart"
Cohesion: 0.05
Nodes (41): application, ApplicationsPanelPage, _ApplicationsPanelPageState, _AppListItem, _AppListItemState, autofocus, build, _buildCurrentTab (+33 more)

### Community 37 - "android.content.Intent"
Cohesion: 0.12
Nodes (5): BootReceiver, WeatherListener, WeatherReceiver, WeatherListener, WeatherReceiver

### Community 38 - "LauncherNotificationListenerService"
Cohesion: 0.10
Nodes (8): LauncherNotificationListenerService, Runnable, Runnable, NotificationListener, LauncherNotificationListenerService, Runnable, Runnable, NotificationListener

### Community 39 - "dart:async"
Cohesion: 0.10
Nodes (13): main, addAppsChangedListener, completer, fail, getApplicationBanner, getApplicationIcon, getApplications, listener (+5 more)

### Community 40 - "app_card.dart"
Cohesion: 0.06
Nodes (34): _animation, AppCard, _AppCardState, _appImage, application, _appsService, _arrow, _arrows (+26 more)

### Community 41 - "weather_data.dart"
Cohesion: 0.05
Nodes (36): conditionCode, currentCondition, currentConditionCode, currentHumidity, currentTemp, forecasts, formatTemperature, fromJson (+28 more)

### Community 42 - "wallpaper_service_test.dart"
Cohesion: 0.06
Nodes (21): FileNotFoundException, NoFileExplorerException, MockFlauncherChannel, getApplicationDocumentsPath, main, _MockImagePicker, _MockPathProviderPlatform, _MockXFile (+13 more)

### Community 43 - "date_time_widget.dart"
Cohesion: 0.06
Nodes (27): AnimatedCharacter, AnimatedTimeDisplay, build, character, displayText, duration, textStyle, animate (+19 more)

### Community 44 - "mocks.dart"
Cohesion: 0.07
Nodes (18): BlockedNotificationsPage, build, routeName, routeName, build, NotificationsPanel, _showNotificationOptions, fakeApp (+10 more)

### Community 45 - "continue_watching_row.dart"
Cohesion: 0.04
Nodes (40): description, duration, fromMap, id, intentUri, lastEngagementTime, packageName, playbackPosition (+32 more)

### Community 46 - "SettingsService"
Cohesion: 0.10
Nodes (23): BackupService, SettingsService, WatchNextService, BackupRestorePage, build, _confirmFileImport, _confirmImport, _export (+15 more)

### Community 47 - "watch_next_info_panel.dart"
Cohesion: 0.17
Nodes (10): appIconBytes, appsService, build, _canInteract, createState, initState, _openedAt, program (+2 more)

### Community 49 - "category.dart"
Cohesion: 0.08
Nodes (15): applications, CategorySort, CategoryType, ColumnsCount, height, id, LauncherSectionType, name (+7 more)

### Community 50 - "with"
Cohesion: 0.07
Nodes (30): runs-on, steps, KEY_ALIAS, KEY_PASSWORD, KEYSTORE_BASE64, KEYSTORE_FILE, KEYSTORE_PASSWORD, runs-on (+22 more)

### Community 51 - "package:flutter/material.dart"
Cohesion: 0.06
Nodes (11): categoryContainerEmptyState, localizations, build, InputsPanel, build, main, main, main (+3 more)

### Community 52 - "focus_aware_app_bar.dart"
Cohesion: 0.07
Nodes (19): badgeCount, build, createState, dispose, _FocusableIconButton, _FocusableIconButtonState, FocusAwareAppBar, FocusAwareAppBarState (+11 more)

### Community 53 - "LauncherState"
Cohesion: 0.08
Nodes (24): BackAction, BackIntent, context, invoke, isDefaultLauncher, silentForTap, SoundFeedbackDirectionalFocusAction, _backIntents (+16 more)

### Community 54 - "weather_service.dart"
Cohesion: 0.08
Nodes (22): FLauncherChannel, WeatherData, _channel, _checkWeatherOnResume, didChangeAppLifecycleState, dispose, _fetchLatest, hasWeather (+14 more)

### Community 55 - "custom_traversal_policy.dart"
Cohesion: 0.08
Nodes (23): CandidateNode, directionToSearch, distance, _fallbackPolicy, findBestFocusNode, findCandidates, Geometry, inDirection (+15 more)

### Community 56 - "brightness_service.dart"
Cohesion: 0.07
Nodes (25): _applyBrightness, applyCurrentSlotBrightness, _brightnessAfternoon, _brightnessDay, _brightnessEnabled, _brightnessEvening, _brightnessMorning, _brightnessNight (+17 more)

### Community 57 - "android.os.Handler"
Cohesion: 0.08
Nodes (22): NetworkCallbackImpl, java.util.HashMap<String, Object>, java.util.HashMap<String, Object>, java.util.HashMap<String, Object>, java.util.HashMap<String, Object>, NetworkCallbackImplApi31, java.util.HashMap<String, Object>, java.util.HashMap<String, Object> (+14 more)

### Community 58 - "network_service.dart"
Cohesion: 0.07
Nodes (23): _callCount, CellularNetworkType, _channel, _checkPermissionAndStartPolling, _dailyDataUsage, didChangeAppLifecycleState, dispose, _fetchUsage (+15 more)

### Community 59 - "wallpaper_service.dart"
Cohesion: 0.06
Nodes (29): _caption, dispose, ecuadorAssetFor, ecuadorCaptions, ecuadorMoodFor, ecuadorWallpaperSets, _fLauncherChannel, gradient (+21 more)

### Community 60 - "focus_keyboard_listener.dart"
Cohesion: 0.08
Nodes (18): build, builder, createState, dispose, _handledKeys, _handleKey, _keyDownAt, _keyDownEvent (+10 more)

### Community 61 - "wallpaper_panel_page.dart"
Cohesion: 0.11
Nodes (16): WallpaperService, build, _cardBorder, _gradientCard, GradientPanelPage, routeName, build, _pickWallpaper (+8 more)

### Community 63 - "with"
Cohesion: 0.08
Nodes (24): GH_TOKEN, jobs, update-badges, name, on, schedule, workflow_dispatch, permissions (+16 more)

### Community 64 - "State"
Cohesion: 0.11
Nodes (20): FLauncher, _FLauncherState, _BootstrapApp, _BootstrapAppState, FocusKeyboardListener, _FocusKeyboardListenerState, build, _buildPreview (+12 more)

### Community 65 - "StatelessWidget"
Cohesion: 0.06
Nodes (34): ContinueWatchingRow, AlternativeLauncherView, _FavoritesTab, _HiddenTab, _SideloadedTab, _TVTab, _QrAmpliadoDialog, _AboutHeader (+26 more)

### Community 66 - "tv_assistant_page.dart"
Cohesion: 0.10
Nodes (17): _accessibilityOn, action, autofocus, createState, didChangeAppLifecycleState, dispose, hint, initState (+9 more)

### Community 67 - "launcher_state.dart"
Cohesion: 0.09
Nodes (15): ChangeNotifier, handleBackNavigation, _isDefaultLauncher, _launcherVisible, refresh, suppressBackNavigation, _suppressBackUntil, toggleLauncherVisibility (+7 more)

### Community 68 - "watch_next_service.dart"
Cohesion: 0.09
Nodes (19): _callCount, _channel, checkPermission, deleteProgram, didChangeAppLifecycleState, dispose, _hasPendingRefresh, _hasPermission (+11 more)

### Community 69 - "application_info_panel.dart"
Cohesion: 0.08
Nodes (20): AppsCompanion, CategoriesCompanion, App, Category, application, applicationIcon, ApplicationInfoPanel, ApplicationInfoPanelResult (+12 more)

### Community 70 - "build"
Cohesion: 0.18
Nodes (3): build, build, _section

### Community 71 - "gradients.dart"
Cohesion: 0.10
Nodes (17): africanField, all, burningSprings, desertHump, farawayRiver, FLauncherGradient, FLauncherGradients, gradient (+9 more)

### Community 72 - "side_panel_dialog.dart"
Cohesion: 0.12
Nodes (13): alignment, build, child, EnsureVisible, build, child, RightPanelDialog, width (+5 more)

### Community 73 - "Non-TV Apps row"
Cohesion: 0.10
Nodes (19): Launcher home screen screenshot, CloudStream tile, Daily data usage indicator (777.73 MB), Discover ium app tile, Favorites row, Flicky tile, JioHotstar tile, LTv Launcher tile (+11 more)

### Community 74 - "notifications_settings_page.dart"
Cohesion: 0.10
Nodes (17): BrightnessService, NotificationsService, TvInputsService, WeatherService, build, createState, didChangeAppLifecycleState, dispose (+9 more)

### Community 75 - "donate_dialog_test.dart"
Cohesion: 0.11
Nodes (16): _checkQr, density, _focused, _inside, _key, main, _method, _open (+8 more)

### Community 76 - "intent"
Cohesion: 0.18
Nodes (3): LauncherAccessibilityService, LauncherAccessibilityService, MoveFocusToSettingsIntent

### Community 78 - "AppLocalizations"
Cohesion: 0.11
Nodes (17): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsAr, AppLocalizationsDe, AppLocalizationsEn, AppLocalizationsEs, AppLocalizationsFr, AppLocalizationsHi (+9 more)

### Community 79 - "Override"
Cohesion: 0.17
Nodes (4): EventChannel.StreamHandler, EventChannel.StreamHandler, EventChannel.StreamHandler, ContentObserver

### Community 80 - "continue_watching_row_test.dart"
Cohesion: 0.07
Nodes (19): main, mockChannel, notificationsService, streamController, main, mockChannel, watchNextService, watchNextStreamController (+11 more)

### Community 81 - "launcher_sections_panel_page.dart"
Cohesion: 0.10
Nodes (19): LauncherSpacersCompanion, ContinueWatchingSection, LauncherSection, LauncherSpacer, _appsService, _continueWatchingSection, createState, didChangeDependencies (+11 more)

### Community 82 - "App context menu (SmartTube)"
Cohesion: 0.13
Nodes (17): Launcher screenshot 4 (SmartTube context menu open), Add to Category, Application info, CloudStream (launcher tile), App context menu (SmartTube), Flicky (launcher tile), Hide, JioHotstar (launcher tile) (+9 more)

### Community 83 - "dependencies"
Cohesion: 0.12
Nodes (17): dependencies, drift, flutter, google_fonts, image_picker, intl, package_info_plus, path (+9 more)

### Community 84 - "builders"
Cohesion: 0.13
Nodes (16): enabled, build_resolvers|transitive_digests, drift_dev, drift_dev|not_shared, drift_dev|preparing_builder, mockito|mockBuilder, builders, enabled (+8 more)

### Community 85 - "flauncher.dart"
Cohesion: 0.10
Nodes (11): _appBarKey, build, createState, _emptyState, _sections, _wallpaper, main, _buildTestWidget (+3 more)

### Community 87 - "accent_color_page.dart"
Cohesion: 0.15
Nodes (13): AccentColorPage, autofocus, build, color, _ColorTile, _ColorTileState, createState, _focused (+5 more)

### Community 88 - "continue_watching_card_size_page.dart"
Cohesion: 0.14
Nodes (14): autofocus, build, _CardSizeRadioTile, _CardSizeRadioTileState, ContinueWatchingCardSizePage, createState, groupValue, _hasFocus (+6 more)

### Community 89 - "continue_watching_max_items_page.dart"
Cohesion: 0.14
Nodes (14): autofocus, build, ContinueWatchingMaxItemsPage, createState, groupValue, _hasFocus, isSelected, _MaxItemsRadioTile (+6 more)

### Community 92 - "AppsService"
Cohesion: 0.07
Nodes (30): AppsService, AddToCategoryDialog, build, selectedApplication, didUpdateWidget, initState, applications, AppsGrid (+22 more)

### Community 93 - "generate_release_notes.py"
Cohesion: 0.23
Nodes (5): find_apk_size(), get_fastlane_changelog(), get_git_changelog(), get_version_code(), main()

### Community 94 - "screensaver_clock_style_page.dart"
Cohesion: 0.15
Nodes (13): autofocus, build, createState, groupValue, _hasFocus, onChanged, routeName, ScreensaverClockStylePage (+5 more)

### Community 96 - "dev_dependencies"
Cohesion: 0.14
Nodes (14): dev_dependencies, build_runner, drift_dev, flutter_launcher_icons, flutter_lints, flutter_test, mockito, network_image_mock (+6 more)

### Community 97 - "network_widget.dart"
Cohesion: 0.21
Nodes (10): NetworkService, build, child, createState, _focused, _NetworkIconButton, _NetworkIconButtonState, NetworkWidget (+2 more)

### Community 99 - "themes_page.dart"
Cohesion: 0.10
Nodes (19): autofocus, build, onChanged, RoundedSwitchListTile, secondary, title, value, autofocus (+11 more)

### Community 101 - "app.dart"
Cohesion: 0.17
Nodes (8): action, categoryOrders, hidden, lastLaunchedAt, name, packageName, sideloaded, version

### Community 103 - "focusable_settings_tile.dart"
Cohesion: 0.18
Nodes (10): autofocus, build, createState, FocusableSettingsTile, _FocusableSettingsTileState, _focused, leading, onPressed (+2 more)

### Community 104 - "rename_category_dialog.dart"
Cohesion: 0.20
Nodes (9): AddCategoryDialog, _AddCategoryDialogState, build, _controller, createState, dispose, _focusNode, initialValue (+1 more)

### Community 105 - "pubspec.yaml"
Cohesion: 0.18
Nodes (10): description, environment, flutter, sdk, flutter, assets, generate, uses-material-design (+2 more)

### Community 106 - "Release notes v2026.09.15"
Cohesion: 0.22
Nodes (8): Release notes v2026.09.15, Android 7.1 startup crash prevention (#144), Infinite loading splash fix (#145), Independent playback percentage badge setting, Release notes v2026.10.03, Native Android threading and icon decoding hardening, Glow, Squircle and Minimal themes, Optional category app count toggle

### Community 107 - "Full Store Description"
Cohesion: 0.22
Nodes (9): Changelog 6102, Changelog 8107, Full Store Description, Accent Color Support, Data Usage Widget, FLauncher, LTvLauncher, Inbuilt OLED Screensaver (+1 more)

### Community 108 - "tv_input.dart"
Cohesion: 0.22
Nodes (7): fromMap, id, label, other, TvInput, TvInputType, type

### Community 110 - "Sections Panel"
Cohesion: 0.29
Nodes (8): Launcher Sections Panel Screenshot, Add Section Control, Launcher Home App Tiles, Favorites Section, Non-TV Apps Section, Section-Based App Organization, Sections Panel, TV Apps Section

### Community 111 - "display_settings_page.dart"
Cohesion: 0.25
Nodes (4): build, DisplaySettingsPage, _openScreensaverSettings, routeName

### Community 112 - "app_card_keys.dart"
Cohesion: 0.25
Nodes (6): AppCardKeys, cancelKeys, isArrowKey, longPressableKeys, menuKeys, validationKeys

### Community 113 - "Table"
Cohesion: 0.38
Nodes (5): Apps, AppsCategories, Categories, LauncherSpacers, Table

### Community 114 - "../models/category.dart"
Cohesion: 0.29
Nodes (5): actualPackages, defaultHomeCategoryName, hasSameCategoryApplications, isGrid, isUnmodifiedAutomaticCategory

### Community 115 - "build"
Cohesion: 0.12
Nodes (3): build, build, build

### Community 116 - "flutter_icons"
Cohesion: 0.29
Nodes (7): flutter_icons, adaptive_icon_background, adaptive_icon_foreground, android, image_path, ios, min_sdk_android

### Community 117 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 119 - "accessibility_page_test.dart"
Cohesion: 0.18
Nodes (9): appsService, launcherState, main, _methodChannel, pumpAndSettle, _pumpPage, pumpWidget, settingsService (+1 more)

### Community 120 - "CLICK TV Digital logo"
Cohesion: 0.40
Nodes (5): Tecnología | Entretenimiento | Innovación, CLICK TV Digital logo, Globe with glowing orbit rings, Blue play-button triangle with TV badge, Tu Mundo sin Límites tagline

### Community 121 - "Settings panel"
Cohesion: 0.50
Nodes (5): Launcher Settings Screenshot, Accent Color setting, Brightness Scheduler setting, Launcher home screen with app tiles, Settings panel

### Community 122 - "banner_dark.svg"
Cohesion: 0.83
Nodes (3): LTvLauncher wordmark, Purple accent color #7C4DFF (LTv), White text color #FFFFFF (Launcher)

### Community 124 - "CLICK TV Digital banner"
Cohesion: 0.67
Nodes (4): CLICK TV Digital banner, CLICK TV Digital, Blue play-button TV icon, Tu Mundo sin Limites

### Community 126 - "back_button_actions.dart"
Cohesion: 0.50
Nodes (3): BACK_BUTTON_ACTION_CLOCK, BACK_BUTTON_ACTION_NOTHING, BACK_BUTTON_ACTION_SCREENSAVER

### Community 146 - "Estado del proyecto: CLICK TV Launcher y Alerta EC"
Cohesion: 0.25
Nodes (7): Cómo instalar un build firmado, Estado del proyecto: CLICK TV Launcher y Alerta EC, Lo que ya funciona en el TV (verificado), Pendiente de verificar en el TV, Pendiente sin resolver, Preferencias del usuario (aplican siempre), Ramas y builds

### Community 147 - "NetworkChangeReceiver"
Cohesion: 0.33
Nodes (3): NetworkChangeReceiver, java.util.HashMap<String, Object>, java.util.HashMap<String, Object>

### Community 148 - "NetworkChangeReceiver"
Cohesion: 0.33
Nodes (3): NetworkChangeReceiver, java.util.HashMap<String, Object>, java.util.HashMap<String, Object>

### Community 149 - "weather_service_test.dart"
Cohesion: 0.29
Nodes (5): main, mockChannel, validWeatherJson, weatherService, weatherStreamController

### Community 151 - "Avisos de terceros"
Cohesion: 0.40
Nodes (4): Avisos de terceros, Clean Your TV (MIT), FLauncher (GPLv3), Fotografías de Ecuador (Wikimedia Commons)

### Community 152 - "debloat.sh"
Cohesion: 0.60
Nodes (4): adb_cmd(), LC_ALL, debloat.sh script, usage()

### Community 153 - "set-home.sh"
Cohesion: 0.70
Nodes (4): adb_cmd(), home_now(), LC_ALL, set-home.sh script

## Ambiguous Edges - Review These
- `Favorites row` → `Stre... tile (name cut off, likely Stremio)`  [AMBIGUOUS]
  docs/images/screenshot_1.png · relation: references

## Knowledge Gaps
- **3919 isolated node(s):** `_appBarKey`, `createState`, `build`, `_sections`, `_wallpaper` (+3914 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 4327 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **43 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SettingsService` connect `SettingsService` to `settings_service.dart`, `static const String`, `main.dart`, `mocks.dart`, `continue_watching_row.dart`, `watch_next_info_panel.dart`, `LauncherState`, `wallpaper_service.dart`, `wallpaper_panel_page.dart`, `State`, `StatelessWidget`, `launcher_state.dart`, `notifications_settings_page.dart`, `flauncher.dart`, `accent_color_page.dart`, `continue_watching_card_size_page.dart`, `continue_watching_max_items_page.dart`, `screensaver_clock_style_page.dart`, `themes_page.dart`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **What connects `_appBarKey`, `createState`, `build` to the rest of the system?**
  _3919 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.010526315789473684 - nodes in this community are weakly interconnected._
- **Why does `AppsService` connect `AppsService` to `apps_service.dart`, `backup_service.dart`, `launcher_section_panel_page.dart`, `settings_panel.dart`, `applications_panel_page.dart`, `app_card.dart`, `mocks.dart`, `continue_watching_row.dart`, `SettingsService`, `watch_next_info_panel.dart`, `LauncherState`, `State`, `StatelessWidget`, `tv_assistant_page.dart`, `launcher_state.dart`, `application_info_panel.dart`, `notifications_settings_page.dart`, `launcher_sections_panel_page.dart`, `flauncher.dart`, `build`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Should `app_localizations_es.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.011904761904761904 - nodes in this community are weakly interconnected._
- **Why does `FLauncherChannel` connect `weather_service.dart` to `notifications_service.dart`, `launcher_state.dart`, `watch_next_service.dart`, `wallpaper_service_test.dart`, `apps_service.dart`, `flauncher_channel.dart`, `network_service.dart`, `wallpaper_service.dart`, `main.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Favorites row` and `Stre... tile (name cut off, likely Stremio)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._