import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/marqeeWidget.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously

import '../widgets/sliderImageContainer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.scrollController, final Key? key}) : super(key: key);
  final ScrollController scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  FocusNode searchBarFocusNode = FocusNode();

  //
  List<String> searchValues = [
    "searchProviders",
    "searchServices",
    "searchElectronics",
    "searchHairCutting",
    "searchFanRepair"
  ];
  late ValueNotifier<int> currentSearchValueIndex = ValueNotifier(0);
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

  late final Animation<double> _bottomToCenterTextAnimation = Tween<double>(begin: 1, end: 0)
      .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.25)));

  late final Animation<double> _centerToTopTextAnimation = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.75, 1.0)));

  late Timer? _timer;

  //
  //this is used to show shadow under searchbar while scrolling
  ValueNotifier<bool> showShadowBelowSearchBar = ValueNotifier(false);

  //
  @override
  void dispose() {
    showShadowBelowSearchBar.dispose();
    searchBarFocusNode.dispose();
    currentSearchValueIndex.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialiseAnimation();
    AppQuickActions.initAppQuickActions();
    AppQuickActions.createAppQuickActions();
    //
    checkLocationPermission();
    //
    if (HiveRepository.isUserLoggedIn) {
      LocalAwsomeNotification().init(context);
      NotificationService.init(context);
    }
    Future.delayed(Duration.zero, fetchHomeScreenData);
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.scrollController.position.pixels > 7 && !showShadowBelowSearchBar.value) {
      showShadowBelowSearchBar.value = true;
    } else if (widget.scrollController.position.pixels < 7 && showShadowBelowSearchBar.value) {
      showShadowBelowSearchBar.value = false;
    }
  }

  Future<void> fetchHomeScreenData() async {
    //
    final Map<String, dynamic> currencyData =
        context.read<SystemSettingCubit>().getSystemCurrencyDetails();

    systemCurrency = currencyData['currencySymbol'];
    systemCurrencyCountryCode = currencyData['currencyCountryCode'];
    decimalPointsForPrice = currencyData['decimalPoints'];
    //
    final List<Future> futureAPIs = <Future>[
      context.read<HomeScreenCubit>().fetchHomeScreenData(),
      if (HiveRepository.getUserToken != "") ...[
        context.read<CartCubit>().getCartDetails(isReorderCart: false),
        context.read<BookmarkCubit>().fetchBookmark(type: 'list')
      ]
    ];
    await Future.wait(futureAPIs);
  }

  Future<void> checkLocationPermission() async {
    //
    final LocationPermission permission = await Geolocator.checkPermission();
    //
    if ((permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) &&
        ((HiveRepository.getLatitude == "0.0" || HiveRepository.getLatitude == "") &&
            (HiveRepository.getLongitude == "0.0" || HiveRepository.getLongitude == ""))) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, allowLocationScreenRoute);
        /*Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const AllowLocationScreen()));*/
      });
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position;

      if (HiveRepository.getLatitude != null &&
          HiveRepository.getLongitude != null &&
          HiveRepository.getLatitude != "" &&
          HiveRepository.getLongitude != "") {
        final latitude = HiveRepository.getLatitude ?? "0.0";
        final longitude = HiveRepository.getLongitude ?? "0.0";

        await GeocodingPlatform.instance.placemarkFromCoordinates(
          double.parse(latitude.toString()),
          double.parse(longitude.toString()),
        );
      } else {
        position = await Geolocator.getCurrentPosition();
        await GeocodingPlatform.instance
            .placemarkFromCoordinates(position.latitude, position.longitude);
      }

      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: SafeArea(
          child: Scaffold(
            appBar: _getAppBar(),
            body: Stack(
              children: [
                Column(
                  children: [
                    const CustomSizedBox(
                      height: 70,
                    ),
                    Expanded(
                      child: BlocBuilder<CartCubit, CartState>(
                        // we have added Cart cubit
                        // because we want to calculate bottom padding of scroll
                        //
                        builder: (final BuildContext context, final CartState state) =>
                            BlocBuilder<HomeScreenCubit, HomeScreenState>(
                          builder: (context, HomeScreenState homeScreenState) {
                            if (homeScreenState is HomeScreenDataFetchSuccess) {
                              /* If data available in cart then it will return providerId,
                            and if it's returning 0 means cart is empty
                            so we do not need to add extra bottom height for padding
                            */
                              final cartButtonHeight =
                                  context.read<CartCubit>().getProviderIDFromCartData() == '0'
                                      ? 0
                                      : bottomNavigationBarHeight + 10;
                              if (homeScreenState.homeScreenData.category!.isEmpty &&
                                  homeScreenState.homeScreenData.sections!.isEmpty &&
                                  homeScreenState.homeScreenData.sliders!.isEmpty) {
                                return Center(
                                  child: NoDataContainer(
                                    titleKey: 'weAreNotAvailableHere'.translate(context: context),
                                  ),
                                );
                              }
                              return CustomRefreshIndicator(
                                onRefreshCallback: fetchHomeScreenData,
                                displacment: 12,
                                child: SingleChildScrollView(
                                  controller: widget.scrollController,
                                  padding: EdgeInsets.only(
                                    bottom: getScrollViewBottomPadding(context) + cartButtonHeight,
                                  ),
                                  child: Column(
                                    children: [
                                      homeScreenState.homeScreenData.sliders!.isEmpty
                                          ? const CustomSizedBox()
                                          : SliderImageContainer(
                                              sliderImages: homeScreenState.homeScreenData.sliders!,
                                            ),
                                      _getCategoryListContainer(
                                        categoryList: homeScreenState.homeScreenData.category!,
                                      ),
                                      _getSections(
                                        sectionsList: homeScreenState.homeScreenData.sections!,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (homeScreenState is HomeScreenDataFetchFailure) {
                              return ErrorContainer(
                                errorMessage:
                                    homeScreenState.errorMessage.translate(context: context),
                                onTapRetry: () {
                                  fetchHomeScreenData();
                                },
                              );
                            }
                            return _homeScreenShimmerLoading();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  builder: (final BuildContext context, final Object? value, final Widget? child) =>
                      CustomContainer(
                    color: Theme.of(context).colorScheme.primaryColor,
                    boxShadow: showShadowBelowSearchBar.value
                        ? [
                            BoxShadow(
                              offset: const Offset(0, 0.75),
                              spreadRadius: 1,
                              blurRadius: 5,
                              color: Theme.of(context).colorScheme.blackColor.withOpacity(0.2),
                            )
                          ]
                        : [],
                    child: _getSearchBarContainer(),
                  ),
                  valueListenable: showShadowBelowSearchBar,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomNavigationBarHeight, right: 5, left: 5),
                  child: const Align(
                      alignment: Alignment.bottomCenter, child: CartSubDetailsContainer()),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _getSearchBarContainer() {
    return CustomInkWellContainer(
      onTap: () async {
        await Navigator.pushNamed(context, searchScreen);
      },
      child: CustomContainer(
        margin: const EdgeInsets.all(15),
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,
        border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: ValueListenableBuilder(
                  valueListenable: currentSearchValueIndex,
                  builder: (context, int searchValueIndex, _) {
                    return AnimatedBuilder(
                        animation: _bottomToCenterTextAnimation,
                        builder: (context, child) {
                          final dy =
                              _bottomToCenterTextAnimation.value - _centerToTopTextAnimation.value;

                          final opacity = 1 -
                              _bottomToCenterTextAnimation.value -
                              _centerToTopTextAnimation.value;

                          return Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            alignment: Alignment(-1, dy),
                            child: Opacity(
                                opacity: opacity,
                                child: CustomText(
                                    searchValues[searchValueIndex].translate(context: context))),
                          );
                        });
                  }),
            ),
            CustomContainer(
              width: 30,
              height: 30,
              margin: const EdgeInsetsDirectional.only(end: 10),
              padding: const EdgeInsets.all(5),
              child: CustomSvgPicture(
                svgImage: 'search',
                color: Theme.of(context).colorScheme.accentColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getCategoryTextContainer() => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              'category'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 18,
              textAlign: TextAlign.left,
            ),
            // CustomSvgPicture(svgImage: 'arrow_forward')
          ],
        ),
      );

  Widget _getCategoryListContainer({required final List<CategoryModel> categoryList}) =>
      categoryList.isEmpty
          ? const CustomSizedBox()
          : CustomContainer(
              color: Theme.of(context).colorScheme.secondaryColor,
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  _getCategoryTextContainer(),
                  _getCategoryItemsContainer(categoryList),
                ],
              ),
            );

  Widget _getTitleShimmerEffect({
    required final double height,
    required final double width,
    required final double borderRadius,
  }) =>
      CustomShimmerLoadingContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );

  Widget _getCategoryShimmerEffect() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
            child: _getTitleShimmerEffect(
              width: MediaQuery.sizeOf(context).width * (0.7),
              height: MediaQuery.sizeOf(context).height * (0.02),
              borderRadius: borderRadiusOf10,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 15),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  numberOfShimmerContainer,
                  (final int index) => Column(
                    children: [
                      const CustomShimmerLoadingContainer(
                        width: 75,
                        height: 75,
                        borderRadius: borderRadiusOf10,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      const CustomSizedBox(
                        height: 5,
                      ),
                      _getTitleShimmerEffect(width: 75, height: 10, borderRadius: borderRadiusOf10)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _getSingleSectionShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _getTitleShimmerEffect(
                width: MediaQuery.sizeOf(context).width * (0.7),
                height: MediaQuery.sizeOf(context).height * (0.02),
                borderRadius: borderRadiusOf10,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  4,
                  (final int index) => const Padding(
                    padding: EdgeInsetsDirectional.only(top: 10, end: 5, start: 5),
                    child: CustomShimmerLoadingContainer(
                      width: 120,
                      height: 140,
                      borderRadius: borderRadiusOf10,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  AppBar _getAppBar() => AppBar(
        elevation: 0.5,
        surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        leadingWidth: 0,
        leading: const CustomSizedBox(),
        title: CustomInkWellContainer(
          onTap: () {
            UiUtils.showBottomSheet(
              enableDrag: true,
              isScrollControlled: true,
              useSafeArea: true,
              child: CustomContainer(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: const LocationBottomSheet(),
              ),
              context: context,
            ).then((final value) {
              if (value != null) {
                if (value['navigateToMap']) {
                  Navigator.pushNamed(
                    context,
                    googleMapRoute,
                    arguments: {
                      "defaultLatitude": value['latitude'].toString(),
                      "defaultLongitude": value['longitude'].toString(),
                      'showAddressForm': false
                    },
                  );
                }
              }
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your location
              CustomText(
                'your_location'.translate(context: context),
                color: Theme.of(context).colorScheme.lightGreyColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 12,
                textAlign: TextAlign.start,
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
                      child: MarqueeWidget(
                        direction: Axis.horizontal,
                        //animationDuration: const Duration(seconds: 1),
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box(HiveRepository.userDetailBoxKey).listenable(),
                          builder: (BuildContext context, Box box, _) => CustomText(
                            HiveRepository.getLocationName ??
                                "selectYourLocation".translate(context: context),
                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          CustomInkWellContainer(
            onTap: () {
              final authStatus = context.read<AuthenticationCubit>().state;
              if (authStatus is UnAuthenticatedState) {
                UiUtils.showAnimatedDialog(context: context, child: const LogInAccountDialog());

                return;
              }
              Navigator.pushNamed(context, notificationRoute);
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
              child: CustomSvgPicture(
                svgImage: "notification",
                color: Theme.of(context).colorScheme.accentColor,
              ),
            ),
          ),
        ],
      );

  Widget _getSections({required final List<Sections> sectionsList}) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sectionsList.length,
        itemBuilder: (final BuildContext context, int index) {
          return sectionsList[index].partners.isEmpty &&
                  sectionsList[index].subCategories.isEmpty &&
                  sectionsList[index].onGoingBookings.isEmpty &&
                  sectionsList[index].previousBookings.isEmpty
              ? const CustomSizedBox()
              : _getSingleSectionContainer(sectionsList[index]);
        },
      );

  Widget _getSingleSectionContainer(final Sections sectionData) => SingleChildScrollView(
        child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (context, state) {
            final token = HiveRepository.getUserToken;
            if ((sectionData.sectionType == "previous_order" && token == "") ||
                (sectionData.sectionType == "ongoing_order" && token == ""))
              return const CustomSizedBox();
            //
            return CustomContainer(
              margin: const EdgeInsets.only(top: 10),
              color: Theme.of(context).colorScheme.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getSingleSectionTitle(sectionData),
                  _getSingleSectionData(sectionData),
                ],
              ),
            );
          },
        ),
      );

  Widget _getSingleSectionTitle(final Sections sectionData) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 10),
        child: CustomText(
          sectionData.title!,
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          maxLines: 1,
          textAlign: TextAlign.left,
        ),
      );

  CustomSizedBox _getSingleSectionData(final Sections sectionData) {
    return CustomSizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(end: 15, start: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            sectionData.subCategories.isNotEmpty
                ? sectionData.subCategories.length
                : sectionData.partners.isNotEmpty
                    ? sectionData.partners.length
                    : sectionData.onGoingBookings.isNotEmpty
                        ? sectionData.onGoingBookings.length
                        : sectionData.previousBookings.length,
            (index) {
              if (sectionData.subCategories.isNotEmpty) {
                return SectionCardForCategoryAndProviderContainer(
                  title: sectionData.subCategories[index].name!,
                  image: sectionData.subCategories[index].image!,
                  discount: "0",
                  cardHeight: 200,
                  imageHeight: 135,
                  imageWidth: 120,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      subCategoryRoute,
                      arguments: {
                        "categoryId": sectionData.subCategories[index].id,
                        "appBarTitle": sectionData.subCategories[index].name,
                        "type": CategoryType.category,
                      },
                    );
                  },
                );
              } else if (sectionData.partners.isNotEmpty) {
                return SectionCardForCategoryAndProviderContainer(
                  title: sectionData.partners[index].companyName!,
                  image: sectionData.partners[index].image!,
                  discount: sectionData.partners[index].discount!,
                  cardHeight: 200,
                  imageHeight: 135,
                  imageWidth: 120,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {"providerId": sectionData.partners[index].id},
                    ).then(
                      (final Object? value) {
                        //we are changing the route name
                        //to use CartSubDetailsContainer widget to navigate to provider details screen
                        Routes.previousRoute = Routes.currentRoute;
                        Routes.currentRoute = navigationRoute;
                      },
                    );
                  },
                );
              } else if (sectionData.onGoingBookings.isNotEmpty) {
                //
                final Booking bookingData = sectionData.onGoingBookings[index];
                //

                return _getBookingDetailsCard(bookingDetailsData: bookingData);
              } else if (sectionData.previousBookings.isNotEmpty) {
                //
                final Booking bookingData = sectionData.previousBookings[index];
                //
                return _getBookingDetailsCard(bookingDetailsData: bookingData);
              }
              return const CustomSizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _getBookingDetailsCard({required Booking bookingDetailsData}) {
    return CustomContainer(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      color: Theme.of(context).colorScheme.primaryColor,
      borderRadius: borderRadiusOf10,
      width: MediaQuery.sizeOf(context).width * 0.9,
      child: BookingCardContainer(
        bookingDetails: bookingDetailsData,
      ),
    );
  }

  Widget _getCategoryItemsContainer(final List<CategoryModel> categoryList) => CustomSizedBox(
        height: 120,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => const CustomSizedBox(
            width: 10,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, final int index) {
            return CustomContainer(
              color: Theme.of(context).colorScheme.secondaryColor,
              borderRadius: borderRadiusOf10,
              // padding: const EdgeInsetsDirectional.all(5),
              margin: const EdgeInsets.only(top: 10),
              child: Center(
                child: ImageWithText(
                  imageURL: categoryList[index].categoryImage!,
                  title: categoryList[index].name!,
                  imageContainerHeight: 65,
                  imageContainerWidth: 65,
                  textContainerHeight: 30,
                  textContainerWidth: 65,
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
        ),
      );

  Widget _homeScreenShimmerLoading() => SingleChildScrollView(
        padding: EdgeInsets.only(bottom: getScrollViewBottomPadding(context)),
        child: Column(
          children: [
            _getSliderImageShimmerEffect(),
            _getCategoryShimmerEffect(),
            Column(
              children: List.generate(
                numberOfShimmerContainer,
                (final int index) => _getSingleSectionShimmerEffect(),
              ),
            )
          ],
        ),
      );

  Widget _getSliderImageShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        child: CustomShimmerLoadingContainer(
          width: MediaQuery.sizeOf(context).width,
          height: 170,
          borderRadius: borderRadiusOf10,
        ),
      );

  void _initialiseAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (currentSearchValueIndex.value != searchValues.length - 1) {
        currentSearchValueIndex.value += 1;
      } else {
        currentSearchValueIndex.value = 0;
      }
      _animationController.forward(from: 0.0);
    });
    //
    _animationController.forward();
  }
}
