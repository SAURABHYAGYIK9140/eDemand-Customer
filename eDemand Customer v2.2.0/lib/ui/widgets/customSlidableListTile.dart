import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomSlidableTileContainer extends StatelessWidget {

  const CustomSlidableTileContainer(
      {required this.imageURL, required this.title, required this.subTitle, required this.durationTitle, required this.dateSent, required this.showBorder, required this.tileBackgroundColor, final Key? key,
      this.onSlideTap,
      this.slidableChild,})
      : super(key: key);
  final VoidCallback? onSlideTap;
  final bool showBorder;
  final Color tileBackgroundColor;
  final String imageURL;
  final String title;
  final String subTitle;
  final String durationTitle;
  final Widget? slidableChild;
  final String dateSent;

  CustomContainer _buildNotificationContainer({required final BuildContext context}) => CustomContainer(
      height: 92,
      width: double.infinity,

        color: tileBackgroundColor,
        borderRadius: borderRadiusOf10,

      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            if (imageURL != '') ...[
              Align(
                alignment: AlignmentDirectional.topStart,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusOf50),
                  child: CustomCachedNetworkImage(
                    networkImageUrl: imageURL,
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const CustomSizedBox(
                width: 10,
              )
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(title.trim(),

                          color: Theme.of(context).colorScheme.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,),
                  const CustomSizedBox(height: 5),
                  CustomText(subTitle,

                      maxLines: 2,

                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 12,
                      textAlign: TextAlign.start,),
                  const CustomSizedBox(height: 5),
                  Expanded(
                    child: CustomText(dateSent.convertToAgo(context: context),

                        maxLines: 2,

                            color: Theme.of(context).colorScheme.lightGreyColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 10,
                        textAlign: TextAlign.start,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  @override
  Widget build(final BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomInkWellContainer(
        onTap: onSlideTap,
        child: CustomContainer(
          clipBehavior: Clip.antiAlias,

            border: showBorder ? Border.all(width: 0.5) : null,
            borderRadius: borderRadiusOf10,
            color: tileBackgroundColor,

          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  if (slidableChild != null) ...[
                    Positioned.fill(
                      child: Builder(
                          builder: (final BuildContext context) => Padding(
                                padding: EdgeInsets.zero,
                                child: CustomContainer(

                                      color: AppColors.redColor,
                                      borderRadius: borderRadiusOf10,
                                ),
                              ),),
                    ),
                  ],
                  if (slidableChild != null) ...[
                    Slidable(
                      key: UniqueKey(),
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        extentRatio: 0.24,
                        children: slidableChild != null ? [slidableChild!] : [],
                      ),
                      child: _buildNotificationContainer(context: context),
                    ),
                  ] else ...[
                    _buildNotificationContainer(context: context)
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
}
