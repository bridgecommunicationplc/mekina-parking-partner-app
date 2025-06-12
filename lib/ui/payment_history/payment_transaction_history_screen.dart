import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/model/payment_transaction_history_controller.dart';
import 'package:owner/model/payment_transaction_model.dart';
import 'package:owner/themes/app_them_data.dart';
import 'package:owner/themes/common_ui.dart';
import 'package:owner/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class PaymentTransactionHistoryScreen extends StatelessWidget {
  const PaymentTransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: PaymentTransactionHistoryController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              isBack: true,
              'Payment Transaction History'.tr,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.paymentTransactionList.isEmpty
                    ? Constant.showEmptyView(
                        message: "Payment Transaction not found".tr)
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        itemCount: controller.paymentTransactionList.length,
                        itemBuilder: (context, index) {
                          PaymentTransactionModel paymentTransactionModel =
                              controller.paymentTransactionList[index];
                          return transactionCard(
                              controller, themeChange, paymentTransactionModel);
                        },
                      ),
          );
        });
  }

  transactionCard(PaymentTransactionHistoryController controller, themeChange,
      PaymentTransactionModel transactionModel) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Image.asset(
                  {
                        "Telebirr": "assets/images/telebirr.png",
                        "MPesa": "assets/images/mpesa.png",
                        "CBE": "assets/images/cbe.png",
                      }[transactionModel.paymentType] ??
                      "assets/images/telebirr.png",
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
}
