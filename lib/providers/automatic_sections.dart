import '../models/category.dart';

const String defaultHomeCategoryName = 'TV Apps';

bool hasSameCategoryApplications(Category category, Set<String> expectedPackages) {
  final actualPackages = category.applications.map((app) => app.packageName).toSet();
  return actualPackages.length == expectedPackages.length &&
      actualPackages.containsAll(expectedPackages);
}

bool isUnmodifiedAutomaticCategory(
  Category category, {
  required String name,
  required int order,
  required Set<String> expectedPackages,
}) {
  final isGrid = name == 'TV Apps';
  return category.name == name &&
      category.order == order &&
      category.sort == CategorySort.manual &&
      category.type == (isGrid ? CategoryType.grid : CategoryType.row) &&
      category.columnsCount == Category.ColumnsCount &&
      category.rowHeight == Category.RowHeight &&
      hasSameCategoryApplications(category, expectedPackages);
}
