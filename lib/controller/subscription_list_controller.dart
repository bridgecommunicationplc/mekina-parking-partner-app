import 'package:get/get.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/subscription_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class MySubscriptionListController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<SubscriptionModel> subscription = <SubscriptionModel>[].obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
      await FireStoreUtils.getMyParkingList().then((parkingData) {
        if(parkingData!=null){
          parkingList.value = parkingData;
        }
      });

    // await FireStoreUtils.getSubscriptionList().then((subscriptionData) {
    //   if (subscriptionData != null) {
    //     subscription.value = subscriptionData;
    //   }
    // });
      await FireStoreUtils.getSubscriptionList().then((subscriptionData) {
        if (subscriptionData != null) {
          List<SubscriptionModel> filteredSubscriptions = subscriptionData
              .where((subscription) =>
              parkingList.value.any((parking) => parking.id == subscription.parkingId))
              .toList();

          subscription.value = filteredSubscriptions;
        }
      });
    isLoading.value = false;
  }


}
