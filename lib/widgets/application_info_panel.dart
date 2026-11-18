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
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flauncher/widgets/app_card_keys.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/add_to_category_dialog.dart';
import 'package:flauncher/widgets/side_panel_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/l10n/app_localizations_en.dart';

import '../models/app.dart';
import '../models/category.dart';

class ApplicationInfoPanel extends StatefulWidget
{
  final Category? category;
  final App application;
  final ImageProvider? applicationIcon;

  const ApplicationInfoPanel({
    required this.category,
    required this.application,
    this.applicationIcon
  });

  @override
  State<ApplicationInfoPanel> createState() => _ApplicationInfoPanelState();
}

class _ApplicationInfoPanelState extends State<ApplicationInfoPanel>
{
  late Future<bool> _hasCustomBannerFuture;

  @override
  void initState() {
    super.initState();
    _hasCustomBannerFuture = context.read<AppsService>()
        .hasCustomBanner(widget.application.packageName);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return SidePanelDialog(
        width: 300,
        isRightSide: false,
        child: HeldOkGuard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (widget.applicationIcon != null)
                  Image(image: widget.applicationIcon!, width: 50)
                else
                  const Icon(Icons.image_not_supported_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.application.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.application.packageName,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "v${widget.application.version}",
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                 children: [
                   // Acciones principales del menú de OK largo (1 s), en el
                   // orden en que se usan con el D-pad. "Abrir" recibe el foco
                   // al abrir el panel para no tener que buscarlo con flechas.
                   _PanelAction(
                     key: const Key('app-panel-open'),
                     autofocus: true,
                     icon: Icons.open_in_new,
                     label: localizations.open,
                     onPressed: () async {
                       final appsService = context.read<AppsService>();
                       Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                       await appsService.launchApp(widget.application);
                     },
                   ),
                   _PanelAction(
                     key: const Key('app-panel-info'),
                     icon: Icons.info_outlined,
                     label: localizations.appInfo,
                     onPressed: () async {
                       final appsService = context.read<AppsService>();
                       Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                       await appsService.openAppInfo(widget.application);
                     },
                   ),
                   _PanelAction(
                     key: const Key('app-panel-uninstall'),
                     icon: Icons.delete_outlined,
                     label: localizations.uninstall,
                     onPressed: () async {
                       final appsService = context.read<AppsService>();
                       Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                       await appsService.uninstallApp(widget.application);
                     },
                   ),
                   const Divider(),
                   // Add to Category button
                   TextButton(
                     child: Row(
                       children: [
                         const Icon(Icons.add_box_outlined),
                         Container(width: 8),
                         Flexible(
                           child: Text(localizations.withEllipsisAddTo, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                         ),
                       ],
                     ),
                     onPressed: () async {
                       Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                       await showDialog(
                         context: context,
                         builder: (context) => AddToCategoryDialog(widget.application),
                       );
                     },
                   ),
                   // Reorder button (Second as requested)
                   if (widget.category?.sort == CategorySort.manual)
                     TextButton(
                       child: Row(
                         children: [
                           const Icon(Icons.open_with),
                           Container(width: 8),
                           Flexible(
                             child: Text(localizations.reorder, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                           ),
                         ],
                       ),
                       onPressed: () => Navigator.of(context).pop(ApplicationInfoPanelResult.reorderApp),
                     ),
                   // Favorites toggle button
                   Builder(
                     builder: (context) {
                       final appsService = context.watch<AppsService>();
                       final isInFavorites = appsService.isAppInFavorites(widget.application);
                       return TextButton(
                         child: Row(
                           children: [
                             Icon(isInFavorites ? Icons.star : Icons.star_border),
                             Container(width: 8),
                             Flexible(
                               child: Text(
                                 isInFavorites
                                     ? localizations.removeFrom(localizations.favoriteApps)
                                     : '${localizations.withEllipsisAddTo} ${localizations.favoriteApps}',
                                 style: Theme.of(context).textTheme.bodyMedium,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                           ],
                         ),
                         onPressed: () async {
                           await appsService.toggleFavorite(widget.application);
                           Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                         },
                       );
                     },
                   ),
                   TextButton(
                     child: Row(
                       children: [
                         Icon(widget.application.hidden ? Icons.visibility : Icons.visibility_off_outlined),
                         Container(width: 8),
                         Flexible(
                           child: Text(widget.application.hidden ? localizations.show : localizations.hide, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                         ),
                       ],
                     ),
                     onPressed: () async {
                       if (widget.application.hidden) {
                         await context.read<AppsService>().showApplication(widget.application);
                       } else {
                         await context.read<AppsService>().hideApplication(widget.application);
                       }
                       Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                     },
                   ),
                   if (widget.category != null)
                     TextButton(
                       child: Row(
                         children: [
                           const Icon(Icons.delete_sweep_outlined),
                           Container(width: 8),
                           Flexible(
                             child: Text(
                               localizations.removeFrom(widget.category?.name ?? ''),
                               style: Theme.of(context).textTheme.bodyMedium,
                               maxLines: 2,
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         ],
                       ),
                       onPressed: () async {
                         final cat = widget.category;
                         if (cat != null) {
                           await context.read<AppsService>().removeFromCategory(widget.application, cat);
                         }
                         Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                       },
                     ),
                   const Divider(),
                   FutureBuilder<bool>(
                     future: _hasCustomBannerFuture,
                     builder: (context, snapshot) {
                       final hasCustom = snapshot.data ?? false;
                       return Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           TextButton(
                             child: Row(
                               children: [
                                 const Icon(Icons.image_search),
                                 Container(width: 8),
                                 Flexible(
                                   child: Text('Set Custom Banner', style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                                 ),
                               ],
                             ),
                             onPressed: () async {
                               try {
                                 final picker = ImagePicker();
                                 final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                 if (pickedFile != null) {
                                   final docDir = await getApplicationDocumentsDirectory();
                                   // Sanitize package name for filename
                                   final safePackageName = widget.application.packageName
                                       .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
                                   final savedImage = File('${docDir.path}/custom_banner_$safePackageName.png');
                                   await File(pickedFile.path).copy(savedImage.path);
                                   // Clean up temp file from ImagePicker
                                   await File(pickedFile.path).delete();
                                   await context.read<AppsService>().setCustomAppBanner(widget.application.packageName, savedImage.path);
                                   // Refresh the future to reflect the change
                                   setState(() {
                                     _hasCustomBannerFuture = context.read<AppsService>()
                                         .hasCustomBanner(widget.application.packageName);
                                   });
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Failed to set banner: $e')),
                                   );
                                 }
                               }
                               if (context.mounted) Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                             },
                           ),
                           if (hasCustom)
                             TextButton(
                               child: Row(
                                 children: [
                                   const Icon(Icons.hide_image_outlined),
                                   Container(width: 8),
                                   Flexible(
                                     child: Text('Clear Custom Banner', style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                                   ),
                                 ],
                               ),
                               onPressed: () async {
                                 try {
                                   await context.read<AppsService>().removeCustomAppBanner(widget.application.packageName);
                                   // Refresh the future to reflect the change
                                   setState(() {
                                     _hasCustomBannerFuture = context.read<AppsService>()
                                         .hasCustomBanner(widget.application.packageName);
                                   });
                                 } catch (e) {
                                   if (context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text('Failed to clear banner: $e')),
                                     );
                                   }
                                 }
                                 if (context.mounted) Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                               },
                             ),
                         ],
                       );
                     }
                   ),
                 ]
                )
              )
            )
          ]
        )
        )
      );
  }
}

