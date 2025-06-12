import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/send_notification.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/dashboard_controller.dart';
import 'package:owner/controller/parking_view_controller.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/ui/booking_process/review_summery_screen.dart';
import 'package:owner/ui/dashboard_screen.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class ParkingViewScreen extends StatelessWidget {
  const ParkingViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ParkingViewController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "pick_parking_spot".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                        itemCount: int.parse(controller.parkingModel.value.parkingSpace.toString()),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(4.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                        itemBuilder: (context, int index) {
                          return Obx(
                            () {
                              var isBooked = controller.selectedOrderModel.where((element) => element.parkingSlotId.toString() == "A-${index + 1}");
                              print("isBooked ${isBooked}");
                              return InkWell(
                                onTap: () {
                                  if (isBooked.isEmpty) {
                                    controller.selectedParking.value = "A-${index + 1}";
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: index.isEven ? const BorderSide(color: AppThemData.grey04) : BorderSide.none,
                                          bottom: const BorderSide(color: AppThemData.grey04),
                                          top: const BorderSide(color: AppThemData.grey04),
                                          left: index.isOdd ? const BorderSide(color: AppThemData.grey04) : BorderSide.none)),
                                  child: isBooked.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Image.asset(
                                            "assets/images/car_image.png",
                                          ),
                                        )
                                      : controller.selectedParking.value == "A-${index + 1}"
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey04),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset("assets/icon/ic_parking_select.svg", width: 24, height: 24),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'A-${index + 1}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: AppThemData.medium,
                                                      color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary07,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Center(
                                                child: Text(
                                                  'A-${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                                                  ),
                                                ),
                                              ),
                                            ),
                                ),
                              );
                            },
                          );
                        }),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Book".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    if (controller.selectedParking.value.isEmpty) {
                      ShowToastDialog.showToast("Please select your parking".tr);
                    } else {
                      ShowToastDialog.showLoader("Please wait...".tr);
                      controller.orderModel.value.parkingSlotId = controller.selectedParking.value;
                      UserModel? receiverUserModel =
                          await FireStoreUtils.getUserProfile(
                          controller.orderModel.value.parkingDetails!.userId.toString());

                      UserModel? userModel =
                          await FireStoreUtils.getUserProfile(
                              controller.orderModel.value.userId.toString());

                      Map<String, dynamic> playLoad = <String, dynamic>{
                        "type": "order",
                        "orderId": controller.orderModel.value.id
                      };
                      // await SendNotification.sendOneNotification(
                      //     token: userModel!.fcmToken.toString(),
                      //     title: 'Thank You for Using Our Parking Service!',
                      //     body:
                      //         'Thanks for parking with us. We look forward to welcoming you again!',
                      //     payload: playLoad);
                      await SendNotification.sendOneNotification(
                          token: receiverUserModel!.fcmToken.toString(),
                          title: 'Booking Placed',
                          body:
                          '${controller.orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(controller.orderModel.value.bookingDate!)}.',
                          payload: playLoad);

                      await FireStoreUtils.setOrder(controller.orderModel.value).then((value) {
                        if (value == true) {
                          ShowToastDialog.closeLoader();
                          DashboardScreenController dashboardController =
                          Get.put(DashboardScreenController());
                          dashboardController.selectedIndex(1);
                          Get.offAll(() => const DashBoardScreen());
                        }
                      });
                      // Get.to(() => const ReviewSummaryScreen(), arguments: {"orderModel": controller.orderModel.value});
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
