import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class Profile extends StatefulWidget {
  const Profile({
    required this.scrollController,
    final Key? key,
    this.currentVersion,
  }) : super(key: key);
  final String? currentVersion;
  final ScrollController scrollController;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? latestVersionOfAndroid, latestVersionOfIOS;

  @override
  void initState() {
    super.initState();
    getLatestVersions();
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  void getLatestVersions() {
    Future.delayed(Duration.zero).then((final value) {
      final versionDetails = context.read<SystemSettingCubit>().getApplicationVersionDetails();
      latestVersionOfAndroid = versionDetails['androidVersion'] ?? "1.0.0";
      latestVersionOfIOS = versionDetails['iOSVersion'] ?? "1.0.0";
    });
  }

  Widget _getText({
    required final String text,
    final double? fontSize,
    final Color? fontColor,
    final FontWeight? fontWeight,
  }) =>
      CustomText(
        text,
        fontSize: fontSize,
        color: fontColor,
        fontWeight: fontWeight,
        maxLines: 1,
      );

  Widget getTitleContainer({required final String title, final double? height}) => CustomSizedBox(
        height: height ?? 30,
        width: MediaQuery.sizeOf(context).width,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 5),
          child: _getText(
            text: title,
            fontColor: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      );

  Widget _getListItem({
    required final String imageName,
    required final String title,
    final String? subTitle,
    final bool showDarkModeToggle = false,
    final double? height,
    final VoidCallback? onTap,
    final bool showLanguageName = false,
  }) =>
      CustomInkWellContainer(
        onTap: onTap,
        child: CustomContainer(
          height: height ?? 40,
          width: MediaQuery.sizeOf(context).width,
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
                      child: CustomSvgPicture(
                        svgImage: imageName,
                        color: Theme.of(context).colorScheme.accentColor,
                        height: 22,
                        width: 22,
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            title,
                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          if (subTitle != null)
                            CustomText(
                              subTitle,
                              color: Theme.of(context).colorScheme.lightGreyColor,
                              fontSize: 12,
                            ),
                        ],
                      ),
                    ),
                    if (showLanguageName)
                      _getText(
                        text: HiveRepository.getSelectedLanguageName,
                        fontSize: 12,
                        fontColor: Theme.of(context).colorScheme.lightGreyColor,
                      ),
                    if (showDarkModeToggle)
                      Expanded(
                        flex: 2,
                        child: CupertinoSwitch(
                          value: context.read<AppThemeCubit>().state.appTheme == AppTheme.dark,
                          onChanged: (final bool value) {
                            //save selected theme preference
                            HiveRepository.setDarkThemeEnable = value;
                            // HiveRepository.putValuesOf(
                            //     boxName: HiveRepository.themeBoxKey,
                            //     key: HiveRepository.isDarkThemeEnableKey,
                            //     value: value);
                            //
                            if (value) {
                              context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                            } else {
                              context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                            }
                          },
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget backgroundContainer({required final Widget child}) => CustomContainer(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: borderRadiusOf10,
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        padding: const EdgeInsets.all(10),
        child: child,
      );

  @override
  Widget build(final BuildContext context) => AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'profile'.translate(context: context),
            isLeadingIconEnable: false,
            centerTitle: true,
            elevation: 0.5,
            actions: [
              BlocBuilder<UserDetailsCubit, UserDetailsState>(
                builder: (final BuildContext context, final UserDetailsState state) {
                  final token = HiveRepository.getUserToken;
                  if (token != "") {
                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 15, 12),
                      child: CustomFlatButton(
                        backgroundColor: Colors.transparent,
                        width: MediaQuery.sizeOf(context).width * 0.25,
                        text: 'logout'.translate(context: context),
                        fontColor: AppColors.redColor,
                        showBorder: true,
                        //
                        radius: 50,
                        fontSize: 14,
                        borderColor: AppColors.redColor,
                        innerPadding: 5,
                        onPressed: () {
                          UiUtils.showAnimatedDialog(
                              context: context, child: const LogoutAccountDialog());
                        },
                      ),
                    );
                  }

                  return const CustomSizedBox();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(bottom: 65),
            child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
              builder: (final BuildContext context, UserDetailsState state) {
                final token = HiveRepository.getUserToken;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<UserDetailsCubit, UserDetailsState>(
                      builder: (final BuildContext context, final UserDetailsState userDetails) {
                        if (userDetails is UserDetails) {
                          return CustomInkWellContainer(
                            onTap: () {
                              if (token == "") {
                                Navigator.pushNamed(
                                  context,
                                  loginRoute,
                                  arguments: {'source': 'profileScreen'},
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  editProfileRoute,
                                  arguments: {'source': 'profileScreen'},
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: backgroundContainer(
                                child: Row(
                                  children: [
                                    Ink(
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              CustomInkWellContainer(
                                                child: CustomContainer(
                                                  width: 70,
                                                  height: 70,
                                                  borderRadius: borderRadiusOf50,
                                                  border: Border.all(
                                                    color: Theme.of(context).colorScheme.blackColor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(borderRadiusOf50),
                                                      child: (HiveRepository
                                                                      .getUserProfilePictureURL ==
                                                                  null ||
                                                              HiveRepository
                                                                      .getUserProfilePictureURL ==
                                                                  '')
                                                          ? CustomSvgPicture(
                                                              svgImage: "dr_profile",
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .blackColor,
                                                            )
                                                          : CustomCachedNetworkImage(
                                                              height: 100,
                                                              width: 100,
                                                              networkImageUrl: HiveRepository
                                                                  .getUserProfilePictureURL
                                                                  .toString(),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (token != "") {
                                                    Navigator.pushNamed(
                                                      context,
                                                      editProfileRoute,
                                                      arguments: {'source': 'profileScreen'},
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const CustomSizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (token != "") ...{
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 2),
                                              child: _getText(
                                                text: HiveRepository.getUsername ?? "",
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                fontColor: Theme.of(context).colorScheme.blackColor,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 2),
                                              child: _getText(
                                                text:
                                                    "${HiveRepository.getUserMobileCountryCode ?? ""}${HiveRepository.getUserMobileNumber ?? ""}",
                                                fontSize: 14,
                                                fontColor:
                                                    Theme.of(context).colorScheme.lightGreyColor,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 2),
                                              child: _getText(
                                                text: HiveRepository.getUserEmailId ?? '',
                                                fontSize: 14,
                                                fontColor:
                                                    Theme.of(context).colorScheme.lightGreyColor,
                                              ),
                                            ),
                                          } else ...{
                                            _getText(
                                              text: 'guest'.translate(context: context),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            _getText(
                                              text: "login_or_signup".translate(context: context),
                                              fontSize: 12,
                                            )
                                          },
                                        ],
                                      ),
                                    ),
                                    // const Spacer(),
                                    if (token != "")
                                      CustomContainer(
                                        width: 25,
                                        height: 25,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .accentColor
                                            .withOpacity(0.2),
                                        borderRadius: borderRadiusOf5,
                                        child: Icon(
                                          Icons.edit,
                                          color: Theme.of(context).colorScheme.accentColor,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return const CustomSizedBox();
                      },
                    ),
                    if (token != "")
                      backgroundContainer(
                        child: Column(
                          children: [
                            getTitleContainer(title: 'content'.translate(context: context)),
                            const CustomDivider(
                              thickness: 0.5,
                              height: 1,
                            ),
                            _getListItem(
                              imageName: "dr_notification",
                              title: 'notification'.translate(context: context),
                              onTap: () {
                                Navigator.pushNamed(context, notificationRoute);
                              },
                            ),
                            _getListItem(
                              imageName: "dr_favorite",
                              title: 'bookmark'.translate(context: context),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  bookmarkRoute,
                                );
                              },
                            ),
                            _getListItem(
                              imageName: "dr_address",
                              title: 'address'.translate(context: context),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  manageAddressScreen,
                                  arguments: {'appBarTitle': 'address'},
                                );
                              },
                            ),
                            _getListItem(
                              onTap: () {
                                Navigator.pushNamed(context, paymentDetailsScreen);
                              },
                              imageName: "dr_payment",
                              title: 'payment'.translate(context: context),
                            ),
                          ],
                        ),
                      ),
                    backgroundContainer(
                      child: Column(
                        children: [
                          getTitleContainer(title: 'preference'.translate(context: context)),
                          const CustomDivider(
                            thickness: 0.5,
                            height: 1,
                          ),
                          _getListItem(
                            showLanguageName: true,
                            imageName: "dr_language",
                            title: 'language'.translate(context: context),
                            onTap: () {
                              UiUtils.showBottomSheet(
                                context: context,
                                child: const ChooseLanguageBottomSheet(),
                              );
                            },
                          ),
                          _getListItem(
                            showDarkModeToggle: true,
                            imageName: "dr_theme",
                            title: 'darkMode'.translate(context: context),
                          ),
                        ],
                      ),
                    ),
                    backgroundContainer(
                      child: Column(
                        children: [
                          getTitleContainer(title: 'termAndPrivacy'.translate(context: context)),
                          const CustomDivider(
                            thickness: 0.5,
                            height: 1,
                          ),
                          _getListItem(
                            imageName: "dr_terms",
                            title: 'termsofservice'.translate(context: context),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(appSettingsRoute, arguments: "termsofservice");
                            },
                          ),
                          _getListItem(
                            imageName: "dr_privacy",
                            title: 'privacyAndPolicy'.translate(context: context),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(appSettingsRoute, arguments: "privacyAndPolicy");
                            },
                          ),
                        ],
                      ),
                    ),
                    backgroundContainer(
                      child: Column(
                        children: [
                          getTitleContainer(title: 'others'.translate(context: context)),
                          const CustomDivider(
                            thickness: 0.5,
                            height: 1,
                          ),
                          _getListItem(
                            imageName: "dr_share",
                            title: 'shareApp'.translate(context: context),
                            onTap: () {
                              try {
                                if (Platform.isAndroid) {
                                  // ignore: prefer_interpolation_to_compose_strings
                                  Share.share(customerAppAndroidLink);
                                } else {
                                  Share.share(customerAppIOSLink);
                                }
                              } catch (e) {
                                UiUtils.showMessage(
                                  context,
                                  'somethingWentWrong'.translate(context: context),
                                  MessageType.warning,
                                );
                              }
                            },
                          ),
                          _getListItem(
                            imageName: "dr_rateus",
                            title: 'rateApp'.translate(context: context),
                            onTap: () {
                              {
                                LaunchReview.launch(
                                  androidAppId: packageName,
                                  iOSAppId: customerAppIOSLink,
                                );
                              }
                            },
                          ),
                          _getListItem(
                            imageName: "dr_help",
                            title: 'help'.translate(context: context),
                            onTap: () {
                              Navigator.pushNamed(context, faqsRoute);
                            },
                          ),
                          _getListItem(
                            imageName: "dr_contact_us",
                            title: 'contactUs'.translate(context: context),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(appSettingsRoute, arguments: "contactUs");
                            },
                          ),
                          _getListItem(
                            imageName: "dr_aboutus",
                            title: 'aboutUs'.translate(context: context),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(appSettingsRoute, arguments: "aboutUs");
                            },
                          ),
                          _getListItem(
                            imageName: "dr_become_provider",
                            title: 'becomeProvider'.translate(context: context),
                            onTap: () async {
                              if (Platform.isAndroid) {
                                if (await canLaunchUrl(Uri.parse(providerAppAndroidLink))) {
                                  try {
                                    launchUrl(Uri.parse(providerAppAndroidLink),
                                        mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    UiUtils.showMessage(
                                      context,
                                      "somethingWentWrong".translate(context: context),
                                      MessageType.error,
                                    );
                                  }
                                }
                              } else if (Platform.isIOS) {
                                if (await canLaunchUrl(Uri.parse(providerAppIOSLink))) {
                                  try {
                                    launchUrl(Uri.parse(providerAppIOSLink),
                                        mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    UiUtils.showMessage(
                                      context,
                                      "somethingWentWrong".translate(context: context),
                                      MessageType.error,
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          /*      if ((Platform.isAndroid && latestVersionOfAndroid != null) || (Platform.isIOS && latestVersionOfIOS != null))
                        if (((Platform.isAndroid && Version.parse(latestVersionOfAndroid ?? "1.0.1") > Version.parse(widget.currentVersion ?? '1.0.1')) ||
                                (Platform.isIOS && Version.parse(latestVersionOfIOS ?? "1.0.1") > Version.parse(widget.currentVersion ?? '1.0.1'))) &&
                            widget.currentVersion != null)
                          _getListItem(
                            imageName: 'dr_app_update',
                            subTitle: "${ "currentVersion")} ${Version.parse(widget.currentVersion ?? '1.0.0')}",
                            height: 60,
                            title:  "updateAppTitle"),
                            onTap: () {
                              launchUrl(Uri.parse(playStoreApplicationLink), mode: LaunchMode.externalApplication);
                            },
                          ),*/
                        ],
                      ),
                    ),
                    if (token != "") ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CustomRoundedButton(
                          onTap: () async {
                            UiUtils.showAnimatedDialog(
                              context: context,
                              child: BlocProvider(
                                create: (context) =>
                                    DeleteUserAccountCubit(AuthenticationRepository()),
                                child: const DeleteUserAccountDialog(),
                              ),
                            );
                          },
                          widthPercentage: 1,
                          backgroundColor: AppColors.redColor,
                          buttonTitle: '',
                          showBorder: false,
                          borderColor: AppColors.redColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: CustomSvgPicture(
                                  svgImage: 'dr_delete_account',
                                  color: AppColors.whiteColors,
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                              CustomSizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.05,
                              ),
                              CustomText(
                                'deleteAccount'.translate(context: context),
                                color: AppColors.whiteColors,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,

                              ),
                            ],
                          ),
                        ),
                      )
                    ]
                  ],
                );
              },
            ),
          ),
        ),
      );
}
