// ignore_for_file: file_names

import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/searchServicesWithProvidersCubit.dart';
import 'package:e_demand/ui/screens/search/widgets/providerListWidget.dart';
import 'package:e_demand/ui/screens/search/widgets/servicesListWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({final Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider<SearchProviderCubit>(
              create: (final context) => SearchProviderCubit(ProviderRepository()),
            ),
            BlocProvider<SearchServicesCubit>(
              create: (final context) => SearchServicesCubit(),
            ),
          ],
          child: const SearchScreen(),
        ),
      );
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  // search provider controller
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _providerScrollController = ScrollController();
  final ScrollController _serviceScrollController = ScrollController();
  late TabController _tabController = TabController(length: 2, vsync: this);
  List<String> tabs = ["services", "providers"]; //give delay to live search
  Timer? delayTimer;
  ValueNotifier<bool> hasValuesInTextField = ValueNotifier(false);

  //to check length of search text
  int previousLength = 0;

  ///
  @override
  void initState() {
    super.initState();
    //listen to search text change to  fetch data
    _searchController.addListener(searchListener);
    _providerScrollController.addListener(searchMoreProviders);
    _serviceScrollController.addListener(searchMoreServices);
  }

  //
  void searchListener() {
    if (_searchController.text.isEmpty) {
      delayTimer?.cancel();
      hasValuesInTextField.value = false;
    }

    if (delayTimer?.isActive ?? false) delayTimer?.cancel();

    delayTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        hasValuesInTextField.value = true;

        if (_searchController.text.length != previousLength) {
          searchProviders();
          searchServices();
          previousLength = _searchController.text.length;
        }
      }
    });
  }

  void searchProviders() {
    context
        .read<SearchProviderCubit>()
        .searchProvider(searchKeyword: _searchController.text.trim().toString());
  }

  //
  void searchServices() {
    context
        .read<SearchServicesCubit>()
        .searchServices(searchString: _searchController.text.trim().toString());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _providerScrollController.dispose();
    _serviceScrollController.dispose();
    delayTimer?.cancel();
    _tabController.dispose();
    hasValuesInTextField.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: AppBar(
            leading: CustomInkWellContainer(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: CustomSvgPicture(
                  svgImage: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                      ? Directionality.of(context)
                              .toString()
                              .contains(TextDirection.RTL.value.toLowerCase())
                          ? "back_arrow_dark_ltr"
                          : "back_arrow_dark"
                      : Directionality.of(context)
                              .toString()
                              .contains(TextDirection.RTL.value.toLowerCase())
                          ? "back_arrow_light_ltr"
                          : "back_arrow_light",
                  color: Theme.of(context).colorScheme.accentColor,
                ),
              ),
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: CustomSizedBox(
                height: 35,
                child: TextField(
                  autofocus: true,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.blackColor),
                  controller: _searchController,
                  cursorColor: Theme.of(context).colorScheme.blackColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 2, left: 15),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryColor,
                    hintText: 'startTyping'.translate(context: context),
                    hintStyle:
                        TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.blackColor),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(borderRadiusOf10)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(borderRadiusOf10)),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(Radius.circular(borderRadiusOf10)),
                    ),
                    suffixIcon: ValueListenableBuilder(
                        valueListenable: hasValuesInTextField,
                        builder: (context, bool value, child) {
                          if (value) {
                            return CustomInkWellContainer(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                            );
                          }
                          return CustomContainer(
                            padding: const EdgeInsets.all(10),
                            child: CustomSvgPicture(
                              svgImage: 'search',
                              height: 12,
                              width: 12,
                              color: Theme.of(context).colorScheme.blackColor,
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          ),
          body: Column(
            children: [
              CustomContainer(
                color: Theme.of(context).colorScheme.secondaryColor,
                height: 50,
                width: MediaQuery.sizeOf(context).width,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).colorScheme.accentColor,
                      unselectedLabelColor: Theme.of(context).colorScheme.lightGreyColor,
                      labelColor: Theme.of(context).colorScheme.accentColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.only(bottom: 5),
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.only(bottom: 10),
                      tabs: tabs
                          .map((e) => Tab(
                                text: e.translate(context: context),
                              ))
                          .toList()),
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  ServicesListWidget(
                    onTapRetry: () => searchServices(),
                    onErrorButtonPressed: () => searchMoreServices(),
                    servicesScrollController: _serviceScrollController,
                  ),
                  ProviderListWidget(
                    onTapRetry: () => searchProviders(),
                    onErrorButtonPressed: () => searchMoreProviders(),
                    providerScrollController: _providerScrollController,
                  ),
                ]),
              ),
            ],
          ),
        ),
      );

  void searchMoreProviders() {
    if (!context.read<SearchProviderCubit>().hasMoreProviders()) {
      return;
    }

// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger = 0.7 * _providerScrollController.position.maxScrollExtent;

// _providerScrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_providerScrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context
            .read<SearchProviderCubit>()
            .searchMoreProvider(searchKeyword: _searchController.text.trim());
      }
    }
  }

  void searchMoreServices() {
    if (!context.read<SearchServicesCubit>().hasMore()) {
      return;
    }

// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger = 0.7 * _serviceScrollController.position.maxScrollExtent;

// _serviceScrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_serviceScrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context
            .read<SearchServicesCubit>()
            .searchMoreServices(searchString: _searchController.text.trim());
      }
    }
  }
}
