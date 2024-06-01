import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/selectableListBottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CategoryType { category, subcategory }

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({
    required this.categoryId,
    required this.appBarTitle,
    final Key? key,
    this.subCategoryId,
  }) : super(key: key);

  //
  final String categoryId;
  final String? subCategoryId;
  final String appBarTitle;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (final context) => SubCategoryAndProviderCubit(
              providerRepository: ProviderRepository(),
              subCategoryRepository: SubCategoryRepository(),
            ),
          ),
          BlocProvider(
            create: (final context) => ProviderCubit(ProviderRepository()),
          ),
        ],
        child: SubCategoryScreen(
          categoryId: arguments["categoryId"],
          appBarTitle: arguments["appBarTitle"],
          subCategoryId: arguments["subCategoryId"],
        ),
      ),
    );
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> with SingleTickerProviderStateMixin {
  String sortByDefaultOptionValue = 'popularity';
  late String sortByDefaultOptionName = "popularity";

  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) => fetchSubCategoryAndProviderData());
    super.initState();
  }

  void fetchSubCategoryAndProviderData() {
    context.read<SubCategoryAndProviderCubit>().getSubCategoriesAndProviderList(
          subCategoryID: widget.subCategoryId,
          categoryID: widget.categoryId,
          providerSortBy: sortByDefaultOptionValue,
        );
  }

  Widget _getSubCategoryShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(top: 10, start: 10, end: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              numberOfShimmerContainer,
              (final int index) => Column(
                children: [
                  const CustomShimmerLoadingContainer(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    borderRadius: borderRadiusOf50,
                  ),
                  CustomShimmerLoadingContainer(
                    width: MediaQuery.sizeOf(context).width * 0.25,
                    height: MediaQuery.sizeOf(context).height * 0.01,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: widget.appBarTitle,
        ),
        body: Stack(
          children: [
            CustomSizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child: BlocBuilder<SubCategoryAndProviderCubit, SubCategoryAndProviderState>(
                builder: (final BuildContext context,
                    final SubCategoryAndProviderState subCategoryAndProviderState) {
                  if (subCategoryAndProviderState is SubCategoryAndProviderFetchFailure) {
                    return ErrorContainer(
                      errorMessage:
                          subCategoryAndProviderState.errorMessage.translate(context: context),
                      onTapRetry: () {
                        fetchSubCategoryAndProviderData();
                      },
                    );
                  } else if (subCategoryAndProviderState is SubCategoryAndProviderFetchSuccess) {
                    //
                    // If subCategory and provider list is empty then show No Data found message
                    if (subCategoryAndProviderState.subCategoryList.isEmpty &&
                        subCategoryAndProviderState.providerList.isEmpty) {
                      return NoDataContainer(
                          titleKey: 'noProvidersFound'.translate(context: context));
                    }
                    return _getSubCategoryAndProviderList(
                      subCategoryAndProviderState.subCategoryList,
                      subCategoryAndProviderState.providerList,
                      subCategoryAndProviderState.providerList.length.toString(),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _getSubCategoryShimmerEffect(),
                        const ProviderListShimmerEffect(showTotalProviderContainer: true),
                      ],
                    ),
                  );
                },
              ),
            ),
            BlocConsumer<ProviderCubit, ProviderState>(
              listener: (final BuildContext context, final ProviderState state) {
                if (state is ProviderFetchSuccess) {
                  context.read<SubCategoryAndProviderCubit>().emitSuccessState(
                        providerList: state.providerList,
                        totalProviders: state.totalProviders,
                      );
                }
              },
              builder: (final BuildContext context, final ProviderState state) {
                if (state is ProviderFetchInProgress) {
                  return Center(
                    child: CustomCircularProgressIndicator(
                      color: Theme.of(context).colorScheme.accentColor,
                    ),
                  );
                }
                return const CustomSizedBox();
              },
            ),
          ],
        ),
      );

  Widget _getSubCategoryList(final List<SubCategory> subCategoryList) => ListView.builder(
        padding: const EdgeInsetsDirectional.only(start: 5, end: 15),
        scrollDirection: Axis.horizontal,
        itemCount: subCategoryList.length,
        itemBuilder: (final BuildContext context, final int index) =>
            _getSubCategoryItem(subCategoryList[index]),
      );

  Widget _getSubCategoryItem(final SubCategory subCategoryList) {
    final darkModeColor = subCategoryList.darkBackgroundColor == ""
        ? Theme.of(context).colorScheme.secondaryColor
        : subCategoryList.darkBackgroundColor!.toColor();
    final lightModeColor = subCategoryList.lightBackgroundColor == ""
        ? Theme.of(context).colorScheme.secondaryColor
        : subCategoryList.lightBackgroundColor!.toColor();
    //
    return CustomContainer(
      color: Theme.of(context).brightness == Brightness.light ? lightModeColor : darkModeColor,
      borderRadius: borderRadiusOf10,
      padding: const EdgeInsetsDirectional.only(
        top: 10,
        start: 10,
        end: 10,
      ),
      margin: const EdgeInsetsDirectional.only(
        top: 10,
        start: 10,
      ),
      child: ImageWithText(
        imageURL: subCategoryList.categoryImage!,
        title: subCategoryList.name ?? "",
        fontWeight: FontWeight.w500,
        textContainerHeight: 30,
        textContainerWidth: 100,
        imageContainerHeight: 110,
        imageContainerWidth: 100,
        imageRadius: borderRadiusOf10,
        maxLines: 2,
        lightModeBackgroundColor: subCategoryList.lightBackgroundColor,
        darkModeBackgroundColor: subCategoryList.darkBackgroundColor,
        onTap: () {
          Navigator.pushNamed(
            context,
            subCategoryRoute,
            arguments: {
              'subCategoryId': subCategoryList.id,
              'categoryId': '',
              'appBarTitle': subCategoryList.name,
              'type': CategoryType.subcategory
            },
          );
        },
      ),
    );
  }

  Widget _getSubCategoryAndProviderList(
    final List<SubCategory> subCategoryList,
    final List<Providers> providerList,
    final String totalProviders,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (final BuildContext context, final bool innerBoxIsScrolled) =>
          <Widget>[],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: subCategoryList.isNotEmpty
                ? CustomSizedBox(height: 175, child: _getSubCategoryList(subCategoryList))
                : const CustomSizedBox(),
          ),
          if (providerList.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: SliverAppBarDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Column(
                  children: [
                    _getTotalProviderAndViewOptionsContainer(
                      totalProviders: totalProviders,
                      context: context,
                      catId: widget.categoryId,
                      subCatId: widget.subCategoryId,
                    ),
                  ],
                ),
              ),
            ),
          if (providerList.isNotEmpty)
            SliverToBoxAdapter(
              child: _getProviderList(providerList, totalProviders),
            )
        ],
      ),
    );
  }

  Widget _getTotalProviderAndViewOptionsContainer({
    required final String totalProviders,
    required final BuildContext context,
    required final String catId,
    final String? subCatId,
  }) =>
      CustomContainer(
        color: Theme.of(context).colorScheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'provider'.translate(context: context),
                  color: Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  textAlign: TextAlign.left,
                ),
                CustomText(
                  "$totalProviders ${"serviceProvider".translate(context: context)}",
                  color: Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 10,
                  textAlign: TextAlign.left,
                )
              ],
            ),
            const Spacer(),
            CustomInkWellContainer(
              onTap: () {
                UiUtils.showBottomSheet(
                    context: context,
                    enableDrag: true,
                    child: SelectableListBottomSheet(bottomSheetTitle: "sortBy", itemList: [
                      {
                        "title": "popularity",
                        "id": "0",
                        "isSelected": sortByDefaultOptionName == "popularity"
                      },
                      {
                        "title": "discountHighToLow",
                        "id": "1",
                        "isSelected": sortByDefaultOptionName == "discount"
                      },
                      {
                        "title": "topRated",
                        "id": "2",
                        "isSelected": sortByDefaultOptionName == "ratings"
                      },
                    ])).then((value) {
                  if (value != null) {
                    value as Map;

                    if (value["selectedItemName"] == 'popularity') {
                      sortByDefaultOptionName = 'popularity';
                    } else if (value["selectedItemName"] == 'discountHighToLow') {
                      sortByDefaultOptionName = 'discount';
                    } else if (value["selectedItemName"] == 'topRated') {
                      sortByDefaultOptionName = 'ratings';
                    }
                    context.read<ProviderCubit>().getProviders(
                          categoryID: widget.categoryId,
                          subCategoryID: widget.subCategoryId,
                          filter: sortByDefaultOptionName,
                        );
                  }
                });
              },
              child: Icon(Icons.sort, color: Theme.of(context).colorScheme.accentColor),
            )
          ],
        ),
      );

  Widget _getProviderList(final List<Providers> providerList, final String totalProviders) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              providerList.length,
              (index) => ProviderListItem(
                providerDetails: providerList[index],
                categoryId: widget.categoryId,
              ),
            )),
      );
}
