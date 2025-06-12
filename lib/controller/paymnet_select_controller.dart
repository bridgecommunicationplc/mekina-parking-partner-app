import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/send_notification.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/controller/dashboard_controller.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/payment_method_model.dart';
import 'package:owner/model/payment_transaction_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/ui/dashboard_screen.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class PaymentSelectController extends GetxController {
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxBool isLoading = false.obs;

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getArgument();
    getPaymentData();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      update();
    }
    update();
  }

  getPaymentData() async {
    isLoading.value = true;
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        selectedPaymentMethod.value = orderModel.value.paymentType.toString();
      }
    });

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });

    isLoading.value = false;
    update();
  }

  RxDouble couponAmount = 0.0.obs;

  double calculateAmount() {
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
    return (double.parse(orderModel.value.subTotal.toString()) -
            double.parse(couponAmount.toString())) +
        double.parse(taxAmount.value);
  }

  completeCashOrder() async {
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());
    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = false;
    orderModel.value.paymentType = selectedPaymentMethod.value;
    if (receiverUserModel!.adminCommission != null &&
        receiverUserModel.adminCommission!.toJson().isNotEmpty &&
        receiverUserModel.adminCommission!
            .toJson()
            .values
            .any((element) => element != null)) {
      orderModel.value.adminCommission = receiverUserModel.adminCommission;
    } else {
      orderModel.value.adminCommission = Constant.adminCommission;
    }
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();

    UserModel? userModel =
        await FireStoreUtils.getUserProfile(orderModel.value.userId.toString());

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "order",
      "orderId": orderModel.value.id
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
            '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
        payload: playLoad);

    // await FireStoreUtils.getWatchman(
    //         orderModel.value.parkingDetails!.id.toString(),
    //         orderModel.value.parkingDetails!.userId.toString())
    //     .then((value) async {
    //   if (value != null) {
    //     await SendNotification.sendOneNotification(
    //         token: value.fcmToken.toString(),
    //         title: 'Booking Placed',
    //         body:
    //             '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
    //         payload: playLoad);
    //   }
    // });

    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        DashboardScreenController dashboardController =
            Get.put(DashboardScreenController());
        dashboardController.selectedIndex(1);
        Get.offAll(() => const DashBoardScreen());
        // Get.to(() => const ParkingTicketScreen(), arguments: {"orderModel": orderModel.value});
      }
    });
  }

  completeOrder() async {
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());

    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = true;
    if (orderModel.value.duration != null && double.parse(orderModel.value.duration.toString()) >= 1.0) {
      orderModel.value.extraPaymentCompleted = true;
    }
    orderModel.value.paymentType = selectedPaymentMethod.value;
    if (receiverUserModel!.adminCommission != null &&
        receiverUserModel.adminCommission!.toJson().isNotEmpty &&
        receiverUserModel.adminCommission!
            .toJson()
            .values
            .any((element) => element != null)) {
      orderModel.value.adminCommission = receiverUserModel.adminCommission;
    } else {
      orderModel.value.adminCommission = Constant.adminCommission;
    }
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();
    orderModel.value.status = Constant.completed;
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: calculateAmount().toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: true,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Parking amount credited");
    await FireStoreUtils.setWalletTransaction(transactionModel)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount: calculateAmount().toString(),
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    PaymentTransactionModel paymentTransactionModel = PaymentTransactionModel(
        id: Constant.getUuid(),
        amount: calculateAmount().toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Parking amount debited");

    await FireStoreUtils.setPaymentTransaction(paymentTransactionModel)
        .then((value) async {});

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission debited");
    await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount:
                "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    // UserModel? userModel =
    //     await FireStoreUtils.getUserProfile(orderModel.value.userId.toString());
    //
    // Map<String, dynamic> playLoad = <String, dynamic>{
    //   "type": "order",
    //   "orderId": orderModel.value.id
    // };

    // await SendNotification.sendOneNotification(
    //     token: userModel!.fcmToken.toString(),
    //     title: 'Thank You for Using Our Parking Service!',
    //     body:
    //         'Thanks for parking with us. We look forward to welcoming you again!',
    //     payload: playLoad);

    // await SendNotification.sendOneNotification(
    //     token: receiverUserModel!.fcmToken.toString(),
    //     title: 'Booking Placed',
    //     body:
    //         '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
    //     payload: playLoad);

    // await FireStoreUtils.getWatchman(
    //         orderModel.value.parkingDetails!.id.toString(),
    //         orderModel.value.parkingDetails!.userId.toString())
    //     .then((value) async {
    //   if (value != null) {
    //     await SendNotification.sendOneNotification(
    //         token: value.fcmToken.toString(),
    //         title: 'Booking Placed',
    //         body:
    //             '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
    //         payload: playLoad);
    //   }
    // });
    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        DashboardScreenController dashboardController =
            Get.put(DashboardScreenController());
        dashboardController.selectedIndex(1);
        Get.offAll(() => const DashBoardScreen());
        ShowToastDialog.showToast("Successful",
            position: EasyLoadingToastPosition.top);
        // Get.to(() => const ParkingTicketScreen(), arguments: {"orderModel": orderModel.value});
      }
    });
  }

  confirmPayment() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());
    RxDouble couponAmount = 0.0.obs;
    ShowToastDialog.showLoader("Please wait..");
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
    orderModel.value.paymentCompleted = true;
    if (orderModel.value.duration != null && double.parse(orderModel.value.duration.toString()) >= 1.0) {
      orderModel.value.extraPaymentCompleted = true;
    }
    if (userModel!.adminCommission != null &&
        userModel.adminCommission!.toJson().isNotEmpty &&
        userModel.adminCommission!
            .toJson()
            .values
            .any((element) => element != null)) {
      orderModel.value.adminCommission = userModel.adminCommission;
    } else {
      orderModel.value.adminCommission = Constant.adminCommission;
    }
    orderModel.value.status = Constant.completed;
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
        DashboardScreenController dashboardController =
            Get.put(DashboardScreenController());
        dashboardController.selectedIndex(1);
        Get.offAll(() => const DashBoardScreen());
        ShowToastDialog.showToast("Successful",
            position: EasyLoadingToastPosition.top);
      }
    });
  }

  Future<void> showPhoneNumberDialog(BuildContext context) async {
    final TextEditingController phoneNumberController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Telebirr Phone Number'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '+251 ',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.length == 9) {
                  Get.back();
                  createArifPayPayment(
                    amount: calculateAmount().toStringAsFixed(
                        Constant.currencyModel!.decimalDigits!),
                    context: context,
                    phoneNumber: '251$phoneNumber', // Prefix with +251
                  );
                } else {
                  ShowToastDialog.showToast(
                      "Please enter a valid phone number with 9 digits");
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showMPesaPhoneNumberDialog(BuildContext context) async {
    final TextEditingController phoneNumberController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter MPesa Phone Number'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '+251 ',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.length == 9) {
                  Get.back();
                  createMPesaPayment(
                    amount: calculateAmount().toStringAsFixed(
                        Constant.currencyModel!.decimalDigits!),
                    context: context,
                    phoneNumber: '251$phoneNumber', // Prefix with +251
                  );
                } else {
                  ShowToastDialog.showToast(
                      "Please enter a valid phone number with 9 digits");
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCbePhoneNumberDialog(BuildContext context) async {
    final TextEditingController phoneNumberController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter CBE Phone Number'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '+251 ',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.length == 9) {
                  Get.back();
                  createCbeSessionIdPayment(
                    amount: calculateAmount().toStringAsFixed(
                        Constant.currencyModel!.decimalDigits!),
                    context: context,
                    phoneNumber: '251$phoneNumber', // Prefix with +251
                  );
                } else {
                  ShowToastDialog.showToast(
                      "Please enter a valid phone number with 9 digits");
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  // ArifPay
  Future<void> createArifPayPayment(
      {required String amount,
      required BuildContext context,
      required String phoneNumber}) async {
    final url =
        'https://gateway.arifpay.net/api/checkout/telebirr-ussd/transfer/direct';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final nonce = generateNonce();
    final body = jsonEncode({
      "cancelUrl": "https://example.com",
      "phone": phoneNumber,
      // "phone": "251911287144", //mekina client Arifpay Number
      // "phone": "251983832880", //arifpay client number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "TELEBIRR_USSD" // Don't change this
      ],
      "expireDate": "2080-02-01T03:45:27",
      "items": [
        {
          "name": "test",
          "quantity": 1,
          "price": amount.toString(),
          "description": "",
          "image": ""
        }
      ],
      "beneficiaries": [
        {
          "accountNumber": "01320811436100", // dont change
          "bank": "AWINETAA", //dont change
          "amount": amount.toString()
        }
      ],
      "lang": "EN"
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      print("testStatusCode:: ${response.statusCode}");
      var data = jsonDecode(response.body);
      final notifyUrl =
          data['data']['transaction']['checkoutSession']['notifyUrl'];
      final transaction =
          data['data']['transaction']['checkoutSession']['uuid'];
      if (notifyUrl != null) {
        ShowToastDialog.showLoader("Payment Processing...");
        await checkPaymentStatus(transaction);
      } else {
        log("Success URL is null");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  //Mpesa
  Future<void> createMPesaPayment(
      {required String amount,
      required BuildContext context,
      required String phoneNumber}) async {
    final url =
        'https://gateway.arifpay.net/api/checkout/mpesa/transfer/direct';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final nonce = generateNonce();
    final body = jsonEncode({
      "cancelUrl": "https://example.com",
      "phone": phoneNumber,
      // "phone": "251911287144", //client Arifpay Number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      // auto generate a unique value for this
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "MPESA" // Don't change this
      ],
      "expireDate": "2080-02-01T03:45:27",
      // look out for the format of the expire date
      "items": [
        {
          "name": "test",
          "quantity": 1,
          "price": amount.toString(),
          "description": "",
          "image": ""
        }
      ],
      "beneficiaries": [
        {
          "accountNumber": "01320811436100", // dont change
          "bank": "AWINETAA", //dont change
          "amount": amount.toString()
        }
      ],
      "name": "Belay",
      "lang": "EN"
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      final notifyUrl =
          data['data']['transaction']['checkoutSession']['notifyUrl'];
      final transaction =
          data['data']['transaction']['checkoutSession']['uuid'];
      if (notifyUrl != null) {
        log("Notify URL found: $notifyUrl");
        ShowToastDialog.showLoader("Payment Processing...");
        await checkPaymentStatus(transaction);
      } else {
        log("Success URL is null");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  //CBE session ID create
  Future<void> createCbeSessionIdPayment(
      {required String amount,
      required BuildContext context,
      required String phoneNumber}) async {
    final url = 'https://gateway.arifpay.net/api/checkout/session';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final nonce = generateNonce();
    final body = jsonEncode({
      "cancelUrl": "https://example.com",
      "phone": phoneNumber,
      // "phone": "251911287144", //client Arifpay Number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      // auto generate a unique value for this
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "CBE" // Don't change this
      ],
      "expireDate": "2080-02-01T03:45:27",
      // look out for the format of the expire date
      "items": [
        {
          "name": "test",
          "quantity": 1,
          "price": amount.toString(),
          "description": "",
          "image": ""
        }
      ],
      "beneficiaries": [
        {
          "accountNumber": "01320811436100", // dont change
          "bank": "AWINETAA", //dont change
          "amount": amount.toString()
        }
      ],
      "name": "Belay",
      "lang": "EN"
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      final sessionId = data['data']['sessionId'];
      log("Notify URL found: $sessionId");
      ShowToastDialog.showLoader("Payment Processing...");
      await createCbeDirectPayment(
          sessionId: sessionId, phoneNumber: phoneNumber);
    } else {
      log("Success URL is null");
    }
  }

  //CBE Payment
  Future<void> createCbeDirectPayment(
      {required String sessionId, required String phoneNumber}) async {
    final url = 'https://gateway.arifpay.net/api/checkout/cbe/direct/transfer';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final body = jsonEncode({
      "phoneNumber": phoneNumber,
      "sessionId": sessionId,
      // "phone": "251911287144", //client Arifpay Number
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      final transaction =
          data['data']['transaction']['checkoutSession']['uuid'];
      log("Notify URL found: $transaction");
      ShowToastDialog.showLoader("Payment Processing...");
      await checkPaymentStatus(transaction);
    } else {
      log("Success URL is null");
    }
  }

  Future<void> checkPaymentStatus(String transactionUuid) async {
    const int maxRetries = 10; // Number of retries before timeout
    const Duration delayBetweenRetries =
        Duration(seconds: 3); // Delay between each retry

    int retryCount = 0;
    bool isPaymentComplete = false;

    ShowToastDialog.showLoader("Checking Payment Status...");

    while (!isPaymentComplete && retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('https://mekinaparking.com/admin/arifpay/getPaymentData'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'uuid': transactionUuid}),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          final status = data['data'][0]['status'];

          if (status == 'success') {
            isPaymentComplete = true;
            ShowToastDialog.closeLoader();
            ShowToastDialog.showToast("Payment Successful!!");
            Get.back();
            completeOrder();
            log("Payment completion successful: ${response.body}");
          } else if (status == 'failed') {
            isPaymentComplete = true;
            ShowToastDialog.closeLoader();
            ShowToastDialog.showToast("Payment Unsuccessful!!");
          } else {
            log("Payment still pending, retrying...");
          }
        } else {
          log('Error checking payment status: ${response.body}');
        }
      } catch (e) {
        log('Error: $e');
      }

      if (!isPaymentComplete) {
        retryCount++;
        await Future.delayed(delayBetweenRetries);
      }
    }

    if (!isPaymentComplete) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Payment Timeout or Failed");
      log("Payment status check timed out.");
    }
  }
}
