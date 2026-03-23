import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PegasusApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);

class PegasusApp extends StatelessWidget {
  const PegasusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pegasus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      routerConfig: _router,
    );
  }
}
