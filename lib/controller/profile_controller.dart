import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/user_vehicle_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class ProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  RxList<UserModel> allUserList = <UserModel>[].obs;
  RxList<UserModel> getAllUserVehicleList = <UserModel>[].obs;
  RxList<UserModel> allVehicleUserList = <UserModel>[].obs;
  RxString userId = "".obs;
  RxString vehicleNumber = "".obs;
  RxString vehicleId = "".obs;
  RxString vehicleUserId = "".obs;
  RxList<String> userIds = <String>[].obs;
  RxList<String> userSubscriptionIds = <String>[].obs;
  RxList<UserVehicleModel> userVehicle = <UserVehicleModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });

    await FireStoreUtils.getAllUser().then((value) {
      if (value != null) {
        allVehicleUserList.value = value;
        for (var allUser in allVehicleUserList.value) {
          userIds.add(allUser.id!);
        }
      }
    });

    await FireStoreUtils.getSubscriptionUsers().then((userList) {
      if (userList != null) {
        allUserList.value = userList;
        userSubscriptionIds.value = userList.map((user) => user.id!).toList();
      }
    });

    await FireStoreUtils.getSubscriptionUserVehicle(userId.value).then((value) {
      if (value != null) {
        userVehicle.value = value;
        for (var vehicle in userVehicle.value) {
          vehicleNumber.value = vehicle.vehicleNumber!;
          vehicleId.value = vehicle.id!;
          vehicleUserId.value = vehicle.userId!;
        }
      }
    });

    isLoading.value = false;
  }
}
