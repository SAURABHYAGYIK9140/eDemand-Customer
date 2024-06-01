import 'package:e_demand/app/generalImports.dart';

//State
abstract class FandqsState {}

class FaqsInitial extends FandqsState {}

class FaqsFetchInProgress extends FandqsState {}

class FaqsFetchSuccess extends FandqsState {
  FaqsFetchSuccess(
      {required this.totalFaqCount,
      required this.isLoadingMoreFaqs,
      required this.isLoadingMoreError,
      required this.faqsList});

  final List<Faqs> faqsList;
  final int totalFaqCount;
  final bool isLoadingMoreFaqs;
  final bool isLoadingMoreError;

  FaqsFetchSuccess copyWith({
    final List<Faqs>? faqsList,
    final int? totalFaqCount,
    final bool? isLoadingMoreFaqs,
    final bool? isLoadingMoreError,
  }) =>
      FaqsFetchSuccess(
        isLoadingMoreFaqs: isLoadingMoreFaqs ?? this.isLoadingMoreFaqs,
        isLoadingMoreError: isLoadingMoreError ?? this.isLoadingMoreError,
        totalFaqCount: totalFaqCount ?? this.totalFaqCount,
        faqsList: faqsList ?? this.faqsList,
      );
}

class FaqsFetchFailure extends FandqsState {
  FaqsFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class FandqsCubit extends Cubit<FandqsState> {
  FandqsCubit(this.faqsRepository) : super(FaqsInitial());
  SystemRepository faqsRepository;

  Future<void> fetchFAQs() async {
    try {
      emit(FaqsFetchInProgress());

      final Map<String, dynamic> parameter = {Api.limit: limitOfAPIData, Api.offset: 0};

      final Map<String, dynamic> fAndQData = await faqsRepository.getFAndQ(parameter: parameter);
      //
      emit(FaqsFetchSuccess(
          isLoadingMoreFaqs: false,
          isLoadingMoreError: false,
          faqsList: fAndQData['fAndQData'],
          totalFaqCount: fAndQData["totalFaqs"]));
    } catch (e) {
      emit(FaqsFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMoreFAndQs() async {
    final FaqsFetchSuccess currentState = state as FaqsFetchSuccess;
    try {
      //
      final List<Faqs> faqsOldData = currentState.faqsList;
      //
      if (currentState.isLoadingMoreFaqs) {
        return;
      }
      //
      emit(currentState.copyWith(isLoadingMoreFaqs: true));
      //
      final Map<String, dynamic> parameter = {
        Api.limit: limitOfAPIData,
        Api.offset: faqsOldData.length
      };
      //
      final Map<String, dynamic> fAndQData = await faqsRepository.getFAndQ(parameter: parameter);
      //
      faqsOldData.addAll(fAndQData["fAndQData"]);
      //
      emit(
        currentState.copyWith(
          faqsList: faqsOldData,
          isLoadingMoreFaqs: false,
        ),
      );
    } catch (error) {
      emit(
        currentState.copyWith(
          isLoadingMoreFaqs: false,
          isLoadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreFAndQs() {
    if (state is FaqsFetchSuccess) {
      return (state as FaqsFetchSuccess).faqsList.length <
          (state as FaqsFetchSuccess).totalFaqCount;
    }
    return false;
  }
}
