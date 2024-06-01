import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';


class AboutProviderContainer extends StatelessWidget {
  final Providers providerDetails;

  AboutProviderContainer({super.key, required this.providerDetails});

  Widget CustomContainerWithTitle({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return CustomContainer(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,

        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,

              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.blackColor,

          ),
          const CustomSizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }

  Widget ProviderDescriptionSection({required BuildContext context}) {
    return CustomContainerWithTitle(
      context: context,
      title: "companyInformation".translate(context: context),
      child: HtmlWidget(providerDetails.longDescription ?? ""),
    );
  }

  Widget ContactUsSection({
    required BuildContext context,
  }) {
    return CustomContainerWithTitle(
      context: context,
      title: "contactUs".translate(context: context),
      child: CustomInkWellContainer(
        onTap: () async {
          try {
            await launchUrl(
              Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=${providerDetails.latitude},${providerDetails.longitude}',
              ),
              mode: LaunchMode.externalApplication,
            );
          } catch (e) {
            UiUtils.showMessage(context, e.toString(), MessageType.warning);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadiusOf10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.parse(providerDetails.latitude ?? "0.0"),
                      double.parse(providerDetails.longitude ?? "0.0"),
                    ),
                    zoom: 12,
                  ),
                  zoomControlsEnabled: false,
                  liteModeEnabled: Platform.isAndroid,
                  scrollGesturesEnabled: true,
                  markers: Set<Marker>.of([
                    Marker(
                      markerId: MarkerId(
                        providerDetails.id.toString(),
                      ),
                      position: LatLng(
                        double.parse(providerDetails.latitude ?? "0.0"),
                        double.parse(providerDetails.longitude ?? "0.0"),
                      ),
                    )
                  ]),
                ),
              ),
            ),
            const CustomSizedBox(height: 5),
            CustomText(
              providerDetails.companyName ?? "",

                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                height: 2,

              maxLines: 1,
            ),
            Row(
              children: [
                CustomSvgPicture(
                  svgImage: "current_location",
                  height: 20,
                  width: 20,
                  color: Theme.of(context).colorScheme.accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: CustomText(
                      providerDetails.address ?? "",

                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12,

                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 10,
        right: 15,
        left: 15,
        bottom: context.read<CartCubit>().getProviderIDFromCartData() == '0'
            ? 0
            : bottomNavigationBarHeight + 10,
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainerWithTitle(
                context: context,
                title: "aboutThisProvider".translate(context: context),
                child: ReadMoreText(
                  providerDetails.about!,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "showMore".translate(context: context),
                  trimExpandedText: "showLess".translate(context: context),
                  lessStyle: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  moreStyle: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              CustomContainerWithTitle(
                context: context,
                title: "businessHours".translate(context: context),
                child: Column(
                  children: List.generate(providerDetails.businessDayInfo!.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: CustomText(
                            providerDetails.businessDayInfo![index].day
                                .toString()
                                .translate(context: context),
                          ),
                        ),
                        //const Spacer(),
                        Expanded(
                          flex: 6,
                          child: providerDetails.businessDayInfo![index].isOpen == "1"
                              ? CustomText(
                                  "${providerDetails.businessDayInfo![index].openingTime.toString().formatTime()}  -  ${providerDetails.businessDayInfo![index].closingTime.toString().formatTime()}",

                                  maxLines: 1,
                                )
                              : Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: CustomText(
                                    "closed".translate(context: context),

                                      height: 1.5,
                                      color: Theme.of(context).colorScheme.lightGreyColor,

                                    maxLines: 1,
                                  ),
                                ),
                        )
                      ],
                    );
                  }),
                ),
              ),
              if (providerDetails.otherImagesOfTheService!.isNotEmpty) ...[
                CustomContainerWithTitle(
                  context: context,
                  title: "photos".translate(context: context),
                  child: GalleryImagesStyles(imagesList: providerDetails.otherImagesOfTheService!),
                ),
              ],
              if (providerDetails.longDescription!.isNotEmpty) ...[
                ProviderDescriptionSection(context: context),
              ],
              if (providerDetails.address!.isNotEmpty &&
                  context.read<SystemSettingCubit>().showProviderAddressDetails()) ...[
                ContactUsSection(context: context)
              ]
            ],
          ),
        ],
      ),
    );
  }
}
