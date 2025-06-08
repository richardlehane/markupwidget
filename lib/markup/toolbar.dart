import 'package:fluent_ui/fluent_ui.dart';
import 'app_state.dart';
import 'app_state_manager.dart';

class MarkupToolbar extends StatelessWidget {
  const MarkupToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStateManager manager = AppStateManager.of(context);
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
          child: ToggleButton(
            checked:
                manager.appState.toggleButtonsState ==
                ToggleButtonsState.emphasis,
            onChanged: (v) {
              AppStateWidget.of(
                context,
              ).updateToggleButtonsStateOnButtonPressed(
                ToggleButtonsState.emphasis,
              );
            },
            child: SizedBox(
              width: 75.0,
              child: Row(
                children: [
                  const Icon(FluentIcons.bold, size: 12.0),
                  Expanded(child: const Text("Emphasis")),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
          child: ToggleButton(
            checked:
                manager.appState.toggleButtonsState ==
                ToggleButtonsState.source,
            onChanged: (v) {
              AppStateWidget.of(
                context,
              ).updateToggleButtonsStateOnButtonPressed(
                ToggleButtonsState.source,
              );
            },
            child: SizedBox(
              width: 75.0,
              child: Row(
                children: [
                  const Icon(FluentIcons.italic, size: 12.0),
                  Expanded(child: const Text("Source")),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
          child: ToggleButton(
            checked:
                manager.appState.toggleButtonsState == ToggleButtonsState.link,
            onChanged: (v) {
              AppStateWidget.of(
                context,
              ).updateToggleButtonsStateOnButtonPressed(
                ToggleButtonsState.link,
              );
            },
            child: SizedBox(
              width: 75.0,
              child: Row(
                children: [
                  const Icon(FluentIcons.link, size: 12.0),
                  Expanded(child: const Text("Link")),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 5.0),
          child: ToggleButton(
            checked: manager.appState.listButtonState,
            onChanged: (v) {
              AppStateWidget.of(
                context,
              ).updateListButtonStateOnButtonPressed(v);
            },
            child: SizedBox(
              width: 75.0,
              child: Row(
                children: [
                  const Icon(FluentIcons.bulleted_list, size: 12.0),
                  Expanded(child: const Text("List")),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
