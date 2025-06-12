import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/review_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class MySummaryController extends GetxController {
  Rx<TextEditingController> couponCodeTextFieldController =
      TextEditingController().obs;
  RxBool isLoading = true.obs;
  RxDouble extraDurationInHours = 0.0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<UserModel> otherUserModel = UserModel().obs;
  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  RxDouble couponAmount = 0.0.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      if (orderModel.value.coupon != null) {
        if (orderModel.value.coupon!.id != null) {
          if (orderModel.value.coupon!.type == "fix") {
            couponAmount.value =
                double.parse(orderModel.value.coupon!.amount.toString());
          } else {
            couponAmount.value =
                double.parse(orderModel.value.subTotal.toString()) *
                    double.parse(orderModel.value.coupon!.amount.toString()) /
                    100;
          }
        }
      }
    }
    getReview();
    update();

    if(orderModel.value.parkingInTime!=null && orderModel.value.parkingOutTime!=null){
      DateTime inTime = orderModel.value.parkingInTime!.toDate();
      DateTime outTime = orderModel.value.parkingOutTime!.toDate();

      DateTime endTime = orderModel.value.
      bookingEndTime!
          .toDate();

      if (inTime != null) {
        if (outTime
            .isAfter(endTime)) {
          Duration extraTime =
          outTime.difference(
              endTime);
          extraDurationInHours.value +=
              extraTime.inMinutes /
                  60;
        }
      }
    }

    update();
  }

  calculateExtraParkingAmount() {
    return double.parse(orderModel.value.perHrPrice.toString()) *
        extraDurationInHours.value;
  }

  getReview() async {
    await FireStoreUtils.getReview(orderModel.value.id.toString())
        .then((value) {
      if (value != null) {
        reviewModel.value = value;
      }
    });
    await FireStoreUtils.getUserProfile(reviewModel.value.customerId.toString())
        .then((value) {
      if (value != null) {
        otherUserModel.value = value;
      }
    });
    isLoading.value = false;
  }

  double calculateAmount() {
    RxString taxAmount = "0.0".obs;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = (double.parse(taxAmount.value) +
                Constant().calculateTax(
                    amount:
                        (double.parse(orderModel.value.subTotal.toString()) -
                                double.parse(couponAmount.toString()))
                            .toString(),
                    taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    double perHrPrice = 0.0;
    double extraTimeHours = 0.0;
    if (orderModel.value.isExtraTimeRequestAccept == true) {
      perHrPrice =
          double.tryParse(orderModel.value.perHrPrice?.toString() ?? '0') ?? 0.0;
      extraTimeHours =
          double.tryParse(orderModel.value.extraTimeHours ?? '0') ?? 0.0;
    }
    return (double.parse(orderModel.value.subTotal.toString()) -
            double.parse(couponAmount.toString())) +
        double.parse(taxAmount.value) +
        (double.parse(orderModel.value.perHrPrice.toString()) *
            extraDurationInHours.value) +
        (perHrPrice * extraTimeHours);
  }

  confirmPayment() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());
    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = true;

    if (userModel!.adminCommission != null &&
        userModel.adminCommission!.toJson().isNotEmpty &&
        userModel.adminCommission!.toJson().values.any((element) => element != null)) {
      orderModel.value.adminCommission = userModel.adminCommission;
    } else {
      orderModel.value.adminCommission = Constant.adminCommission;
    }

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.value.paymentType.toString(),
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.back();
      }
    });
  }
}
