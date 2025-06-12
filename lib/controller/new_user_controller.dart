import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class AddNewUserController extends GetxController {
  Rx<UserModel> userModel = UserModel().obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  RxString gender = "Male".obs;
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> dateOfBirthController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController =
      TextEditingController(text: "+251").obs;
  RxString profileImage = "".obs;

  void handleGenderChange(String? value) {
    gender.value = value!;
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

  addProfile() async {
    ShowToastDialog.showLoader("please_wait".tr);
    if (Constant().hasValidUrl(profileImage.value) == false &&
        profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }

    Map<String, dynamic> userData = {
      'id': Constant.getUuid(),
      'fullName': fullNameController.value.text,
      'profilePic': profileImage.value,
      'dateOfBirth': dateOfBirthController.value.text,
      'email': emailController.value.text,
      'phoneNumber': phoneNumberController.value.text,
      'countryCode': countryCodeController.value.text,
      'gender': gender.value,
      'createdAt': Timestamp.now(),
      'role': 'customer',
      'walletAmount': '',
    };

    FireStoreUtils.updateNewUser(userData).then(
      (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          "New user created".tr,
        );
        Get.back();
        update();
      },
    );
  }
}
