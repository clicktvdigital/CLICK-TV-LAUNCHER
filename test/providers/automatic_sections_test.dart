import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/automatic_sections.dart';
import 'package:flutter_test/flutter_test.dart';

App _app(String packageName) => App(
      packageName: packageName,
      name: packageName,
      version: '1',
      hidden: false,
    );

void main() {
  test('new installations have only the TV Apps home section', () {
    expect(defaultHomeCategoryName, 'TV Apps');
  });

  test('recognizes the untouched automatic category layout', () {
    final category = Category.withApplications(
      name: 'Favorites',
      id: 3,
      order: 2,
      applications: const [],
    );

    expect(
      isUnmodifiedAutomaticCategory(
        category,
        name: 'Favorites',
        order: 2,
        expectedPackages: <String>{},
      ),
      isTrue,
    );
  });

  test('does not classify a manually populated automatic category as untouched', () {
    final category = Category.withApplications(
      name: 'Favorites',
      id: 3,
      order: 2,
      applications: [_app('com.example.manual')],
    );

    expect(
      isUnmodifiedAutomaticCategory(
        category,
        name: 'Favorites',
        order: 2,
        expectedPackages: <String>{},
      ),
      isFalse,
    );
  });

  test('does not classify a reordered automatic section as untouched', () {
    final category = Category.withApplications(
      name: 'Non-TV Apps',
      id: 2,
      order: 4,
      applications: const [],
    );

    expect(
      isUnmodifiedAutomaticCategory(
        category,
        name: 'Non-TV Apps',
        order: 1,
        expectedPackages: <String>{},
      ),
      isFalse,
    );
  });
}
