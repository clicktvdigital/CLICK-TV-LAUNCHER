import 'package:flauncher/l10n/app_localizations.dart';

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
