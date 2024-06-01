import 'package:e_demand/cubits/fetchUserCurrentLocationCubit.dart';
import 'package:e_demand/ui/widgets/tooltipShapeBorder.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({
    final Key? key,
    required this.showAddressForm,
    this.addressDetails,
    required this.defaultLatitude,
    required this.defaultLongitude,
  }) : super(key: key);

  //
  final bool showAddressForm;
  final GetAddressModel? addressDetails;
  final String defaultLatitude;
  final String defaultLongitude;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map argument = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AddAddressCubit(),
          ),
          BlocProvider(
            create: (context) => FetchUserCurrentLocationCubit(),
          ),
          BlocProvider(
            create: (final context) =>
                CheckProviderAvailabilityCubit(providerRepository: ProviderRepository()),
          ),
        ],
        child: Builder(
          builder: (context) => GoogleMapScreen(
            showAddressForm: argument['showAddressForm'],
            addressDetails: argument['details'],
            defaultLatitude: argument["defaultLatitude"] ?? "0.0",
            defaultLongitude: argument["defaultLongitude"] ?? "0.0",
          ),
        ),
      ),
    );
  }
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
//

  //String lineOneAddress = "", lineTwoAddress = "";
  late CameraPosition initialCameraPosition;

  //
  ValueNotifier selectedAddress =
      ValueNotifier({"lineOneAddress": "", "lineTwoAddress": "", "selectedCity": ""});

  //
  double? selectedLatitude, selectedLongitude;

  late Marker initialLocation;

  final StreamController markerController = StreamController();
  final Completer<GoogleMapController> _controller = Completer();
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    //
    if (widget.showAddressForm) {
      Future.delayed(
        Duration.zero,
        () {
          context.read<FetchUserCurrentLocationCubit>().fetchUserCurrentLocation();
        },
      );
    }
    selectedLatitude = double.parse(widget.defaultLatitude);
    selectedLongitude = double.parse(widget.defaultLongitude);
    //
    initialLocation = Marker(
      markerId: const MarkerId("1"),
      position: LatLng(
          double.parse(selectedLatitude.toString()), double.parse(selectedLongitude.toString())),
      onTap: () {},
    );

    checkProviderAvailability(
      latitude: widget.defaultLatitude,
      longitude: widget.defaultLongitude,
    );
    //
    markerController.sink.add({
      Marker(
        markerId: const MarkerId("1"),
        position: LatLng(selectedLatitude!, selectedLongitude!),
        onTap: () {},
      )
    });

    initialCameraPosition =
        CameraPosition(zoom: 16, target: LatLng(selectedLatitude!, selectedLongitude!));

    createAddressFromCoOrdinates(
      selectedLatitude!,
      selectedLongitude!,
    );
  }

  Future<void> createAddressFromCoOrdinates(final double latitude, final double longitude) async {
    //
    _customInfoWindowController.hideInfoWindow?.call();
    //
    print("lat are $latitude lomg are $longitude");
    final List<Placemark> placeMark =
        await GeocodingPlatform.instance.placemarkFromCoordinates(latitude, longitude);
    final name = placeMark[0].name;
    final subLocality = placeMark[0].subLocality;
    final locality = placeMark[0].locality;
    final country = placeMark[0].country;
    final administrativeArea = placeMark[0].administrativeArea;
    final String? postalCode = placeMark[0].postalCode;

    selectedAddress.value = {
      "lineOneAddress": filterAddressString("$name,$subLocality,$locality,$country"),
      "lineTwoAddress": filterAddressString("$postalCode,$locality,$administrativeArea"),
      "selectedCity": locality
    };
  }

  Future<void> checkProviderAvailability({
    required final String latitude,
    required final String longitude,
  }) async {
    context.read<CheckProviderAvailabilityCubit>().checkProviderAvailability(
          isAuthTokenRequired: false,
          checkingAtCheckOut: "0",
          latitude: latitude,
          longitude: longitude,
        );
  }

  Future<void> _placeMarkerOnLatitudeAndLongitude(
      {required final double latitude, required final double longitude}) async {
    //
    selectedLatitude = latitude;
    selectedLongitude = longitude;
    //
    //
    final latLong = LatLng(latitude, longitude);
    final Marker marker = Marker(
      markerId: const MarkerId("1"),
      position: latLong,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(_infoWindowContainer(), latLong);
      },
    );
    markerController.sink.add({marker});

    final GoogleMapController controller = await _controller.future;

    final newCameraPosition =
        CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: latLong));
    await controller.animateCamera(newCameraPosition).then((value) async {
      await checkProviderAvailability(
          latitude: selectedLatitude.toString(), longitude: selectedLongitude.toString());

      await createAddressFromCoOrdinates(selectedLatitude!, selectedLongitude!);
    });
    //
  }

  Container _infoWindowContainer() => Container(
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.blackColor,
          shape: const TooltipShapeBorder(radius: 10),
          shadows: const [BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              'yourServiceWillHere'.translate(context: context),
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondaryColor,
            ),
            CustomText(
              'movePinToLocation'.translate(context: context),
              fontSize: 10,
              color: Theme.of(context).colorScheme.lightGreyColor,
            )
          ],
        ),
      );

  void _showAddressSheet(
    final BuildContext context,
  ) {
    UiUtils.showBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        child: CustomContainer(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: BlocProvider.value(
            value: context.read<AddAddressCubit>(),
            child: Builder(
              builder: (final context) {
                final String userMobileNumber = "${HiveRepository.getUserMobileNumber}";
                final String selectedCity = selectedAddress.value["selectedCity"];
                return AddressSheet(
                  addressDataModel: AddressModel(
                      latitude: selectedLatitude.toString(),
                      longitude: selectedLongitude.toString(),
                      addressId: widget.addressDetails?.id,
                      address: widget.addressDetails?.address,
                      mobile: widget.addressDetails?.mobile ?? userMobileNumber,
                      area: widget.addressDetails?.area,
                      cityName: widget.addressDetails?.cityName ?? selectedCity,
                      type: widget.addressDetails?.type ?? "",
                      isDefault: widget.addressDetails?.isDefault ?? "0"),
                  isUpdateAddress: widget.addressDetails == null ? false : true,
                  addressId: widget.addressDetails == null ? null : widget.addressDetails!.id,
                );
              },
            ),
          ),
        ));
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'selectLocation'.translate(context: context),
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        ),
        body: WillPopScope(
          onWillPop: () async =>
              Future.delayed(const Duration(milliseconds: 1000)).then((final value) => true),
          child: StreamBuilder(
            stream: markerController.stream,
            initialData: {initialLocation},
            builder: (context, AsyncSnapshot snapshot) =>
                BlocListener<AddAddressCubit, AddAddressState>(
              listener: (final BuildContext context, AddAddressState state) {
                if (state is AddAddressSuccess) {
                  if (snapshot.hasData) {
                    final position = snapshot.data.elementAt(0).position;

                    HiveRepository.setLongitude = position.longitude;
                    HiveRepository.setLatitude = position.latitude;
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(widget.addressDetails == null ? null : true);
                }
              },
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    markers: Set.of(snapshot.data),
                    onTap: (final LatLng position) async {
                      print("position is ${position.longitude} \n ${position.latitude}");
                      _placeMarkerOnLatitudeAndLongitude(
                          longitude: position.longitude, latitude: position.latitude);
                      //_onTapGoogleMap(position);
                    },
                    onCameraMove: (final position) {
                      _customInfoWindowController.onCameraMove!();
                    },
                    onMapCreated: (GoogleMapController controller) async {
                      if (context.read<AppThemeCubit>().state.appTheme == AppTheme.dark) {
                        await controller.setMapStyle(
                          await rootBundle.loadString("assets/mapTheme/darkMap.json"),
                        );
                        setState(() {});
                      }
                      _controller.complete(controller);
                      _customInfoWindowController.googleMapController = controller;
                    },
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    initialCameraPosition: initialCameraPosition,
                  ),
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 60,
                    width: 185,
                    offset: 48,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.bottomEnd,
                            child: CustomContainer(
                              margin: const EdgeInsets.all(20),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  color: Theme.of(context).colorScheme.blackColor.withOpacity(0.2),
                                )
                              ],
                              child: CustomInkWellContainer(
                                onTap: () {
                                  context
                                      .read<FetchUserCurrentLocationCubit>()
                                      .fetchUserCurrentLocation();
                                },
                                child: BlocConsumer<FetchUserCurrentLocationCubit,
                                    FetchUserCurrentLocationState>(
                                  listener: (context, state) {
                                    if (state is FetchUserCurrentLocationSuccess) {
                                      _placeMarkerOnLatitudeAndLongitude(
                                        latitude: state.position.latitude,
                                        longitude: state.position.longitude,
                                      );
                                    } else if (state is FetchUserCurrentLocationFailure) {
                                      UiUtils.showMessage(
                                          context,
                                          state.errorMessage.translate(context: context),
                                          MessageType.error);
                                    }
                                  },
                                  builder: (context, state) {
                                    Widget? child;
                                    if (state is FetchUserCurrentLocationInProgress) {
                                      child = CustomCircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.blackColor,
                                      );
                                    }
                                    return CustomContainer(
                                      color: Theme.of(context).colorScheme.secondaryColor,
                                      borderRadius: borderRadiusOf50,
                                      width: 60,
                                      height: 60,
                                      child: child ??
                                          Icon(
                                            Icons.my_location_outlined,
                                            size: 35,
                                            color: Theme.of(context).colorScheme.blackColor,
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          BlocBuilder<CheckProviderAvailabilityCubit,
                              CheckProviderAvailabilityState>(
                            builder: (final context, final checkProviderAvailabilityState) {
                              if (checkProviderAvailabilityState
                                  is CheckProviderAvailabilityFetchSuccess) {
                                return BlocBuilder<AddAddressCubit, AddAddressState>(
                                  builder:
                                      (final BuildContext context, final AddAddressState state) =>
                                          CustomContainer(
                                    height: 150,
                                    width: MediaQuery.sizeOf(context).width,
                                    padding: const EdgeInsets.only(top: 10),
                                    color: Theme.of(context).colorScheme.secondaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, -5),
                                        blurRadius: 4,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor
                                            .withOpacity(0.2),
                                      )
                                    ],
                                    borderRadiusStyle: const BorderRadius.only(
                                      topLeft: Radius.circular(borderRadiusOf20),
                                      topRight: Radius.circular(borderRadiusOf20),
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: selectedAddress,
                                      builder: (context, value, child) {
                                        value as Map;
                                        return Column(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    CustomSvgPicture(
                                                      svgImage: "current_location",
                                                      height: 20,
                                                      width: 20,
                                                      color:
                                                          Theme.of(context).colorScheme.blackColor,
                                                    ),
                                                    const CustomSizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          if (checkProviderAvailabilityState
                                                              .error) ...[
                                                            CustomText(
                                                              "serviceNotAvailableAtSelectedLocation"
                                                                  .translate(context: context),
                                                              maxLines: 1,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.normal,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .blackColor,
                                                            )
                                                          ] else ...[
                                                            CustomText(
                                                              value["lineOneAddress"] ?? "",
                                                              maxLines: 1,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .blackColor,
                                                            ),
                                                            const CustomSizedBox(
                                                              height: 5,
                                                            ),
                                                            CustomText(
                                                              value["lineTwoAddress"],
                                                              maxLines: 1,
                                                              fontSize: 14,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .lightGreyColor,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (!checkProviderAvailabilityState.error)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 12,
                                                ),
                                                child: CustomRoundedButton(
                                                  onTap: () {
                                                    if (context
                                                            .read<FetchUserCurrentLocationCubit>()
                                                            .state
                                                        is FetchUserCurrentLocationInProgress) {
                                                      return;
                                                    }
                                                    if (widget.showAddressForm) {
                                                      //complete address button click
                                                      _showAddressSheet(
                                                        context,
                                                      );
                                                    } else {
                                                      //confirm address button click
                                                      HiveRepository.setLocationName =
                                                          value["lineOneAddress"];
                                                      HiveRepository.setLongitude =
                                                          selectedLongitude;
                                                      HiveRepository.setLatitude = selectedLatitude;

                                                      Future.delayed(Duration.zero, () {
                                                        context
                                                            .read<HomeScreenCubit>()
                                                            .fetchHomeScreenData();
                                                        //
                                                        if (Routes.previousRoute ==
                                                            allowLocationScreenRoute) {
                                                          Navigator.popUntil(
                                                            context,
                                                            (final Route route) => route.isFirst,
                                                          );
                                                        } else {
                                                          Navigator.of(context)
                                                              .pushNamedAndRemoveUntil(
                                                            navigationRoute,
                                                            (final route) => false,
                                                          );
                                                        }
                                                      });
                                                    }
                                                  },
                                                  widthPercentage: 1,
                                                  backgroundColor: (context
                                                              .watch<FetchUserCurrentLocationCubit>()
                                                              .state
                                                          is FetchUserCurrentLocationInProgress)
                                                      ? Theme.of(context).colorScheme.lightGreyColor
                                                      : Theme.of(context).colorScheme.accentColor,
                                                  buttonTitle: (widget.showAddressForm
                                                          ? 'completeAddress'
                                                          : "confirmAddress")
                                                      .translate(context: context),
                                                  showBorder: false,
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                              return CustomContainer(
                                height: 150,
                                width: MediaQuery.sizeOf(context).width,
                                color: Theme.of(context).colorScheme.secondaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, -5),
                                    blurRadius: 4,
                                    color:
                                        Theme.of(context).colorScheme.blackColor.withOpacity(0.2),
                                  )
                                ],
                                borderRadiusStyle: const BorderRadius.only(
                                  topLeft: Radius.circular(borderRadiusOf20),
                                  topRight: Radius.circular(borderRadiusOf20),
                                ),
                                child: Center(
                                  child: (checkProviderAvailabilityState
                                          is CheckProviderAvailabilityFetchFailure)
                                      ? CustomText("somethingWentWrong".translate(context: context))
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomShimmerLoadingContainer(
                                              height: 10,
                                              width: MediaQuery.sizeOf(context).width * 0.9,
                                              borderRadius: borderRadiusOf10,
                                            ),
                                            const CustomSizedBox(
                                              height: 10,
                                            ),
                                            CustomShimmerLoadingContainer(
                                              height: 10,
                                              width: MediaQuery.sizeOf(context).width * 0.9,
                                              borderRadius: borderRadiusOf10,
                                            ),
                                            const CustomSizedBox(
                                              height: 10,
                                            ),
                                            CustomShimmerLoadingContainer(
                                              height: 10,
                                              width: MediaQuery.sizeOf(context).width * 0.9,
                                              borderRadius: borderRadiusOf10,
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: CustomInkWellContainer(
                      onTap: () {
                        UiUtils.showBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          useSafeArea: true,
                          child: const LocationBottomSheet(),
                          context: context,
                        ).then((final value) {
                          if (value != null) {
                            if (value['navigateToMap']) {
                              _placeMarkerOnLatitudeAndLongitude(
                                latitude: double.parse(value['latitude'].toString()),
                                longitude: double.parse(value['longitude'].toString()),
                              );
                            }
                          }
                        });
                      },
                      child: CustomContainer(
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.all(15),
                        height: 50,
                        color: Theme.of(context).colorScheme.secondaryColor,
                        borderRadius: borderRadiusOf10,
                        border: Border.all(color: Theme.of(context).colorScheme.blackColor),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: CustomText('searchLocation'.translate(context: context),
                                  color: Theme.of(context).colorScheme.lightGreyColor),
                            ),
                            Expanded(
                              child: CustomSvgPicture(
                                svgImage: 'search',
                                color: Theme.of(context).colorScheme.accentColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    markerController.close();
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
