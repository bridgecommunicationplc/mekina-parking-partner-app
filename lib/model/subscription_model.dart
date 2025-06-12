import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  String? id;
  Timestamp? createdAt;
  bool? isEnable;
  String? maxSpace;
  String? ownerId;
  String? parkingId;
  String? title;
  List<Plan>? plan;

  SubscriptionModel(
      {this.id,
      this.createdAt,
      this.isEnable,
      this.maxSpace,
      this.ownerId,
      this.parkingId,
      this.title,
      this.plan});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    if (json['plan'] != null) {
      plan = <Plan>[];
      json['plan'].forEach((v) {
        plan!.add(Plan.fromJson(v));
      });
    }
    id = json['id'];
    maxSpace = json['maxSpace'];
    ownerId = json['ownerId'];
    parkingId = json['parkingId'];
    title = json['title'];
    isEnable = json['isEnable'] ?? false;
    createdAt = json['createdAt'] ?? Timestamp.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (plan != null) {
      data['plan'] = plan!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['maxSpace'] = maxSpace;
    data['ownerId'] = ownerId;
    data['parkingId'] = parkingId;
    data['title'] = title;
    data['isEnable'] = isEnable;
    data['createdAt'] = createdAt ?? Timestamp.now();
    return data;
  }
}

class Plan {
  String? months;
  String? price;

  Plan({this.months, this.price});

  Plan.fromJson(Map<String, dynamic> json) {
    months = json['months'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['months'] = months;
    data['price'] = price;
    return data;
  }
}
