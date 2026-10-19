import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/store.dart';
import 'screens/title_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MobileTycoonApp());
}

class MobileTycoonApp extends StatelessWidget {
  const MobileTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStore()..load(),
      child: MaterialApp(
        title: 'Mobile Tycoon',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFF2979FF),
            surface: Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161616),
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1E1E),
          ),
          useMaterial3: true,
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    if (!store.loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }
    if (store.hasGame && !(store.state!.gameOver)) {
      return const GameScreen();
    }
    return const TitleScreen();
  }
}
