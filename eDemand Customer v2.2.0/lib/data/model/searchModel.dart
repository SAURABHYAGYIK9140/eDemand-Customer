import 'package:e_demand/app/generalImports.dart';

class SearchModel {
  final List<Providers> providers;
  final List<Services> services;

  SearchModel({
    required this.providers,
    required this.services,
  });

  SearchModel copyWith({
    List<Providers>? providers,
    List<Services>? services,
  }) =>
      SearchModel(
        providers: providers ?? this.providers,
        services: services ?? this.services,
      );

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        providers: List<Providers>.from(json["providers"].map((x) => Providers.fromJson(x))),
        services: List<Services>.from(json["Services"].map((x) => Services.fromJson(x))),
      );
}
