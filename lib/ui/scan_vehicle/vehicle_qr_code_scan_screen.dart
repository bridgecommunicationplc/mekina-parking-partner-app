import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/ui/scan_vehicle/scan_vehicle_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class VehicleQrCodeScanScreen extends StatelessWidget {
  final String? vehicleNumber;
  final String? userId;
  final String? id;
  final Timestamp? createdAt;

  const VehicleQrCodeScanScreen(
      {super.key, this.vehicleNumber, this.userId, this.id, this.createdAt});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        'Scan QR code'.tr,
      ),
      body: MobileScanner(onDetect: (capture) async {
        final List<Barcode> barcodes = capture.barcodes;
        // final Uint8List? image = capture.image;
        for (final barcode in barcodes) {
          Get.back();
          print("barcodeRawValue: ${barcode.rawValue}");

          if (barcode.rawValue == null) {
            ShowToastDialog.showToast("Invalid QR code".tr);
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

              ShowToastDialog.showLoader("Please wait".tr);
              await FirebaseFirestore.instance.collection('scan_vehicle').add({
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
              ShowToastDialog.showToast("Invalid QR code".tr);
            }
          } catch (e) {
            ShowToastDialog.showToast("Error parsing QR code".tr);
          }
        }
      }),
    );
  }
}
