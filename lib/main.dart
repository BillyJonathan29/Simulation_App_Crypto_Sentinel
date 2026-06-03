import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'providers/app_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // setPreferredOrientations tidak support di Web, langsung runApp
    runApp(
      ChangeNotifierProvider(
        create: (context) => AppStateProvider(),
        child: const MyApp(),
      ),
    );
  } else {
    // Lock app orientation to Portrait (mobile only)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).then((_) {
      runApp(
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(),
          child: const MyApp(),
        ),
      );
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto-Sentinel Mobile Banking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}

