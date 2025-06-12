import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/paymnet_select_controller.dart';
import 'package:owner/payment/createRazorPayOrderModel.dart';
import 'package:owner/payment/rozorpayConroller.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentSelectScreen extends StatelessWidget {
  PaymentSelectScreen({super.key});
  final Razorpay _razorpay = Razorpay();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<PaymentSelectController>(
        init: PaymentSelectController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface()
                .customAppBar(context, themeChange, "Select Payment Method".tr),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.isLoading.value
                        ? Constant.loader()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: controller.paymentModel.value.cash !=
                                          null &&
                                      controller.paymentModel.value.cash!
                                              .enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.cash!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/wallet.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.arifpay !=
                                              null &&
                                          controller.paymentModel.value.arifpay!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      "Telebirr",
                                      themeChange,
                                      "assets/images/telebirr.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.arifpay !=
                                              null &&
                                          controller.paymentModel.value.arifpay!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(controller, "MPesa",
                                      themeChange, "assets/images/mpesa.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.arifpay !=
                                              null &&
                                          controller.paymentModel.value.arifpay!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(controller, "CBE",
                                      themeChange, "assets/images/cbe.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.payfast !=
                                              null &&
                                          controller.paymentModel.value.payfast!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.payfast!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/payfast.png"),
                                ),

                                Visibility(
                                  visible:
                                  controller.paymentModel.value.razorpay !=
                                      null &&
                                      controller.paymentModel.value
                                          .razorpay!.enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.razorpay!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/rezorpay.png"),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemData.grey10
                  : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Pay ${controller.orderModel.value.subTotal}".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    if (controller.selectedPaymentMethod.value == "Telebirr") {
                      await controller.showPhoneNumberDialog(context);
                    } else if (controller.selectedPaymentMethod.value ==
                        "MPesa") {
                      await controller.showMPesaPhoneNumberDialog(context);
                    } else if (controller.selectedPaymentMethod.value ==
                        "CBE") {
                      await controller.showCbePhoneNumberDialog(context);
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.cash!.name) {
                      // controller.completeCashOrder();
                      controller.confirmPayment();
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  cardDecoration(PaymentSelectController controller, String value, themeChange,
      String image) {
    return Obx(
      () => Column(
        children: [
          InkWell(
            onTap: () {
              controller.selectedPaymentMethod.value = value;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemData.grey10
                            : AppThemData.grey03,
                        borderRadius: BorderRadius.circular(10)),
                    child: value.toLowerCase() == 'cash'.toLowerCase()
                        ? SizedBox(
                            width: 80,
                            height: 36,
                            child: Icon(
                              Icons.money,
                              // size: 50,
                            ),
                          )
                        : Image.asset(
                            image,
                            width: 80,
                            height: 36,
                          ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: themeChange.getThem()
                              ? AppThemData.grey01
                              : AppThemData.grey08),
                    ),
                  ),
                  if (value.toLowerCase() == 'wallet'.toLowerCase())
                    Text(
                        Constant.amountShow(
                            amount: controller.userModel.value.walletAmount),
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppThemData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemData.grey01
                                : AppThemData.grey10)),
                  Radio(
                    value: value.toString(),
                    groupValue: controller.selectedPaymentMethod.value,
                    activeColor: themeChange.getThem()
                        ? AppThemData.primary08
                        : AppThemData.primary08,
                    onChanged: (value) {
                      controller.selectedPaymentMethod.value = value.toString();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
