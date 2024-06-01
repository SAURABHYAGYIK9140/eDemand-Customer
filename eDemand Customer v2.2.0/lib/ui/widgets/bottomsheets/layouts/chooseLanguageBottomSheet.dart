import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ChooseLanguageBottomSheet extends StatefulWidget {
  const ChooseLanguageBottomSheet({final Key? key}) : super(key: key);

  @override
  State<ChooseLanguageBottomSheet> createState() => _ChooseLanguageBottomSheetState();
}

class _ChooseLanguageBottomSheetState extends State<ChooseLanguageBottomSheet> {
//
  Column getLanguageTile({required final AppLanguage appLanguage}) => Column(
        children: [
          CustomInkWellContainer(
            onTap: () {
              context.read<LanguageCubit>().changeLanguage(
                    selectedLanguageCode: appLanguage.languageCode,
                    selectedLanguageName: appLanguage.languageName,
                  );
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  CustomSizedBox(
                    height: 25,
                    width: 25,
                    child: CustomSvgPicture(svgImage: appLanguage.imageURL, height: 25, width: 25),
                  ),
                  const CustomSizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      appLanguage.languageName,
                      color: Theme.of(context).colorScheme.blackColor,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
          ),
          const CustomDivider()
        ],
      );

  //
  @override
  Widget build(final BuildContext context) => BottomSheetLayout(
      title: 'selectLanguage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          appLanguages.length,
          (final int index) => getLanguageTile(appLanguage: appLanguages[index]),
        ),
      ));
}
