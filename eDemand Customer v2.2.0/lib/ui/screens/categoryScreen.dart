import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.scrollController, final Key? key}) : super(key: key);
  final ScrollController scrollController;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) {
      fetchCategory();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchCategory() {
    context.read<CategoryCubit>().getCategory();
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'category'.translate(context: context),
            isLeadingIconEnable: false,
            centerTitle: true,
            elevation: 0.5,
          ),
          body: CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () {
              fetchCategory();
            },
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (final BuildContext context, final CategoryState categoryState) {
                if (categoryState is CategoryFetchFailure) {
                  return ErrorContainer(
                    errorMessage: categoryState.errorMessage.translate(context: context),
                    onTapRetry: fetchCategory,
                    showRetryButton: true,
                  );
                } else if (categoryState is CategoryFetchSuccess) {
                  return categoryState.categoryList.isEmpty
                      ? NoDataContainer(
                          titleKey: 'noCategoryFound'.translate(context: context),
                          showRetryButton: true,
                          onTapRetry: () {
                            fetchCategory();
                          },
                        )
                      : _getCategoryList(categoryList: categoryState.categoryList);
                }

                return _getCategoryShimmerEffect();
              },
            ),
          ),
        ),
      );

  Widget _getCategoryShimmerEffect() => GridView.builder(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        itemCount: numberOfShimmerContainer * 2,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (final context, final index) => const CustomSizedBox(
          height: 75,
          width: 75,
          child: Column(
            children: [
              CustomShimmerLoadingContainer(
                height: 75,
                width: 75,
                borderRadius: borderRadiusOf10,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 5),
                child: CustomShimmerLoadingContainer(
                  width: 70,
                  height: 10,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _getCategoryList({required final List<CategoryModel> categoryList}) => GridView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(15, 15, 15, bottomNavigationBarHeight),
        itemCount: categoryList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (final BuildContext context, int index) {
          final Color darkModeColor = categoryList[index].backgroundDarkColor == ""
              ? Theme.of(context).colorScheme.secondaryColor
              : categoryList[index].backgroundDarkColor!.toColor();
          final Color lightModeColor = categoryList[index].backgroundLightColor == ""
              ? Theme.of(context).colorScheme.secondaryColor
              : categoryList[index].backgroundLightColor!.toColor();
          return CustomContainer(
            color:
                Theme.of(context).brightness == Brightness.light ? lightModeColor : darkModeColor,
            borderRadius: borderRadiusOf10,
            padding: const EdgeInsetsDirectional.only(
              top: 10,
              start: 10,
              end: 10,
            ),
            child: Center(
              child: ImageWithText(
                imageURL: categoryList[index].categoryImage!,
                title: categoryList[index].name!,
                imageContainerHeight: 75,
                imageContainerWidth: 75,
                textContainerHeight: 30,
                textContainerWidth: 75,
                maxLines: 2,
                imageRadius: borderRadiusOf10,
                fontWeight: FontWeight.w500,
                darkModeBackgroundColor: categoryList[index].backgroundDarkColor,
                lightModeBackgroundColor: categoryList[index].backgroundLightColor,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    subCategoryRoute,
                    arguments: {
                      'categoryId': categoryList[index].id,
                      'appBarTitle': categoryList[index].name,
                      'type': CategoryType.category,
                    },
                  );
                },
              ),
            ),
          );
        },
      );
}
