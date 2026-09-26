import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});
  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AcademyModalSearch(
    controller: _controller,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AcademySearchBar(
            controller: _controller,
            onCancel: () {
              _controller.clear();
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => AcademyModalListView(
              children: [
                for (var i = 1; i <= 30; i++)
                  if ('Компонент $i'.toLowerCase().contains(
                    value.text.toLowerCase(),
                  ))
                    AcademyRow(
                      title: 'Компонент $i',
                      onPressed: () => closeAcademyModal(context, i),
                    ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