enum ApplicationInfoPanelResult { none, reorderApp }

class _PanelAction extends StatelessWidget {
  const _PanelAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.autofocus = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextButton(
        autofocus: autofocus,
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

/// El panel se abre mientras OK sigue presionado (1 s). Sin este filtro, las
/// repeticiones de esa misma pulsación activarían el botón con foco ("Abrir")
/// en cuanto aparece el panel. Se ignoran las teclas de validación hasta el
/// primer KeyUp, sea cual sea su código lógico: algunos controles de TV box
/// sueltan OK como Control Right, y esperar un KeyUp de OK se comía la primera
/// pulsación dentro del menú. Una flecha también desactiva el filtro por si el
/// control perdió el KeyUp. Si el panel se abrió con Menú/Info o táctil, no
/// filtra.
@visibleForTesting
class HeldOkGuard extends StatefulWidget {
  const HeldOkGuard({super.key, required this.child});

  final Widget child;

  @override
  State<HeldOkGuard> createState() => _HeldOkGuardState();
}

class _HeldOkGuardState extends State<HeldOkGuard> {
  late bool _waitingForRelease = HardwareKeyboard.instance.logicalKeysPressed
      .any(AppCardKeys.validationKeys.contains);

  @override
  void initState() {
    super.initState();
    ctvKeyLog('menú abierto; OK aún presionado=$_waitingForRelease '
        'teclas=${HardwareKeyboard.instance.logicalKeysPressed.map((k) => k.debugName).toList()}');
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (AppCardKeys.validationKeys.contains(event.logicalKey)) {
            ctvKeyLog('menú ${event.runtimeType} ${event.logicalKey.debugName} '
                'filtro=${_waitingForRelease ? 'activo' : 'libre'}');
          }
          if (!_waitingForRelease) return KeyEventResult.ignored;
          final key = event.logicalKey;
          final isValidation = AppCardKeys.validationKeys.contains(key);
          if (event is KeyUpEvent) {
            _waitingForRelease = false;
            return isValidation ? KeyEventResult.handled : KeyEventResult.ignored;
          }
          if (AppCardKeys.isArrowKey(key)) {
            _waitingForRelease = false;
            return KeyEventResult.ignored;
          }
          return isValidation ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: widget.child,
      );
}
