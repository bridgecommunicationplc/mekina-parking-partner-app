import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/subscription_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class AddSubscriptionController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<SubscriptionModel> subscriptionModel = SubscriptionModel().obs;
  var subscription = SubscriptionModel(plan: <Plan>[].obs).obs;

  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> maxSpaceLimitController =
      TextEditingController().obs;

  RxBool isActive = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  GlobalKey<FormFieldState> key = GlobalKey<FormFieldState>();
  var planSaveData;

  @override
  void onInit() {
    Get.arguments;
    if (Get.arguments != '') {
      getData(ownerId: Get.arguments);
    } else {
      isLoading.value = false;
    }
    getParkingDataComman();
    super.onInit();
  }

  getParkingDataComman() async {
    await getParkingData();
  }

  getData({required String ownerId}) async {
    await FireStoreUtils.getSubscription(ownerId).then((value) {
      if (value != null) {
        subscriptionModel.value = value;
        nameController.value.text = subscriptionModel.value.title.toString();
        maxSpaceLimitController.value.text =
            subscriptionModel.value.maxSpace.toString();
        isActive.value = subscriptionModel.value.isEnable ?? true;
      }
    });

    isLoading.value = false;
  }

  void addPlan() {
    subscription.value.plan!.add(Plan(months: "", price: ""));
    update();
  }

  void removePlan(int index) {
    if (index >= 0 && index < subscription.value.plan!.length) {
      subscription.value.plan!.removeAt(index);
      update();
    }
  }

  void savePlans() {
    for (var plan in subscription.value.plan!) {
      if (plan.months == null || plan.months!.isEmpty) {
        Get.snackbar("Validation Error", "Please enter months for all plans");
        return;
      }
      if (plan.price == null || plan.price!.isEmpty) {
        Get.snackbar("Validation Error", "Please enter price for all plans");
        return;
      }
    }

    print(
        "Plans saved: ${subscription.value.plan!.map((e) => e.toJson()).toList()}");

    Get.snackbar("Success", "Plans saved successfully!");
  }

  getParkingData() async {
    await FireStoreUtils.getMyParkingList().then((value) {
      if (value != null) {
        parkingList.value = value;
        for (var element in parkingList) {
          if (element.id == subscriptionModel.value.parkingId) {
            selectedParkingModel.value = element;
          }
        }
      }
    });
    print("-=======>${parkingList.length}");
    isLoading.value = false;
    update();
  }

  addSubscription() async {
    ShowToastDialog.showLoader("please_wait".tr);
    SubscriptionModel subscriptionModelData = subscriptionModel.value;

    subscriptionModelData.id = Constant.getUuid();
    subscriptionModelData.title = nameController.value.text;
    subscriptionModelData.maxSpace = maxSpaceLimitController.value.text;
    subscriptionModelData.ownerId = FireStoreUtils.getCurrentUid();
    subscriptionModelData.parkingId = selectedParkingModel.value.id;
    subscriptionModelData.createdAt = Timestamp.fromDate(DateTime.now());
    subscriptionModelData.isEnable = isActive.value;
    final List<Plan>? planList = subscription.value.plan;
    subscriptionModelData.plan = planList;

    FireStoreUtils.updateSubscription(subscriptionModelData).then(
      (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          Get.arguments != ''
              ? "Subscription updated successfully".tr
              : "Subscription added successfully".tr,
        );
        Get.back();
        update();
      },
    );
  }

  checkValidation() {
    if (nameController.value.text == '') {
      return 'Please Enter Valid Name';
    } else if (maxSpaceLimitController.value.text == '') {
      return 'Please Enter Valid Max Space Limit';
    } else if (subscription.value.plan!.isEmpty) {
      return 'Please Enter Valid Plan Validity';
    } else {
      return null;
    }
  }
}
