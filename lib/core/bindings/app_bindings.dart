import 'package:get/get.dart';
import 'package:smartone/presentation/pages/login/login_controller.dart';
import 'package:smartone/presentation/pages/register/register_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => RegisterController(), fenix: true);
  }
}
