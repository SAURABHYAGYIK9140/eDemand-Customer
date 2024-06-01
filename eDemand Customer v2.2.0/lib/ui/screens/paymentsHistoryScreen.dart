import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/customLoadingMoreContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  static Route route(final RouteSettings settings) => CupertinoPageRoute(
        builder: (final BuildContext context) => BlocProvider(
          create: (final context) => FetchUserPaymentDetailsCubit(SystemRepository()),
          child: Builder(
            builder: (final context) => const PaymentsScreen(),
          ),
        ),
      );

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPaymentDetails();
    _scrollController.addListener(fetchMorePaymentDetails);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchMorePaymentDetails() {
    if (!context.read<FetchUserPaymentDetailsCubit>().hasMoreTransactions()) {
      return;
    }

// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<FetchUserPaymentDetailsCubit>().fetchUsersMorePaymentDetails();
      }
    }
  }

//
  void fetchPaymentDetails() {
    context.read<FetchUserPaymentDetailsCubit>().fetchUserPaymentDetails();
  }

  //
  SingleChildScrollView _buildPaymentDetailsShimmerLoading() => SingleChildScrollView(
        child: Column(
          children: List.generate(
            numberOfShimmerContainer,
            (final int index) => CustomShimmerLoadingContainer(
              height: 100,
              width: MediaQuery.sizeOf(context).width * 0.9,
              borderRadius: borderRadiusOf10,
              margin: const EdgeInsets.all(10),
            ),
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          elevation: 0,
          title: 'payment'.translate(context: context),
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        ),
        body: BlocBuilder<FetchUserPaymentDetailsCubit, FetchUserPaymentDetailsState>(
          builder: (final BuildContext context, final FetchUserPaymentDetailsState state) {
            if (state is FetchUserPaymentDetailsFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage.translate(context: context),
                onTapRetry: () {
                  fetchPaymentDetails();
                },
              );
            }
            if (state is FetchUserPaymentDetailsSuccess) {
              if (state.paymentDetails.isEmpty) {
                return NoDataContainer(
                  titleKey: 'noPaymentDetailsFound'.translate(context: context),
                );
              }
              return CustomRefreshIndicator(
                displacment: 12,
                onRefreshCallback: () {
                  fetchPaymentDetails();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _buildPaymentHistoryCard(
                      isLoadingMoreError: state.isLoadingMoreError,
                      isLoadingMoreData: state.isLoadingMorePayments,
                      paymentDetails: state.paymentDetails),
                ),
              );
            }
            return _buildPaymentDetailsShimmerLoading();
          },
        ),
      );

  Widget _getDetails({final String? title, final String? subTitle}) => Row(
        children: [
          CustomText(
            title ?? '',

              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 14,

          ),
          Expanded(
            child: CustomText(
              " ${subTitle ?? " "}",
            
                color: Theme.of(context).colorScheme.lightGreyColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 12,
            maxLines: 1,
            ),
          ),
        ],
      );

  Widget _buildPaymentHistoryCard(
          {required final bool isLoadingMoreData,
          required final bool isLoadingMoreError,
          required final List<Payment> paymentDetails}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          paymentDetails.length,
          (final int index) {
            if (index >=
                paymentDetails.length + (isLoadingMoreData || isLoadingMoreError ? 1 : 0)) {
              return CustomLoadingMoreContainer(
                isError: isLoadingMoreError,
                onErrorButtonPressed: () {
                  fetchMorePaymentDetails();
                },
              );
            }

            return CustomContainer(

                color: Theme.of(context).colorScheme.secondaryColor,
                borderRadius: borderRadiusOf10,

              width: MediaQuery.sizeOf(context).width,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(

                        child: _getDetails(
                          title: 'amount'.translate(context: context),
                          subTitle: (paymentDetails[index].amount!).priceFormat(),
                        ),
                      ),
                      CustomSizedBox(

                        height: 25,
                        child: // Phone number : 8523674126
                            CustomText(
                          paymentDetails[index].status.toString().capitalize(),

                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 12,

                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  _getDetails(
                    title: 'bookingId'.translate(context: context),
                    subTitle: paymentDetails[index].orderId,
                  ),
                  _getDetails(
                    title: 'message'.translate(context: context),
                    subTitle: paymentDetails[index].message,
                  ),
                  _getDetails(
                    title: 'transactionId'.translate(context: context),
                    subTitle: paymentDetails[index].txnId,
                  ),
                ],
              ),
            );
          },
        ),
      );
}
