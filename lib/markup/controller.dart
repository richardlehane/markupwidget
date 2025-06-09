import 'package:fluent_ui/fluent_ui.dart';
import 'package:xml/xml.dart';
import 'app_state.dart';

const bullet = "\u2022";

class MarkupTextEditingController extends TextEditingController {
  MarkupTextEditingController({
    super.text,
    List<int>? markup,
    List<String>? urls,
  }) : markup = markup ?? [],
       urls = urls ?? [],
       parrot = TextEditingController();

  MarkupTextEditingController.fromValue(
    super.value, {
    List<int>? markup,
    List<String>? urls,
  }) : markup = markup ?? [],
       urls = urls ?? [],
       parrot = TextEditingController(),
       super.fromValue();

  final TextEditingController parrot;
  final List<int> markup;
  final List<String> urls;
  bool listUpdateOperation =
      false; // flag that the update is related to a listUpdate
  bool listToggled = false;
  ToggleButtonsState buttonsState = ToggleButtonsState.none;

  // Ensure markup and text stay synchronized
  // Return true if button states need updating
  bool update() {
    if (listUpdateOperation) {
      listUpdateOperation = false;
      return false;
    }

    // Just a selection change, no text modification
    if (markup.length == text.length) {
      return true;
    }

    // Handle list auto-formatting
    if (_shouldAddListBullet()) {
      _addListBullet();
      return false;
    }

    // Synchronize markup length with text length
    _syncMarkupLength();
    return false;
  }

  // if list button is active and we've just added a single newline character, add a list.
  bool _shouldAddListBullet() {
    return text.length == markup.length + 1 &&
        selection.start > 0 &&
        listToggled &&
        text[selection.start - 1] == "\n";
  }

  void _addListBullet() {
    listUpdateOperation = true;
    if (selection.start == text.length) {
      markup.addAll([0, 0, 0]);
      text += "$bullet ";
    } else {
      markup.insertAll(selection.start, [0, 0, 0]);
      text =
          "${text.substring(0, selection.start)}$bullet ${text.substring(selection.start + 1)}";
    }
  }

