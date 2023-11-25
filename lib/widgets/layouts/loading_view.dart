import 'package:flutter/material.dart';

// import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/utils/update_checker_no_store.dart';
import 'package:concieltalk/widgets/layouts/empty_page.dart';
// import 'package:concieltalk/widgets/matrix.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await UpdateCheckerNoStore(context).checkUpdate();
        VRouter.of(context).to(
          '/biometrics',
          queryParameters: VRouter.of(context).queryParameters,
        );
      },
    );
    return const EmptyPage(loading: true);
  }
}
