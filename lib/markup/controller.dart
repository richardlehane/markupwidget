import 'package:fluent_ui/fluent_ui.dart';
import 'dart:typed_data';
import 'app_state.dart';

class MarkupTextEditingController extends TextEditingController {
  MarkupTextEditingController({super.text, Uint8List? markup})
    : markup = markup ?? [],
      parrot = TextEditingController();

  MarkupTextEditingController.fromValue(super.value, {Uint8List? markup})
    : markup = markup ?? [],
      parrot = TextEditingController(),
      super.fromValue();

  final TextEditingController parrot;
  final List<int> markup;
  bool listUpdateOperation =
      false; // flag that the update is related to a listUpdate
  bool listToggled = false;
  ToggleButtonsState buttonsState = ToggleButtonsState.none;

  // text has changed, update markup
  // return true if following this operation it is necessary to update the toggle buttons
  bool update() {
    if (listUpdateOperation) {
      listUpdateOperation = false;
      return false;
    }
    if (markup.length == text.length) {
      return true;
    } // likely just a move of selection
    // if we've toggled list and have just added a new line...
    if (text.length == markup.length + 1 &&
        selection.start > 0 &&
        listToggled &&
        text[selection.start - 1] == "\n") {
      listUpdateOperation = true;
      if (selection.start == text.length) {
        markup.addAll([0, 0, 0]);
        text += "\u2022 ";
      } else {
        markup.insertAll(selection.start, [0, 0, 0]);
        text =
            "${text.substring(0, selection.start)}\u2022 ${text.substring(selection.start + 1, text.length)}";
      }
      return false;
    }
    // we delete
    if (markup.length > text.length) {
      if (selection.start < text.length) {
        markup.removeRange(
          selection.start,
          selection.start + markup.length - text.length,
        );
      } else {
        while (markup.length > text.length) {
          markup.removeLast();
        }
      }
    }
    // we add
    if (selection.start < text.length) {
      markup.insertAll(
        selection.start,
        List<int>.filled(text.length - markup.length, buttonsState.toInt()),
      );
    } else {
      while (markup.length < text.length) {
        markup.add(buttonsState.toInt());
      }
    }
    return false;
  }

  ToggleButtonsState toggleButtonsActive() {
    if (selection.isCollapsed) {
      if (selection.start < 0) return buttonsState;
      return selection.start < text.characters.length
          ? fromInt(markup[selection.start])
          : buttonsState;
    }
    int thisStyle = markup[selection.start];
    for (int i = selection.start + 1; i < selection.end; i++) {
      if (thisStyle != markup[i]) return ToggleButtonsState.none;
    }
    return fromInt(thisStyle);
  }

  bool listActive() {
    for (int i = selection.start; i >= 0; i--) {
      if (i >= text.length) continue;
      if (text[i] == "\u2022") return true;
      if (text[i] == "\n") return false;
    }
    return false;
  }

  void updateSelection(ToggleButtonsState alter) {
    buttonsState = alter;
    int start = selection.start;
    int end = selection.end;
    if (alter == ToggleButtonsState.none &&
        selection.isCollapsed &&
        start < text.characters.length) {
      int old = markup[start];
      for (int i = start - 1; i >= 0; i--) {
        if (markup[i] != old) break;
        start--;
      }
      for (int i = end; i < text.characters.length; i++) {
        if (markup[i] != old) break;
        end++;
      }
    }
    for (; start < end; start++) {
      markup[start] = alter.toInt();
    }
  }

  void updateList(bool value) {
    listToggled = value;
    int off = selection.start;
    // adding a list
    if (value) {
      for (; off > 0; off--) {
        if (off >= text.length) continue;
        if (text[off] == "\n") {
          markup.insertAll(off, [0, 0]);
          listUpdateOperation = true;
          text =
              "${text.substring(0, off)}\n\u2022 ${text.substring(off + 1, text.length)}";
          return;
        }
      }
      listUpdateOperation = true;
      markup.insertAll(0, [0, 0]);
      text = "\u2022 $text";
      return;
    }
    // deleting
    for (; off >= 0; off--) {
      if (off >= text.length) continue;
      if (text[off] == "\u2022") {
        if (off + 1 < text.length && text[off + 1] == " ") {
          listUpdateOperation = true;
          markup.removeRange(off, off + 2);
          text = text.substring(0, off) + text.substring(off + 2, text.length);
        } else {
          listUpdateOperation = true;
          markup.removeAt(off);
          text = text.substring(0, off) + text.substring(off + 1, text.length);
        }
      }
    }
  }

  // iterate through the markup buffer and text, chunking text according to styles
  List<TextSpan> applyStyles() {
    List<TextSpan> ret = [];
    StringBuffer buf = StringBuffer();
    int style = 0;
    Iterator<int> it = markup.iterator;
    for (var char in text.characters) {
      if (it.moveNext()) {
        if (it.current == style) {
          buf.write(char);
        } else {
          if (buf.length > 0) {
            ret.add(toSpan(style, buf.toString()));
            buf.clear();
          }
          style = it.current;
          buf.write(char);
        }
      } else {
        // shouldn't be here
        buf.write(char);
      }
    }
    ret.add(toSpan(style, buf.toString()));
    return ret;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(
      !value.composing.isValid || !withComposing || value.isComposingRangeValid,
    );

    return TextSpan(
      style: TextStyle(color: Colors.black),
      children: applyStyles(),
    );
  }
}

// Create textspans with style
TextSpan toSpan(int style, String text) {
  switch (style) {
    case 0:
      return TextSpan(text: text);
    case 1:
      return TextSpan(
        style: TextStyle(fontWeight: FontWeight.bold),
        text: text,
      );
    case 2:
      return TextSpan(
        style: TextStyle(fontStyle: FontStyle.italic),
        text: text,
      );
    default:
      return TextSpan(
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
        text: text,
      );
  }
}
