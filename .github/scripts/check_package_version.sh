#!/usr/bin/env bash
# Fails when academy_ui changes for its consumers without a new version and a
# CHANGELOG entry. Compares the working tree with the merge base of <base-ref>.
#
# Usage: check_package_version.sh <base-ref>
set -euo pipefail

base_ref=${1:?Usage: check_package_version.sh <base-ref>}
package=packages/academy_ui
semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

cd "$(git rev-parse --show-toplevel)"
merge_base=$(git merge-base "$base_ref" HEAD)

fail() {
  echo "::error::$1" >&2
  exit 1
}

version_in() {
  sed -n 's/^version:[[:space:]]*//p' | head -n 1
}

# Succeeds when version $1 is strictly greater than version $2.
is_greater() {
  local a1 a2 a3 b1 b2 b3
  IFS=. read -r a1 a2 a3 <<<"$1"
  IFS=. read -r b1 b2 b3 <<<"$2"
  ((a1 != b1)) && { ((a1 > b1)); return; }
  ((a2 != b2)) && { ((a2 > b2)); return; }
  ((a3 > b3))
}

base_version=$(git show "$merge_base:$package/pubspec.yaml" | version_in)
head_version=$(version_in <"$package/pubspec.yaml")

[[ $head_version =~ $semver ]] ||
  fail "Версия '$head_version' в $package/pubspec.yaml должна иметь вид X.Y.Z."

if [[ $head_version == "$base_version" ]]; then
  # Tests, docs and tools do not reach consumers, so they need no release.
  changed=$(git diff --name-only "$merge_base" -- \
    "$package/lib" "$package/assets" "$package/third_party" "$package/pubspec.yaml")
  if [[ -n $changed ]]; then
    echo "Изменённые файлы пакета:" >&2
    echo "$changed" >&2
    fail "Пакет изменён, но версия осталась $base_version. Поднимите версию и добавьте запись в CHANGELOG.md."
  fi
  echo "Пакет для приложений не менялся, версия $head_version."
  exit 0
fi

[[ $base_version =~ $semver ]] ||
  fail "Базовая версия '$base_version' должна иметь вид X.Y.Z."
is_greater "$head_version" "$base_version" ||
  fail "Новая версия $head_version должна быть больше базовой $base_version."

top_entry=$(sed -n 's/^## //p' "$package/CHANGELOG.md" 2>/dev/null | head -n 1 || true)
[[ $top_entry == "$head_version" ]] ||
  fail "Первая запись в $package/CHANGELOG.md должна быть '## $head_version', сейчас '${top_entry:-нет}'."

echo "Версия $base_version → $head_version, запись в CHANGELOG.md есть."
