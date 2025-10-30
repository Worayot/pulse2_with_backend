import 'package:flutter/material.dart';

class HomeCardData {
  final String? fullname;
  final String? gender;
  final String? hn;
  final String? age;
  final String? bedNum;
  final String? ward;
  final String? mews;
  final String? patientID;
  final DateTime? createdAt;
  final TimeOfDay? inspectionTime;

  HomeCardData({
    this.fullname,
    this.gender,
    this.hn,
    this.age,
    this.bedNum,
    this.ward,
    this.mews,
    this.patientID,
    this.createdAt,
    this.inspectionTime,
  });
}
