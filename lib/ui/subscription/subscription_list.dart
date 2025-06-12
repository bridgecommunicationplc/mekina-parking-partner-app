import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/controller/subscription_list_controller.dart';
import 'package:owner/model/subscription_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/ui/subscription/add_subscription_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class MySubscriptionList extends StatelessWidget {
  final bool isBack;

  const MySubscriptionList({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MySubscriptionListController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
                context, themeChange, 'Subscription'.tr,
                isBack: isBack,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                    child: RoundedButtonFill(
                      width: 40,
                      title: "Add Subscription".tr,
                      color: AppThemData.primary06,
                      onPress: () async {
                        Get.to(() => const AddSubscriptionScreen(isEdit: false),
                                arguments: '')
                            ?.then((value) {
                          controller.getData();
                        });
                      },
                    ),
                  ),
                ]),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.subscription.isEmpty
                      ? Constant.showEmptyView(
                          message: "No subscription added".tr)
                      : ListView.separated(
                          itemCount: controller.subscription.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, int index) {
                            SubscriptionModel subscriptionData =
                                controller.subscription[index];
                            return InkWell(
                              // onTap: () {
                              //   controller.isLoading.value = true;
                              //   Get.to(
                              //           () => const AddSubscriptionScreen(
                              //               isEdit: true),
                              //           arguments: subscriptionData.id ?? '')
                              //       ?.then((value) {
                              //     controller.getData();
                              //   });
                              // },
                              child: Container(
                                height: Responsive.height(13, context),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: themeChange.getThem()
                                      ? AppThemData.grey10
                                      : AppThemData.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    subscriptionData.title
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey01
                                                          : AppThemData.grey10,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppThemData.semiBold,
                                                    ),
                                                  ),
                                                ),
                                                // const Icon(
                                                //   Icons.edit,
                                                //   color: AppThemData.warning08,
                                                // ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "ID : ",
                                                  style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey01
                                                          : AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AppThemData.bold,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                Text(
                                                  subscriptionData.id
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey01
                                                          : AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AppThemData.regular,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Max Space: ${subscriptionData.maxSpace.toString()}"
                                                      .tr,
                                                  style: const TextStyle(
                                                    color:
                                                        AppThemData.blueLight07,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        AppThemData.semiBold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 18,
                                                    child: VerticalDivider(
                                                        thickness: 1,
                                                        color: AppThemData
                                                            .grey05)),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: subscriptionData
                                                                .isEnable ==
                                                            true
                                                        ? AppThemData.success07
                                                        : AppThemData.error07,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      child: Text(
                                                        subscriptionData
                                                                    .isEnable ==
                                                                true
                                                            ? "Active".tr
                                                            : "Disable".tr,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppThemData
                                                                .white,
                                                            fontFamily:
                                                                AppThemData
                                                                    .medium),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                        ),
            ),
          );
        });
  }
}
