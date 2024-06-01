import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/shareProviderDetailsCubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({final Key? key}) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => CustomNavigationBarState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) => CustomNavigationBar(
          key: bottomNavigationBarGlobalKey,
        ),
      );
}

class CustomNavigationBarState extends State<CustomNavigationBar> {
  String? currentVersion;
  ValueNotifier<int> selectedIndexOfBottomNavigationBar = ValueNotifier(0);
  List<ScrollController> scrollControllerList = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      scrollControllerList.add(ScrollController());
    }
    Future.delayed(Duration.zero).then((final value) {
      context.read<ShareProviderDetailsCubit>().initializeDynamicLink(context: context);

      context.read<VerifyOtpCubit>().setInitialState();
      context.read<VerifyPhoneNumberCubit>().setInitialState();
    });
    fetchCurrentVersion();
  }

  Future<void> fetchCurrentVersion() async {
    try {
      currentVersion = await PackageInfo.fromPlatform().then((final value) => value.version);
    } catch (_) {}
  }

  @override
  void dispose() {
    selectedIndexOfBottomNavigationBar.dispose();
    for (int i = 0; i < 4; i++) {
      scrollControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: ValueListenableBuilder(
          valueListenable: selectedIndexOfBottomNavigationBar,
          builder: (final context, final Object? value, final Widget? child) => PopScope(
            onPopInvoked: (didPop) {
              if (!didPop) {
                selectedIndexOfBottomNavigationBar.value = 0;
                return;
              }
            },
            canPop: selectedIndexOfBottomNavigationBar.value == 0,
            child: Stack(
              children: [
                IndexedStack(
                  sizing: StackFit.passthrough,
                  index: selectedIndexOfBottomNavigationBar.value,
                  children: [
                    HomeScreen(scrollController: scrollControllerList[0]),
                    BookingsScreen(
                      key: bookingScreenGlobalKey,
                      scrollController: scrollControllerList[1],
                    ),
                    CategoryScreen(scrollController: scrollControllerList[2]),
                    Profile(
                      scrollController: scrollControllerList[3],
                      currentVersion: '1.0.0',
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBar(
                    backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                    selectedItemColor: Theme.of(context).colorScheme.accentColor,
                    unselectedItemColor: Theme.of(context).colorScheme.lightGreyColor,
                    selectedFontSize: 12,
                    currentIndex: selectedIndexOfBottomNavigationBar.value,
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    onTap: (final int selectedIndex) {
                      final previousSelectedIndex = selectedIndexOfBottomNavigationBar.value;
                      selectedIndexOfBottomNavigationBar.value = selectedIndex;
                      //animate scroll to top when pressing the item twice
                      if (previousSelectedIndex == selectedIndex &&
                          scrollControllerList[selectedIndex].positions.isNotEmpty) {
                        scrollControllerList[selectedIndex].animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                      //
                      if (HiveRepository.getUserToken == "" &&
                          selectedIndex == 1 &&
                          previousSelectedIndex != 1) {
                        UiUtils.showAnimatedDialog(
                            context: context, child: const LogInAccountDialog());
                      }
                    },
                    items: [
                      _getBottomNavigationBarItem(
                        activeImage: "active_explore",
                        deActiveImage: "explore",
                        title: 'explore'.translate(context: context),
                        index: 0,
                        currentIndex: selectedIndexOfBottomNavigationBar.value,
                      ),
                      _getBottomNavigationBarItem(
                        activeImage: "active_booking",
                        deActiveImage: "booking",
                        title: 'booking'.translate(context: context),
                        index: 1,
                        currentIndex: selectedIndexOfBottomNavigationBar.value,
                      ),
                      _getBottomNavigationBarItem(
                        activeImage: "active_category",
                        deActiveImage: "category",
                        title: 'category'.translate(context: context),
                        index: 2,
                        currentIndex: selectedIndexOfBottomNavigationBar.value,
                      ),
                      _getBottomNavigationBarItem(
                        activeImage: "active_profile",
                        deActiveImage: "profile",
                        title: 'profile'.translate(context: context),
                        index: 3,
                        currentIndex: selectedIndexOfBottomNavigationBar.value,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  BottomNavigationBarItem _getBottomNavigationBarItem({
    required final String activeImage,
    required final String deActiveImage,
    required final String title,
    required final int index,
    required final int currentIndex,
  }) =>
      BottomNavigationBarItem(
        icon: currentIndex == index
            ? CustomSvgPicture(
                svgImage: activeImage,
                color: Theme.of(context).colorScheme.accentColor,
              )
            : CustomSvgPicture(
                svgImage: deActiveImage,
              ),
        label: title,
      );
}
