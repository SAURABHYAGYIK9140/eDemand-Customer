import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';

String? isValidMobileNumber({required final String number, required final BuildContext context}) {
  if (number.isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  } else if (number.length < minimumMobileNumberDigit || number.length > maximumMobileNumberDigit) {
    return "mobileNumberShouldBeBetween6And15Numbers".translate(context: context);
  }

  return null;
}

String? isValidEmail({required final String email, required BuildContext context}) {
  if (RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(email)) {
    return null;
  }
  return "pleaseEnterValidEmail".translate(context: context);
}

String? isTextFieldEmpty({required final String? value, required final BuildContext context}) {
  if (value!.isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  }

  return null;
}

/// Replace extra coma from String
///
String filterAddressString(String text) {
  const String middleDuplicateComaRegex = ',(.?),';
  const String leadingAndTrailingComa = r'(^,)|(,$)';
  final RegExp removeComaFromString = RegExp(
    middleDuplicateComaRegex,
    caseSensitive: false,
    multiLine: true,
  );

  final RegExp leadingAndTrailing = RegExp(
    leadingAndTrailingComa,
    multiLine: true,
    caseSensitive: false,
  );

  final String filteredText =
      text.trim().replaceAll(removeComaFromString, ",").replaceAll(leadingAndTrailing, "");

  return filteredText;
}
