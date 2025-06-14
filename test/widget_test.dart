import 'package:flutter_test/flutter_test.dart';
import 'package:markupwidget/markup/controller.dart';
import 'package:xml/xml.dart';

void _roundTrip(String testXml) {
  final document = XmlDocument.parse(testXml);
  final testController = MarkupTextEditingController.fromXML(
    document.rootElement.childElements.toList(),
  );
  final testElements = testController.toXML();
  expect(
    testElements.toString(),
    document.rootElement.childElements.toList().toString(),
  );
}

void main() {
  test('XML simple', () {
    _roundTrip("<root><Paragraph>Test</Paragraph></root>");
  });
  test('XML two paras', () {
    _roundTrip(
      "<root><Paragraph>Test</Paragraph><Paragraph>Second paragraph</Paragraph></root>",
    );
  });
  test('XML emphasis', () {
    _roundTrip(
      "<root><Paragraph>Test has <Emphasis>hello</Emphasis></Paragraph><Paragraph>Second paragraph</Paragraph></root>",
    );
  });
  test('XML source', () {
    _roundTrip(
      "<root><Paragraph>Test has <Emphasis>hello</Emphasis></Paragraph><Paragraph>Second <Source>paragraph</Source></Paragraph></root>",
    );
  });
  test('XML link', () {
    _roundTrip(
      "<root><Paragraph>Test has <Emphasis>hello</Emphasis></Paragraph><Paragraph>Second <Source url=\"test\">paragraph</Source></Paragraph></root>",
    );
  });
  test('XML list', () {
    _roundTrip(
      "<root><Paragraph>Test</Paragraph><Paragraph>Second paragraph: <List><Item>one</Item><Item>two</Item></List></Paragraph></root>",
    );
  });
  test('XML list harder', () {
    _roundTrip(
      "<root><Paragraph>Test</Paragraph><Paragraph>Second paragraph: <List><Item>one</Item><Item>two <Emphasis>hello</Emphasis></Item></List></Paragraph><Paragraph>Another</Paragraph></root>",
    );
  });
  test('XML list raw', () {
    _roundTrip(
      "<root><Paragraph><List><Item>one</Item><Item>two <Emphasis>hello</Emphasis></Item></List></Paragraph><Paragraph>Another</Paragraph></root>",
    );
  });
}
