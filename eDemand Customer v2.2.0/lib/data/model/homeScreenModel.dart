import 'package:e_demand/data/model/categoryModel.dart';
import 'package:e_demand/data/model/sectionModel.dart';
import 'package:e_demand/data/model/sliderImagesModel.dart';

class HomeScreenModel {

  HomeScreenModel(this.sections, this.category, this.sliders);

  HomeScreenModel.fromJson(final Map<String?, dynamic> json) {

    if (json["sections"] != null) {
      sections = <Sections>[];
      json["sections"].forEach((final v) {

        sections!.add(Sections.fromJson(v));
      });
    }
    if (json["sliders"] != null) {
      sliders = <SliderImages>[];
      json["sliders"].forEach((final v) {
        sliders!.add(SliderImages.fromJson(v));
      });
    }
    if (json["categories"] != null) {
      category = <CategoryModel>[];
      json["categories"].forEach((final v) {
        category!.add(CategoryModel.fromJson(v));
      });
    }
  }
  List<Sections>? sections;
  List<CategoryModel>? category;
  List<SliderImages>? sliders;
}
