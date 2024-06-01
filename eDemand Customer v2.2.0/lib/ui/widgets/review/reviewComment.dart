import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/customReadMoreTextContainer.dart';
import 'package:flutter/material.dart';

class ReviewDetails extends StatelessWidget {
  const ReviewDetails({required this.reviews, final Key? key}) : super(key: key);
  final Reviews reviews;

  @override
  Widget build(final BuildContext context) {
    final time1 = DateTime.parse(reviews.ratedOn!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusOf20),
                  child: CustomCachedNetworkImage(
                    networkImageUrl: reviews.profileImage!,
                    fit: BoxFit.fill,
                    width: 50,
                    height: 50,
                  ),
                ),
                const CustomSizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(
                        reviews.userName!,

                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,

                        textAlign: TextAlign.left,
                      ),
                      Row(
                        children: <Widget>[
                          StarRating(
                            rating: double.parse(reviews.rating!),
                            onRatingChanged: (final double rating) => rating,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CustomText(
                              double.parse(reviews.rating!).toStringAsFixed(1),

                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.blackColor,
                                fontSize: 12,

                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: CustomText(
                                time1.toString().convertToAgo(context: context),

                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.lightGreyColor,

                                maxLines: 1,

                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (reviews.comment!.isNotEmpty) ...[
            const CustomSizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomReadMoreTextContainer(
                text: reviews.comment!,

              ),
            ),
          ],
          if (reviews.images!.isNotEmpty) ...[
            const CustomSizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  reviews.images!.length,
                  (final index) => CustomInkWellContainer(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        imagePreview,
                        arguments: {
                          "startFrom": index,
                          "reviewDetails": reviews,
                          "isReviewType": true,
                          "dataURL": reviews.images
                        },
                      );
                    },
                    child: CustomContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: CustomCachedNetworkImage(
                        networkImageUrl: reviews.images![index],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
