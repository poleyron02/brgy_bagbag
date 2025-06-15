import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:brgy_bagbag/models/incident_person.dart';

class IncidentReport {
  String id;
  bool archived;
  String status;
  String blotterType;
  String incidentCase;
  String title;
  Timestamp occurredAt;
  String location;
  String narrative;

  List<IncidentPerson> complainants;
  List<IncidentPerson> offenders;

  Timestamp createdAt;
  Timestamp updatedAt;

  IncidentReport({
    required this.id,
    this.archived = false,
    this.status = 'Mediated',
    required this.blotterType,
    required this.incidentCase,
    required this.title,
    required this.occurredAt,
    required this.location,
    required this.narrative,
    required this.complainants,
    required this.offenders,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'archived': archived
    });
    result.addAll({
      'status': status
    });
    result.addAll({
      'blotterType': blotterType
    });
    result.addAll({
      'incidentCase': incidentCase
    });
    result.addAll({
      'title': title
    });
    result.addAll({
      'occurredAt': occurredAt
    });
    result.addAll({
      'location': location
    });
    result.addAll({
      'narrative': narrative
    });
    result.addAll({
      'complainants': complainants.map((x) => x.toMap()).toList()
    });
    result.addAll({
      'offenders': offenders.map((x) => x.toMap()).toList()
    });
    result.addAll({
      'createdAt': createdAt
    });
    result.addAll({
      'updatedAt': updatedAt
    });

    return result;
  }

  factory IncidentReport.fromMap(Map<String, dynamic> map) {
    return IncidentReport(
      id: map['id'] ?? '',
      archived: map['archived'] ?? false,
      status: map['status'] ?? '',
      blotterType: map['blotterType'] ?? '',
      incidentCase: map['incidentCase'] ?? '',
      title: map['title'] ?? '',
      occurredAt: map['occurredAt'],
      location: map['location'] ?? '',
      narrative: map['narrative'] ?? '',
      complainants: List<IncidentPerson>.from(map['complainants']?.map((x) => IncidentPerson.fromMap(x))),
      offenders: List<IncidentPerson>.from(map['offenders']?.map((x) => IncidentPerson.fromMap(x))),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory IncidentReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    Map<String, dynamic> map = doc.data()!;
    map.addAll({
      'id': doc.id
    });
    return IncidentReport.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory IncidentReport.fromJson(String source) => IncidentReport.fromMap(json.decode(source));
}
