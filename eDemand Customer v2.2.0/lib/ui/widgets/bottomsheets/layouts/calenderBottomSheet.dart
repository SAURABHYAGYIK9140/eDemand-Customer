import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';

class CalenderBottomSheet extends StatefulWidget {
  const CalenderBottomSheet({
    required this.providerId,
    required this.advanceBookingDays,
    final Key? key,
    this.selectedDate,
    this.selectedTime,
    this.orderId,
  }) : super(key: key);

  final String providerId;
  final String advanceBookingDays;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? orderId;

  @override
  State<CalenderBottomSheet> createState() => _CalenderBottomSheetState();
}

class _CalenderBottomSheetState extends State<CalenderBottomSheet> with TickerProviderStateMixin {
  late DateTime selectedDate;
  String? selectedTime;
  String? message;
  int? selectedTimeSlotIndex;
  List<String> listOfDay = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];

  void fetchTimeSlots() {
    context
        .read<TimeSlotCubit>()
        .getTimeslotDetails(providerID: int.parse(widget.providerId), selectedDate: selectedDate);
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();

    Future.delayed(Duration.zero).then((final value) {
      fetchTimeSlots();
    });
  }

  Widget verticalSpacing() {
    return const CustomSizedBox(
      height: 10,
    );
  }

  @override
  Widget build(final BuildContext context) => WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(
            {
              "selectedDate": selectedDate,
              "selectedTime": selectedTime,
              "message": message,
              "isSaved": false
            },
          );
          return true;
        },
        child: SafeArea(
          child: StatefulBuilder(
            builder: (final BuildContext context, final setStater) => BottomSheetLayout(
              title: "selectDateAndTime".translate(context: context),
              child: CustomSizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Align(
                  child: CustomContainer(
                    color: Theme.of(context).colorScheme.primaryColor,
                    borderRadius: borderRadiusOf10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomText(
                            "selectDateOfTheService".translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.blackColor,
                          ),
                        ),
                        verticalSpacing(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: List.generate(int.parse(widget.advanceBookingDays), (index) {
                              final DateTime date = DateTime.now().add(Duration(days: index));
                              final String day =
                                  listOfDay[date.weekday - 1].translate(context: context);
                              return CustomInkWellContainer(
                                onTap: () {
                                  if (DateFormat("yyyy-MM-dd").format(selectedDate) ==
                                      DateFormat("yyyy-MM-dd").format(DateTime.parse(date.toString()))) {
                                    return;
                                  }
                                  selectedTime=null;
                                  selectedTimeSlotIndex=null;
                                  selectedDate = DateTime.parse(date.toString());
                                  setStater(() {});
                                  fetchTimeSlots();
                                },
                                child: CustomContainer(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  border: intl.DateFormat("yyyy-MM-dd").format(selectedDate) ==
                                          intl.DateFormat("yyyy-MM-dd").format(date)
                                      ? Border.all(color: Theme.of(context).colorScheme.accentColor)
                                      : null,
                                  color: Theme.of(context).colorScheme.secondaryColor,
                                  borderRadius: borderRadiusOf10,
                                  child: Column(
                                    children: [
                                      CustomText(
                                        "${date.day} / ${date.month}",
                                        color: Theme.of(context).colorScheme.blackColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      CustomText(
                                        day.length > 3 ? day.substring(0, 3) : day,
                                        color: Theme.of(context).colorScheme.lightGreyColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        verticalSpacing(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: CustomText(
                            "selectTimeOfTheService".translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.blackColor,
                          ),
                        ),
                        verticalSpacing(),
                        Expanded(
                          child: BlocConsumer<TimeSlotCubit, TimeSlotState>(
                            listener: (final context, final state) {
                              if (state is TimeSlotFetchSuccess) {
                                if (state.isError) {
                                  UiUtils.showMessage(
                                    context,
                                    state.message,
                                    MessageType.warning,
                                  );
                                }
                              }
                            },
                            builder: (final context, final state) {
                              //timeslot background color
                              final Color disabledTimeSlotColor =
                                  Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.35);
                              final Color selectedTimeSlotColor =
                                  Theme.of(context).colorScheme.accentColor;
                              final Color defaultTimeSlotColor =
                                  Theme.of(context).colorScheme.secondaryColor;

                              //timeslot border color
                              final Color disabledTimeSlotBorderColor =
                                  Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.35);
                              final Color selectedTimeSlotBorderColor =
                                  Theme.of(context).colorScheme.accentColor;
                              final Color defaultTimeSlotBorderColor =
                                  Theme.of(context).colorScheme.secondaryColor;

                              //timeslot text color
                              final Color disabledTimeSlotTextColor =
                                  Theme.of(context).colorScheme.blackColor;
                              final Color selectedTimeSlotTextColor = AppColors.whiteColors;
                              final Color defaultTimeSlotTextColor =
                                  Theme.of(context).colorScheme.blackColor;

                              if (state is TimeSlotFetchSuccess) {
                                return state.isError
                                    ? Center(
                                        child: CustomText(state.message),
                                      )
                                    : GridView.count(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 2.7,
                                        children: List<Widget>.generate(
                                              state.slotsData.length,
                                              (index) {
                                                return CustomInkWellContainer(
                                                  onTap: () {
                                                    if (state.slotsData[index].isAvailable == 0) {
                                                      return;
                                                    }

                                                    selectedTime = state.slotsData[index].time;
                                                    message = state.slotsData[index].message;
                                                    selectedTimeSlotIndex = index;
                                                    setState(() {});
                                                  },
                                                  child: slotItemContainer(
                                                    backgroundColor:
                                                        state.slotsData[index].isAvailable == 0
                                                            ? disabledTimeSlotColor
                                                            : selectedTimeSlotIndex == index
                                                                ? selectedTimeSlotColor
                                                                : defaultTimeSlotColor,
                                                    borderColor:
                                                        state.slotsData[index].isAvailable == 0
                                                            ? disabledTimeSlotBorderColor
                                                            : selectedTimeSlotIndex == index
                                                                ? selectedTimeSlotBorderColor
                                                                : defaultTimeSlotBorderColor,
                                                    titleColor:
                                                        state.slotsData[index].isAvailable == 0
                                                            ? disabledTimeSlotTextColor
                                                            : selectedTimeSlotIndex == index
                                                                ? selectedTimeSlotTextColor
                                                                : defaultTimeSlotTextColor,
                                                    title: (state.slotsData[index].time ?? "")
                                                        .formatTime(),
                                                  ),
                                                );
                                              },
                                            ) +
                                            <Widget>[
                                              CustomInkWellContainer(
                                                onTap: () {
                                                  displayTimePicker(context);
                                                },
                                                child: slotItemContainer(
                                                    backgroundColor: Colors.transparent,
                                                    titleColor:
                                                        Theme.of(context).colorScheme.accentColor,
                                                    borderColor:
                                                        Theme.of(context).colorScheme.accentColor,
                                                    title: selectedTime ??
                                                        "addSlot".translate(context: context)),
                                              )
                                            ],
                                      );
                              }
                              if (state is TimeSlotFetchFailure) {
                                return ErrorContainer(
                                  onTapRetry: () {
                                    fetchTimeSlots();
                                  },
                                  errorMessage: state.errorMessage.translate(context: context),
                                );
                              }
                              return Center(
                                child: CustomText("loading".translate(context: context)),
                              );
                            },
                          ),
                        ),
                        _getCloseAndContinueNavigateButton()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget slotItemContainer({
    required Color backgroundColor,
    required Color borderColor,
    required Color titleColor,
    required String title,
  }) {
    return CustomContainer(
      width: 150,
      height: 20,
      color: backgroundColor,
      borderRadius: borderRadiusOf10,
      border: Border.all(
        width: 0.5,
        color: borderColor,
      ),
      child: Center(
        child: CustomText(
          title,
          color: titleColor,
        ),
      ),
    );
  }

//
  Future displayTimePicker(final BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = "${time.hour}:${time.minute}:00".convertTime();
        selectedTimeSlotIndex = null;
      });
    }
  }

  Widget _getCloseAndContinueNavigateButton() =>
      BlocConsumer<ValidateCustomTimeCubit, ValidateCustomTimeState>(
        listener: (
          final BuildContext context,
          final ValidateCustomTimeState validateCustomTimeState,
        ) {
          if (validateCustomTimeState is ValidateCustomTimeSuccess) {
            if (!validateCustomTimeState.error) {
              Navigator.of(context).pop(
                {
                  "selectedDate": selectedDate,
                  "selectedTime": selectedTime,
                  "message": message,
                  "isSaved": true
                },
              );
            } else {
              UiUtils.showMessage(context,
                  validateCustomTimeState.message.translate(context: context), MessageType.error);
            }
          } else if (validateCustomTimeState is ValidateCustomTimeFailure) {
            UiUtils.showMessage(
              context,
              validateCustomTimeState.errorMessage.translate(context: context),
              MessageType.error,
            );
          }
        },
        builder: (context, validateCustomTimeState) {
          Widget? child;
          if (validateCustomTimeState is ValidateCustomTimeInProgress) {
            child = CustomCircularProgressIndicator(color: AppColors.whiteColors);
          } else if (validateCustomTimeState is ValidateCustomTimeFailure ||
              validateCustomTimeState is ValidateCustomTimeSuccess) {
            child = null;
          }
          return CloseAndConfirmButton(
            closeButtonPressed: () {
              Navigator.pop(context);
            },
            confirmButtonPressed: () {
              context.read<ValidateCustomTimeCubit>().validateCustomTime(
                    providerId: widget.providerId,
                    selectedDate: intl.DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse("$selectedDate"))
                        .toString(),
                    selectedTime: selectedTime.toString(),
                    orderId: widget.orderId,
                  );
            },
            confirmButtonChild: child,
            showProgressIndicator: false,
            confirmButtonName: "continue",
          );
        },
      );
}
