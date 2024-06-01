import 'package:e_demand/ui/widgets/customLoadingMoreContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => BlocProvider<FandqsCubit>(
          create: (final BuildContext context) => FandqsCubit(SystemRepository()),
          child: const FaqsScreen(),
        ),
      );

  @override
  State<FaqsScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<FaqsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setScrollListener();
    Future.delayed(Duration.zero).then((final value) {
      fetchFAQs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void setScrollListener() {
    _scrollController.addListener(fetchMoreFaqs);
  }

  void fetchFAQs() {
    context.read<FandqsCubit>().fetchFAQs();
  }

  void fetchMoreFaqs() {
    if (!context.read<FandqsCubit>().hasMoreFAndQs()) {
      return;
    }

// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<FandqsCubit>().fetchMoreFAndQs();
      }
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'Help Center'.translate(context: context),
        ),
        body: CustomRefreshIndicator(
          displacment: 12,
          onRefreshCallback: () {
            fetchFAQs();
          },
          child: BlocBuilder<FandqsCubit, FandqsState>(
            builder: (final BuildContext context, final FandqsState faqState) {
              if (faqState is FaqsFetchFailure) {
                return ErrorContainer(
                  errorMessage: faqState.errorMessage.translate(context: context),
                  onTapRetry: fetchFAQs,
                  showRetryButton: true,
                );
              } else if (faqState is FaqsFetchSuccess) {
                var isExpanded = false;
                return faqState.faqsList.isEmpty
                    ? NoDataContainer(titleKey: 'noFaqsFound'.translate(context: context))
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: List.generate(
                            faqState.faqsList.length +
                                (faqState.isLoadingMoreFaqs || faqState.isLoadingMoreError ? 1 : 0),
                            (final int index) {
                              if (index >= faqState.faqsList.length) {
                                return CustomLoadingMoreContainer(
                                  isError: faqState.isLoadingMoreError,
                                  onErrorButtonPressed: () {
                                    fetchMoreFaqs();
                                  },
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Theme(
                                  data:
                                      Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    onExpansionChanged: (final bool value) {
                                      setState(() {
                                        isExpanded = value;
                                      });
                                    },
                                    leading: isExpanded
                                        ? const Icon(Icons.remove)
                                        : const Icon(Icons.add),
                                    tilePadding: EdgeInsets.zero,
                                    childrenPadding: EdgeInsets.zero,
                                    collapsedIconColor: Theme.of(context).colorScheme.blackColor,
                                    expandedAlignment: Alignment.topLeft,
                                    title: CustomText(
                                      faqState.faqsList[index].question,

                                        color: Theme.of(context).colorScheme.blackColor,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12,

                                      textAlign: TextAlign.left,
                                    ),
                                    subtitle: const CustomText(""),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    children: <Widget>[
                                      CustomText(
                                        faqState.faqsList[index].answer,

                                          color: Theme.of(context).colorScheme.lightGreyColor,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 12,

                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
              }

              return _getShimmerEffect();
            },
          ),
        ),
      );

  Widget _getShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
                numberOfShimmerContainer,
                    (final index) =>CustomShimmerLoadingContainer(
                  margin: const EdgeInsets.all(15),
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  borderRadius: borderRadiusOf10,
                )
            ),
          ),
        ),
      );
}
