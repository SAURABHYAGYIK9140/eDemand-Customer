// ignore_for_file: unused_local_variable

import 'package:e_demand/app/generalImports.dart';

class LocationRepository {
  //
  static Future<Position> getLocationDataAndStoreIntoHive() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    final List<Placemark> placeMark = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);

    final String address = filterAddressString(
      "${placeMark[0].name},${placeMark[0].subLocality},${placeMark[0].locality},${placeMark[0].country}",
    );

    HiveRepository.setLongitude = position.longitude;
    HiveRepository.setLatitude = position.latitude;
    HiveRepository.setLocationName = address;
    return position;
  }

  static Future<void> requestPermission({
    ///if permission is allowed recently then onGranted method will invoke,
    final Function(Position position)? onGranted,

    ///if permission is rejected  then onRejected method will invoke,
    final Function()? onRejected,

    ///if permission is allowed already then allowed method will invoke,
    final Function(Position position)? allowed,
  }) async {
    //
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      //
      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        //
        final Position position = await getLocationDataAndStoreIntoHive();
        onGranted?.call(position);
      } else {
/*        HiveRepository.setLongitude = "0.0";
        HiveRepository.setLatitude = "0.0";*/
        onRejected?.call();
      }
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final Position position = await getLocationDataAndStoreIntoHive();
      allowed?.call(position);
    } else if (permission == LocationPermission.deniedForever) {}
  }

  static Future getCurrentLocationAndStoreDataIntoHive() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final Position position = await getLocationDataAndStoreIntoHive();
      //
      final List<Placemark> placeMark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      //
      return placeMark;
    }
  }

  static Future<Position?> getCurrentLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    //
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } else if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      await requestPermission(
        allowed: (position) {
          return position;
        },
        onGranted: (position) {
          return position;
        },
        onRejected: () {
          return null;
        },
      );
    }
    return null;
  }


}
