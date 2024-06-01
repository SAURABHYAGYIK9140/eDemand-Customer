// ignore_for_file: sized_box_for_whitespace, file_names

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomOnBoarding extends StatefulWidget {
  const CustomOnBoarding({
    required this.pageController,
    required this.heading,
    required this.body,
    required this.assetImagePath,
    required this.currentScreenNumber,
    required this.totalScreen,
    final Key? key,
    this.time = const Duration(seconds: 3),
  }) : super(key: key);
  final String assetImagePath;
  final String body;
  final int currentScreenNumber;
  final String heading;
  final PageController pageController;
  final Duration time;
  final int totalScreen;

  @override
  State<CustomOnBoarding> createState() => _CustomOnBoardingState();
}

class _CustomOnBoardingState extends State<CustomOnBoarding> with TickerProviderStateMixin {
  late final AnimationController _progressAnimationController =
      AnimationController(vsync: this, duration: widget.time)..forward();

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _progressAnimationController.addStatusListener((final AnimationStatus status) {
      if (status == AnimationStatus.completed && widget.currentScreenNumber != widget.totalScreen) {
        widget.pageController
            .nextPage(duration: const Duration(milliseconds: 400), curve: Curves.linear);
      }
      if (status == AnimationStatus.completed && widget.currentScreenNumber == widget.totalScreen) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (final route) => false,
          arguments: {"source": "introSliderScreen"},
        );
      }
    });
  }

  CustomContainer _buildDownToUpGradientContainer() => CustomContainer(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,

          gradient: LinearGradient(
            stops: const [0.1, 0.54],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),

      );

  CustomContainer _buildOnboardingBackgroundImage() => CustomContainer(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,

          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(widget.assetImagePath.getPngImage()),
          ),

      );

  CustomContainer _buildBottomContainer(final context) => CustomContainer(
        width: MediaQuery.sizeOf(context).width,
        constraints:
            BoxConstraints(minHeight: 100, maxHeight: MediaQuery.sizeOf(context).height * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    widget.heading.translate(context: context),

                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColors,

                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  CustomText(
                    widget.body.translate(context: context),
               color: AppColors.whiteColors, fontSize: 18,
                  ),

                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 15),
                child: CustomFlatButton(
                  backgroundColor: Theme.of(context).colorScheme.lightGreyColor,
                  width: 70,
                  height: 32,
                  text: '${widget.currentScreenNumber}-${widget.totalScreen}',
                ),
              ),
            ),
            const CustomSizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _progressAnimationController,
                builder: (BuildContext context, Widget? child) => LinearProgressIndicator(
                  backgroundColor: AppColors.whiteColors.withOpacity(0.5),
                  color: AppColors.whiteColors,
                  value: _progressAnimationController.value,
                  minHeight: 5,
                ),
              ),
            )
          ],
        ),
      );

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildOnboardingBackgroundImage(),
          _buildDownToUpGradientContainer(),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: 50,
            end: 15,
            child: CustomFlatButton(
              innerPadding: 10,
              text: "skip_here".translate(context: context),
              backgroundColor: Colors.grey.withOpacity(0.4),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (final route) => false,
                  arguments: {"source": "introSliderScreen"},
                );
              },
            ),
          ),
          Positioned.directional(
            bottom: 0,
            textDirection: Directionality.of(context),
            child: _buildBottomContainer(context),
          ),
        ],
      ),
    );
  }
}
