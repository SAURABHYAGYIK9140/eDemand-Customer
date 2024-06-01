import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({final Key? key}) : super(key: key);

  @override
  State<LocationBottomSheet> createState() => CityBottomSheetState();
}

class CityBottomSheetState extends State<LocationBottomSheet> {
  final TextEditingController _searchLocation = TextEditingController();
  Timer? delayTimer;
  GooglePlaceAutocompleteCubit? cubitReference;
  int searchedTextLength = 0;
  ValueNotifier<int> previousSearchedTextLength = ValueNotifier(0);

  void _requestLocationPermission() {
    LocationRepository.requestPermission(
      allowed: (final Position position) {
        Navigator.pop(
          context,
          {
            'navigateToMap': true,
            "latitude": position.latitude.toString(),
            "longitude": position.longitude.toString()
          },
        );
      },
      onRejected: () async {

      },
      onGranted: (final Position position) async {
        Navigator.pop(
          context,
          {
            'navigateToMap': true,
            "latitude": position.latitude.toString(),
            "longitude": position.longitude.toString()
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchLocation.addListener(() {
      previousSearchedTextLength.value = _searchLocation.text.length;
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
        cubitReference?.clearCubit();
      } else if (_searchLocation.text.length >= 3) {
        if (delayTimer?.isActive ?? false) delayTimer?.cancel();

        delayTimer = Timer(const Duration(milliseconds: 500), () {
          if (_searchLocation.text.isNotEmpty) {
            if (_searchLocation.text.length != searchedTextLength) {
              context
                  .read<GooglePlaceAutocompleteCubit>()
                  .searchLocationFromPlacesAPI(text: _searchLocation.text);
              searchedTextLength = _searchLocation.text.length;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    cubitReference?.clearCubit();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReference = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
  }

  Widget getPlaceContainer({
    ///if it is from stored searched places then we will directly navigate to the Map and will not store again in the local data
    required bool isFromHistory,
    required String placeName,
    required String placeId,
    String? latitude,
    String? longitude,
  }) {
    return Column(
      children: [
        CustomInkWellContainer(
          onTap: () async {
            dynamic coOrdinates = null;

            if (!isFromHistory) {
              coOrdinates = await GooglePlaceRepository().getPlaceDetailsFromPlaceId(placeId);
              //
              HiveRepository.storePlaceInHive(
                placeId: placeId,
                placeName: placeName,
                longitude: coOrdinates['lng'].toString(),
                latitude: coOrdinates['lat'].toString(),
              );
            }
            //
            Future.delayed(Duration.zero, () {
              Navigator.pop(
                context,
                {
                  'navigateToMap': true,
                  "latitude": latitude ?? coOrdinates['lat'].toString(),
                  "longitude": longitude ?? coOrdinates['lng'].toString()
                },
              );
            });
          },
          child: Row(
            children: [
              CustomSizedBox(
                width: 35,
                height: 25,
                child: Icon(
                  Icons.location_city,
                  color: Theme.of(context).colorScheme.accentColor,
                ),
              ),
              const CustomSizedBox(
                width: 15,
              ),
              Expanded(
                child: CustomText(
                  placeName,

                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,

                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        const CustomDivider(),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => CustomContainer(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: BottomSheetLayout(
          title: 'selectLocation',
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomInkWellContainer(
                  onTap: () {
                    _requestLocationPermission();
                  },
                  borderRadius: BorderRadius.circular(borderRadiusOf10),
                  child: CustomContainer(
                    height: 35,
                    width: double.infinity,


                        borderRadius: borderRadiusOf10,
                        border: Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).colorScheme.accentColor),
                          const CustomSizedBox(width: 15),
                          CustomText(
                            "useCurrentLocation".translate(context: context),
                         color: Theme.of(context).colorScheme.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const CustomSizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  labelText: 'searchLocation'.translate(context: context),
                  hintText: 'enterLocationAreaCity'.translate(context: context),
                  controller: _searchLocation,
                  textInputType: TextInputType.text,
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: previousSearchedTextLength,
                    builder: (context, int value, child) {
                      return CustomInkWellContainer(
                        onTap: () {
                          delayTimer?.cancel();
                          cubitReference?.clearCubit();
                          _searchLocation.clear();
                        },
                        child: CustomContainer(
                          margin: const EdgeInsetsDirectional.only(end: 5),
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          child: value >= 1
                              ? Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.lightGreyColor,
                                )
                              : CustomSvgPicture(
                                  svgImage: 'search',
                                  height: 12,
                                  width: 12,
                                  color: Theme.of(context).colorScheme.blackColor,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<GooglePlaceAutocompleteCubit, GooglePlaceAutocompleteState>(
                  builder: (BuildContext context, googlePlaceState) {
                    if (googlePlaceState is GooglePlaceAutocompleteInitial) {
                      final List<Map> recentPlaces = HiveRepository.getStoredPlaces;

                      if (recentPlaces.isEmpty) return const CustomSizedBox();
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        CustomText(
                          "recentSearchedPlaces".translate(context: context),
                          maxLines: 1,

                              color: Theme.of(context).colorScheme.blackColor, fontSize: 14,
                        ),
                        const CustomSizedBox(
                          height: 10,
                        ),
                        CustomContainer(
                          constraints: BoxConstraints(
                              minHeight: 100, maxHeight: MediaQuery.sizeOf(context).height * 0.5),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: List.generate(
                                recentPlaces.length,
                                (index) => getPlaceContainer(
                                  isFromHistory: true,
                                  longitude: recentPlaces[index]["longitude"],
                                  latitude: recentPlaces[index]["latitude"],
                                  placeName: recentPlaces[index]["name"],
                                  placeId: recentPlaces[index]["placeId"],
                                ),
                              ),
                            ),
                          ),
                        )
                      ]);
                    }
                    if (googlePlaceState is GooglePlaceAutocompleteSuccess) {
                      if ((googlePlaceState.autocompleteResult.predictions ?? []).isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                                CustomText(
                                  "searchResults".translate(context: context),
                                  maxLines: 1,

                                      color: Theme.of(context).colorScheme.blackColor, fontSize: 14,
                                ),
                                const CustomSizedBox(
                                  height: 10,
                                ),
                              ] +
                              List.generate(
                                googlePlaceState.autocompleteResult.predictions!.length,
                                (index) {
                                  final Prediction placeData =
                                      googlePlaceState.autocompleteResult.predictions![index];
                                  return getPlaceContainer(
                                      isFromHistory: false,
                                      placeName: placeData.description ?? "",
                                      placeId: placeData.placeId ?? "");
                                },
                              ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:
                            Center(child: CustomText("noLocationFound".translate(context: context))),
                      );
                    }

                    if (googlePlaceState is GooglePlaceAutocompleteInProgress) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: CustomCircularProgressIndicator(
                            color: Theme.of(context).colorScheme.accentColor,
                          ),
                        ),
                      );
                    }
                    return const CustomSizedBox();
                  },
                )
              ],
            ),
          ),
        ),
      );
}
