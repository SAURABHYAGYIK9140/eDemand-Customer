import 'package:e_demand/app/generalImports.dart';

abstract class SearchServicesState {}

class SearchServicesInitialState extends SearchServicesState {}

class SearchServicesProgressState extends SearchServicesState {}

class SearchServicesFailureState extends SearchServicesState {
  final String errorMessage;

  SearchServicesFailureState({required this.errorMessage});
}

class SearchServicesSuccessState extends SearchServicesState {
  final List<Providers> providersWithServicesList;
  final int totalData;
  final bool isLoadingMore;
  final bool isLoadingMoreError;

  SearchServicesSuccessState({
    required this.providersWithServicesList,
    required this.totalData,
    required this.isLoadingMore,
    required this.isLoadingMoreError,
  });

  SearchServicesSuccessState copyWith({
    List<Providers>? providersWithServicesList,
    int? totalData,
    bool? isLoadingMore,
    bool? isLoadingMoreError,
  }) {
    return SearchServicesSuccessState(
        providersWithServicesList: providersWithServicesList ?? this.providersWithServicesList,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        totalData: totalData ?? this.totalData,
        isLoadingMoreError: isLoadingMoreError ?? this.isLoadingMoreError);
  }
}

class SearchServicesCubit extends Cubit<SearchServicesState> {
  final ServiceRepository _serviceRepository = ServiceRepository();

  SearchServicesCubit()
      : super(
          SearchServicesInitialState(),
        );

  Future<void> searchServices({required String searchString}) async {
    emit(SearchServicesProgressState());
    try {
      final Map<String, dynamic> data = await _serviceRepository.searchServicesWithProviders(
        offset: "0",
        searchText: searchString,
        isAuthTokenRequired: false,
        limit: "5",
      );
      return emit(SearchServicesSuccessState(
          totalData: int.parse((data["totalProvidersWithServices"] ?? 0).toString()),
          providersWithServicesList: data["providersWithServices"],
          isLoadingMore: false,
          isLoadingMoreError: false));
    } catch (e) {
      emit(
        SearchServicesFailureState(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> searchMoreServices({required String searchString}) async {
    if (state is SearchServicesSuccessState) {
      final stateAs = state as SearchServicesSuccessState;
      if (stateAs.isLoadingMore) {
        return;
      }
      try {
        emit(stateAs.copyWith(isLoadingMore: true));

        final Map<String, dynamic> moreServicesWithProvidersData =
            await _serviceRepository.searchServicesWithProviders(
                offset: stateAs.providersWithServicesList.length.toString(),
                isAuthTokenRequired: true,
                searchText: searchString,
                limit: "5");

        final List<Providers> servicesWithProvidersData = stateAs.providersWithServicesList;

        servicesWithProvidersData.addAll(moreServicesWithProvidersData['providersWithServices']);

        emit(
          SearchServicesSuccessState(
              isLoadingMore: false,
              isLoadingMoreError: false,
              totalData: stateAs.totalData,
              providersWithServicesList: servicesWithProvidersData),
        );
      } catch (e) {
        emit(
          (state as SearchServicesSuccessState).copyWith(isLoadingMoreError: true),
        );
      }
    }
  }

  bool hasMore() {
    if (state is SearchServicesSuccessState) {
      return (state as SearchServicesSuccessState).providersWithServicesList.length <
          (state as SearchServicesSuccessState).totalData;
    }
    return false;
  }
}
