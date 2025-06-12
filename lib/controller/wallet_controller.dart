import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:http/io_client.dart';

// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:owner/model/bank_details_model.dart';
import 'package:owner/model/payment/razorpay_failed_model.dart';
import 'package:owner/model/payment/xenditModel.dart';
import 'package:owner/model/payment_method_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/model/withdraw_model.dart';
import 'package:owner/payment/MercadoPagoScreen.dart';
import 'package:owner/payment/PayFastScreen.dart';
import 'package:owner/payment/getPaytmTxtToken.dart';
import 'package:owner/payment/midtrans_screen.dart';
import 'package:owner/payment/orangePayScreen.dart';
import 'package:owner/payment/paystack/pay_stack_screen.dart';
import 'package:owner/payment/paystack/pay_stack_url_model.dart';
import 'package:owner/payment/paystack/paystack_url_genrater.dart';
import 'package:owner/payment/stripe_failed_model.dart';
import 'package:owner/payment/xenditScreen.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/ui/wallet/arifpay_payment.dart';
import 'package:owner/utils/file_handle_api.dart';
import 'package:owner/utils/fire_store_utils.dart';
import 'package:owner/utils/pdf_invoice_formate.dart';
import 'package:pdf/pdf.dart';

// import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

class WalletController extends GetxController {
  Rx<TextEditingController> amountController = TextEditingController().obs;
  Rx<TextEditingController> withdrawalAmountController =
      TextEditingController().obs;
  Rx<TextEditingController> emailAddressController =
      TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> noteController =
      TextEditingController(text: "Withdrawal").obs;
  RxString phoneNumber = "".obs;

  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxString selectedPayment = "".obs;
  RxDouble serviceFee= 0.0.obs;


  Rx<BankDetailsModel> bankDetailsModel = BankDetailsModel().obs;

  RxInt selectedTabIndex = 0.obs;