  void _syncMarkupLength() {
    int textLength = text.length;
    int markupLength = markup.length;
    int cursor =
        (selection.start < 0)
            ? textLength
            : selection.start; // selection.start may be -1 if no selection
    // Text was deleted - delete markup
    if (markupLength > textLength) {
      markup.removeRange(cursor, cursor + markupLength - textLength);
    } else if (markupLength < textLength) {
      // Text was added - add markup
      int addCount = textLength - markupLength;
      int currentStyle = buttonsState.toInt();
      if (cursor < markupLength) {
        markup.insertAll(cursor, List.filled(addCount, currentStyle));
      } else {
        markup.addAll(List.filled(addCount, currentStyle));
      }
    }
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
      if (text[i] == bullet) return true;
      if (text[i] == "\n") return false;
    }
    return false;
  }

  void updateSelection(ToggleButtonsState alter, {String? url}) {
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

    int markupValue = alter.toInt();
    if (alter == ToggleButtonsState.link && url != null) {
      int urlIndex = urls.indexOf(url);
      if (urlIndex == -1) {
        urls.add(url);
        urlIndex = urls.length - 1;
      }
      markupValue = urlIndex + 3; // URLs start at index 3
    }

    for (; start < end; start++) {
      markup[start] = markupValue;
    }
  }

  String? getUrlForSelection() {
    if (selection.isCollapsed && selection.start < markup.length) {
      int markupValue = markup[selection.start];
      if (markupValue >= 3) {
        int urlIndex = markupValue - 3;
        return urlIndex < urls.length ? urls[urlIndex] : null;
      }
    } else if (!selection.isCollapsed) {
      int markupValue = markup[selection.start];
      if (markupValue >= 3) {
        for (int i = selection.start; i < selection.end; i++) {
          if (markup[i] != markupValue) return null; // Mixed selection
        }
        int urlIndex = markupValue - 3;
        return urlIndex < urls.length ? urls[urlIndex] : null;
      }
    }
    return null;
  }

  void updateLinkUrl(String newUrl) {
    if (selection.isCollapsed && selection.start < markup.length) {
      int markupValue = markup[selection.start];
      if (markupValue >= 3) {
        int urlIndex = markupValue - 3;
        if (urlIndex < urls.length) {
          urls[urlIndex] = newUrl;
        }
      }
    }
  }

  void updateList(bool value) {
    listToggled = value;
    int off = selection.end;
    int start = (selection.start == off) ? 0 : selection.start;
    String edited = text;
    // adding a list
    if (value) {
      for (; off >= start; off--) {
        if (off >= text.length) continue;
        if (text[off] == "\n" || off == 0) {
          markup.insertAll(off, [0, 0]);
          edited =
              (off == 0)
                  ? "$bullet $edited"
                  : "${edited.substring(0, off)}\n$bullet ${edited.substring(off + 1, edited.length)}";
          if (selection.isCollapsed) return;
        }
      }
      if (edited != text) {
        listUpdateOperation = true;
        text = edited;
      }
      return;
    }
    // deleting
    for (; off >= start; off--) {
      if (off >= edited.length) continue;
      if (edited[off] == "\n" && selection.isCollapsed) break;
      if (edited[off] == bullet) {
        if (off + 1 < edited.length && edited[off + 1] == " ") {
          markup.removeRange(off, off + 2);
          edited =
              edited.substring(0, off) +
              edited.substring(off + 2, edited.length);
        } else {
          markup.removeAt(off);
          edited =
              edited.substring(0, off) +
              edited.substring(off + 1, edited.length);
        }
      }
    }
    if (edited != text) {
      listUpdateOperation = true;
      text = edited;
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

  List<XmlElement> toXML() {
    List<XmlElement> ret = [];
    StringBuffer buf = StringBuffer();
    XmlElement thisPara = XmlElement(XmlName("Paragraph"));
    XmlElement thisList = XmlElement(XmlName("List"));
    XmlElement thisItem = XmlElement(XmlName("Item"));
    bool inList = false;
    int style = 0;
    Iterator<int> it = markup.iterator;
    CharacterRange cr = text.characters.iterator;

    while (cr.moveNext()) {
      it.moveNext();
      if (cr.current == "\n") {
        cr.moveNext();
        // Add a list item if needed
        if (cr.current == bullet) {
          it.moveNext();
          if (inList) {
            thisItem.children.add(
              toNode(style, buf.toString()),
            ); // commit the previous list item
            thisList.children.add(thisItem); // does this need to use copy??
            thisItem = XmlElement(XmlName("Item")); // make a new item
          } else {
            inList = true;
            cr.moveNext(); // skip the following space
            if (cr.current == " ") {
              it.moveNext;
            } else {
              cr.moveBack();
            }
            continue;
          }
        }
        cr.moveBack(); // not a bullet!
        if (inList) {
          inList = false;
          // commit the list
          thisItem.children.add(toNode(style, buf.toString()));
          buf.clear(); // commit the previous list item
          thisList.children.add(thisItem); // does this need to use copy??
          thisItem = XmlElement(XmlName("Item"));
          thisPara.children.add(thisList);
          thisList = XmlElement(XmlName("List"));
          ret.add(thisPara.copy());
          thisPara = XmlElement(XmlName("Paragraph"));
        } else {
          // not a list, commit the para
          thisPara.children.add(toNode(style, buf.toString()));
          buf.clear();
          ret.add(thisPara);
          thisPara = XmlElement(XmlName("Paragraph"));
        }
        continue;
      }
      if (it.current == style) {
        buf.write(cr.current);
      } else {
        if (buf.length > 0) {
          if (inList) {
            thisItem.children.add(toNode(style, buf.toString()));
          } else {
            thisPara.children.add(toNode(style, buf.toString()));
          }
          buf.clear();
        }
        style = it.current;
        buf.write(cr.current);
      }
    }
    if (inList) {
      // commit the list
      thisItem.children.add(
        toNode(style, buf.toString()),
      ); // commit the previous list item
      thisList.children.add(thisItem); // does this need to use copy??
      thisPara.children.add(thisList);
      ret.add(thisPara);
    } else {
      // not a list, commit the para
      thisPara.children.add(toNode(style, buf.toString()));
      ret.add(thisPara);
    }
    return ret;
  }

  XmlNode toNode(int style, String text) {
    switch (style) {
      case 0:
        return XmlText(text);
      case 1:
        return toElement("Emphasis", text);
      case 2:
        return toElement("Source", text);
      default:
        int index = style - 3;
        if (index > urls.length - 1) {
          return toElement("Source", text, "url", urls[index]);
        } else {
          return toElement("Source", text);
        }
    }
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

XmlElement toElement(
  String name,
  String value, [
  String? attrName,
  String? attrVal,
]) {
  List<XmlAttribute> attrs =
      (attrName == null) ? [] : [XmlAttribute(XmlName(attrName), attrVal!)];
  return XmlElement(XmlName(name), attrs, [XmlText(value)], false);
}
