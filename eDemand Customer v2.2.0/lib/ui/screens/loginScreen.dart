import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: file_names, use_build_context_synchronously

import '../../app/generalImports.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({required this.source, final Key? key}) : super(key: key);
  final String source;

  @override
  State<LogInScreen> createState() => _LogInScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (final _) => LogInScreen(
        source: arguments['source'],
      ),
    );
  }
}

class _LogInScreenState extends State<LogInScreen> {
  String phoneNumberWithCountryCode = "";
  String onlyPhoneNumber = "";
  String countryCode = "";

  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();
  final TextEditingController _numberFieldController = TextEditingController();

  @override
  void dispose() {
    _numberFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();

    final bool isvalidNumber = verifyPhoneNumberFormKey.currentState!.validate();

    if (isvalidNumber) {
      //
      final String countryCallingCode = context.read<CountryCodeCubit>().getSelectedCountryCode();
      //
      phoneNumberWithCountryCode = countryCallingCode + _numberFieldController.text;
      onlyPhoneNumber = _numberFieldController.text;
      countryCode = countryCallingCode;
//
//       context
//           .read<VerifyPhoneNumberCubit>()
//           .verifyPhoneNumber(phoneNumberWithCountryCode, onCodeSent: () {});\
      Navigator.pushNamed(
        context,
        otpVerificationRoute,
        arguments: {
          'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
          'phoneNumberWithOutCountryCode': onlyPhoneNumber,
          'countryCode': countryCode,
          'source': widget.source
        },
      );
    }
  }

  Padding _buildPhoneNumberFiled() => Padding(
    padding: const EdgeInsetsDirectional.only(top: 15, bottom: 60),
    child: MobileNumberFiled(controller: _numberFieldController),
  );

  Padding _buildSubHeading() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 25),
    child: Align(
      alignment: Alignment.centerLeft,
      child: CustomText(
        'login_or_signup'.translate(context: context),
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 16,
        textAlign: TextAlign.left,
      ),
    ),
  );

  Align _buildHeading() => Align(
    alignment: Alignment.centerLeft,
    child: // heading
    CustomText(
      'welcome_to_app'.translate(context: context),
      color: Theme.of(context).colorScheme.blackColor,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      fontSize: 28,
      textAlign: TextAlign.left,
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          surfaceTintColor: Theme.of(context).colorScheme.primaryColor,
          elevation: 0,
          leading: CustomSizedBox(),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 8),
              child: BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
                builder: (final context, final VerifyOtpState state) => CustomFlatButton(
                  width: 100,
                  fontColor: Theme.of(context).colorScheme.blackColor,
                  backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  text: 'skip_here'.translate(context: context),
                  onPressed: (state is PhoneNumberVerificationInProgress)
                      ? () {
                    UiUtils.showMessage(
                      context,
                      'verificationIsInProgress'.translate(context: context),
                      MessageType.warning,
                    );
                  }
                      : () async {
                    HiveRepository.setUserSkippedTheLoginBefore = true;
                    // await HiveRepository.putValuesOf(
                    //         boxName: HiveRepository.authStatusBoxKey,
                    //         key: HiveRepository.isUserSkippedLoginBeforeKey,
                    //         value: true);

                    //await Hive.box(authStatusBoxKey).put(isUserSkippedLoginBefore, true);
                    //
                    if (widget.source == 'dialog') {
                      Navigator.pop(context);
                    } else if (Routes.previousRoute == onBoardingRoute ||
                        Routes.previousRoute == splashRoute) {
                      await Navigator.pushReplacementNamed(context, navigationRoute);
                    } else if (Routes.previousRoute == navigationRoute) {
                      Navigator.pop(context);
                    } else {
                      await Navigator.pushReplacementNamed(context, navigationRoute);
                    }
                  },
                ),
              ),
            )
          ],
        ),
        body: Form(
          key: verifyPhoneNumberFormKey,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(28),
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeading(),
                    _buildSubHeading(),
                    _buildPhoneNumberFiled(),
                    const CustomSizedBox(),
                    _buildContinueButton(),
                  ],
                ),
                Positioned.directional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  textDirection: Directionality.of(context),
                  child: CustomSizedBox(
                    width: size.width,
                    child: Column(
                      children: [
                        CustomText(
                          "by_continue_agree".translate(context: context),
                          textAlign: TextAlign.center,
                          color: Theme.of(context).colorScheme.lightGreyColor,
                          fontSize: 16,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomInkWellContainer(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(appSettingsRoute, arguments: 'termsofservice');
                                },
                                child: CustomText(
                                  "terms_service".translate(context: context),
                                  color: Theme.of(context).colorScheme.blackColor,
                                  showUnderline: true,
                                ),
                              ),
                              CustomText(
                                " & ",
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              CustomInkWellContainer(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(appSettingsRoute, arguments: 'privacyAndPolicy');
                                },
                                child: CustomText(
                                  "privacyAndPolicy".translate(context: context),
                                  color: Theme.of(context).colorScheme.blackColor,
                                  showUnderline: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() => BlocConsumer<VerifyPhoneNumberCubit, VerifyPhoneNumberState>(
    listener: (final BuildContext context, final verifyPhoneNumberState) {
      if (verifyPhoneNumberState is SendVerificationCodeInProgress) {
        Navigator.pushNamed(
          context,
          otpVerificationRoute,
          arguments: {
            'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
            'phoneNumberWithOutCountryCode': onlyPhoneNumber,
            'countryCode': countryCode,
            'source': widget.source
          },
        );
      } else if (verifyPhoneNumberState is PhoneNumberVerificationFailure) {
        String errorMessage = '';

        errorMessage = findFirebaseError(context, verifyPhoneNumberState.error.code);
        UiUtils.showMessage(
            context, errorMessage.translate(context: context), MessageType.error);
      }
    },
    builder: (final BuildContext context, final VerifyPhoneNumberState verifyPhoneNumberState) {
      Widget? child;
      if (verifyPhoneNumberState is PhoneNumberVerificationInProgress) {
        child = CustomCircularProgressIndicator(
          color: AppColors.whiteColors,
        );
      }
      return CustomRoundedButton(
        height: 50,
        onTap: () async {
          if (verifyPhoneNumberState is PhoneNumberVerificationInProgress) {
            return;
          }
          _onContinueButtonClicked();
        },
        buttonTitle: 'continueText'.translate(context: context),
        widthPercentage: 0.9,
        backgroundColor: Theme.of(context).colorScheme.accentColor,
        showBorder: false,
        child: child,
      );
    },
  );
}