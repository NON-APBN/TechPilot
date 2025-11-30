import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('id')); // Default to Indonesian

  void toggleLanguage() {
    if (state.languageCode == 'id') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('id'));
    }
  }

  void setLanguage(Locale locale) {
    emit(locale);
  }
}
