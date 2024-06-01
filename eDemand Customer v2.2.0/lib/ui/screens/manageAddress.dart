import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/Dialog/layouts/deleteAddressDialog.dart';
import 'package:e_demand/ui/widgets/addNewAddressContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageAddress extends StatefulWidget {
  const ManageAddress({required this.appBarTitle, final Key? key}) : super(key: key);
  final String appBarTitle;

  @override
  State<ManageAddress> createState() => _ManageAddressState();

  static Route<ManageAddress> route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, String>;
    return CupertinoPageRoute(
      builder: (final _) => ManageAddress(appBarTitle: arguments["appBarTitle"]!),
    );
  }
}

class _ManageAddressState extends State<ManageAddress> {
  //
  Widget buildAddressSelector() => MultiBlocListener(
        listeners: [
          BlocListener<AddAddressCubit, AddAddressState>(
            listener: (final BuildContext context, AddAddressState addAddressState) {
              if (addAddressState is AddAddressSuccess) {
                final GetAddressModel getAddressModel =
                    GetAddressModel.fromJson(addAddressState.result["data"][0]);
                context.read<AddressesCubit>().addAddress(getAddressModel);
              }
            },
          ),
          BlocListener<DeleteAddressCubit, DeleteAddressState>(
            listener: (final BuildContext context, final DeleteAddressState state) {
              if (state is DeleteAddressSuccess) {
                context.read<AddressesCubit>().removeAddress(state.id);
              }
            },
          ),
        ],
        child: BlocConsumer<GetAddressCubit, GetAddressState>(
          listener: (final BuildContext context, final GetAddressState getAddressState) {
            if (getAddressState is GetAddressSuccess) {
              //inserting because there is Plus Button in ListView at 0 index

              if (getAddressState.data.isNotEmpty) {
                if (getAddressState.data[0].id != null) {
                  getAddressState.data.insert(0, GetAddressModel.fromJson({}));
                }
              }

              for (var i = 0; i < getAddressState.data.length; i++) {
                //we will make default address as selected address
                //so we will take index of selected address and address data

                if (getAddressState.data[i].isDefault == "1") {
                  /*  selectedAddressIndex = i + 1;
                  selectedAddress = getAddressState.data[i];
                  setState(() {});*/
                }
              }

              context.read<AddressesCubit>().load(getAddressState.data);
            }
          },
          builder: (final BuildContext context, final GetAddressState getAddressState) {
            if (getAddressState is GetAddressFail) {
              return ErrorContainer(
                errorMessage: getAddressState.error.translate(context: context),
                showRetryButton: true,
                onTapRetry: () {
                  context.read<GetAddressCubit>().fetchAddress();
                },
              );
            }

            if (getAddressState is GetAddressSuccess) {
              return BlocBuilder<AddressesCubit, AddressesState>(
                builder: (final context, final AddressesState addressesState) {
                  if (addressesState is Addresses) {
                    if (addressesState.addresses.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: AddAddressContainer(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  googleMapRoute,
                                  arguments: {
                                    "defaultLatitude": HiveRepository.getLatitude,
                                    "defaultLongitude": HiveRepository.getLongitude,
                                    'showAddressForm': true
                                  },
                                ).then((final Object? value) {
                                  context.read<GetAddressCubit>().fetchAddress();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: NoDataContainer(
                                titleKey: "noAddressFound".translate(context: context),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(addressesState.addresses.length, (final int index) {
                          late GetAddressModel addressData;
                          if (getAddressState.data.isNotEmpty) {
                            addressData = addressesState.addresses[index];
                          }

                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              child: AddAddressContainer(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    googleMapRoute,
                                    arguments: {
                                      "defaultLatitude": HiveRepository.getLatitude,
                                      "defaultLongitude": HiveRepository.getLongitude,
                                      'showAddressForm': true
                                    },
                                  ).then((final Object? value) {
                                    context.read<GetAddressCubit>().fetchAddress();
                                  });
                                },
                              ),
                            );
                          }

                          return CustomContainer(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(10),
                            color: Theme.of(context).colorScheme.secondaryColor,
                            borderRadius: borderRadiusOf10,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CustomContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      width: 40,
                                      child: CustomSvgPicture(
                                        svgImage: addressData.type == 'home'
                                            ? 'homeadd'
                                            : addressData.type == 'Other'
                                                ? 'location_mark'
                                                : 'officeadd',
                                        color: Theme.of(context).colorScheme.accentColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomText(
                                        addressData.type
                                            .toString()
                                            .toLowerCase()
                                            .translate(context: context),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.blackColor,
                                      ),
                                    ),
                                    CustomContainer(
                                      height: 20,
                                      width: 50,
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: PopupMenuButton<int>(
                                          color: Theme.of(context).colorScheme.accentColor,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadiusDirectional.only(
                                              topStart: Radius.circular(borderRadiusOf10),
                                              bottomEnd: Radius.circular(borderRadiusOf10),
                                              bottomStart: Radius.circular(borderRadiusOf10),
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          iconSize: 24,
                                          onSelected: (final selected) {
                                            if (selected == 1) {
                                              Navigator.pushNamed(
                                                context,
                                                googleMapRoute,
                                                arguments: {
                                                  "defaultLatitude":
                                                      addressData.lattitude.toString(),
                                                  "defaultLongitude":
                                                      addressData.longitude.toString(),
                                                  'details': addressData,
                                                  'showAddressForm': true
                                                },
                                              ).then((final Object? value) {
                                                if (value == true) {
                                                  context.read<GetAddressCubit>().fetchAddress();
                                                }
                                              });
                                            }

                                            if (selected == 2) {
                                              UiUtils.showAnimatedDialog(
                                                context: context,
                                                child: DeleteAddressDialog(
                                                  onConfirmButtonPressed: () {
                                                    try {
                                                      context
                                                          .read<DeleteAddressCubit>()
                                                          .deleteAddress(addressData.id as String);
                                                      Navigator.pop(context);
                                                    } catch (_) {}
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            // popupmenu item 1
                                            PopupMenuItem(
                                              onTap: () {},
                                              value: 1,
                                              // row has two child icon and text.
                                              child: CustomText(
                                                "edit".translate(context: context),
                                                color: AppColors.whiteColors,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                            // popupmenu item 2
                                            PopupMenuItem(
                                              value: 2,
                                              // row has two child icon and text
                                              child: CustomText(
                                                "delete".translate(context: context),
                                                color: AppColors.whiteColors,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                          offset: const Offset(0, 24),
                                          elevation: 2,
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Theme.of(context).colorScheme.accentColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const CustomSizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const CustomSizedBox(width: 40),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            '${addressData.address},${addressData.area},${addressData.state}, ${addressData.country}',
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.blackColor,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
                                          ),
                                          CustomText(
                                            '${addressData.mobile}',
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.blackColor,
                                            maxLines: 1,
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const CustomSizedBox(
                                      height: 20,
                                      width: 50,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    );
                  }

                  return const CustomSizedBox();
                },
              );
            }
            return ListView.builder(
              itemCount: numberOfShimmerContainer,
              shrinkWrap: true,
              itemBuilder: (context, int index) => const CustomShimmerLoadingContainer(
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                height: 140,
                width: 24,
              ),
            );
          },
        ),
      );

  @override
  void initState() {
    super.initState();
    context.read<GetAddressCubit>().fetchAddress();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: widget.appBarTitle.translate(context: context),
        ),
        body: CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () {
              context.read<GetAddressCubit>().fetchAddress();
            },
            child: buildAddressSelector()),
      );
}
