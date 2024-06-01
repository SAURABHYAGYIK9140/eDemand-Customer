import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingCardContainer extends StatelessWidget {
  final Booking bookingDetails;
  DateTime? selectedDate;
  dynamic selectedTime;
  String? message;

  BookingCardContainer({
    super.key,
    required this.bookingDetails,
  });

  //
  Widget _buildDateAndTimeContainer(
          {required final BuildContext context, required final String time}) =>
      CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 5),
        color: Theme.of(context).colorScheme.primaryColor,
        borderRadius: borderRadiusOf10,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: CustomSizedBox(
                height: 35,
                width: 35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusOf50),
                  child: CustomContainer(
                    borderRadius: borderRadiusOf50,
                    border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                    padding: const EdgeInsets.all(5),
                    child: CustomSvgPicture(
                      svgImage: 'schedule_timmer',
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                  ),
                ),
              ),
            ),
            const CustomSizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText('schedule'.translate(context: context),
                      color: Theme.of(context).colorScheme.lightGreyColor, fontSize: 12),
                  CustomText(
                    time,
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ],
              ),
            )
          ],
        ),
      );

  Widget _buildAddressContainer({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          CustomSvgPicture(
              svgImage: "current_location",
              width: 20,
              height: 20,
              color: Theme.of(context).colorScheme.accentColor),
          const CustomSizedBox(width: 10),
          Expanded(
            child: CustomText(
              bookingDetails.address ?? "",
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceContainer({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          CustomSvgPicture(
              width: 20,
              height: 20,
              svgImage: "discount",
              color: Theme.of(context).colorScheme.accentColor),
          const CustomSizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomText(
            (bookingDetails.finalTotal ?? "0").priceFormat(),
            color: Theme.of(context).colorScheme.accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          )),
        ],
      ),
    );
  }

  Widget _buildImageAndTitleRow({
    required final BuildContext context,
  }) =>
      CustomInkWellContainer(
        onTap: () {
          Navigator.pushNamed(
            context,
            providerRoute,
            arguments: {"providerId": bookingDetails.partnerId ?? "0"},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadiusOf50),
                child: CustomContainer(
                  height: 35,
                  width: 35,
                  borderRadius: borderRadiusOf50,
                  child: CustomCachedNetworkImage(
                      height: 50,
                      width: 50,
                      networkImageUrl: bookingDetails.profileImage ?? "",
                      fit: BoxFit.cover),
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomText(
                  "${"worker".translate(context: context)} ${bookingDetails.companyName}",
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.blackColor,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildStatusAndInvoiceContainer({
    required final BuildContext context,
  }) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildStatusRow(context: context)),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomText(
                    "${"invoiceNumber".translate(context: context)}: ",
                    maxLines: 1,
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    textAlign: TextAlign.end,
                  ),
                ),
                CustomText(
                  bookingDetails.invoiceNo ?? "0",
                  color: Theme.of(context).colorScheme.accentColor,
                  maxLines: 1,
                ),
              ],
            )),
          ],
        ),
      );

  Widget _buildStatusRow({
    required final BuildContext context,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CustomSizedBox(
            height: 30,
            width: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadiusOf10),
              child: CustomSvgPicture(
                svgImage:
                    "${UiUtils.getStatusColorAndImage(context: context, statusVal: bookingDetails.status ?? "")["imageName"]}",
              ),
            ),
          ),
          const CustomSizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomContainer(
              height: 30,
              width: 100,
              color: UiUtils.getStatusColorAndImage(
                      context: context, statusVal: bookingDetails.status ?? "")["color"]
                  .withOpacity(0.2),
              borderRadius: borderRadiusOf5,
              child: Center(
                child: CustomText(
                  (bookingDetails.status ?? "").translate(context: context).capitalize(),
                  color: UiUtils.getStatusColorAndImage(
                      context: context, statusVal: bookingDetails.status ?? "")["color"],
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      );

//
  Widget _buildServiceListContainer({
    required final BuildContext context,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          bookingDetails.services!.length,
          (final int index) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomSizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadiusOf10),
                    child: CustomCachedNetworkImage(
                      fit: BoxFit.fill,
                      networkImageUrl: bookingDetails.services![index].image ?? "",
                    ),
                  ),
                ),
                const CustomSizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomText(
                    '${bookingDetails.services![index].serviceTitle}',
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.blackColor,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      width: MediaQuery.sizeOf(context).width,
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusAndInvoiceContainer(
            context: context,
          ),
          const CustomDivider(
            thickness: 0.5,
          ),
          _buildServiceListContainer(
            context: context,
          ),
          _buildDateAndTimeContainer(
              context: context,
              time:
                  '${bookingDetails.dateOfService.toString().formatDate()}, ${bookingDetails.startingTime.toString().formatTime()}'),
          if (bookingDetails.providerAddress != "" && bookingDetails.addressId != "0")
            _buildAddressContainer(context: context),
          _buildPriceContainer(context: context),
          const CustomDivider(
            thickness: 0.5,
          ),
          _buildImageAndTitleRow(
            context: context,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                if (bookingDetails.isCancelable == "1" && bookingDetails.status != "cancelled") ...[
                  Expanded(
                    child: CancelAndRescheduleButton(
                      bookingId: bookingDetails.id ?? "0",
                      buttonName: "cancelBooking",
                      onButtonTap: () {
                        context.read<ChangeBookingStatusCubit>().changeBookingStatus(
                              pressedButtonName: "cancelBooking",
                              bookingStatus: 'cancelled',
                              bookingId: bookingDetails.id ?? "0",
                            );
                      },
                    ),
                  ),
                  if (bookingDetails.status == "awaiting" || bookingDetails.status == "confirmed")
                    const CustomSizedBox(
                      width: 10,
                    )
                ],
                if (bookingDetails.status == "awaiting" || bookingDetails.status == "confirmed")
                  Expanded(
                      child: CancelAndRescheduleButton(
                          bookingId: bookingDetails.id ?? "0",
                          buttonName: "reschedule",
                          onButtonTap: () {
                            UiUtils.showBottomSheet(
                              enableDrag: true,
                              context: context,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider<ValidateCustomTimeCubit>(
                                    create: (context) =>
                                        ValidateCustomTimeCubit(cartRepository: CartRepository()),
                                  ),
                                  BlocProvider(
                                    create: (context) => TimeSlotCubit(CartRepository()),
                                  )
                                ],
                                child: CalenderBottomSheet(
                                  advanceBookingDays:
                                      bookingDetails.providerAdvanceBookingDays.toString(),
                                  providerId: bookingDetails.partnerId.toString(),
                                  selectedDate: selectedDate,
                                  selectedTime: selectedTime,
                                  orderId: bookingDetails.id ?? "0",
                                ),
                              ),
                            ).then((value) {
                              //

                              selectedDate = DateTime.parse(DateFormat("yyyy-MM-dd")
                                  .format(DateTime.parse("${value['selectedDate']}")));
                              //
                              selectedTime = value['selectedTime'];
                              //
                              message = value['message'];
                              //
                              final bool isSaved = value['isSaved'];

                              if (selectedTime != null && selectedTime != null && isSaved) {
                                context.read<ChangeBookingStatusCubit>().changeBookingStatus(
                                    pressedButtonName: "reschedule",
                                    bookingStatus: 'rescheduled',
                                    bookingId: bookingDetails.id!,
                                    selectedTime: selectedTime.toString(),
                                    selectedDate: selectedDate.toString());
                              }
                            });
                          })),
              ],
            ),
          ),
          if (bookingDetails.status == "completed") ...[
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  if (bookingDetails.isReorderAllowed == "1") ...[
                    Expanded(
                      child: ReOrderButton(
                        bookingDetails: bookingDetails,
                        isReorderFrom: "bookings",
                        bookingId: bookingDetails.id ?? "0",
                      ),
                    ),
                    const CustomSizedBox(
                      width: 10,
                    ),
                  ],
                  Expanded(
                    child: DownloadInvoiceButton(bookingId: bookingDetails.id ?? "0"),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}
