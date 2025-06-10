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
  final FocusNode focusNode = FocusNode();
  final MarkupTextEditingController markupTextEditingController =
      MarkupTextEditingController();
  ToggleButtonsState toggleButtonsState = ToggleButtonsState.none;
  bool listButtonState = false;

  void updateToggleButtonsStateOnButtonPressed(
    ToggleButtonsState value, {
    String? url,
  }) {
    setState(() {
      ToggleButtonsState newState = toggleButtonsState.alter(value);
      markupTextEditingController.updateSelection(newState, url: url);
      toggleButtonsState = newState;
      focusNode.requestFocus();
    });
  }

  void updateListButtonStateOnButtonPressed(bool value) {
    setState(() {
      markupTextEditingController.updateList(value);
      listButtonState = value;
      focusNode.requestFocus();
    });
  }

  void updateAllButtonsStateOnSelectionChanged() {
    if (markupTextEditingController.update()) {
      setState(() {
        toggleButtonsState = markupTextEditingController.buttonsState;
        listButtonState = markupTextEditingController.listToggled;
      });
    } else {
      markupTextEditingController.parrot.text = '''
            Selection start: ${markupTextEditingController.selection.start} End: ${markupTextEditingController.selection.end}
            Collapsed: ${markupTextEditingController.selection.isCollapsed}
            Text length: ${markupTextEditingController.text.length}
            Markup length: ${markupTextEditingController.markup.length}
            Markup: ${markupTextEditingController.markup.toString()}
            Links: ${markupTextEditingController.urls.toString()}
            XML: ${markupTextEditingController.toXML().toString()}''';
    }
  }

  @override
  void initState() {
    super.initState();
    markupTextEditingController.removeListener(
      updateAllButtonsStateOnSelectionChanged,
    ); // not sure if needed
    markupTextEditingController.addListener(
      updateAllButtonsStateOnSelectionChanged,
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    markupTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkupToolbar(
          toggleButtonsState: toggleButtonsState,
          listButtonState: listButtonState,
          updateToggleButtonsStateOnButtonPressed:
              updateToggleButtonsStateOnButtonPressed,
          updateListButtonStateOnButtonPressed:
              updateListButtonStateOnButtonPressed,
        ),
        SizedBox(
          height: 200.0,
          child: TextBox(
            focusNode: focusNode,
            maxLines: null,
            controller: markupTextEditingController,
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        SizedBox(
          height: 200.0,
          child: TextBox(
            controller: markupTextEditingController.parrot,
            readOnly: true,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
