import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:owner/model/subscription_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/user_vehicle_model.dart';
import 'package:owner/utils/fire_store_utils.dart';

class ScanVehicleController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<SubscriptionModel> subscription = <SubscriptionModel>[].obs;
  RxList<UserVehicleModel> userVehicle = <UserVehicleModel>[].obs;
  RxList<UserModel> allUserList = <UserModel>[].obs;
  RxString userId = "".obs;
  RxString vehicleNumber = "".obs;
  RxString vehicleId = "".obs;
  RxString vehicleUserId = "".obs;
  RxList<Map<String, dynamic>> scannedVehicles = <Map<String, dynamic>>[].obs;
  var vehicleList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    getData();
    fetchVehicleData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getSubscriptionList().then((value) {
      if (value != null) {
        subscription.value = value;
      }
    });
    await FireStoreUtils.getSubscriptionUsers().then((value) {
      if (value != null) {
        allUserList.value = value;
        for (var user in allUserList.value) {
          userId.value = user.id!;
        }
      }
    });
    await FireStoreUtils.getSubscriptionUserVehicle(userId.value).then((value) {
      if (value != null) {
        userVehicle.value = value;
        for (var vehicle in userVehicle.value) {
          vehicleNumber.value = vehicle.vehicleNumber!;
          vehicleId.value = vehicle.id!;
          vehicleUserId.value = vehicle.userId!;
        }
      }
    });
    isLoading.value = false;
  }

  Future<void> fetchVehicleData() async {
    final currentUserId = FireStoreUtils.getCurrentUid();
    FirebaseFirestore.instance
        .collection('scan_vehicle')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      vehicleList.value = snapshot.docs
          .map((doc) => {
                'vehicleNumber': doc['vehicleNumber'],
                'userId': doc['userId'],
                'id': doc['id'],
                'createdAt': doc['createdAt'],
              })
          .toList();
      print("scanVehicledata ${vehicleList.value}");
    });
  }
}
