// ignore_for_file: file_names, must_be_immutable, depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:owner/model/payment_method_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArifpayPaymentScreen extends StatefulWidget {
  final String initialURl;
  final Arifpay arifPaySettingData;

  const ArifpayPaymentScreen({
    super.key,
    required this.initialURl,
    required this.arifPaySettingData,
  });

  @override
  State<ArifpayPaymentScreen> createState() => _ArifPayPaymentScreenState();
}

class _ArifPayPaymentScreenState extends State<ArifpayPaymentScreen> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    initController();
    log("PaymentURL :: ${widget.initialURl}");
    super.initState();
  }

  initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest navigation) async {
            print("urll ${navigation.url}");
            // if (navigation.url.contains('/fedapaycallback')) {
            //   Get.back(result: true);
            // } else {
            //   Get.back(result: false);
            // }
            if (navigation.url == widget.arifPaySettingData.successUrl) {
              Get.back(result: true);
            } else if (navigation.url == widget.arifPaySettingData.notifyUrl) {
              Get.back(result: false);
            } else if (navigation.url == widget.arifPaySettingData.cancelUrl) {
              _showMyDialog(context);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showMyDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: AppThemData.secondary07,
            title: const Text("Payment"),
            centerTitle: false,
            leading: GestureDetector(
              onTap: () {
                _showMyDialog(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )),
        body: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Payment'),
          content: const SingleChildScrollView(
            child: Text('Are you want to cancel Payment?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
