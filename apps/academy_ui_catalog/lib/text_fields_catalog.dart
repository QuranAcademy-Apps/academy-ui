import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

/// All text field styles together, using the same theme and editing foundation.
class TextFieldsCatalog extends StatefulWidget {
  const TextFieldsCatalog({super.key});

  @override
  State<TextFieldsCatalog> createState() => _TextFieldsCatalogState();
}

class _TextFieldsCatalogState extends State<TextFieldsCatalog> {
  final _name = TextEditingController(text: 'Аюб Бибулатов');
  final _phone = TextEditingController(text: '+7 9');
  final _email = TextEditingController();
  final _verified = TextEditingController(text: 'ayub@example.com');

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email, _verified]) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _section(
    BuildContext context,
    String title,
    String description,
    List<Widget> fields,
  ) {
    final theme = AcademyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...fields,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _section(
        context,
        'Обычный placeholder',
        'Название внутри пустого поля исчезает при вводе.',
        [
          const AcademyTextField(
            placeholder: 'Почта',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          const AcademyTextField(
            placeholder: 'Пароль',
            obscureText: true,
            clearable: false,
          ),
          const SizedBox(height: 12),
          const AcademyTextField(
            placeholder: 'Недоступный ввод',
            enabled: false,
          ),
          const SizedBox(height: 12),
          const AcademyTextField(placeholder: 'Только чтение', readOnly: true),
          const SizedBox(height: 12),
          const AcademyTextField(
            placeholder: 'Поле с иконками',
            leading: AcademySfIcon(AcademySymbols.book, size: 18),
            trailing: AcademySfIcon(AcademySymbols.plus, size: 18),
          ),
        ],
      ),
      _section(
        context,
        'Заголовок над полем',
        'Название всегда видно снаружи поля.',
        [
          const AcademyField(
            label: 'Почта',
            placeholder: 'Введите почту',
            help: 'Для важных писем и входа в профиль',
          ),
          const AcademyField(label: 'Ошибка', error: 'Заполните поле'),
          const AcademyField(label: 'Недоступное поле', enabled: false),
        ],
      ),
      _section(
        context,
        'Плавающий заголовок',
        'Нажмите на пустое поле: название плавно поднимется. '
            'После очистки и выхода из поля оно вернётся на место.',
        [
          const AcademyFloatingInput(label: 'Пустое поле'),
          AcademyFloatingInput(
            label: 'Имя',
            controller: _name,
            textInputAction: TextInputAction.next,
          ),
          AcademyFloatingInput(
            label: 'Номер телефона',
            controller: _phone,
            help: 'Для входа в профиль',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _email,
            builder: (context, value, _) {
              final invalid =
                  value.text.isNotEmpty &&
                  !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.text);
              return AcademyFloatingInput(
                label: 'Почта',
                controller: _email,
                help: 'Для важных писем и входа в профиль',
                error: invalid ? 'Похоже, почта написана неверно' : null,
                keyboardType: TextInputType.emailAddress,
              );
            },
          ),
          AcademyFloatingInput(
            label: 'Подтверждённая почта',
            controller: _verified,
            help: 'Для важных писем и входа в профиль',
            readOnly: true,
            allowClear: false,
            suffix: Semantics(
              label: 'Почта подтверждена',
              child: AcademySfIcon(
                AcademySymbols.complete,
                size: 22,
                color: AcademyTheme.of(context).colorScheme
                    .toneForeground(AcademyTone.success),
              ),
            ),
          ),
          const AcademyFloatingInput(label: 'Недоступное поле', enabled: false),
        ].withGaps(),
      ),
    ],
  );
}

extension on List<Widget> {
  /// [AcademyFloatingInput] has no outer margin, unlike [AcademyField].
  List<Widget> withGaps() => [
    for (final (index, field) in indexed) ...[
      if (index > 0) const SizedBox(height: 12),
      field,
    ],
  ];
}
