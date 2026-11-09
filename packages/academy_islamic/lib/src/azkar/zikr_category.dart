/// Built-in collections of the corpus. `id` matches `azkar.json` and storage.
enum ZikrCategory {
  morning('morning'),
  evening('evening'),
  afterSalah('after-salah'),
  night('night'),
  other('other'),
  hundredDua('hundred-dua');

  const ZikrCategory(this.id);
  final String id;

  static ZikrCategory? byId(String id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Daily routines get progress and a «start reading» flow; the rest are
  /// reference collections.
  bool get isDaily =>
      this == morning || this == evening || this == afterSalah || this == night;
}
