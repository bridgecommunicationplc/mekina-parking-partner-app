import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:owner/constant/collection_name.dart';
import 'package:owner/constant/constant.dart';
import 'package:owner/model/admin_commission.dart';
import 'package:owner/model/bank_details_model.dart';
import 'package:owner/model/currency_model.dart';
import 'package:owner/model/faq_model.dart';
import 'package:owner/model/language_model.dart';
import 'package:owner/model/on_boarding_model.dart';
import 'package:owner/model/order_model.dart';
import 'package:owner/model/parking_facilities_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/payment_method_model.dart';
import 'package:owner/model/payment_transaction_model.dart';
import 'package:owner/model/review_model.dart';
import 'package:owner/model/subscription_model.dart';
import 'package:owner/model/tax_model.dart';
import 'package:owner/model/user_model.dart';
import 'package:owner/model/user_vehicle_model.dart';
import 'package:owner/model/vehicle_brand_model.dart';
import 'package:owner/model/vehicle_model.dart';
import 'package:owner/model/wallet_transaction_model.dart';
import 'package:owner/model/withdraw_model.dart';
import 'package:owner/widgets/geoflutterfire/src/geoflutterfire.dart';
import 'package:owner/widgets/geoflutterfire/src/models/point.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<void> updateNewUser(Map<String, dynamic> userData) async {
    try {
      String userId =
          userData['id'] ?? fireStore.collection(CollectionName.users).doc().id;
      await fireStore.collection(CollectionName.users).doc(userId).set(
            userData,
            SetOptions(merge: true),
          );
    } catch (e) {
      print("Error updating user: $e");
      throw e;
    }
  }

  static Future<List<UserVehicleModel>?> getUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<bool> updateSubscription(
      SubscriptionModel subscriptionModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .doc(subscriptionModel.id)
        .set(subscriptionModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool> updateWatchmen(UserModel watchModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(watchModel.id)
        .set(watchModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<bool?> updateOtherUserWallet(
      {required String amount, required String id}) async {
    bool isAdded = false;
    await getUserProfile(id).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                    double.parse(amount))
                .toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<UserModel?> getWatchman(
      String parkingId, String ownerId) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "security")
        .where("parkingId", isEqualTo: parkingId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        userModel = UserModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  Stream<List<ParkingModel>> getFilterParking(
      {double? latitude,
      double? longLatitude,
      String? parkingType,
      String? distance}) async* {
    getNearestFilterParking = StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];

    var query = fireStore
        .collection(CollectionName.parking)
        .where("parkingType", isEqualTo: parkingType)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(distance.toString()),
            field: 'position',
            strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestFilterParking!.sink.add(ordersList);
    });

    yield* getNearestFilterParking!.stream;
  }

  static Future<UserModel?> getWatchMen(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<SubscriptionModel?> getSubscription(String ownerId) async {
    SubscriptionModel? subscriptionModel;
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .doc(ownerId)
        .get()
        .then((value) {
      if (value.exists) {
        subscriptionModel = SubscriptionModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      subscriptionModel = null;
    });
    return subscriptionModel;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore
        .collection(CollectionName.tax)
        .where('country', isEqualTo: Constant.country)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<ParkingModel?> getParking(String uuid) async {
    ParkingModel? parkingModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        parkingModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      parkingModel = null;
    });
    return parkingModel;
  }

  static Future<bool?> bookMarked(ParkingModel parkingModel) async {
    try {
      if (parkingModel.bookmarkedUser == null) {
        parkingModel.bookmarkedUser = [];
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      } else {
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      }
      await fireStore
          .collection(CollectionName.parking)
          .doc(parkingModel.id)
          .set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<VehicleBrandModel>?> gerBrand() async {
    List<VehicleBrandModel> brandList = [];

    await fireStore
        .collection(CollectionName.brand)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleBrandModel taxModel = VehicleBrandModel.fromJson(element.data());
        brandList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return brandList;
  }

  static Future<List<UserVehicleModel>?> getSubscriptionUserVehicle(
      userId) async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .where("userId", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<List<UserVehicleModel>> getAllUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel userVehicleModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(userVehicleModel);
      }
    });
    return userVehicleList;
  }

  static Future<List<UserModel>?> getUser(userId) async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("id", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel facilitiesModel = UserModel.fromJson(element.data());
        userList.add(facilitiesModel);
      }
    });
    return userList;
  }

  static Future<bool> updateUserVehicle(
      UserVehicleModel userVehicleModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.userVehicles)
        .doc(userVehicleModel.id)
        .set(userVehicleModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<VehicleModel>?> getVehicleModel(String id) async {
    List<VehicleModel> vehicleModel = [];

    await fireStore
        .collection(CollectionName.model)
        .where("brandId", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleModel taxModel = VehicleModel.fromJson(element.data());
        vehicleModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleModel;
  }

  static Future<List<OrderModel>?> getOrder(Timestamp date, Timestamp startTime,
      Timestamp endTime, String parkingId) async {
    List<OrderModel> orderList = [];
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .where(
          'parkingId',
          isEqualTo: parkingId,
        )
        .where('status', whereIn: [Constant.placed, Constant.onGoing])
        .where('bookingDate', isEqualTo: date)
        .get()
        .then((value) async {
          for (var element in value.docs) {
            OrderModel orderModel = OrderModel.fromJson(element.data());
            orderList.add(orderModel);
          }
        });
    return orderList;
  }

  static Future<List<OrderModel>?> getOrderForSearch(String parkingId) async {
    List<OrderModel> orderList = [];
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .where(
          'parkingId',
          isEqualTo: parkingId,
        )
        .where('status', whereIn: [Constant.placed, Constant.onGoing])
        .get()
        .then((value) async {
          for (var element in value.docs) {
            OrderModel orderModel = OrderModel.fromJson(element.data());
            orderList.add(orderModel);
          }
        });
    return orderList;
  }

  static Future<bool?> removeBookMarked(ParkingModel parkingModel) async {
    try {
      parkingModel.bookmarkedUser!.remove(getCurrentUid());

      await fireStore
          .collection(CollectionName.parking)
          .doc(parkingModel.id)
          .set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await fireStore
        .collection(CollectionName.currency)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore
          .collection(CollectionName.users)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  getSettings() async {
    fireStore
        .collection(CollectionName.settings)
        .doc("globalKey")
        .snapshots()
        .listen((event) {
      if (event.exists) {
        Constant.mapAPIKey = event.data()!["googleMapKey"];
        Constant.radius = event.data()!["radius"];
        Constant.distanceType = event.data()!["distanceType"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("notification_setting")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!['senderId'].toString();
        Constant.jsonNotificationFileURL =
            value.data()!['serviceJson'].toString();
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("global")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.minimumAmountToDeposit =
            value.data()!["minimumAmountToDeposit"];
        Constant.minimumAmountToWithdrawal =
            value.data()!["minimumAmountToWithdrawal"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("referral")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("contact_us")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("adminCommission")
        .get()
        .then((value) {
      Constant.adminCommission = AdminCommission.fromJson(value.data()!);
    });
  }

  static Future<ParkingModel?> getUserParkingDetails(String id) async {
    ParkingModel? parkingModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(id)
        .get()
        .then((value) {
      parkingModel = ParkingModel.fromJson(value.data()!);
    });
    return parkingModel;
  }

  static Future<String?> saveParkingDetails(
      ParkingModel createSlotModel) async {
    try {
      await fireStore
          .collection(CollectionName.parking)
          .doc(createSlotModel.id)
          .set(createSlotModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("payment")
        .get()
        .then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  static Future<List<ParkingFacilitiesModel>> getParkingFacilities() async {
    List<ParkingFacilitiesModel> facilitiesModelList = [];
    await fireStore
        .collection(CollectionName.facilities)
        .where('isEnable', isEqualTo: true)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingFacilitiesModel facilitiesModel =
            ParkingFacilitiesModel.fromJson(element.data());
        facilitiesModelList.add(facilitiesModel);
      }
    });
    return facilitiesModelList;
  }

  final geo = Geoflutterfire();
  StreamController<List<ParkingModel>>? getNearestOrderRequestController;

  Stream<List<ParkingModel>> getParkingNearest(
      {double? latitude, double? longLatitude}) async* {
    getNearestOrderRequestController =
        StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];
    var query = fireStore
        .collection(CollectionName.parking)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(Constant.radius),
            field: 'position',
            strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestOrderRequestController!.sink.add(ordersList);
    });

    yield* getNearestOrderRequestController!.stream;
  }

  StreamController<List<ParkingModel>>? getNearestFilterParking;

  static Future<OrderModel?> getSingleOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  static Future<List<ParkingModel>?> getMyParkingList() async {
    List<ParkingModel> parkingList = [];
    await fireStore
        .collection(CollectionName.parking)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);
      }
    });
    return parkingList;
  }

  static Future<List<UserModel>> getAllUser() async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "customer")
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromJson(element.data());
        userList.add(userModel);
      }
    });
    return userList;
  }

  static Future<List<UserModel>> getSubscriptionUsers() async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "customer")
        .where("subscriptions", isNotEqualTo: null)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromJson(element.data());
        if (userModel.subscriptions != null &&
            userModel.subscriptions!.isNotEmpty) {
          userList.add(userModel);
        }
      }
    });
    return userList;
  }

  static Future<List<UserModel>?> getWatchmenList() async {
    List<UserModel> watchmenList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("ownerId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel facilitiesModel = UserModel.fromJson(element.data());
        watchmenList.add(facilitiesModel);
      }
    });
    return watchmenList;
  }

  static Future<List<SubscriptionModel>?> getSubscriptionList() async {
    List<SubscriptionModel> subscriptionList = [];
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        SubscriptionModel subscriptionDataModel =
            SubscriptionModel.fromJson(element.data());
        subscriptionList.add(subscriptionDataModel);
      }
    });
    return subscriptionList;
  }

  static Future<bool> parkingAssignCheck(
      String parkingID, String watchmanId) async {
    bool isAssign = false;
    await fireStore
        .collection(CollectionName.users)
        .where("parkingId", isEqualTo: parkingID)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        if (value.docs.first.id != watchmanId) {
          isAssign = true;
        } else {
          isAssign = false;
        }
      } else {
        isAssign = false;
      }
    });
    return isAssign;
  }

  static Future<ParkingModel?> getParkingDetails(String uuid) async {
    ParkingModel? slotModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        slotModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      slotModel = null;
    });
    return slotModel;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.walletTransaction)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setPaymentTransaction(
      PaymentTransactionModel paymentTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.paymentTransaction)
        .doc(paymentTransactionModel.id)
        .set(paymentTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    await getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                    double.parse(amount))
                .toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModel = [];

    await fireStore
        .collection(CollectionName.walletTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel taxModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModel;
  }

  static Future<List<PaymentTransactionModel>?> getPaymentTransaction() async {
    List<PaymentTransactionModel> paymentTransactionModel = [];

    await fireStore
        .collection(CollectionName.paymentTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        PaymentTransactionModel taxModel =
        PaymentTransactionModel.fromJson(element.data());
        paymentTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return paymentTransactionModel;
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore
        .collection(CollectionName.faq)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore
        .collection(CollectionName.review)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<List<WithdrawModel>> getWithDrawRequest() async {
    List<WithdrawModel> withdrawalList = [];
    await fireStore
        .collection(CollectionName.withdrawalHistory)
        .where('userId', isEqualTo: getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WithdrawModel documentModel = WithdrawModel.fromJson(element.data());
        withdrawalList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return withdrawalList;
  }

  static Future<BankDetailsModel?> getBankDetails() async {
    BankDetailsModel? bankDetailsModel;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      if (value.data() != null) {
        bankDetailsModel = BankDetailsModel.fromJson(value.data()!);
      }
    });
    return bankDetailsModel;
  }

  static Future<bool?> updateBankDetails(
      BankDetailsModel bankDetailsModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(bankDetailsModel.userId)
        .set(bankDetailsModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> bankDetailsIsAvailable() async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      if (value.exists) {
        isAdded = true;
      } else {
        isAdded = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setWithdrawRequest(WithdrawModel withdrawModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.withdrawalHistory)
        .doc(withdrawModel.id)
        .set(withdrawModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }
}
