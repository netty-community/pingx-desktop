import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'ui/screens/home_screen.dart';
import 'package:macos_ui/macos_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure window settings
  await windowManager.ensureInitialized();
  await windowManager.setTitle('PingX');
  await windowManager.setMinimumSize(const Size(1600, 900));
  await windowManager.setSize(const Size(1600, 900));
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  runApp(const ProviderScope(child: PingXApp()));
}

class PingXApp extends StatelessWidget {
  const PingXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'PingX',
      theme: MacosThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: MacosColors.white,
        canvasColor: MacosColors.white,
      ),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
