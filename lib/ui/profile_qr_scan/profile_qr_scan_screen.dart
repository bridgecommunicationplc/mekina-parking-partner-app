import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:owner/constant/collection_name.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/dashboard_controller.dart';
import 'package:owner/controller/profile_controller.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/ui/after_scanned/after_scanned_screen.dart';
import 'package:owner/ui/after_scanned/early_arrive_screen.dart';
import 'package:owner/ui/dashboard_screen.dart';
import 'package:owner/ui/scan_vehicle/scan_vehicle_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class ProfileQrCodeScanScreen extends StatelessWidget {
  final String? orderId;

  const ProfileQrCodeScanScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final ProfileController profileController = Get.find<ProfileController>();
    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        'Scan QR code'.tr,
      ),
      body: MobileScanner(
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            final rawValue = barcode.rawValue;
            Get.back();
            if (rawValue == null) {
              DashboardScreenController dashboardController =
                  Get.put(DashboardScreenController());
              dashboardController.selectedIndex(0);
              Get.offAll(() => const DashBoardScreen());
              ShowToastDialog.showToast("No Parking Found");
              continue;
            }
            try {
              final Map<String, dynamic> parsedData =
                  jsonDecode(barcode.rawValue!);
              if (parsedData.containsKey('vehicleNumber') &&
                  parsedData.containsKey('userId') &&
                  parsedData.containsKey('id')) {
                final String vehicleNumber = parsedData['vehicleNumber'];
                final String userId = parsedData['userId'];
                final String id = parsedData['id'];
                // if (profileController.matchedVehicleId.value.trim() ==
                //     parsedData['userId'].toString().trim()) {
                if(profileController.userSubscriptionIds.contains(userId)){
                  ShowToastDialog.showLoader("Please wait".tr);
                  await FirebaseFirestore.instance
                      .collection('scan_vehicle')
                      .add({
                    'vehicleNumber': vehicleNumber,
                    'userId': FireStoreUtils.getCurrentUid(),
                    'id': id,
                    'createdAt': Timestamp.now(),
                  });
                  ShowToastDialog.closeLoader();
                  Get.to(ScanVehicleScreen(
                      isBack: true,
                      vehicleNumber: '',
                      userId: '',
                      id: '',
                      createdAt: Timestamp.now()));
                  ShowToastDialog.showToast("Qr Code scan successfully".tr);
                } else {
                  DashboardScreenController dashboardController =
                      Get.put(DashboardScreenController());
                  dashboardController.selectedIndex(0);
                  Get.offAll(() => const DashBoardScreen());
                  ShowToastDialog.showToast("Subscription Not Found".tr);
                }
              }
            } catch (e) {
              if (orderId == null) {
                ShowToastDialog.showLoader("Please wait".tr);
                await FireStoreUtils.fireStore
                    .collection(CollectionName.bookedParkingOrder)
                    .doc(barcode.rawValue)
                    .get()
                    .then((value) async {
                  OrderModel orderModel = OrderModel.fromJson(value.data()!);
                  ShowToastDialog.closeLoader();
                  if (orderModel.parkingDetails!.userId !=
                      FireStoreUtils.getCurrentUid()) {
                    ShowToastDialog.showToast("Invalid QR code".tr);
                  } else if (orderModel.status == Constant.completed) {
                    ShowToastDialog.showToast(
                        "This booking already completed".tr);
                  } else if (orderModel.status == Constant.onGoing) {
                    ShowToastDialog.showToast("This Order already scanned".tr);
                  } else if (DateTime.now()
                      .isBefore(orderModel.bookingStartTime!.toDate())) {
                    Get.to(() => const EarlyArriveScreen(),
                        arguments: {"orderModel": orderModel});
                  } else {
                    Get.to(
                        () => const AfterScannedScreen(
                              isEarlyScan: true,
                            ),
                        arguments: {"orderModel": orderModel});
                  }
                });
                debugPrint('Barcode found! ${barcode.rawValue}'.tr);
              } else if (rawValue == orderId) {
                await FireStoreUtils.fireStore
                    .collection(CollectionName.bookedParkingOrder)
                    .doc(barcode.rawValue)
                    .get()
                    .then((value) async {
                  OrderModel orderModel = OrderModel.fromJson(value.data()!);
                  ShowToastDialog.closeLoader();
                  if (orderModel.parkingDetails!.userId !=
                      FireStoreUtils.getCurrentUid()) {
                    ShowToastDialog.showToast("Invalid QR code".tr);
                  } else if (orderModel.status == Constant.completed) {
                    ShowToastDialog.showToast(
                        "This booking already completed".tr);
                  } else if (orderModel.status == Constant.onGoing) {
                    ShowToastDialog.showToast("This Order already scanned".tr);
                  } else if (DateTime.now()
                      .isBefore(orderModel.bookingStartTime!.toDate())) {
                    Get.to(() => const EarlyArriveScreen(),
                        arguments: {"orderModel": orderModel});
                  } else {
                    Get.to(
                        () => const AfterScannedScreen(
                              isEarlyScan: true,
                            ),
                        arguments: {"orderModel": orderModel});
                  }
                });
              } else {
                ShowToastDialog.showToast("Invalid QR code".tr);
              }
            }
          }
        },
      ),
    );
  }
}
