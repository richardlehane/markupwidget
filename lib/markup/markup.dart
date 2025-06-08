import 'package:fluent_ui/fluent_ui.dart';
import 'app_state.dart';
import 'toolbar.dart';
import 'controller.dart';
import 'app_state_manager.dart';

class Markup extends StatelessWidget {
  const Markup({super.key});
  @override
  Widget build(BuildContext context) {
    return AppStateWidget(child: MarkupWidget());
  }
}

class MarkupWidget extends StatefulWidget {
  const MarkupWidget({super.key});

  @override
  State<MarkupWidget> createState() => _MarkupWidgetState();
}

class _MarkupWidgetState extends State<MarkupWidget> {
  late MarkupTextEditingController _markupTextEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _markupTextEditingController =
        AppStateManager.of(context).appState.markupTextEditingController;
    _focusNode = AppStateManager.of(context).appState.focusNode;
    _markupTextEditingController.addListener(() {
      _markupTextEditingController.parrot.text =
          '''Selection start: ${_markupTextEditingController.selection.start} End: ${_markupTextEditingController.selection.end}
          Collapsed: ${_markupTextEditingController.selection.isCollapsed}
          Text length: ${_markupTextEditingController.text.length}
          Markup length: ${_markupTextEditingController.markup.length}
          Markup: ${_markupTextEditingController.markup.toString()}''';
      if (_markupTextEditingController.update()) {
        AppStateWidget.of(
          context,
        ).updateAllButtonsStateOnSelectionChanged(_markupTextEditingController);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkupToolbar(),
        SizedBox(
          height: 200.0,
          child: TextBox(
            focusNode: _focusNode,
            maxLines: null,
            controller: _markupTextEditingController,
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        SizedBox(
          height: 200.0,
          child: TextBox(
            controller: _markupTextEditingController.parrot,
            readOnly: true,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
