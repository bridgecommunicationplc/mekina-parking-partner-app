import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:owner/model/admin_commission.dart';
import 'package:owner/model/coupon_model.dart';
import 'package:owner/model/parking_model.dart';
import 'package:owner/model/tax_model.dart';
import 'package:owner/model/user_vehicle_model.dart';

class OrderModel {
  String? id;
  String? userId;
  String? parkingId;
  String? parkingSlotId;
  Timestamp? bookingDate;
  Timestamp? bookingStartTime;
  Timestamp? bookingEndTime;
  Timestamp? extraTimeEnd;
  Timestamp? extraTimeStart;
  String? duration;
  String? extraDuration;
  String? perHrPrice;
  String? status;
  String? paymentType;
  String? subTotal;
  String? customerPhoneNumber;
  String? customerName;
  String? vehicleNumberPlate;
  String? bookedBy;
  String? extraTimeHours;
  bool? paymentCompleted;
  bool? isExtraTimeApplied;
  bool? notificationSent;
  bool? isExtraTimeRequestAccept;
  bool? extraPaymentCompleted;
  bool? isParkingLeave;
  UserVehicleModel? userVehicle;
  ParkingModel? parkingDetails;
  List<TaxModel>? taxList;
  AdminCommission? adminCommission;
  CouponModel? coupon;
  Timestamp? createdAt;
  Timestamp? updateAt;
  Timestamp? parkingInTime;
  Timestamp? parkingOutTime;

  OrderModel({
    this.id,
    this.userId,
    this.parkingId,
    this.parkingSlotId,
    this.bookingDate,
    this.bookingStartTime,
    this.bookingEndTime,
    this.extraTimeEnd,
    this.extraTimeStart,
    this.duration,
    this.extraDuration,
    this.perHrPrice,
    this.status,
    this.paymentType,
    this.subTotal,
    this.customerPhoneNumber,
    this.customerName,
    this.vehicleNumberPlate,
    this.bookedBy,
    this.extraTimeHours,
    this.paymentCompleted,
    this.isExtraTimeApplied,
    this.notificationSent,
    this.isExtraTimeRequestAccept,
    this.extraPaymentCompleted,
    this.isParkingLeave,
    this.userVehicle,
    this.parkingDetails,
    this.taxList,
    this.adminCommission,
    this.coupon,
    this.createdAt,
    this.updateAt,
    this.parkingInTime,
    this.parkingOutTime,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    parkingId = json['parkingId'];
    parkingSlotId = json['parkingSlotId'];
    bookingDate = json['bookingDate'];
    bookingStartTime = json['bookingStartTime'];
    bookingEndTime = json['bookingEndTime'];
    extraTimeEnd = json['extraTimeEnd'];
    extraTimeStart = json['extraTimeStart'];
    duration = json['duration'];
    extraDuration = json['extraDuration'];
    perHrPrice = json['perHrPrice'];
    status = json['status'];
    paymentType = json['paymentType'];
    subTotal = json['subTotal'];
    customerPhoneNumber = json['customerPhoneNumber'];
    customerName = json['customerName'];
    vehicleNumberPlate = json['vehicleNumberPlate'];
    bookedBy = json['bookedBy'];
    extraTimeHours = json['extraTimeHours'];
    paymentCompleted = json['paymentCompleted'];
    isExtraTimeApplied = json['isExtraTimeApplied'];
    notificationSent = json['notificationSent'];
    isExtraTimeRequestAccept = json['isExtraTimeRequestAccept'];
    extraPaymentCompleted = json['extraPaymentCompleted'];
    isParkingLeave = json['isParkingLeave'];
    userVehicle = json['userVehicle'] != null
        ? UserVehicleModel.fromJson(json['userVehicle'])
        : null;
    parkingDetails = json['parkingDetails'] != null
        ? ParkingModel.fromJson(json['parkingDetails'])
        : null;
    if (json['taxList'] != null) {
      taxList = <TaxModel>[];
      json['taxList'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }
    adminCommission = json['adminCommission'] != null
        ? AdminCommission.fromJson(json['adminCommission'])
        : null;
    coupon =
        json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
    parkingInTime = json['parkingInTime'];
    parkingOutTime = json['parkingOutTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['parkingId'] = parkingId;
    data['parkingSlotId'] = parkingSlotId;
    data['bookingDate'] = bookingDate;
    data['bookingStartTime'] = bookingStartTime;
    data['bookingEndTime'] = bookingEndTime;
    data['extraTimeEnd'] = extraTimeEnd;
    data['extraTimeStart'] = extraTimeStart;
    data['duration'] = duration;
    data['extraDuration'] = extraDuration;
    data['perHrPrice'] = perHrPrice;
    data['status'] = status;
    data['paymentType'] = paymentType;
    data['subTotal'] = subTotal;
    data['customerPhoneNumber'] = customerPhoneNumber;
    data['customerName'] = customerName;
    data['vehicleNumberPlate'] = vehicleNumberPlate;
    data['bookedBy'] = bookedBy;
    data['extraTimeHours'] = extraTimeHours;
    data['paymentCompleted'] = paymentCompleted;
    data['isExtraTimeApplied'] = isExtraTimeApplied;
    data['notificationSent'] = notificationSent;
    data['isExtraTimeRequestAccept'] = isExtraTimeRequestAccept;
    data['extraPaymentCompleted'] = extraPaymentCompleted;
    data['isParkingLeave'] = isParkingLeave;

    if (userVehicle != null) {
      data['userVehicle'] = userVehicle!.toJson();
    }
    if (parkingDetails != null) {
      data['parkingDetails'] = parkingDetails!.toJson();
    }
    if (taxList != null) {
      data['taxList'] = taxList!.map((v) => v.toJson()).toList();
    }
    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updateAt'] = updateAt;
    data['parkingInTime'] = parkingInTime;
    data['parkingOutTime'] = parkingOutTime;
    return data;
  }
}
