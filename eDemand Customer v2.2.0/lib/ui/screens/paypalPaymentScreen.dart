// ignore_for_file: void_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/generalImports.dart';

class PayPalPaymentScreen extends StatefulWidget {
  const PayPalPaymentScreen({required this.paymentUrl, final Key? key}) : super(key: key);
  final String paymentUrl;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => PayPalPaymentScreen(paymentUrl: arguments['paymentURL']),
    );
  }

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {


  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      UiUtils.showMessage(
        context,
        "doNotPressBackWhilePaymentAndDoubleTapBackButtonToExit".translate(context: context),
        MessageType.warning,
      );

      return Future.value(false);
    }
    Navigator.pop(context, {"paymentStatus": "Failed"});
    return Future.value(true);
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
              leading: CustomInkWellContainer(
                onTap: () async {
                  final DateTime now = DateTime.now();
                  if (currentBackPressTime == null ||
                      now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
                    currentBackPressTime = now;
                    UiUtils.showMessage(
                      context,
                      'doNotPressBackWhilePaymentAndDoubleTapBackButtonToExit'
                          .translate(context: context),
                      MessageType.warning,
                    );

                    return Future.value(false);
                  }
                  Navigator.pop(context, {'paymentStatus': 'Failed'});
                  return Future.value(true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: CustomSvgPicture(svgImage:
                      context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                          ? Directionality.of(context)
                                  .toString()
                                  .contains(TextDirection.RTL.value.toLowerCase())
                              ? "back_arrow_dark_ltr"
                              : "back_arrow_dark"
                          : Directionality.of(context)
                                  .toString()
                                  .contains(TextDirection.RTL.value.toLowerCase())
                              ? "back_arrow_light_ltr"
                              : "back_arrow_light",
                    ),
                  ),
                ),
              ),
              title:
                  CustomText(appName,  color: Theme.of(context).colorScheme.blackColor),
              centerTitle: true,
              elevation: 1,
              backgroundColor: Theme.of(context).colorScheme.secondaryColor,
              surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            ),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(Theme.of(context).colorScheme.primaryContainer)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (final progress) {
                      // Update loading bar.
                    },
                    onPageStarted: (final url) {},
                    onPageFinished: (String url) {},
                    onWebResourceError: (final WebResourceError error) {},
                    onNavigationRequest: (final request) {
                      if (request.url.startsWith("${baseUrl}app_payment_status")) {
                        final url = request.url;
                        if (url.contains('payment_status=Completed')) {
                          Navigator.pop(context, {'paymentStatus': 'Completed'});
                        } else if (url.contains('payment_status=Failed')) {
                          Navigator.pop(context, {'paymentStatus': 'Failed'});
                        }
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  ),
                )
                ..loadRequest(Uri.parse(widget.paymentUrl)),
            ),
          ),
        ),
      );

}
