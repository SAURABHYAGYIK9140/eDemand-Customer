import 'package:e_demand/app/generalImports.dart';

class CategoryRepository {
  //
  ///This method is used to fetch categories
  Future fetchCategory({final int? limitOfAPIData, final int? offset}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        Api.longitude: HiveRepository.getLongitude,
        // HiveRepository.getLongitude,
        Api.latitude: HiveRepository.getLatitude
        
      };
      final result =
          await Api.post(parameter: parameters, url: Api.getCategories, useAuthToken: false);

      return (result['data'] as List)
          .map((final e) => CategoryModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
