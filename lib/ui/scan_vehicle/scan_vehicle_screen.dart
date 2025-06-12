import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/controller/scan_vehicle_conrtoller.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class ScanVehicleScreen extends StatelessWidget {
  final bool isBack;
  final String vehicleNumber;
  final String userId;
  final String id;
  final Timestamp createdAt;

  const ScanVehicleScreen(
      {required this.isBack,
      super.key,
      required this.vehicleNumber,
      required this.userId,
      required this.id,
      required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final ScanVehicleController controller = Get.put(ScanVehicleController());

    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        'Scan Vehicle'.tr,
        isBack: isBack,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Obx(() {
          if (controller.vehicleList.isEmpty) {
            return Constant.showEmptyView(message: "No Vehicle Scan".tr);
          }
          return ListView.separated(
            itemCount: controller.vehicleList.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, int index) {
              final vehicle = controller.vehicleList[index];
              return VehicleInfoCard(
                vehicle: vehicle,
                themeChange: themeChange,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 8,
              );
            },
          );
        }),
      ),
    );
  }
}

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final DarkThemeProvider themeChange;

  const VehicleInfoCard({
    required this.vehicle,
    required this.themeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.height(12, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${vehicle['vehicleNumber']}",
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemData.grey01
                          : AppThemData.grey10,
                      fontSize: 14,
                      fontFamily: AppThemData.semiBold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm:ss dd MMM yy').format(
                    (vehicle['createdAt'] as Timestamp).toDate(),
                  ),
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.grey01
                        : AppThemData.grey10,
                    fontSize: 14,
                    fontFamily: AppThemData.semiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "ID: ",
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.grey01
                        : AppThemData.grey07,
                    fontSize: 12,
                    fontFamily: AppThemData.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  vehicle['id'],
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.grey01
                        : AppThemData.grey07,
                    fontSize: 12,
                    fontFamily: AppThemData.regular,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "UserID: ",
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.grey01
                        : AppThemData.grey07,
                    fontSize: 12,
                    fontFamily: AppThemData.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  vehicle['userId'],
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.grey01
                        : AppThemData.grey07,
                    fontSize: 12,
                    fontFamily: AppThemData.regular,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
