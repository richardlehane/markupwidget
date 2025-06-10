import 'package:fluent_ui/fluent_ui.dart';
import 'toolbar.dart';
import 'controller.dart';
import 'togglebutton.dart';

class Markup extends StatefulWidget {
  const Markup({super.key});

  @override
  State<Markup> createState() => _MarkupState();
}

class _MarkupState extends State<Markup> {
  final FocusNode _focusNode = FocusNode();
  final MarkupTextEditingController _markupTextEditingController =
      MarkupTextEditingController();
  ToggleButtonsState _toggleButtonsState = ToggleButtonsState.none;
  bool _listButtonState = false;

  void _updateToggleButtonsStateOnButtonPressed(
    ToggleButtonsState value, {
    String? url,
  }) {
    setState(() {
      ToggleButtonsState newState = _toggleButtonsState.alter(value);
      _markupTextEditingController.updateSelection(newState, url: url);
      _toggleButtonsState = newState;
      _focusNode.requestFocus();
    });
  }

  void _updateListButtonStateOnButtonPressed(bool value) {
    setState(() {
      _markupTextEditingController.updateList(value);
      _listButtonState = value;
      _focusNode.requestFocus();
    });
  }

  void _updateAllButtonsStateOnSelectionChanged() {
    setState(() {
      if (_markupTextEditingController.update()) {
        setState(() {
          _toggleButtonsState =
              _markupTextEditingController.toggleButtonsActive();
          _listButtonState = _markupTextEditingController.listActive();
        });
      } else {
        _markupTextEditingController.parrot.text =
            '''Selection start: ${_markupTextEditingController.selection.start} End: ${_markupTextEditingController.selection.end}
            Collapsed: ${_markupTextEditingController.selection.isCollapsed}
            Text length: ${_markupTextEditingController.text.length}
            Markup length: ${_markupTextEditingController.markup.length}
            Markup: ${_markupTextEditingController.markup.toString()}
            XML: ${_markupTextEditingController.toXML().toString()}''';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _markupTextEditingController.removeListener(
      _updateAllButtonsStateOnSelectionChanged,
    ); // not sure if needed
    _markupTextEditingController.addListener(
      _updateAllButtonsStateOnSelectionChanged,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _markupTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkupToolbar(
          toggleButtonsState: _toggleButtonsState,
          listButtonState: _listButtonState,
          updateToggleButtonsStateOnButtonPressed:
              _updateToggleButtonsStateOnButtonPressed,
          updateListButtonStateOnButtonPressed:
              _updateListButtonStateOnButtonPressed,
        ),
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
