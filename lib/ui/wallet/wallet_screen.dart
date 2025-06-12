import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/wallet_controller.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/model/withdraw_model.dart';
import 'package:owner/payment/createRazorPayOrderModel.dart';
import 'package:owner/payment/rozorpayConroller.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/themes/responsive.dart';
import 'package:owner/themes/round_button_fill.dart';
import 'package:owner/themes/text_field_widget.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:owner/utils/file_handle_api.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/utils/pdf_invoice_formate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  final bool isBack;

  WalletScreen({required this.isBack, super.key});

  PdfColor themeColor = PdfColors.black;
  pw.Font font = pw.Font.courier();
  WalletController walletController = Get.put(WalletController());
  String transactionId = '';

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final List<String> paymentMethods = ["Telebirr", "CBE"];
    return GetX<WalletController>(
        init: WalletController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
                context, themeChange, "Wallet".tr,
                isBack: isBack),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: Responsive.width(100, context),
                          decoration: const BoxDecoration(
                            color: Color(0xff1c0493),
                            // image: DecorationImage(

                            // image: ExactAssetImage(
                            //     'assets/images/ic_wallet_bg.png'),
                            // fit: BoxFit.fill),
                          ),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "Total Amount".tr,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppThemData.medium,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                Constant.amountShow(
                                    amount: controller
                                        .userModel.value.walletAmount),
                                style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: AppThemData.bold,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Minimum Withdrawal will be a ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal.toString())}"
                                  .tr,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppThemData.medium,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RoundedButtonFill(
                                      title: "Add Cash".tr,
                                      color: AppThemData.white,
                                      textColor: Colors.black,
                                      icon: const Icon(Icons.add,
                                          color: Colors.black),
                                      isRight: false,
                                      onPress: () {
                                        paymentMethodDialog(
                                            context, controller, themeChange);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: RoundedButtonFill(
                                      title: "Withdrawal".tr,
                                      color: AppThemData.primary05,
                                      onPress: () async {
                                        if (double.parse(controller
                                                .userModel.value.walletAmount
                                                .toString()) <=
                                            double.parse(Constant
                                                .minimumAmountToWithdrawal
                                                .toString())) {
                                          ShowToastDialog.showToast(
                                              "Insufficient balance".tr);
                                        } else {
                                          // ShowToastDialog.showLoader(
                                          //     "Please wait".tr);
                                          // await FireStoreUtils
                                          //         .bankDetailsIsAvailable()
                                          //     .then((value) {
                                          //   ShowToastDialog.closeLoader();
                                          //   if (value == true) {
                                          withdrawalBottomSheet(
                                              context, controller, themeChange);
                                          // } else {
                                          //   ShowToastDialog.showToast(
                                          //       "Your bank details is not available.Please add bank details"
                                          //           .tr);
                                          // }
                                          // });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TabBar(
                                  onTap: (value) {
                                    controller.selectedTabIndex.value = value;
                                  },
                                  labelStyle: const TextStyle(
                                      fontFamily: AppThemData.semiBold),
                                  labelColor: themeChange.getThem()
                                      ? AppThemData.primary07
                                      : AppThemData.grey10,
                                  unselectedLabelStyle: const TextStyle(
                                      fontFamily: AppThemData.medium),
                                  unselectedLabelColor: themeChange.getThem()
                                      ? AppThemData.grey06
                                      : AppThemData.grey06,
                                  indicatorColor: AppThemData.primary06,
                                  indicatorWeight: 1,
                                  tabs: [
                                    Tab(
                                      text: "Transaction History".tr,
                                    ),
                                    Tab(
                                      text: "Withdrawal History".tr,
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      controller.transactionList.isEmpty
                                          ? Constant.showEmptyView(
                                              message:
                                                  "Transaction not found".tr)
                                          : ListView.builder(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              itemCount: controller
                                                  .transactionList.length,
                                              itemBuilder: (context, index) {
                                                WalletTransactionModel
                                                    walletTractionModel =
                                                    controller
                                                        .transactionList[index];
                                                return transactionCard(
                                                    controller,
                                                    themeChange,
                                                    walletTractionModel);
                                              },
                                            ),
                                      FutureBuilder<List<WithdrawModel>?>(
                                          future: FireStoreUtils
                                              .getWithDrawRequest(),
                                          builder: (context, snapshot) {
                                            switch (snapshot.connectionState) {
                                              case ConnectionState.waiting:
                                                return Constant.loader();
                                              case ConnectionState.done:
                                                if (snapshot.hasError) {
                                                  return Text(snapshot.error
                                                      .toString());
                                                } else {
                                                  return snapshot.data!.isEmpty
                                                      ? Constant.showEmptyView(
                                                          message:
                                                              "No withdrawal history found"
                                                                  .tr)
                                                      : ListView.builder(
                                                          itemCount: snapshot
                                                              .data!.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            WithdrawModel
                                                                walletTransactionModel =
                                                                snapshot.data![
                                                                    index];
                                                            Timestamp
                                                                walletTransactionDate =
                                                                walletTransactionModel
                                                                    .createdDate!;
                                                            String
                                                                formattedDate =
                                                                controller
                                                                    .formatTimestamp(
                                                                        walletTransactionDate);
                                                            int amount = int.parse(
                                                                walletTransactionModel
                                                                    .amount
                                                                    .toString());
                                                            String words =
                                                                NumberToWordsEnglish
                                                                    .convert(
                                                                        amount);
                                                            transactionId =
                                                                walletTransactionModel
                                                                    .transactionId
                                                                    .toString();
                                                            return Column(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {},
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            5),
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          "assets/icon/ic_wallet_debit.svg",
                                                                          width:
                                                                              52,
                                                                          height:
                                                                              52,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      walletTransactionModel.note.toString(),
                                                                                      style: TextStyle(
                                                                                        fontSize: 16,
                                                                                        fontFamily: AppThemData.medium,
                                                                                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    Constant.amountShow(amount: walletTransactionModel.amount.toString()),
                                                                                    style: TextStyle(
                                                                                      fontSize: 16,
                                                                                      fontFamily: AppThemData.medium,
                                                                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      Constant.timestampToDate(walletTransactionModel.createdDate!),
                                                                                      style: TextStyle(fontSize: 12, fontFamily: AppThemData.regular, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    walletTransactionModel.paymentStatus.toString().toUpperCase(),
                                                                                    style: TextStyle(
                                                                                        fontSize: 12,
                                                                                        fontFamily: AppThemData.regular,
                                                                                        color: walletTransactionModel.paymentStatus == "pending"
                                                                                            ? Colors.blue
                                                                                            : walletTransactionModel.paymentStatus == "rejected"
                                                                                                ? Colors.red
                                                                                                : Colors.green),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  walletTransactionModel.paymentStatus == "approved"
                                                                                      ? IconButton(
                                                                                          icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                                                                                          padding: EdgeInsets.zero,
                                                                                          onPressed: () {
                                                                                            generateInvoiceAndView(phoneNumber: walletTransactionModel.phone.toString(), paymentStatus: walletTransactionModel.paymentStatus.toString(), createdAt: formattedDate.toString(), sessionId: walletTransactionModel.transactionId.toString(), amount: walletTransactionModel.amount.toString(), wordsAmount: words.toString(), note: walletTransactionModel.note.toString(), withdrawMethod: walletTransactionModel.withdrawMethod.toString(), serviceFee: walletTransactionModel.serviceFees.toString());
                                                                                          },
                                                                                        )
                                                                                      : SizedBox.shrink(),
                                                                                  walletTransactionModel.paymentStatus == "approved"
                                                                                      ? IconButton(
                                                                                          icon: Icon(Icons.download, color: Colors.grey),
                                                                                          padding: EdgeInsets.zero,
                                                                                          onPressed: () {
                                                                                            generateInvoiceAndDownload(phoneNumber: walletTransactionModel.phone.toString(), paymentStatus: walletTransactionModel.paymentStatus.toString(), createdAt: formattedDate.toString(), sessionId: walletTransactionModel.transactionId.toString(), amount: walletTransactionModel.amount.toString(), wordsAmount: words.toString(), note: walletTransactionModel.note.toString(), withdrawMethod: walletTransactionModel.withdrawMethod.toString(), serviceFee: walletTransactionModel.serviceFees.toString());
                                                                                          },
                                                                                        )
                                                                                      : SizedBox.shrink(),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Divider(
                                                                    thickness:
                                                                        1,
                                                                    color: AppThemData
                                                                        .grey04),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                }
                                              default:
                                                return Text('Error'.tr);
                                            }
                                          })
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  paymentMethodDialog(
      BuildContext context, WalletController controller, themeChange) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: StatefulBuilder(builder: (context1, setState) {
                return Obx(
                  () => Scaffold(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: themeChange.getThem()
                              ? AppThemData.grey10
                              : AppThemData.grey01,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Container(
                                    width: 134,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemData.grey01
                                          : AppThemData.labelColorLightPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Add Money to Wallet'.tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: AppThemData.medium,
                                          color: themeChange.getThem()
                                              ? AppThemData.grey01
                                              : AppThemData.grey10,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: themeChange.getThem()
                                            ? AppThemData.grey01
                                            : AppThemData.grey10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFieldWidget(
                            title: 'Enter Amount'.tr,
                            onPress: () {},
                            controller: controller.amountController.value,
                            hintText: 'Enter Amount'.tr,
                            textInputType:
                                const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9]')),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  Constant.currencyModel!.symbol.toString(),
                                  style: const TextStyle(
                                      fontSize: 20, color: AppThemData.grey08)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppThemData.blueLight07,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Minimum amount will be a ${Constant.amountShow(amount: Constant.minimumAmountToDeposit.toString())}"
                                    .tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: AppThemData.medium,
                                    color: themeChange.getThem()
                                        ? AppThemData.blueLight07
                                        : AppThemData.blueLight07),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.strip !=
                                              null &&
                                          controller.paymentModel.value.strip!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.strip!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/strip.png"),
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
                                      controller.paymentModel.value.paypal !=
                                              null &&
                                          controller.paymentModel.value.paypal!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.paypal!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/paypal.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.payStack !=
                                              null &&
                                          controller.paymentModel.value
                                                  .payStack!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.payStack!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/paystack.png"),
                                ),
                                Visibility(
                                  visible: controller
                                              .paymentModel.value.mercadoPago !=
                                          null &&
                                      controller.paymentModel.value.mercadoPago!
                                              .enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.mercadoPago!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/mercadopogo.png"),
                                ),
                                Visibility(
                                  visible: controller
                                              .paymentModel.value.flutterWave !=
                                          null &&
                                      controller.paymentModel.value.flutterWave!
                                              .enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.flutterWave!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/flutterwave.png"),
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
                                // Visibility(
                                //   visible: controller.paymentModel.value.paytm != null && controller.paymentModel.value.paytm!.enable == true,
                                //   child: cardDecoration(controller, controller.paymentModel.value.paytm!.name.toString(), themeChange, "assets/images/paytm.png"),
                                // ),
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
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.xendit !=
                                              null &&
                                          controller.paymentModel.value.xendit!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.xendit!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/xendit.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.orangePay !=
                                              null &&
                                          controller.paymentModel.value
                                                  .orangePay!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.orangePay!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/orangeMoney.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.midtrans !=
                                              null &&
                                          controller.paymentModel.value
                                                  .midtrans!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.midtrans!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/midtrans.png"),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottomNavigationBar: Container(
                      color: themeChange.getThem()
                          ? AppThemData.grey10
                          : AppThemData.grey11,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RoundedButtonFill(
                          title: "Topup".tr,
                          height: 5.5,
                          color: AppThemData.primary06,
                          fontSizes: 16,
                          onPress: () async {
                            if (controller
                                .amountController.value.text.isNotEmpty) {
                              Get.back();
                              if (double.parse(
                                      controller.amountController.value.text) >=
                                  double.parse(Constant.minimumAmountToDeposit
                                      .toString())) {
                                // if (controller.selectedPaymentMethod.value ==
                                //     controller.paymentModel.value.strip!.name) {
                                //   controller.stripeMakePayment(
                                //       amount: controller
                                //           .amountController.value.text);
                                // } else
                                if (controller.selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.paypal!.name) {
                                  // controller.paypalPayment(controller.amountController.value.text);
                                  controller.paypalPaymentSheet(
                                      controller.amountController.value.text);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    "Telebirr") {
                                  await controller
                                      .showPhoneNumberDialog(context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    "MPesa") {
                                  await controller
                                      .showMPesaPhoneNumberDialog(context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    "CBE") {
                                  await controller
                                      .showCbePhoneNumberDialog(context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.payStack!.name) {
                                  controller.payStackPayment(
                                      controller.amountController.value.text);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.mercadoPago!.name) {
                                  controller.mercadoPagoMakePayment(
                                      context: context,
                                      amount: controller
                                          .amountController.value.text);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.flutterWave!.name) {
                                  controller.flutterWaveInitiatePayment(
                                      context: context,
                                      amount: controller
                                          .amountController.value.text);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.payfast!.name) {
                                  controller.payFastPayment(
                                      context: context,
                                      amount: controller
                                          .amountController.value.text);
                                }
                                // else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name) {
                                //   controller.getPaytmCheckSum(context, amount: double.parse(controller.amountController.value.text));
                                // }
                                else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.xendit!.name) {
                                  controller.xenditPayment(
                                      context,
                                      double.parse(controller
                                          .amountController.value.text));
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.orangePay!.name) {
                                  controller.orangeMakePayment(
                                      amount: controller
                                          .amountController.value.text
                                          .toString(),
                                      context: context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.midtrans!.name) {
                                  controller.midtransMakePayment(
                                      amount: controller
                                          .amountController.value.text
                                          .toString(),
                                      context: context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    controller
                                        .paymentModel.value.razorpay!.name) {
                                  RazorPayController()
                                      .createOrderRazorPay(
                                          amount: int.parse(controller
                                              .amountController.value.text),
                                          razorpayModel: controller
                                              .paymentModel.value.razorpay)
                                      .then((value) {
                                    if (value == null) {
                                      Get.back();
                                      ShowToastDialog.showToast(
                                          "Something went wrong, please contact admin."
                                              .tr);
                                    } else {
                                      CreateRazorPayOrderModel result = value;
                                      controller.openCheckout(
                                          amount: controller
                                              .amountController.value.text,
                                          orderId: result.id);
                                    }
                                  });
                                } else {
                                  ShowToastDialog.showToast(
                                      "Please select payment method".tr);
                                }
                              } else {
                                ShowToastDialog.showToast(
                                    "Please Enter minimum amount of ${Constant.amountShow(amount: Constant.minimumAmountToDeposit)}"
                                        .tr);
                              }
                            } else {
                              ShowToastDialog.showToast(
                                  "Please enter amount".tr);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ));
  }

  transactionCard(WalletController controller, themeChange,
      WalletTransactionModel transactionModel) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SvgPicture.asset(
                  transactionModel.isCredit == true
                      ? "assets/icon/ic_wallet_credit.svg"
                      : "assets/icon/ic_wallet_debit.svg",
                  width: 52,
                  height: 52,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transactionModel.note.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppThemData.medium,
                                color: themeChange.getThem()
                                    ? AppThemData.grey01
                                    : AppThemData.grey09,
                              ),
                            ),
                          ),
                          Text(
                            "${transactionModel.isCredit == false ? "(-" : ""}${Constant.amountShow(amount: transactionModel.amount.toString().replaceAll("-", " "))}${transactionModel.isCredit == false ? ")" : ""}",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppThemData.medium,
                              color: themeChange.getThem()
                                  ? AppThemData.grey01
                                  : AppThemData.grey09,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        Constant.timestampToDate(transactionModel.createdDate!),
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: AppThemData.regular,
                            color: themeChange.getThem()
                                ? AppThemData.grey07
                                : AppThemData.grey07),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(thickness: 1, color: AppThemData.grey04),
      ],
    );
  }

  cardDecoration(
      WalletController controller, String value, themeChange, String image) {
    return Obx(
      () => Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              controller.selectedPaymentMethod.value = value;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemData.grey10
                            : AppThemData.grey03,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Image.asset(
                        image,
                        width: 60,
                        height: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppThemData.bold,
                          color: themeChange.getThem()
                              ? AppThemData.grey06
                              : AppThemData.grey10),
                    ),
                  ),
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
          Divider(
              thickness: 1,
              color: themeChange.getThem()
                  ? AppThemData.grey08
                  : AppThemData.grey04),
        ],
      ),
    );
  }

  withdrawalBottomSheet(
      BuildContext context, WalletController controller, themeChange) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.6,
              child: StatefulBuilder(builder: (context1, setState) {
                return Obx(
                  () => Scaffold(
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                width: 134,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: ShapeDecoration(
                                  color: AppThemData.labelColorLightPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Withdrawal'.tr,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: AppThemData.medium,
                                      color: themeChange.getThem()
                                          ? AppThemData.grey01
                                          : AppThemData.grey10,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: themeChange.getThem()
                                        ? AppThemData.grey01
                                        : AppThemData.grey10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              color: themeChange.getThem()
                                  ? AppThemData.grey09
                                  : AppThemData.grey03,
                              thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFieldWidget(
                              title: 'Amount'.tr,
                              onPress: () {},
                              controller:
                                  controller.withdrawalAmountController.value,
                              hintText: 'Enter Amount'.tr,
                              textInputType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]')),
                              ],
                              prefix: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                    Constant.currencyModel!.symbol.toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: AppThemData.grey08)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: Text("Payment Method".tr,
                                style: const TextStyle(
                                    fontFamily: AppThemData.medium,
                                    fontSize: 14,
                                    color: AppThemData.grey07)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                errorStyle: const TextStyle(color: Colors.red),
                                isDense: true,
                                filled: true,
                                fillColor: themeChange.getThem()
                                    ? AppThemData.grey10
                                    : AppThemData.grey03,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 10),
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
                              value: controller.selectedPayment.value.isEmpty
                                  ? null
                                  : controller.selectedPayment.value,
                              hint: Text("Select Payment Method"),
                              items: controller.paymentMethods
                                  .map((String method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  controller.selectedPayment.value =
                                      newValue ?? ""; // Store selected value
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 18.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFieldWidget(
                              title: 'Note'.tr,
                              onPress: () {},
                              controller: controller.noteController.value,
                              hintText: 'Enter Note'.tr,
                              textInputType: TextInputType.text,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFieldWidget(
                              title: 'Email Address'.tr,
                              onPress: () {},
                              controller:
                                  controller.emailAddressController.value,
                              hintText: 'Enter Email Address'.tr,
                              textInputType: TextInputType.text,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 16),
                          //   child: TextFieldWidget(
                          //     title: 'Phone Number'.tr,
                          //     onPress: () {},
                          //     controller:
                          //         controller.phoneNumberController.value,
                          //     hintText: 'Enter Phone Number'.tr,
                          //     textInputType: TextInputType.text,
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppThemData.blueLight07,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "minimum withdrawal amount will be a  ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal.toString())}"
                                      .tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppThemData.medium,
                                      color: themeChange.getThem()
                                          ? AppThemData.blueLight07
                                          : AppThemData.blueLight07),
                                ),
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'Bank Details'.tr,
                          //         style: TextStyle(
                          //           fontSize: 14,
                          //           fontFamily: AppThemData.medium,
                          //           color: themeChange.getThem()
                          //               ? AppThemData.grey07
                          //               : AppThemData.grey07,
                          //         ),
                          //       ),
                          //       const SizedBox(
                          //         height: 10,
                          //       ),
                          //       Row(
                          //         children: [
                          //           SvgPicture.asset(
                          //               "assets/icon/ic_bank_image.svg",
                          //               height: 45,
                          //               width: 45),
                          //           const SizedBox(
                          //             width: 10,
                          //           ),
                          //           Expanded(
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 Text(
                          //                   controller
                          //                       .bankDetailsModel.value.bankName
                          //                       .toString(),
                          //                   style: TextStyle(
                          //                     fontSize: 16,
                          //                     fontFamily: AppThemData.bold,
                          //                     color: themeChange.getThem()
                          //                         ? AppThemData.grey01
                          //                         : AppThemData.grey09,
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                   controller.bankDetailsModel.value
                          //                       .branchName
                          //                       .toString(),
                          //                   style: TextStyle(
                          //                     fontSize: 14,
                          //                     fontFamily: AppThemData.regular,
                          //                     color: themeChange.getThem()
                          //                         ? AppThemData.grey06
                          //                         : AppThemData.grey06,
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                   controller.bankDetailsModel.value
                          //                       .accountNumber
                          //                       .toString(),
                          //                   style: TextStyle(
                          //                     fontSize: 14,
                          //                     fontFamily: AppThemData.regular,
                          //                     color: themeChange.getThem()
                          //                         ? AppThemData.grey06
                          //                         : AppThemData.grey06,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    bottomNavigationBar: Container(
                      color: themeChange.getThem()
                          ? AppThemData.grey10
                          : AppThemData.grey11,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RoundedButtonFill(
                          title: "Withdraw".tr,
                          height: 5.5,
                          color: AppThemData.primary06,
                          fontSizes: 16,
                          onPress: () async {
                            double walletAmount = double.tryParse(controller
                                    .userModel.value.walletAmount
                                    .toString()) ??
                                0.0;
                            double withdrawalAmount = double.tryParse(controller
                                    .withdrawalAmountController.value.text) ??
                                0.0;
                            if (controller
                                    .amountController.value.text.isEmpty &&
                                controller.selectedPayment.value.isEmpty) {
                              ShowToastDialog.showToast(
                                  "Please enter amount and select payment method"
                                      .tr);
                            } else {
                              Get.back();
                              if (controller.selectedPayment.value ==
                                  'Telebirr') {
                                await controller
                                    .showTelebirrB2cNumberDialog(context);
                              } else if (controller.selectedPayment.value ==
                                  'Cbe') {
                                await controller
                                    .showCbeB2cNumberDialog(context);
                              } else if (walletAmount < withdrawalAmount) {
                                ShowToastDialog.showToast(
                                    "Insufficient balance".tr);
                              } else if (double.parse(
                                      Constant.minimumAmountToWithdrawal) >
                                  withdrawalAmount) {
                                ShowToastDialog.showToast(
                                    "Withdraw amount must be greater or equal to ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal.toString())}"
                                        .tr);
                              } else {
                                // ShowToastDialog.showLoader("Please wait".tr);
                                // WithdrawModel withdrawModel = WithdrawModel();
                                // withdrawModel.id = Constant.getUuid();
                                // withdrawModel.userId =
                                //     FireStoreUtils.getCurrentUid();
                                // withdrawModel.paymentStatus = "pending";
                                // withdrawModel.amount = controller
                                //     .withdrawalAmountController.value.text;
                                // withdrawModel.note =
                                //     controller.noteController.value.text;
                                // withdrawModel.createdDate = Timestamp.now();
                                // withdrawModel.email =
                                //     controller.userModel.value.email;
                                // withdrawModel.phone =
                                //     controller.phoneNumberController.value.text;
                                // withdrawModel.withdrawMethod =
                                //     controller.selectedPayment.value;
                                //
                                // await FireStoreUtils.updateUserWallet(
                                //     amount:
                                //         "-${controller.withdrawalAmountController.value.text}");
                                //
                                // await FireStoreUtils.setWithdrawRequest(
                                //         withdrawModel)
                                //     .then((value) {
                                //   controller.getUser();
                                //   ShowToastDialog.closeLoader();
                                //   ShowToastDialog.showToast(
                                //       "Request sent to admin".tr);
                                //   Get.back();
                                // });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ));
  }

  generateInvoiceAndView(
      {required String phoneNumber,
      required String paymentStatus,
      required String createdAt,
      required String sessionId,
      required String amount,
      required String wordsAmount,
      required String note,
      required String withdrawMethod,
      required String serviceFee}) async {
    pw.Document pdfFile = await PdfInvoiceApi.generate(
        themeColor,
        pw.Font.courier(),
        walletController.userModel.value,
        phoneNumber,
        paymentStatus,
        createdAt,
        sessionId,
        amount,
        wordsAmount,
        note,
        withdrawMethod,
        serviceFee
        // walletModel,
        );

    await FileHandleApi.openFile(
        // name: 'invoice_${walletModel.txnId}.pdf', pdf: pdfFile);
        name: 'invoice.pdf_${transactionId}.pdf',
        pdf: pdfFile);
  }

  generateInvoiceAndDownload(
      {required String phoneNumber,
      required String paymentStatus,
      required String createdAt,
      required String sessionId,
      required String amount,
      required String wordsAmount,
      required String note,
      required String withdrawMethod,
      required String serviceFee}) async {
    ShowToastDialog.showLoader("Downloading file");
    pw.Document pdfFile = await PdfInvoiceApi.generate(
        themeColor,
        pw.Font.courier(),
        walletController.userModel.value,
        phoneNumber,
        paymentStatus,
        createdAt,
        sessionId,
        amount,
        wordsAmount,
        note,
        withdrawMethod,
        serviceFee
        // walletModel,
        );

    FileHandleApi.saveDocument(
        name: 'invoice_${transactionId}_${Constant.getUuid()}.pdf',
        pdf: pdfFile);
  }
}
