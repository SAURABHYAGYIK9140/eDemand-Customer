// ignore_for_file: use_build_context_synchronously

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class DynamicLinkRepository {
  //
   String uriPrefix = dynamicLink["deepLinkPrefix"];
   String domainURL = dynamicLink["domainURL"];

   Future<String> createDynamicLink(
      {required final String shareUrl, final String? title, final String? imageUrl, final String? description,}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: DynamicLinkRepository().uriPrefix,
      link: Uri.parse(shareUrl),
      androidParameters: const AndroidParameters(
        packageName: packageName,
      ),
      iosParameters: const IOSParameters(
        bundleId: packageName,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title ?? appName,
        imageUrl: Uri.parse(imageUrl ?? ""),
        description: description,),);

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.unguessable);

    final Uri uri = shortLink.shortUrl;

    return uri.toString();
  }

   Future<void> initializeDynamicLink({required final BuildContext context}) async {
    //this method will be called when app is on background (app is not open)
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      if (deepLink.queryParameters.containsKey('providerId')) {
        final String id = deepLink.queryParameters['providerId'].toString();
        await Navigator.pushNamed(context, providerRoute, arguments: {
          'providerId': id,
        },);
      }
    }

    //this method will be called when app is on foreground (app is open)
    FirebaseDynamicLinks.instance.onLink.listen((final dynamicLinkData) {
      if (dynamicLinkData.link.queryParameters.containsKey("providerId")) {
        final String providerID = dynamicLinkData.link.queryParameters['providerId'].toString();
        Navigator.pushNamed(context, providerRoute, arguments: {
          'providerId': providerID,
        },);
      }
    });
  }
}
