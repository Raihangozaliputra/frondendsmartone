import 'package:get/get.dart';
import 'package:smartone/presentation/pages/login/login_page.dart';
import 'package:smartone/presentation/pages/register/register_page.dart';

class AppPages {
  static const String initial = '/login';

  static final List<GetPage> routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
