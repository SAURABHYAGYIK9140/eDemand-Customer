import 'dart:convert';

import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/repository/dynamicLinkRepository.dart';
import 'package:flutter/material.dart';

class ShareProviderDetailsState {}

class ShareProviderDetailsInitialState extends ShareProviderDetailsState {}

class ShareProviderDetailsInProgressState extends ShareProviderDetailsState {
  final Providers providerDetails;

  ShareProviderDetailsInProgressState({
    required this.providerDetails,
  });
}

class ShareProviderDetailsSuccessState extends ShareProviderDetailsState {
  final String providerShareURL;
  final Providers providerDetails;

  ShareProviderDetailsSuccessState({
    required this.providerShareURL,
    required this.providerDetails,
  });
}

class ShareProviderDetailsFailureState extends ShareProviderDetailsState {
  final String errorMessage;

  ShareProviderDetailsFailureState({required this.errorMessage});
}

class ShareProviderDetailsCubit extends Cubit<ShareProviderDetailsState> {
  DynamicLinkRepository dynamicLinkRepository = DynamicLinkRepository();

  ShareProviderDetailsCubit() : super(ShareProviderDetailsInitialState());

  Future<void> shareProviderDetails({required Providers providerData}) async {
    try {
      emit(ShareProviderDetailsInProgressState(providerDetails: providerData));

      final String url = await dynamicLinkRepository.createDynamicLink(
        shareUrl: '${DynamicLinkRepository().domainURL}/?providerId=${providerData.providerId}',
        title: providerData.companyName,
        imageUrl: providerData.image,
        description: '<h1>${providerData.companyName}</h1>',
      );
      //
      emit(
        ShareProviderDetailsSuccessState(providerShareURL: url, providerDetails: providerData),
      );
    } catch (e) {
      emit(ShareProviderDetailsFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> initializeDynamicLink({required final BuildContext context}) async {
    dynamicLinkRepository.initializeDynamicLink(context: context);
  }
}
