import 'package:go_router/go_router.dart';

            ElevatedButton(
              onPressed = () {
                GoRouter.of(context).pop();
              },
              child = const Text('Quay lại danh sách sản phẩm'),
            ), 