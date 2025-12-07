import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartone/core/bindings/app_bindings.dart';
import 'package:smartone/core/themes/app_theme.dart';
import 'package:smartone/routes/app_pages.dart';

void main() async {
  // Initialize GetX storage
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart One',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
      defaultTransition: Transition.fade,
    );
  }
}
