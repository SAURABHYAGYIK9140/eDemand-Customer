import 'package:e_demand/app/generalImports.dart';

class SubCategoryRepository {
  //
  ///This method is used to fetch subCategories
  Future<Map<String, dynamic>> fetchSubCategory(
      {required final bool isAuthTokenRequired, required final String categoryID,}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        Api.categoryId: categoryID,
        Api.longitude: HiveRepository.getLongitude,
        Api.latitude: HiveRepository.getLatitude,
      };

      final  result =
          await Api.post(url: Api.getSubCategories, parameter: parameters, useAuthToken: false);

      return {
        "subCategoryList": (result['data'] as List)
            .map((final subCategoryData) => SubCategory.fromJson(Map.from(subCategoryData)))
            .toList(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
