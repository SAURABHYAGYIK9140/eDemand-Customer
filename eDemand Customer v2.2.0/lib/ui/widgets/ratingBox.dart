import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class RatingBox extends StatelessWidget {
  final String averageRating;
  final String totalNumberOfRatings;
  final String totalNumberOfFiveStarRating;
  final String totalNumberOfFourStarRating;
  final String totalNumberOfThreeStarRating;
  final String totalNumberOfTwoStarRating;
  final String totalNumberOfOneStarRating;

  const RatingBox(
      {final Key? key,
      required this.averageRating,
      required this.totalNumberOfRatings,
      required this.totalNumberOfFiveStarRating,
      required this.totalNumberOfFourStarRating,
      required this.totalNumberOfThreeStarRating,
      required this.totalNumberOfTwoStarRating,
      required this.totalNumberOfOneStarRating,})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => CustomContainer(
        height: 175,

          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: borderRadiusOf10,

        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryColor,
                    radius: 35,
                    child: CustomText(
                      double.parse(averageRating).toStringAsFixed(1),

                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w600,

                    ),
                  ),
                  const CustomSizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (final int index) {
                      final double starRating = double.parse(averageRating);
                      if (index < starRating) {
                        return Icon(
                          Icons.star,
                          color: AppColors.ratingStarColor,
                        );
                      }
                      return Icon(Icons.star, color: Theme.of(context).colorScheme.lightGreyColor);
                    }),
                  ),
                  const CustomSizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text: totalNumberOfRatings,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: " ${"reviews".translate(context: context)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.lightGreyColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            VerticalDivider(
              indent: 15,
              endIndent: 15,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ratingProgressBar(
                    context,
                    '5',
                    totalNumberOfRatings != '0'
                        ? int.parse(totalNumberOfFiveStarRating) / int.parse(totalNumberOfRatings)
                        : 0,
                  ),
                  ratingProgressBar(
                    context,
                    '4',
                    totalNumberOfRatings != '0'
                        ? int.parse(totalNumberOfFourStarRating) / int.parse(totalNumberOfRatings)
                        : 0,
                  ),
                  ratingProgressBar(
                    context,
                    '3',
                    totalNumberOfRatings != '0'
                        ? int.parse(totalNumberOfThreeStarRating) / int.parse(totalNumberOfRatings)
                        : 0,
                  ),
                  ratingProgressBar(
                    context,
                    '2',
                    totalNumberOfRatings != '0'
                        ? int.parse(totalNumberOfTwoStarRating) / int.parse(totalNumberOfRatings)
                        : 0,
                  ),
                  ratingProgressBar(
                    context,
                    '1',
                    totalNumberOfRatings != '0'
                        ? int.parse(totalNumberOfOneStarRating) / int.parse(totalNumberOfRatings)
                        : 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget ratingProgressBar(
          final BuildContext context, final String ratingName, final double rating,) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              ratingName,

                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.blackColor,

            ),
            const CustomSizedBox(
              width: 8,
            ),
            CustomContainer(
              width: 110,
              clipBehavior: Clip.antiAlias,
             borderRadius: borderRadiusOf5,
              child: CustomTweenAnimation(
                beginValue: 0,
                endValue: rating.isNaN ? 0 : rating,
                curve: Curves.fastLinearToSlowEaseIn,
                durationInSeconds: 1,
                builder: (final BuildContext context, final double value, final Widget? child) =>
                    LinearProgressIndicator(
                  color: AppColors.ratingStarColor,
                  backgroundColor: Theme.of(context).colorScheme.lightGreyColor,
                  minHeight: 6,
                  value: rating,
                ),
              ),
            )
          ],
        ),
      );
}
