import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/customLoadingMoreContainer.dart';
import 'package:flutter/material.dart';

class ProviderListWidget extends StatelessWidget {
  final ScrollController providerScrollController;
  final VoidCallback onTapRetry;
  final VoidCallback onErrorButtonPressed;

  const ProviderListWidget(
      {super.key,
      required this.providerScrollController,
      required this.onTapRetry,
      required this.onErrorButtonPressed});

  Widget _getProviderList(
          {required final List<Providers> providerList,
          required final bool isLoadingMoreData,
          required final bool isLoadingMoreError}) =>
      ListView.builder(
        controller: providerScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: providerList.length + (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
        itemBuilder: (final BuildContext context, final int index) {
          if (index >= providerList.length) {
            return CustomLoadingMoreContainer(
              isError: isLoadingMoreError,
              onErrorButtonPressed: onErrorButtonPressed,
            );
          }
          return ProviderListItem(
            providerDetails: providerList[index],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchProviderCubit, SearchProviderState>(
      listener: (final BuildContext context, final SearchProviderState searchState) {
        if (searchState is SearchProviderFailure) {
          UiUtils.showMessage(
              context, searchState.errorMessage.translate(context: context), MessageType.error);
        }
      },
      builder: (final BuildContext context, final SearchProviderState searchState) {
        if (searchState is SearchProviderFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: 'somethingWentWrong'.translate(context: context),
              onTapRetry: onTapRetry,
              showRetryButton: true,
            ),
          );
        } else if (searchState is SearchProviderSuccess) {
          if (searchState.providerList.isEmpty) {
            return NoDataContainer(
              titleKey: 'noProviderFound'.translate(context: context),
            );
          }
          return _getProviderList(
              isLoadingMoreError: searchState.isLoadingMoreError,
              providerList: searchState.providerList,
              isLoadingMoreData: searchState.isLoadingMore);
        } else if (searchState is SearchProviderInProgress) {
          return const SingleChildScrollView(
              child: ProviderListShimmerEffect(
            showTotalProviderContainer: false,
          ));
        }
        return NoDataContainer(
          titleKey: "typeToSearch".translate(context: context),
          showRetryButton: false,
        );
      },
    );
  }
}
