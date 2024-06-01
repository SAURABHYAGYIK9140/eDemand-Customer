// ignore_for_file: non_constant_identifier_names

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

Widget MessageContainer({
  required final BuildContext context,
  required final String text,
  required final MessageType type,
}) => Material(
    child: ToastAnimation(
      delay: messageDisplayDuration,
      child: CustomContainer(
        constraints:  BoxConstraints(
            minHeight: 50,
            maxHeight: 60,
            maxWidth: MediaQuery.sizeOf(context).width,
            minWidth: MediaQuery.sizeOf(context).width,),
        clipBehavior: Clip.hardEdge,

//
// using gradient to apply one side dark color in container
            gradient: LinearGradient(stops: const [
              0.02,
              0.02
            ], colors: [
              messageColors[type]!,
              messageColors[type]!.withOpacity(0.1),
            ],),
            borderRadius: borderRadiusOf10,
            border: Border.all(
              color: messageColors[type]!.withOpacity(0.5),
            ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 10,
              child: CustomContainer(
                height: 25,
                width: 25,

                  shape: BoxShape.circle,
                  color: messageColors[type],

                child: Icon(
                  messageIcon[type],
                  color: Theme.of(context).colorScheme.secondaryColor,
                  size: 20,
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 40,
              child: CustomSizedBox(
                width: MediaQuery.sizeOf(context).width - 90,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomText(text.translate(context: context),

                      maxLines: 5,

                          color: messageColors[type],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
