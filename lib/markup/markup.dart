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
  MarkupTextEditingController? _currentController;
  FocusNode? _currentFocusNode;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController =
        AppStateManager.of(context).appState.markupTextEditingController;
    final newFocusNode = AppStateManager.of(context).appState.focusNode;

    // Only update if controller actually changed
    if (_currentController != newController) {
      // Remove listener from old controller
      if (_controllerListener != null && _currentController != null) {
        _currentController!.removeListener(_controllerListener!);
      }

      _currentController = newController;
      _currentFocusNode = newFocusNode;

      // Create and add new listener
      _controllerListener = () {
        if (_currentController!.update()) {
          AppStateWidget.of(
            context,
          ).updateAllButtonsStateOnSelectionChanged(_currentController!);
        }
        _currentController!.parrot.text =
            '''Selection start: ${_currentController!.selection.start} End: ${_currentController!.selection.end}
            Collapsed: ${_currentController!.selection.isCollapsed}
            Text length: ${_currentController!.text.length}
            Markup length: ${_currentController!.markup.length}
            Markup: ${_currentController!.markup.toString()}
            XML: ${_currentController!.toXML().toString()}''';
      };
      _currentController!.addListener(_controllerListener!);
    }
  }

  @override
  void dispose() {
    if (_controllerListener != null && _currentController != null) {
      _currentController!.removeListener(_controllerListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkupToolbar(),
        SizedBox(
          height: 200.0,
          child: TextBox(
            focusNode: _currentFocusNode,
            maxLines: null,
            controller: _currentController,
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        SizedBox(
          height: 200.0,
          child: TextBox(
            controller: _currentController?.parrot,
            readOnly: true,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
