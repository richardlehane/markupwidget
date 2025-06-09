# Claude instructions

## Introduction

This project is a to build a self-contained rich-text editing widget (markup widget) for use in another project called Authority Editor.

Authority Editor is a GUI application written in Flutter for editing XML documents compliant with an XML schema for retention and disposal authorities (which are policy documents defining the retention periods for government records). That XML schema has a series of elements (e.g. ClassDescription and TermDescription elements) that contain mixed content in the form of paragraphs.

E.g.
<ClassDescription>
<Paragraph>Hello Claude this is a paragraph. It may contain additional elements such as <Emphasis>emphasis tags</Emphasis> which are bolded in transformed documents and used to emphasise sections of text.</Paragraph>
<Paragraph>Text can also have source elements which indicate references to sources e.g. <Source>Archives Act 1983</Source>. These elements are rendered with italics in transformed documents.</Paragraph>
<Paragraph>Links are also possible, e.g. <Link url="https://www.anthropic.com">Antropic website</Link> which renders with underlined blue text.</Paragraph>
<Paragraph>Finally, it is possible to include lists of the form:
<List>
    <Item>item one</Item>
    <Item>item two, with <Emphasis>emphasis</Emphasis></Item>
</List>
</Paragraph>
<Paragraph>Note that, while items in lists can contain emphasis, source and link elements, those elements themselves can only contain text (i.e. no overlapping emphasis, source and link elements).</Paragraph>
</ClassDescription>

As this is a complicated component to build, I have made a standalone repository to work on it. 

## Functionality

The markup widget will have the following functionality:

- Text editing (using the TextBox from the FluentUI Flutter library)
- Toolbar for applying Emphasis, Source, Link and List/Item styling [partially implemented]
- Flyover text input fields for editing URLs when Link items created or selected [not yet implemented]
- Custom TextEditingController with an overridden build method that applies the styling [partially implemented]
- Import of styled text from a list of Pargraph XML elements [not yet implemented]
- Export to a list of Paragraph XML elements when focus leaves the widget via a callback function [not yet implemented]

## Design

These features are important to the design:

- Self-contained state: the widget should manage its own state 
- Simple: the design should be as simple as possible to achieve the goal
- Robust: the widget should not leak memory
- Performant: several widgets may be used in screens on the host application so the widget should be as performant as possible.