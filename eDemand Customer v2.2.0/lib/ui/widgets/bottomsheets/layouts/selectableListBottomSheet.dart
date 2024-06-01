
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';


class SelectableListBottomSheet extends StatefulWidget {
  final String bottomSheetTitle;
  final List<Map<String, dynamic>> itemList;

  const SelectableListBottomSheet(
      {super.key, required this.bottomSheetTitle, required this.itemList});

  @override
  State<SelectableListBottomSheet> createState() =>
      _SelectableListBottomSheetState();
}

class _SelectableListBottomSheetState extends State<SelectableListBottomSheet> {
  String? selectedItemId;
  String? selectedItemName;

  Widget getItem(
      {required String title,
      required BuildContext context,
      required bool? isSelected,
      VoidCallback? onTap}) {
    return CustomInkWellContainer(
      onTap: onTap?.call,
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        height: 30,
        child: Row(
          children: [
            CustomText(
               title.translate(context: context),
              fontWeight:
                  isSelected ?? false ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).colorScheme.blackColor,
              fontSize: 14,
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: CustomContainer(
                    height: 25,
                    width: 25,
                    child: CustomCheckBox(
                      onChanged: (p0) {
                        onTap?.call();
                      },
                      value: isSelected,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
        title: widget.bottomSheetTitle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.6),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.itemList.length, (index) {
                    final Map<String, dynamic> itemData =
                        widget.itemList[index];
                    if (itemData["isSelected"]) {
                      selectedItemId = (itemData["id"] ?? "0").toString();
                      selectedItemName = itemData["title"];
                      itemData["isSelected"] = false;
                    }
                    return getItem(
                      context: context,
                      title: itemData["title"],
                      isSelected:
                          selectedItemId == (itemData["id"] ?? "0").toString(),
                      onTap: () {
                        selectedItemId = (itemData["id"] ?? "0").toString();
                        selectedItemName = itemData["title"];
                        itemData["isSelected"] = true;
                        setState(() {});
                      },
                    );
                  }),
                ),
              ),
            ),
            CloseAndConfirmButton(closeButtonPressed: () {
              Navigator.pop(context);
            }, confirmButtonPressed: () {
              Navigator.of(context).pop({
                "selectedItemId": selectedItemId,
                "selectedItemName": selectedItemName
              });
            })
          ],
        ));
  }
}