  RxBool isLoading = true.obs;
  RxList transactionList = <WalletTransactionModel>[].obs;
  final RxList<String> paymentMethods = ["Telebirr", "Cbe"].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentData();
    super.onInit();
  }

  getPaymentData() async {
    await getTraction();
    await getUser();
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;

        // Stripe.publishableKey =
        //     paymentModel.value.strip!.clientpublishableKey.toString();
        // Stripe.merchantIdentifier = 'MekinaParking';
        // Stripe.instance.applySettings();
        setRef();

        razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
        razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      }
    });
    initPayPal();
    isLoading.value = false;
    update();
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
        emailAddressController.value =
            TextEditingController(text: userModel.value.email.toString());
      }
    });
    await FireStoreUtils.getBankDetails().then((value) {
      if (value != null) {
        bankDetailsModel.value = value;
      }
    });
  }

  getTraction() async {
    await FireStoreUtils.getWalletTransaction().then((value) {
      if (value != null) {
        transactionList.value = value;
      }
    });
  }

  walletTopUp() async {
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: amountController.value.text,
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: true,
        note: "Wallet Topup");

    await FireStoreUtils.setWalletTransaction(transactionModel)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
                amount: amountController.value.text)
            .then((value) {
          getUser();
          getTraction();
        });
      }
    });

    ShowToastDialog.showToast("Amount added in your wallet.");
  }

  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode =
        paymentModel.value.paypal!.isSandbox == true ? true : false;

    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: "com.mekinaparking.owner://paypalpay",
      //client id from developer dashboard
      clientID: paymentModel.value.paypal!.paypalClient.toString(),
      //sandbox, staging, live etc
      payPalEnvironment: paymentModel.value.paypal!.isSandbox == true
          ? FPayPalEnvironment.sandbox
          : FPayPalEnvironment.live,
      //what currency do you plan to use? default is US dollars
      currencyCode: FPayPalCurrencyCode.usd,
      //action paynow?
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          ShowToastDialog.showToast("Payment canceled");
        },
        onSuccess: (data) {
          //successfully paid
          //remove all items from queue
          // _flutterPaypalNativePlugin.removeAllPurchaseItems();
          ShowToastDialog.showToast("Payment Successful!!");
          walletTopUp();
        },
        onError: (data) {
          //an error occured
          ShowToastDialog.showToast("error: ${data.reason}");
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          ShowToastDialog.showToast(
              "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
        },
      ),
    );
  }

  paypalPaymentSheet(String amount) {
    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
          // random prices
          amount: double.parse(amount),

          ///please use your own algorithm for referenceId. Maybe ProductID?
          referenceId: FPayPalStrHelper.getRandomString(16),
        ),
      );
    }
    // initPayPal();
    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
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
                    amount: amountController.value.text,
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

  Future<void> showTelebirrB2cNumberDialog(BuildContext context) async {
    final TextEditingController phoneNumberController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Telebirr B2C Phone Number'),
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
                phoneNumber.value = phoneNumberController.text.trim();
                if (phoneNumber.value.length == 9) {
                  Get.back();
                  ShowToastDialog.showLoader("Please wait");
                  telebirrSessionCreate(
                    amount: withdrawalAmountController.value.text.toString(),
                    context: context,
                    phoneNumber: "251$phoneNumber",
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

  Future<void> showCbeB2cNumberDialog(BuildContext context) async {
    final TextEditingController phoneNumberController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter CBE B2C Phone Number'),
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
                phoneNumber.value = phoneNumberController.text.trim();
                if (phoneNumber.value.length == 9) {
                  Get.back();
                  ShowToastDialog.showLoader("Please wait");
                  print("testcbe");
                  cbeSessionCreate(
                    amount: withdrawalAmountController.value.text.toString(),
                    context: context,
                    phoneNumber: "251$phoneNumber",
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
                    amount: amountController.value.text,
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
                    amount: amountController.value.text,
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

  //Telebirr-B2C-Create Session
  Future<void> telebirrSessionCreate(
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
      // "phone": "251952926213", //telebirr Number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "TELEBIRR_USSD" // Don't change this
      ],
      "expireDate": "2080-12-01T03:45:27",
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
      "lang": "EN"
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      ShowToastDialog.closeLoader();
      var data = jsonDecode(response.body);
      final sessionId = data['data']['sessionId'];
      if (sessionId != null) {
        // log("sessionId found: $sessionId");
        await checkTelebirrSession(
            sessionId: sessionId, phoneNumber: phoneNumber);
        // await telebirrPayment(sessionId: sessionId, phoneNumber: phoneNumber);
      } else {
        log("Success URL is null");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  //Cbe-B2C-Create Session
  Future<void> cbeSessionCreate(
      {required String amount,
      required BuildContext context,
      required String phoneNumber}) async {
    print("testcbe1");
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
      // "phone": "251952926213", //telebirr Number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "CBE" // Don't change this
      ],
      "expireDate": "2080-12-01T03:45:27",
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
      "lang": "EN"
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print("response ${response.statusCode}");
    if (response.statusCode == 200) {
      ShowToastDialog.showLoader("Please wait");
      var data = jsonDecode(response.body);
      final sessionId = data['data']['sessionId'];
      if (sessionId != null) {
        log("sessionId found: $sessionId");
        log("phoneNumber: $phoneNumber");
        await checkCbeSession(sessionId: sessionId, phoneNumber: phoneNumber);
        // await telebirrPayment(sessionId: sessionId, phoneNumber: phoneNumber);
      } else {
        log("Success URL is null");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  //Check telebiirr session
  Future<void> checkTelebirrSession(
      {required String sessionId, required String phoneNumber}) async {
    final url = 'https://mekinaparking.com/partner/api/check-session';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final body = jsonEncode({
      "arifpaykey": apikey.toString(),
      "sessionId": sessionId,
      "phoneNumber": phoneNumber,
      // "phone": "251952926213",
      "paymentType": "TELEBIRR_USSD",
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    // print("responseData ${response.body}");
    if (response.statusCode == 200) {
      // print("statusCode ${response.statusCode}");
      var data = jsonDecode(response.body);
      // log("Response Data: ${response.body}");

      final transaction =
          data['data']['data']['transaction']['checkoutSession']['uuid'];
       serviceFee.value =
          data['data']['data']['transaction']['fee'];
      ShowToastDialog.showLoader("Payment Processing...");
      await checkSessionPaymentStatus(transaction);
    } else {
      log("API Error: ${response.statusCode} - ${response.body}");
    }
  }

  //Check CBE session
  Future<void> checkCbeSession(
      {required String sessionId, required String phoneNumber}) async {
    final url = 'https://mekinaparking.com/partner/api/check-session';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final body = jsonEncode({
      "arifpaykey": apikey.toString(),
      "sessionId": sessionId,
      "phoneNumber": phoneNumber,
      // "phone": "251952926213", //telebirr Number
      "paymentType": "CBE",
    });
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      log("Response Data: ${response.body}");

      final transaction =
          data['data']['data']['transaction']['checkoutSession']['uuid'];
      ShowToastDialog.showLoader("Payment Processing...");
      await checkSessionPaymentStatus(transaction);
    } else {
      log("API Error: ${response.statusCode} - ${response.body}");
    }
  }

  //Telebirr-B2C-Payment
  Future<void> telebirrPayment(
      {required String sessionId, required String phoneNumber}) async {
    final url = 'https://telebirr-b2c.arifpay.net/api/Telebirr/b2c/transfer';
    String apikey = paymentModel.value.arifpay!.apiKey.toString();

    final headers = {
      'Content-Type': 'application/json',
      'x-arifpay-key': apikey.toString(),
    };

    final body = jsonEncode({
      "sessionId": sessionId,
      "phoneNumber": phoneNumber,
    });
    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log("Response Data: ${response.body}");

        final transaction =
            data['data']['transaction']['checkoutSession']['uuid'];
        ShowToastDialog.showLoader("Payment Processing...");
        await checkPaymentStatus(transaction);
      } else {
        log("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      log("Request Failed: $e");
    }
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
      // "phone": "251911287144", //client Arifpay Number
      "email": userModel.value.email.toString(),
      "nonce": nonce.toString(),
      // auto generate a unique value for this
      "errorUrl": "http://error.com",
      "notifyUrl": "https://mekinaparking.com/admin/arifpay/notify",
      "successUrl": "https://mekinaparking.com/admin/arifpay/success",
      "paymentMethods": [
        "TELEBIRR_USSD" // Don't change this
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

  Future<void> checkSessionPaymentStatus(String transactionUuid) async {
    const int maxRetries = 10;
    const Duration delayBetweenRetries = Duration(seconds: 3);

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
            WithdrawModel withdrawModel = WithdrawModel();
            withdrawModel.id = Constant.getUuid();
            withdrawModel.userId = FireStoreUtils.getCurrentUid();
            withdrawModel.paymentStatus = 'approved';
            withdrawModel.amount = withdrawalAmountController.value.text;
            withdrawModel.note = noteController.value.text;
            withdrawModel.createdDate = Timestamp.now();
            withdrawModel.email = userModel.value.email;
            withdrawModel.phone = phoneNumber.value;
            withdrawModel.withdrawMethod = selectedPayment.value;
            withdrawModel.transactionId = transactionUuid;
            withdrawModel.serviceFees = serviceFee.value.toString();

            await FireStoreUtils.updateUserWallet(
                amount: "-${withdrawalAmountController.value.text}");
            await FireStoreUtils.setWithdrawRequest(withdrawModel)
                .then((value) {
              getUser();
              ShowToastDialog.showToast("Payment Successful!!");
              Get.back();
            });
            log("Payment completion successful: ${response.body}");
          } else if (status == 'failed') {
            isPaymentComplete = true;
            ShowToastDialog.closeLoader();
            WithdrawModel withdrawModel = WithdrawModel();
            withdrawModel.id = Constant.getUuid();
            withdrawModel.userId = FireStoreUtils.getCurrentUid();
            withdrawModel.paymentStatus = 'rejected';
            withdrawModel.amount = withdrawalAmountController.value.text;
            withdrawModel.note = noteController.value.text;
            withdrawModel.createdDate = Timestamp.now();
            withdrawModel.email = userModel.value.email;
            withdrawModel.phone = phoneNumber.value;
            withdrawModel.withdrawMethod = selectedPayment.value;
            withdrawModel.transactionId = transactionUuid;
            withdrawModel.serviceFees = serviceFee.value.toString();
            await FireStoreUtils.setWithdrawRequest(withdrawModel)
                .then((value) {
              getUser();
              ShowToastDialog.showToast("Payment Unsuccessful!!");
              Get.back();
            });
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

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE MMM dd yyyy hh:mm:ss a').format(dateTime);
  }

  Future<void> checkPaymentStatus(String transactionUuid) async {
    const int maxRetries = 10;
    const Duration delayBetweenRetries = Duration(seconds: 3);

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
            walletTopUp();
            ShowToastDialog.showToast("Payment Successful!!");
            Get.back();
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

  Future<void> completePayment({
    required String uuid,
    required String nonce,
    required String phone,
    required String paymentMethod,
    required double totalAmount,
    required String transactionId,
    // required String notificationUrl,
  }) async {
    final url = 'https://mekinaparking.com/admin/arifpay/success';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "uuid": uuid,
      "nonce": nonce,
      "phone": phone,
      "paymentMethod": paymentMethod,
      "totalAmount": totalAmount,
      "transactionStatus": "SUCCESS",
      "transaction": {
        "transactionId": transactionId,
        "transactionStatus": "SUCCESS"
      },
      "sessionId": uuid
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        walletTopUp();
        ShowToastDialog.showToast("Payment Successful!!");
        log("Payment completion successful: ${response.body}");
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
        log('Error completing payment: ${response.body}');
      }
    } catch (e) {
      log('Error occurred during payment completion: $e');
    }
  }

  // Future<void> notifyPayment(
  //     {required String amount,
  //     required String status,
  //     required String uuid,
  //     required String nonce,
  //     required String currency,
  //     required String transactionId,
  //     required String successUrl}) async {
  //   final url = 'https://mekinaparking.com/admin/arifpay/success';
  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final body = jsonEncode({
  //     "transactionId": transactionId,
  //     "status": status,
  //     "amount": amount,
  //     "uuid": uuid,
  //     "nonce": nonce,
  //     "currency": currency,
  //     "successUrl": successUrl
  //   });
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // ShowToastDialog.showLoader("Notification sent successfully. Please enter pin");
  //       var data = jsonDecode(response.body);
  //       print("notifyResponse ${response.body}");
  //       print("notifyResponse1 ${data.toString()}");
  //       final transactionId = data['data']['transaction_id'];
  //       if (transactionId != null) {
  //         print("transactionId $transactionId}");
  //         await getPaymentDataSuccess(transactionId: transactionId);
  //         // await completePayment(
  //         //   uuid: uuid,
  //         //   nonce: nonce,
  //         //   phone: "251911287144",
  //         //   paymentMethod: "TELEBIRR_USSD",
  //         //   totalAmount: double.parse(amount),
  //         //   transactionId: transactionId,
  //         //   // notificationUrl: ,
  //         // );
  //       } else {
  //         ShowToastDialog.showToast("Notification procesessing");
  //       }
  //     } else {
  //       log('Error completing payment: ${response.body}');
  //     }
  //   } catch (e) {
  //     log('Error occurred during payment completion: $e');
  //   }
  // }

  Future<void> getPaymentDataSuccess({
    required String uuid,
  }) async {
    final url =
        Uri.parse('https://mekinaparking.com/admin/arifpay/getPaymentData');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'uuid': uuid,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final status = data['data'][0]['status'];
        if (status == 'success') {
          ShowToastDialog.closeLoader();
          walletTopUp();
          ShowToastDialog.showToast("Payment Successful!!");
          Get.back();
          log("Payment completion successful: ${response.body}");
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      } else {
        log('Error completing payment: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Strip
  // Future<void> stripeMakePayment({required String amount}) async {
  //   log(double.parse(amount).toStringAsFixed(0));
  //   try {
  //     Map<String, dynamic>? paymentIntentData =
  //         await createStripeIntent(amount: amount);
  //     if (paymentIntentData!.containsKey("error")) {
  //       Get.back();
  //       ShowToastDialog.showToast(
  //           "Something went wrong, please contact admin.");
  //     }
  //     else {
  //       await Stripe.instance.initPaymentSheet(
  //           paymentSheetParameters: SetupPaymentSheetParameters(
  //               paymentIntentClientSecret: paymentIntentData['client_secret'],
  //               allowsDelayedPaymentMethods: false,
  //               googlePay: const PaymentSheetGooglePay(
  //                 merchantCountryCode: 'US',
  //                 testEnv: true,
  //                 currencyCode: "USD",
  //               ),
  //               customFlow: true,
  //               style: ThemeMode.system,
  //               appearance: const PaymentSheetAppearance(
  //                 colors: PaymentSheetAppearanceColors(
  //                   primary: AppThemData.primary06,
  //                 ),
  //               ),
  //               merchantDisplayName: 'MekinaParking'));
  //       displayStripePaymentSheet(amount: amount);
  //     }
  //   } catch (e, s) {
  //     log("$e \n$s");
  //     ShowToastDialog.showToast("exception:$e \n$s");
  //   }
  // }
  //
  // displayStripePaymentSheet({required String amount}) async {
  //   try {
  //     await Stripe.instance.presentPaymentSheet().then((value) {
  //       ShowToastDialog.showToast("Payment successfully");
  //       walletTopUp();
  //     });
  //   } on StripeException catch (e) {
  //     var lo1 = jsonEncode(e);
  //     var lo2 = jsonDecode(lo1);
  //     StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
  //     ShowToastDialog.showToast(lom.error.message);
  //   } catch (e) {
  //     ShowToastDialog.showToast(e.toString());
  //   }
  // }

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      log(paymentModel.value.strip!.stripeSecret.toString());
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  mercadoPagoMakePayment(
      {required BuildContext context, required String amount}) async {
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.mercadoPago!.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "BRL", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.email.toString()},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return": "approved"
      // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MercadoPagoScreen(initialURl: data['init_point'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        walletTopUp();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

//flutter wave Payment Method
  flutterWaveInitiatePayment(
      {required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization':
          'Bearer ${paymentModel.value.flutterWave!.secretKey.toString().trim()}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber.toString(),
        // Add a real phone number
        "name": userModel.value.fullName.toString(),
        // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MercadoPagoScreen(initialURl: data['data']['link'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        walletTopUp();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  ///PayStack Payment Method
  payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(),
            currency: "ZAR",
            secretKey: paymentModel.value.payStack!.secretKey.toString(),
            userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.secretKey.toString(),
          callBackUrl: paymentModel.value.payStack!.callbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!");
            walletTopUp();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!");
          }
        });
      } else {
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.");
      }
    });
  }

  String? _ref;

  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // payFast
  payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(
            payFastSettingData: paymentModel.value.payfast!,
            amount: amount.toString(),
            userModel: userModel.value)
        .then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(
          htmlData: value!, payFastSettingData: paymentModel.value.payfast!));
      if (isDone) {
        Get.back();
        ShowToastDialog.showToast("Payment successfully");
        walletTopUp();
      } else {
        Get.back();
        ShowToastDialog.showToast("Payment Failed");
      }
    });
  }

  ///Paytm payment function
  // getPaytmCheckSum(context, {required double amount}) async {
  //   final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  //   String getChecksum = "${Constant.globalUrl}payments/getpaytmchecksum";

  //   final response = await http.post(
  //       Uri.parse(
  //         getChecksum,
  //       ),
  //       headers: {},
  //       body: {
  //         "mid": paymentModel.value.paytm!.paytmMID.toString(),
  //         "order_id": orderId,
  //         "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
  //       });

  //   final data = jsonDecode(response.body);
  //   log(paymentModel.value.paytm!.paytmMID.toString());

  //   await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
  //     initiatePayment(amount: amount, orderId: orderId).then((value) {
  //       String callback = "";
  //       if (paymentModel.value.paytm!.isSandbox == true) {
  //         callback = "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       } else {
  //         callback = "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       }

  //       GetPaymentTxtTokenModel result = value;
  //       startTransaction(context, txnTokenBy: result.body.txnToken, orderId: orderId, amount: amount, callBackURL: callback, isStaging: paymentModel.value.paytm!.isSandbox);
  //     });
  //   });
  // }

  // Future<void> startTransaction(context, {required String txnTokenBy, required orderId, required double amount, required callBackURL, required isStaging}) async {
  //   try {
  //     var response = AllInOneSdk.startTransaction(
  //       paymentModel.value.paytm!.paytmMID.toString(),
  //       orderId,
  //       amount.toString(),
  //       txnTokenBy,
  //       callBackURL,
  //       isStaging,
  //       true,
  //       true,
  //     );

  //     response.then((value) {
  //       if (value!["RESPMSG"] == "Txn Success") {
  //         print("txt done!!");
  //         ShowToastDialog.showToast("Payment Successful!!");
  //         walletTopUp();
  //       }
  //     }).catchError((onError) {
  //       if (onError is PlatformException) {
  //         Get.back();

  //         ShowToastDialog.showToast(onError.message.toString());
  //       } else {
  //         log("======>>2");
  //         Get.back();
  //         ShowToastDialog.showToast(onError.message.toString());
  //       }
  //     });
  //   } catch (err) {
  //     Get.back();
  //     ShowToastDialog.showToast(err.toString());
  //   }
  // }

  Future verifyCheckSum(
      {required String checkSum,
      required double amount,
      required orderId}) async {
    String getChecksum = "${Constant.globalUrl}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paymentModel.value.paytm!.paytmMID.toString(),
          "order_id": orderId,
          "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(
      {required double amount, required orderId}) async {
    String initiateURL = "${Constant.globalUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (paymentModel.value.paytm!.isSandbox == true) {
      callback =
          "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback =
          "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response =
        await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paymentModel.value.paytm!.paytmMID,
      "order_id": orderId,
      "key_secret": paymentModel.value.paytm!.merchantKey,
      "amount": amount.toString(),
      "currency": "INR",
      "callback_url": callback,
      "custId": FireStoreUtils.getCurrentUid(),
      "issandbox": paymentModel.value.paytm!.isSandbox == true ? "1" : "2",
    });
    log(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null ||
        data["body"]["txnToken"].toString().isEmpty) {
      Get.back();
      ShowToastDialog.showToast("something went wrong, please contact admin.");
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': paymentModel.value.razorpay!.razorpayKey,
      'amount': amount * 100,
      'name': 'MekinaParking',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userModel.value.phoneNumber,
        'email': userModel.value.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Successful!!");
    walletTopUp();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Processing!! via");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Get.back();
    RazorPayFailedModel lom =
        RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ShowToastDialog.showToast("Payment Failed!!");
  }

//XenditPayment
  xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: paymentModel.value.xendit!.apiKey!.toString() ?? "",
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            walletTopUp();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(
          paymentModel.value.xendit!.apiKey!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

//Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment(
      {required String amount, required BuildContext context}) async {
    reset();
    var id = const Uuid().v4();
    var paymentURL = await fetchToken(
        context: context, orderId: id, amount: amount, currency: 'USD');

    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: paymentModel.value.orangePay!,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!!");
          walletTopUp();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Payment Unsuccessful!! \n"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken(
      {required String orderId,
      required String currency,
      required BuildContext context,
      required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${paymentModel.value.orangePay!.auth!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
          context: context,
          amountData: amount,
          currency: currency,
          orderIdData: orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment(
      {required String orderIdData,
      required BuildContext context,
      required String currency,
      required String amountData}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = paymentModel.value.orangePay!.isSandbox! == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": paymentModel.value.orangePay!.merchantKey ?? '',
      "currency":
          paymentModel.value.orangePay!.isSandbox == true ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": paymentModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url": paymentModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url": paymentModel.value.orangePay!.notifyUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

//Midtrans payment
  midtransMakePayment(
      {required String amount, required BuildContext context}) async {
    await createPaymentLink(amount: amount).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            walletTopUp();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var ordersId = const Uuid().v1();
    final url = Uri.parse(paymentModel.value.midtrans!.isSandbox!
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            generateBasicAuthHeader(paymentModel.value.midtrans!.serverKey!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {
          "finish": "https://www.google.com?merchant_order_id=$ordersId"
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Payment link created: ${responseData['payment_url']}');
      return responseData['payment_url'];
    } else {
      return '';
    }
  }
}
