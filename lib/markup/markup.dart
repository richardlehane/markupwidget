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
      toggleButtonsState = toggleButtonsState.alter(value);
      markupTextEditingController.updateSelection(toggleButtonsState, url: url);
      focusNode.requestFocus();
    });
  }

  void updateListButtonStateOnButtonPressed(bool value) {
    setState(() {
      listButtonState = value;
      markupTextEditingController.updateList(listButtonState);
      focusNode.requestFocus();
    });
  }

  void updateAllButtonsStateOnSelectionChanged() {
    if (markupTextEditingController.update()) {
      setState(() {
        toggleButtonsState = markupTextEditingController.buttonsState;
        listButtonState = markupTextEditingController.listToggled;
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
