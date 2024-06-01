import 'package:dio/dio.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:path/path.dart' as p;

class UserRepository {
  Future<Map<String, dynamic>> updateUserDetails(final UpdateUserDetails model) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.username: model.username,
        Api.mobile: model.phone,
        Api.countryCode: model.countryCode,
        Api.email: model.email,
      };

      if (model.image != "") {
        final mimeType = lookupMimeType(model.image!.path);
        final extension = mimeType!.split("/");

        parameter[Api.image] = await MultipartFile.fromFile(
          model.image!.path,
          filename: p.basename(model.image!.path),
          contentType: MediaType('image', extension[1]),
        );
      }

      final Map<String, dynamic> response =
          await Api.post(url: Api.updateUser, parameter: parameter, useAuthToken: true);

      if (response['error']) {
        throw ApiException(response['message'].toString());
      }
      // await HiveRepository.putAllValue(boxName: HiveRepository.userDetailBoxKey, values: {
      //   HiveRepository.userNameKey: response['data']["username"],
      //   HiveRepository.countryCodeKey: response['data']["country_code"],
      //   HiveRepository.profileImageKey: response['data']["image"],
      //   HiveRepository.phoneNumberKey: response['data']["phone"],
      //   HiveRepository.emailIdKey: response['data']["email"]
      // });
      HiveRepository.setUsername = response['data']["username"];
      HiveRepository.setUserMobileCountryCode = response['data']["country_code"];
      HiveRepository.setUserProfilePictureURL = response['data']["image"];
      HiveRepository.setUserMobileNumber = response['data']["phone"];
      HiveRepository.setUserEmailId = response['data']["email"];
      //await Hive.box(userDetailBoxKey).putAll();
      return {
        "data": response['data'],
        'message': response['message'].toString(),
        "error": response['error'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future updateFCM({
    required final String fcmId,
    required final String platform,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        Api.fcmId: fcmId,
        Api.platform: platform
      };

      await Api.post(url: Api.updateFCM, parameter: parameters, useAuthToken: true);
      //
    } catch (_) {
      //
    }
  }
}
