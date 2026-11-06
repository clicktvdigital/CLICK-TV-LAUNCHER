import 'package:flauncher/l10n/app_localizations_es.dart';
import 'package:flauncher/widgets/category_title.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final localizations = AppLocalizationsEs();

  test('localizes built-in category names without changing custom names', () {
    expect(localizedCategoryTitle(localizations, 'TV Apps'), 'Aplicaciones de TV');
    expect(localizedCategoryTitle(localizations, 'Non-TV Apps'), 'Otras aplicaciones');
    expect(localizedCategoryTitle(localizations, 'Favorites'), 'Apps Favoritas');
    expect(localizedCategoryTitle(localizations, 'Mis aplicaciones'), 'Mis aplicaciones');
  });
}
