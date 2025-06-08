import 'package:fluent_ui/fluent_ui.dart';
import 'markup/markup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      home: Contents(),
    );
  }
}

class Contents extends StatelessWidget {
  const Contents({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Markup()),
      ),
    );
  }
}
