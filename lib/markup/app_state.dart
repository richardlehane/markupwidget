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

  final FocusNode focusNode;
  final MarkupTextEditingController markupTextEditingController;
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
  late final FocusNode _focusNode;
  late final MarkupTextEditingController _controller;
  ToggleButtonsState _toggleButtonsState = ToggleButtonsState.none;
  bool _listButtonState = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = MarkupTextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  AppState get _appState => AppState(
    focusNode: _focusNode,
    markupTextEditingController: _controller,
    toggleButtonsState: _toggleButtonsState,
    listButtonState: _listButtonState,
  );

  void updateToggleButtonsStateOnButtonPressed(
    ToggleButtonsState value, {
    String? url,
  }) {
    ToggleButtonsState newState = _toggleButtonsState.alter(value);
    _controller.updateSelection(newState, url: url);
    _toggleButtonsState = newState;
    _focusNode.requestFocus();
    setState(() {});
  }

  void updateListButtonStateOnButtonPressed(bool value) {
    _controller.updateList(value);
    _listButtonState = value;
    _focusNode.requestFocus();
    setState(() {});
  }

  void updateAllButtonsStateOnSelectionChanged(
    MarkupTextEditingController controller,
  ) {
    _toggleButtonsState = controller.toggleButtonsActive();
    _listButtonState = controller.listActive();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppStateManager(state: _appState, child: widget.child);
  }
}
