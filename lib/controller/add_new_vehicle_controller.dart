import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/user_vehicle_model.dart';
import 'package:owner/model/vehicle_brand_model.dart';
import 'package:owner/model/vehicle_model.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddNewVehicleController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> vehicleNumberController =
      TextEditingController().obs;

  Rx<VehicleBrandModel> selectedBrand = VehicleBrandModel().obs;
  RxList<VehicleModel> vehicleModelList = <VehicleModel>[].obs;
  Rx<VehicleModel> selectedVehicleModel = VehicleModel().obs;
  RxList<UserModel> allUserList = <UserModel>[].obs;
  Rx<UserModel> selectUser = UserModel().obs;
  RxString selectUserId=''.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    await getAllUser();
    await gerBrand();
    await getVehicleList();
    isLoading.value = false;
    update();
  }

  RxList<VehicleBrandModel> brandList = <VehicleBrandModel>[].obs;

  getAllUser()async{
    await FireStoreUtils.getAllUser().then((value) {
      if (value != null) {
        allUserList.value = value;
      }
    });
  }

  gerBrand() async {
    await FireStoreUtils.gerBrand().then((value) {
      if (value != null) {
        brandList.value = value;
      }
    });
  }

  RxList<UserVehicleModel> userVehicle = <UserVehicleModel>[].obs;

  getVehicleList() async {
    isLoading.value = true;
    userVehicle.clear();
    await FireStoreUtils.getUserVehicle().then((value) {
      if (value != null) {
        userVehicle.value = value;
      }
    });
    isLoading.value = false;
  }

  getBrandModel() async {
    ShowToastDialog.showLoader("Please wait");
    vehicleModelList.clear();
    selectedVehicleModel.value = VehicleModel();
    await FireStoreUtils.getVehicleModel(selectedBrand.value.id.toString())
        .then((value) {
      if (value != null) {
        vehicleModelList.value = value;
      }
    });
    ShowToastDialog.closeLoader();
  }

  saveVehicleInformation() async {
    ShowToastDialog.showLoader("Please wait");
    UserVehicleModel userVehicleModel = UserVehicleModel();

    userVehicleModel.vehicleModel = selectedVehicleModel.value;
    userVehicleModel.vehicleBrand = selectedBrand.value;
    userVehicleModel.vehicleNumber = vehicleNumberController.value.text;
    userVehicleModel.id = Constant.getUuid();
    userVehicleModel.userId = selectUserId.value.toString();
    Map<String, String> qrDataMap = {
      "vehicleNumber": userVehicleModel.vehicleNumber.toString(),
      "userId": userVehicleModel.userId.toString(),
      "id": userVehicleModel.id.toString(),
    };
    String qrData = jsonEncode(qrDataMap);
    // print("QrData :: ${qrData}");

    final qrValidationResult = QrValidator.validate(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.qrCode != null) {
      final qrPainter = QrPainter.withQr(
        qr: qrValidationResult.qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      final boundary = await qrPainter.toImageData(2048);
      if (boundary != null) {
        final Uint8List pngBytes = boundary.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qrcode.png');
        await file.writeAsBytes(pngBytes);

        FirebaseStorage storage = FirebaseStorage.instance;

        final String fileName =
            'qrcode_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference ref = storage.ref().child('qr_codes/$fileName');

        UploadTask uploadTask = ref.putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        userVehicleModel.qrCode = downloadUrl.toString();

        await FireStoreUtils.updateUserVehicle(userVehicleModel).then((value) {
          ShowToastDialog.closeLoader();
          getVehicleList();
          isLoading.value = false;
          ShowToastDialog.showToast(
            "New vehicle added".tr,
          );
          Get.back(result: true);
        });
      }
    }
  }
}
