import 'package:e_demand/app/generalImports.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  LanguageLoader(this.languageCode);

  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    final language = HiveRepository.getSelectedLanguageCode;
    if (language != "") {
      emit(LanguageLoader(language));
    } else {
      emit(LanguageLoadFail());
    }
  }

  Future<void> changeLanguage({
    required final String selectedLanguageCode,
    required final String selectedLanguageName,
  }) async {
     HiveRepository.setSelectedLanguageCode = selectedLanguageCode;
     HiveRepository.setSelectedLanguageName = selectedLanguageName;
   // await HiveRepository.putValuesOf(boxName: HiveRepository.languageBox, key: HiveRepository.currentLanguageCodeKey, value: selectedLanguageCode);
    //await HiveRepository.putValuesOf(boxName: HiveRepository.languageBox, key: HiveRepository.currentLanguageNameKey, value: selectedLanguageName);
    // await Hive.box(languageBox).put(currentLanguageCodeKey, selectedLanguageCode);
    // await Hive.box(languageBox).put(currentLanguageNameKey, selectedLanguageName);
    emit(LanguageLoader(selectedLanguageCode));
  }
}
