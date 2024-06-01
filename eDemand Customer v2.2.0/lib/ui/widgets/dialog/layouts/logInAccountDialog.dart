import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class LogInAccountDialog extends StatelessWidget {
  const LogInAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialogLayout(
      icon: CustomContainer(
          height: 70,
          width: 70,

              color: Theme.of(context).colorScheme.secondaryColor,
              borderRadius: borderRadiusOf50,
          child:
          Icon(Icons.info, color: Theme.of(context).colorScheme.accentColor, size: 70)),
      title: "loginRequired",
      description: "pleaseLogin",
      //
      cancelButtonName: "notNow",
      cancelButtonBackgroundColor: Theme.of(context).colorScheme.secondaryColor,
      cancelButtonPressed: () {
        Navigator.of(context).pop();
      },
      //
      confirmButtonName: "logIn",
      confirmButtonBackgroundColor: Theme.of(context).colorScheme.accentColor,
      confirmButtonPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, loginRoute, arguments: {'source': 'dialog'});
      },
    );
  }
}
