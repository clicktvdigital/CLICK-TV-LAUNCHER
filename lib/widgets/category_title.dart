import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Título de sección sobre el fondo: chip translúcido local para que se lea
/// sobre cualquier foto sin oscurecer toda la pantalla.
class CategoryTitleChip extends StatelessWidget {
  const CategoryTitleChip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: child,
        ),
      );
}

/// Localizes built-in category names without changing persisted names.
String localizedCategoryTitle(AppLocalizations localizations, String name) {
  switch (name.trim().toLowerCase()) {
    case 'tv apps':
    case 'tv applications':
      return localizations.tvApplications;
    case 'non-tv apps':
    case 'non-tv applications':
      return localizations.nonTvApplications;
    case 'favorites':
      return localizations.favoriteApps;
    default:
      return name;
  }
}
