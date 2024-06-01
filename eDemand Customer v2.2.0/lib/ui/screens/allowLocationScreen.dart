import 'package:app_settings/app_settings.dart';
import 'package:e_demand/app/generalImports.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AllowLocationScreen extends StatefulWidget {
  const AllowLocationScreen({final Key? key}) : super(key: key);

  @override
  State<AllowLocationScreen> createState() => _AllowLocationScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) => const AllowLocationScreen(),
      );
}

class _AllowLocationScreenState extends State<AllowLocationScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _requestLocationPermission() {
    LocationRepository.requestPermission(
      allowed: (final Position position) {
        context.read<HomeScreenCubit>().fetchHomeScreenData();
        Navigator.pop(context);
//        Navigator.pushReplacementNamed(context, navigationRoute);
      },
      onRejected: () async {
        //open app setting for permission

        await AppSettings.openAppSettings();
        UiUtils.showMessage(context, 'Permission Rejected', MessageType.warning);
      },
      onGranted: (final Position position) async {
        context.read<HomeScreenCubit>().fetchHomeScreenData();
        Navigator.pop(context);

        //  await Navigator.pushReplacementNamed(context, navigationRoute);
      },
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(final AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if ((await Permission.location.status) == PermissionStatus.granted) {
        context.read<HomeScreenCubit>().fetchHomeScreenData();
        Navigator.pop(context);
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: false,
    //onWillPop: () async => false,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomSvgPicture(svgImage: "location_access"),
                const CustomSizedBox(height: 10),
                CustomText('permissionRequired'.translate(context: context)),
                const CustomSizedBox(height: 10),
                CustomRoundedButton(
                  widthPercentage: 0.8,
                  backgroundColor: Theme.of(context).colorScheme.accentColor,
                  buttonTitle: "useCurrentLocation".translate(context: context),
                  showBorder: true,
                  onTap: () {
                    _requestLocationPermission();
                  },
                ),
                const CustomSizedBox(height: 10),
                CustomRoundedButton(
                  widthPercentage: 0.8,
                  backgroundColor: Theme.of(context).colorScheme.accentColor,
                  buttonTitle: "manualLocation".translate(context: context),
                  showBorder: true,
                  onTap: () {
                    UiUtils.showBottomSheet(child: const LocationBottomSheet(), context: context)
                        .then((final value) {
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
                ),
              ],
            ),
          ),
        ),
      );
}
