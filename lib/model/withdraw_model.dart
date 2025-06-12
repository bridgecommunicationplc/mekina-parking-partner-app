import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawModel {
  String? id;
  String? userId;
  String? note;
  String? adminNote;
  String? paymentStatus;
  String? transactionId;
  String? serviceFees;
  Timestamp? createdDate;

  // Timestamp? paymentDate;
  String? amount;
  String? email;
  String? phone;
  String? withdrawMethod;

  WithdrawModel(
      {this.id,
      this.userId,
      this.note,
      this.adminNote,
      this.paymentStatus,
      this.transactionId,
      this.serviceFees,
      this.createdDate,
      /*this.paymentDate*/ this.amount,
      this.email,
      this.phone,
      this.withdrawMethod});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    note = json['note'];
    adminNote = json['adminNote'];
    paymentStatus = json['paymentStatus'];
    transactionId = json['transactionId'];
    serviceFees = json['serviceFees'];
    createdDate = json['createdDate'];
    // paymentDate = json['paymentDate'];
    amount = json['amount'];
    email = json['email'];
    phone = json['phone'];
    withdrawMethod = json['withdrawMethod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['note'] = note;
    data['adminNote'] = adminNote;
    data['paymentStatus'] = paymentStatus;
    data['transactionId'] = transactionId;
    data['serviceFees'] = serviceFees;
    data['createdDate'] = createdDate;
    // data['paymentDate'] = paymentDate;
    data['amount'] = amount;
    data['email'] = email;
    data['phone'] = phone;
    data['withdrawMethod'] = withdrawMethod;
    return data;
  }
}
