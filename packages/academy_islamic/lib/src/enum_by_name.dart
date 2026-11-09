/// The value of [values] named [name], or [fallback]: saved data may hold a
/// name that this build does not know.
T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
