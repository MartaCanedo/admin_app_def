import 'package:cloud_firestore/cloud_firestore.dart';

class AllSubjectModel {
  final String id;
  final String name;

  AllSubjectModel({
    required this.id,
    required this.name,
  });

  factory AllSubjectModel.fromDocument(DocumentSnapshot doc) {
    return AllSubjectModel(
      id: doc.id,
      name: doc['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
