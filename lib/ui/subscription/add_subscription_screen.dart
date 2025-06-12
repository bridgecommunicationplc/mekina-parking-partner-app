import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/add_subscription_controller.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/themes/text_field_widget.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class AddSubscriptionScreen extends StatelessWidget {
  final bool isEdit;

  const AddSubscriptionScreen({required this.isEdit, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddSubscriptionController>(
      init: AddSubscriptionController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            isEdit ? "Edit Subscription".tr : 'Add Subscription'.tr,
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldWidget(
                                title: 'Name'.tr,
                                onPress: () {},
                                controller: controller.nameController.value,
                                hintText: 'Enter Name'.tr,
                                textInputType: TextInputType.emailAddress,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                      "assets/icon/ic_account.svg",
                                      color: const Color(0xff697586)),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text("Select Parking".tr,
                                  style: TextStyle(
                                      fontFamily: AppThemData.medium,
                                      fontSize: 14,
                                      color: AppThemData.grey07)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<ParkingModel>(
                                  isExpanded: true,
                                  key: controller.key,
                                  decoration: InputDecoration(
                                    errorStyle:
                                        const TextStyle(color: Colors.red),
                                    isDense: true,
                                    filled: true,
                                    fillColor: themeChange.getThem()
                                        ? AppThemData.grey10
                                        : AppThemData.grey03,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 10),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
                                          "assets/icon/ic_car_image.svg",
                                          height: 24,
                                          width: 24),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey04,
                                          width: 1),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: themeChange.getThem()
                                              ? AppThemData.primary06
                                              : AppThemData.primary06,
                                          width: 1),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey04,
                                          width: 1),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey04,
                                          width: 1),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey04,
                                          width: 1),
                                    ),
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem()
                                            ? AppThemData.grey06
                                            : AppThemData.grey06,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppThemData.medium),
                                  ),
                                  value: controller
                                              .selectedParkingModel.value.id ==
                                          null
                                      ? null
                                      : controller.selectedParkingModel.value,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      // await FireStoreUtils.parkingAssignCheck(
                                      //     value.id.toString(),
                                      //     controller.watchmenModel.value.id
                                      //         .toString())
                                      //     .then((value0) {
                                      //   print("=====>");
                                      //   print(value0);
                                      //   print(controller
                                      //       .selectedParkingModel.value.id);
                                      //   if (value0 == true) {
                                      //     controller.selectedParkingModel
                                      //         .value = ParkingModel();
                                      //     ShowToastDialog.showToast(
                                      //         "This parking already assign to another watchman");
                                      //   } else {
                                      controller.selectedParkingModel.value =
                                          value;
                                      controller.update();
                                      //   }
                                      // });
                                    }
                                  },
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? AppThemData.grey02
                                          : AppThemData.grey08,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppThemData.medium),
                                  hint: Text(
                                    "Select Your Parking".tr,
                                    style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemData.grey07
                                            : AppThemData.grey07),
                                  ),
                                  items: controller.parkingList.map((item) {
                                    return DropdownMenuItem<ParkingModel>(
                                      value: item,
                                      child: Text(item.name.toString(),
                                          style: const TextStyle()),
                                    );
                                  }).toList()),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFieldWidget(
                                title: 'Max space limit'.tr,
                                onPress: () {},
                                controller:
                                    controller.maxSpaceLimitController.value,
                                hintText: 'Enter max space limit'.tr,
                                textInputType: TextInputType.number,
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                      "assets/icon/ic_space.svg",
                                      color: const Color(0xff697586)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text("Subscription plan validity and price".tr,
                                  style: const TextStyle(
                                      fontFamily: AppThemData.medium,
                                      fontSize: 14,
                                      color: AppThemData.grey07)),
                              Obx(() {
                                final plans =
                                    controller.subscription.value.plan!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: plans.length,
                                  itemBuilder: (context, index) {
                                    final plan = plans[index];
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child:
                                              TextFormField(
                                                keyboardType: TextInputType.number,
                                                initialValue: plan.months,
                                                decoration: InputDecoration(
                                                    errorStyle: const TextStyle(color: Colors.red),
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                                    disabledBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    errorBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    border: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    hintText: "Months",
                                                    hintStyle:
                                                    TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium)),
                                                style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                                                onChanged: (value) {
                                                  plan.months = value;
                                                  controller.update();
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child:
                                              TextFormField(
                                                initialValue: plan.price,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                    errorStyle: const TextStyle(color: Colors.red),
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                                    disabledBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    errorBorder: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    border: UnderlineInputBorder(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                                                    ),
                                                    hintText: "Price",
                                                    hintStyle:
                                                    TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium)),
                                                style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                                                onChanged: (value) {
                                                  plan.price = value;
                                                  controller.update();
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  controller.removePlan(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppThemData.blueLight,
                                  ),
                                  onPressed: controller.addPlan,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Active".tr,
                                      style: const TextStyle(
                                          fontFamily: AppThemData.medium,
                                          fontSize: 14,
                                          color: AppThemData.grey07)),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: Switch(
                                        value: controller.isActive.value,
                                        onChanged: (value) {
                                          controller.isActive(value);
                                        },
                                        activeColor: AppThemData.primary06,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              RoundedButtonFill(
                                title: "Save".tr,
                                color: AppThemData.primary06,
                                onPress: () {
                                  if (controller.checkValidation() != null) {
                                    ShowToastDialog.showToast(controller
                                        .checkValidation()
                                        .toString());
                                  } else {
                                    controller.addSubscription();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
