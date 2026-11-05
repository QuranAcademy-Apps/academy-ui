import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Built-in wording. A client delegate placed before [delegate] can override it.
class AcademyLocalizations {
  const AcademyLocalizations(this.locale);
  final Locale locale;
  static const supportedLocales = [Locale('ru'), Locale('en'), Locale('ar')];
  static const delegate = _AcademyLocalizationsDelegate();
  static AcademyLocalizations of(BuildContext context) =>
      Localizations.of<AcademyLocalizations>(context, AcademyLocalizations) ??
      AcademyLocalizations(
        Localizations.maybeLocaleOf(context) ?? const Locale('ru'),
      );
  String _text(String ru, String en, String ar) =>
      switch (locale.languageCode) {
        'ar' => ar,
        'ru' => ru,
        _ => en,
      };
  List<String> get weekdaysShort => switch (locale.languageCode) {
    'ru' => const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
    'ar' => const ['اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد'],
    _ => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  };
  String get cancel => _text('Отмена', 'Cancel', 'إلغاء');
  String get choose => _text('Выбрать', 'Choose', 'اختر');
  String get noResults =>
      _text('Ничего не найдено', 'No results', 'لا توجد نتائج');
  String get loading => _text('Загрузка', 'Loading', 'جار التحميل');
  String get loadError =>
      _text('Не удалось загрузить', 'Could not load', 'تعذر التحميل');
  String get previousMonth =>
      _text('Предыдущий месяц', 'Previous month', 'الشهر السابق');
  String get nextMonth =>
      _text('Следующий месяц', 'Next month', 'الشهر التالي');
  String get clearSelection =>
      _text('Очистить выбор', 'Clear selection', 'مسح الاختيار');
  String selectedCount(int count) =>
      _text('Выбрано: $count', '$count selected', 'تم اختيار $count');
  String get close => _text('Закрыть', 'Close', 'إغلاق');
  String get back => _text('Назад', 'Back', 'رجوع');
  String get imageLoading =>
      _text('Загрузка изображения', 'Loading image', 'جار تحميل الصورة');
  String get closePhotoViewer =>
      _text('Закрыть просмотр фото', 'Close photo viewer', 'إغلاق عارض الصور');
  String get closePhotoViewerHint => _text(
    'Также можно смахнуть фото вниз',
    'You can also swipe the photo down',
    'يمكنك أيضًا سحب الصورة لأسفل',
  );
  String get search => _text('Поиск', 'Search', 'بحث');
  String get closeSearch =>
      _text('Закрыть поиск', 'Close search', 'إغلاق البحث');
  String get openSearch => _text('Открыть поиск', 'Open search', 'فتح البحث');
  String get increase => _text('Увеличить', 'Increase', 'زيادة');
  String get decrease => _text('Уменьшить', 'Decrease', 'تقليل');
  String get information => _text('Информация', 'Information', 'معلومات');
  String get inputPlaceholder =>
      _text('Введите значение', 'Enter a value', 'أدخل قيمة');
  String get retry => _text('Повторить', 'Retry', 'إعادة المحاولة');
  String get confirm => _text('Подтвердить', 'Confirm', 'تأكيد');
  String get progress => _text('Прогресс', 'Progress', 'التقدم');
  String get emptyProgress => _text('Нет пунктов', 'No items', 'لا توجد عناصر');
  String get completed => _text('Завершено', 'Completed', 'مكتمل');
  String get timelineCurrent => _text('Текущий', 'Current', 'الحالي');
  String get timelineUpcoming => _text('Впереди', 'Upcoming', 'قادم');
  String get done => _text('Готово', 'Done', 'تم');
  String get finish => _text('Завершить', 'Finish', 'إنهاء');
  String get nextStep => _text('Следующий шаг', 'Next step', 'الخطوة التالية');
  String get previousStep =>
      _text('Предыдущий шаг', 'Previous step', 'الخطوة السابقة');
  String get next => _text('Далее', 'Next', 'التالي');
  String get skip => _text('Пропустить', 'Skip', 'تخطي');
  String get toastDismissUpHint => _text(
    'Смахните вверх или нажмите, чтобы закрыть',
    'Swipe up or tap to dismiss',
    'اسحب لأعلى أو اضغط للإغلاق',
  );
  String get toastDismissDownHint => _text(
    'Смахните вниз или нажмите, чтобы закрыть',
    'Swipe down or tap to dismiss',
    'اسحب لأسفل أو اضغط للإغلاق',
  );
  String get toastDismissHint => _text(
    'Смахните или нажмите, чтобы закрыть',
    'Swipe or tap to dismiss',
    'اسحب أو اضغط للإغلاق',
  );
  String get drag => _text('Перетащить', 'Drag', 'اسحب');
  String get dropHere => _text('Перетащите сюда', 'Drop here', 'اسحب إلى هنا');
  String get moveUp => _text('Переместить выше', 'Move up', 'نقل لأعلى');
  String get moveDown => _text('Переместить ниже', 'Move down', 'نقل لأسفل');
  String chromeStyle(String name) => switch (name) {
    'gradient' => _text('Хром', 'Chrome', 'كروم'),
    'flat' => _text('Мягкий', 'Soft', 'ناعم'),
    'blur' => _text('Блюр', 'Blur', 'تمويه'),
    'tinted' => _text('Акцентный', 'Tinted', 'ملون'),
    'outlined' => _text('Контур', 'Outlined', 'محدد'),
    'glass' => _text('Стекло', 'Glass', 'زجاج'),
    _ => _text('Без chrome', 'No chrome', 'بدون كروم'),
  };
  String tabDensity(String name) => switch (name) {
    'compact' => _text('Компактный', 'Compact', 'مضغوط'),
    'telegram' => 'Telegram',
    _ => _text('Обычный', 'Standard', 'قياسي'),
  };
  String clearField(String label) =>
      _text('Очистить поле $label', 'Clear $label', 'مسح $label');
  String count(int completed, int total) => _text(
    '$completed из $total',
    '$completed of $total',
    '$completed من $total',
  );
  String completedCount(int completed, int total) => _text(
    'Выполнено $completed из $total',
    '$completed of $total completed',
    'اكتمل $completed من $total',
  );
  String step(int step, int total) => _text(
    'Шаг $step из $total',
    'Step $step of $total',
    'الخطوة $step من $total',
  );
  String itemNumber(int index) =>
      _text('Пункт $index', 'Item $index', 'العنصر $index');
  String moveItem(String label) =>
      _text('Переместить $label', 'Move $label', 'نقل $label');
  String removeItem(String label) =>
      _text('Удалить $label', 'Remove $label', 'حذف $label');
  String moveTo(String label) =>
      _text('Переместить в $label', 'Move to $label', 'نقل إلى $label');
}

class _AcademyLocalizationsDelegate
    extends LocalizationsDelegate<AcademyLocalizations> {
  const _AcademyLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => AcademyLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );
  @override
  Future<AcademyLocalizations> load(Locale locale) =>
      SynchronousFuture(AcademyLocalizations(locale));
  @override
  bool shouldReload(_AcademyLocalizationsDelegate old) => false;
}
