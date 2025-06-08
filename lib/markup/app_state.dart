import 'package:fluent_ui/fluent_ui.dart';
import 'controller.dart';
import 'app_state_manager.dart';

enum ToggleButtonsState {
  none,
  emphasis,
  source,
  link;

  ToggleButtonsState alter(ToggleButtonsState update) {
    if (update == this) {
      return none;
    }
    return update;
  }

  int toInt() {
    switch (this) {
      case none:
        return 0;
      case emphasis:
        return 1;
      case source:
        return 2;
      case link:
        return 3;
    }
  }
}

ToggleButtonsState fromInt(int value) {
  switch (value) {
    case 0:
      return ToggleButtonsState.none;
    case 1:
      return ToggleButtonsState.emphasis;
    case 2:
      return ToggleButtonsState.source;
    default:
      return ToggleButtonsState.link;
  }
}

class AppState {
  const AppState({
    required this.focusNode,
    required this.markupTextEditingController,
    this.toggleButtonsState = ToggleButtonsState.none,
    this.listButtonState = false,
  });

  final MarkupTextEditingController markupTextEditingController;
  final FocusNode focusNode;
  final ToggleButtonsState toggleButtonsState;
  final bool listButtonState;

  AppState copyWith({
    MarkupTextEditingController? markupTextEditingController,
    ToggleButtonsState? toggleButtonsState,
    bool? listButtonState,
  }) {
    return AppState(
      focusNode: focusNode,
      markupTextEditingController:
          markupTextEditingController ?? this.markupTextEditingController,
      toggleButtonsState: toggleButtonsState ?? this.toggleButtonsState,
      listButtonState: listButtonState ?? this.listButtonState,
    );
  }
}

class AppStateWidget extends StatefulWidget {
  const AppStateWidget({super.key, required this.child});

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>()!;
  }

  @override
  State<AppStateWidget> createState() => AppStateWidgetState();
}

class AppStateWidgetState extends State<AppStateWidget> {
  AppState _data = AppState(
    focusNode: FocusNode(),
    markupTextEditingController: MarkupTextEditingController(),
  );

  void updateToggleButtonsStateOnButtonPressed(ToggleButtonsState value) {
    final MarkupTextEditingController controller =
        _data.markupTextEditingController;
    ToggleButtonsState alter = _data.toggleButtonsState.alter(value);
    controller.updateSelection(alter);
    _data = _data.copyWith(
      markupTextEditingController: controller,
      toggleButtonsState: alter,
    );
    _data.focusNode.requestFocus();
    setState(() {});
  }

  void updateListButtonStateOnButtonPressed(bool value) {
    final MarkupTextEditingController controller =
        _data.markupTextEditingController;
    controller.updateList(value);
    _data = _data.copyWith(listButtonState: value);
    _data.focusNode.requestFocus();
    setState(() {});
  }

  void updateAllButtonsStateOnSelectionChanged(
    MarkupTextEditingController controller,
  ) {
    _data = _data.copyWith(
      toggleButtonsState: controller.toggleButtonsActive(),
      listButtonState: controller.listActive(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppStateManager(state: _data, child: widget.child);
  }
}
