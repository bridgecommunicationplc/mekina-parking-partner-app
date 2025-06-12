import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class MyParkingBookingController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<DateTime> selectedDateTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .obs;
  RxString totalTime = ''.obs;

  var orderSearchList = <OrderModel>[].obs;
  var orderModel = <OrderModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    // getArgument();
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;

  getData() async {
    await FireStoreUtils.getMyParkingList().then((value) {
      if (value != null) {
        parkingList.value = value;
        if (parkingList.isNotEmpty) {
          selectedParkingModel.value = parkingList.first;
        }
      }
    });
    isLoading.value = false;
    update();
  }

  // getArgument() async {
  //   dynamic argumentData = Get.arguments;
  //   if (argumentData != null) {
  //     orderModel.value = argumentData['orderModel'];
  //     getBookedParking();
  //   }
  //   update();
  // }

  confirmPayment(OrderModel orderModel) async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(
        orderModel.parkingDetails!.userId.toString());
    RxDouble couponAmount = 0.0.obs;
    ShowToastDialog.showLoader("Please wait..");
    if (orderModel.coupon != null) {
      if (orderModel.coupon!.id != null) {
        if (orderModel.coupon!.type == "fix") {
          couponAmount.value =
              double.parse(orderModel.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.subTotal.toString()) *
              double.parse(orderModel.coupon!.amount.toString()) /
              100;
        }
      }
    }
    orderModel.paymentCompleted = true;

    if (userModel!.adminCommission != null &&
        userModel.adminCommission!.toJson().isNotEmpty &&
        userModel.adminCommission!.toJson().values.any((element) => element != null)) {
      orderModel.adminCommission = userModel.adminCommission;
    } else {
      orderModel.adminCommission = Constant.adminCommission;
    }

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.paymentType.toString(),
        transactionId: orderModel.id,
        isCredit: false,
        userId: orderModel.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
      }
    });
  }

  String calculateDuration(
      Timestamp bookingStartTime, Timestamp parkingOutTime) {
    DateTime start = bookingStartTime.toDate();
    DateTime end = parkingOutTime.toDate();

    double durationInHours = end.difference(start).inMinutes / 60.0;

    return "${durationInHours.toStringAsFixed(1)} hours";
  }

// getBookedParking() async {
//
//   await FireStoreUtils.getOrderForSearch(selectedParkingModel.value.id.toString())
//       .then((value) {
//     if (value != null) {
//       orderModel.value = value;
//     }
//   });
// }
}
