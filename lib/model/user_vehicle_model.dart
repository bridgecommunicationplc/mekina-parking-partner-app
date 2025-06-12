import 'package:owner/model/vehicle_brand_model.dart';
import 'package:owner/model/vehicle_model.dart';

class UserVehicleModel {
  VehicleBrandModel? vehicleBrand;
  VehicleModel? vehicleModel;
  String? vehicleNumber;
  String? id;
  String? qrCode;
  String? userId;

  UserVehicleModel({this.vehicleBrand, this.vehicleModel, this.vehicleNumber, this.qrCode, this.id, this.userId});

  UserVehicleModel.fromJson(Map<String, dynamic> json) {
    vehicleBrand = json['vehicleBrand'] != null ? VehicleBrandModel.fromJson(json['vehicleBrand']) : null;
    vehicleModel = json['vehicleModel'] != null ? VehicleModel.fromJson(json['vehicleModel']) : null;
    vehicleNumber = json['vehicleNumber'];
    qrCode = json['qrCode'];
    id = json['id'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vehicleBrand != null) {
      data['vehicleBrand'] = vehicleBrand!.toJson();
    }
    if (vehicleModel != null) {
      data['vehicleModel'] = vehicleModel!.toJson();
    }
    data['vehicleNumber'] = vehicleNumber;
    data['qrCode'] = qrCode;
    data['id'] = id;
    data['userId'] = userId;
    return data;
  }
}
