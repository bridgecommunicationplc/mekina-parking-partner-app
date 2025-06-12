import 'package:get/get.dart';
import 'package:owner/model/payment_transaction_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class PaymentTransactionHistoryController extends GetxController{
  RxList paymentTransactionList = <PaymentTransactionModel>[].obs;
  RxBool isLoading = true.obs;


  @override
  void onInit() {
    // TODO: implement onInit
    getTransaction();
    super.onInit();
  }

  getTransaction() async {
    await FireStoreUtils.getPaymentTransaction().then((value) {
      if (value != null) {
        paymentTransactionList.value = value;
      }
    });
    isLoading.value = false;
    update();
  }
}