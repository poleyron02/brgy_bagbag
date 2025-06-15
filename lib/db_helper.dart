import 'dart:async';

import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/admin_log.dart';
import 'package:brgy_bagbag/models/announcement.dart';
import 'package:brgy_bagbag/models/announcement_category.dart';
import 'package:brgy_bagbag/models/announcement_receiver.dart';
import 'package:brgy_bagbag/models/barangay_official.dart';
import 'package:brgy_bagbag/models/forms/business_clearance_id.dart';
import 'package:brgy_bagbag/models/forms/business_clearance.dart';
import 'package:brgy_bagbag/models/forms/concern.dart';
import 'package:brgy_bagbag/models/forms/indigency.dart';
import 'package:brgy_bagbag/models/incident_report.dart';
import 'package:brgy_bagbag/models/forms/legal_consultation.dart';
import 'package:brgy_bagbag/models/notification_message.dart';
import 'package:brgy_bagbag/models/request.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

const String announcementName = 'announcements';
const String announcementCategoriesName = 'announcement_categories';
const String announcementReceiverName = 'announcement_receivers';
const String barangayOfficialName = 'barangay_officials';
const String incidentReportName = 'incident_reports';
const String residentsName = 'residents';
const String legalConsultationName = 'legal_consultations';
const String concernsName = 'concerns';
const String indigenciesName = 'indigencies';
const String businessClearanceIdName = 'business_clearance_ids';
const String businessClearancesName = 'business_clearances';
const String requestsName = 'requests';
const String notificationsName = 'notifications';
const String adminAccountsName = 'admin_accounts';
const String adminLogsName = 'admin_logs';

var announcementCollection = db.collection(announcementName).withConverter(fromFirestore: Announcement.fromFirestore, toFirestore: (value, options) => value.toMap());
var announcementCategoriesCollection = db.collection(announcementCategoriesName).withConverter(fromFirestore: AnnouncementCategory.fromFirestore, toFirestore: (value, options) => value.toMap());
var announcementReceiverCollection = db.collection(announcementReceiverName).withConverter(fromFirestore: AnnouncementReceiver.fromFirestore, toFirestore: (value, options) => value.toMap());
var barangayOfficialCollection = db.collection(barangayOfficialName).withConverter(fromFirestore: BarangayOfficial.fromFirestore, toFirestore: (value, options) => value.toMap());
var incidentReportCollection = db.collection(incidentReportName).withConverter(fromFirestore: IncidentReport.fromFirestore, toFirestore: (value, options) => value.toMap());
var residentsCollection = db.collection(residentsName).withConverter(fromFirestore: Resident.fromFirestore, toFirestore: (value, options) => value.toMap());
var legalConsultationsCollection = db.collection(legalConsultationName).withConverter(fromFirestore: LegalConsultation.fromFirestore, toFirestore: (value, options) => value.toMap());
var concernsCollection = db.collection(concernsName).withConverter(fromFirestore: Concern.fromFirestore, toFirestore: (value, options) => value.toMap());
var indigenciesCollection = db.collection(indigenciesName).withConverter(fromFirestore: Indigency.fromFirestore, toFirestore: (value, options) => value.toMap());
var businessClearanceIdCollection = db.collection(businessClearanceIdName).withConverter(fromFirestore: BusinessClearanceId.fromFirestore, toFirestore: (value, options) => value.toMap());
var businessClearancesCollection = db.collection(businessClearancesName).withConverter(fromFirestore: BusinessClearance.fromFirestore, toFirestore: (value, options) => value.toMap());
var requestsCollection = db.collection(requestsName).withConverter(fromFirestore: Request.fromFirestore, toFirestore: (value, options) => value.toMap());
var notificationsCollection = db.collection(notificationsName).withConverter(fromFirestore: NotificationMessage.fromFirestore, toFirestore: (value, options) => value.toMap());
var adminAccountsCollection = db.collection(adminAccountsName).withConverter(fromFirestore: AdminAccount.fromFirestore, toFirestore: (value, options) => value.toMap());
var adminLogsCollection = db.collection(adminLogsName).withConverter(fromFirestore: AdminLog.fromFirestore, toFirestore: (value, options) => value.toMap());

Stream<QuerySnapshot<Announcement>> get announcementsStream => announcementCollection.orderBy('createdAt', descending: true).snapshots().asBroadcastStream();

// Announcement
Future<void> setAnnouncement(Announcement announcement, {DocumentReference<Announcement>? doc}) async => await (doc ?? announcementCollection.doc()).set(announcement);
Future<void> removeAnnouncement(String id) async => await announcementCollection.doc(id).delete();

// Announcement Category
Future<void> setAnnouncementCategory(AnnouncementCategory announcementCategory, {DocumentReference<AnnouncementCategory>? doc}) async => await (doc ?? announcementCategoriesCollection.doc()).set(announcementCategory);
Future<void> removeAnnouncementCategory(String id) async => await announcementCategoriesCollection.doc(id).delete();
Future<bool> get isAnnouncementCategoryEmpty async => ((await announcementCategoriesCollection.count().get()).count ?? 0) <= 0;

// Announcement Category
Future<void> setAnnouncementReceiver(AnnouncementReceiver announcementReceiver, {DocumentReference<AnnouncementReceiver>? doc}) async => await (doc ?? announcementReceiverCollection.doc()).set(announcementReceiver);
Future<void> removeAnnouncementReceiver(String id) async => await announcementReceiverCollection.doc(id).delete();
Future<bool> get isAnnouncementReceiverEmpty async => ((await announcementReceiverCollection.count().get()).count ?? 0) <= 0;

// Barangay Official
Future<void> setBarangayOfficial(BarangayOfficial barangayOfficial, {DocumentReference<BarangayOfficial>? doc}) async => await (doc ?? barangayOfficialCollection.doc()).set(barangayOfficial);
Future<void> removeBarangayOfficial(String id) async => await barangayOfficialCollection.doc(id).delete();

// Incident Report
Future<void> setIncidentReport(IncidentReport incidentReport, {DocumentReference<IncidentReport>? doc}) async => await (doc ?? incidentReportCollection.doc()).set(incidentReport);
Future<void> removeIncidentReport(String id) async => await incidentReportCollection.doc(id).delete();

// Resident
Future<void> setResident(Resident resident, {DocumentReference<Resident>? doc}) async => await (doc ?? residentsCollection.doc()).set(resident);
Future<void> removeResident(String id) async => await residentsCollection.doc(id).delete();

// Legal Consultation
Future<void> setLegalConsultation(LegalConsultation legalConsultation, {DocumentReference<LegalConsultation>? doc}) async {
  await (doc ?? legalConsultationsCollection.doc()).set(legalConsultation);
  await newRequest(legalConsultation.uid, legalConsultationName, legalConsultation.id);
}

Future<void> removeLegalConsultation(String id) async => await legalConsultationsCollection.doc(id).delete();

// Concern
Future<void> setConcern(Concern concern, {DocumentReference<Concern>? doc}) async {
  await (doc ?? concernsCollection.doc()).set(concern);
  await newRequest(concern.uid, concernsName, concern.id);
}

Future<void> removeConcern(String id) async => await concernsCollection.doc(id).delete();

// Indigency
Future<void> setIndigency(Indigency indigency, {DocumentReference<Indigency>? doc}) async {
  await (doc ?? indigenciesCollection.doc()).set(indigency);
  await newRequest(indigency.uid, indigenciesName, indigency.id);
}

Future<void> removeIndigency(String id) async => await indigenciesCollection.doc(id).delete();

// Business Clearance Id
Future<void> setBusinessClearanceId(BusinessClearanceId businessClearanceId, {DocumentReference<BusinessClearanceId>? doc}) async {
  await (doc ?? businessClearanceIdCollection.doc()).set(businessClearanceId);
  await newRequest(businessClearanceId.uid, businessClearanceIdName, businessClearanceId.id);
}

Future<void> removeBusinessClearanceId(String id) async => await businessClearanceIdCollection.doc(id).delete();

// Business Clearance
Future<void> setBusinessClearance(BusinessClearance businessClearance, {DocumentReference<BusinessClearance>? doc}) async {
  await (doc ?? businessClearancesCollection.doc()).set(businessClearance);
  await newRequest(businessClearance.uid, businessClearancesName, businessClearance.id);
}

Future<void> removeBusinessClearance(String id) async => await businessClearancesCollection.doc(id).delete();

// Request
Future<void> setRequest(Request request, {DocumentReference<Request>? doc}) async => await (doc ?? requestsCollection.doc()).set(request);
Future<void> removeRequest(String id) async => await requestsCollection.doc(id).delete();
Future<void> newRequest(String uid, String collection, String collectionId) async {
  DocumentReference<Request> doc = requestsCollection.doc();
  Request request = Request(id: doc.id, uid: uid, collection: collection, collectionId: collectionId, createdAt: Timestamp.now(), updatedAt: Timestamp.now());
  await setRequest(request, doc: doc);
}

Future<void> setRequestStatus(String id, String status) async {
  DocumentReference<Request> doc = requestsCollection.doc(id);
  Request request = (await doc.get()).data()!;
  request.status = status;
  await doc.set(request);
}

// Notification
Future<void> setNotification(NotificationMessage notification, {DocumentReference<NotificationMessage>? doc}) async => await (doc ?? notificationsCollection.doc()).set(notification);
Future<void> removeNotification(String id) async => await notificationsCollection.doc(id).delete();

// Admin Account
Future<void> setAdminAccount(AdminAccount admin, {DocumentReference<AdminAccount>? doc}) async {
  if (doc == null) {
    AggregateQuerySnapshot snapshot = await adminAccountsCollection.where('email', isEqualTo: admin.email).where('password', isEqualTo: admin.password).count().get();
    if ((snapshot.count ?? 0) > 0) return;
  }
  await (doc ?? adminAccountsCollection.doc()).set(admin);
}

Future<void> removeAdminAccount(String id) async => await adminAccountsCollection.doc(id).delete();
Future<AdminAccount?> loginAdmin(String username, String password) async {
  QuerySnapshot<AdminAccount> snapshot = await adminAccountsCollection.where('username', isEqualTo: username).where('password', isEqualTo: password).limit(1).get();
  if (snapshot.docs.isEmpty) return null;
  return snapshot.docs.single.data();
}

// Admin Log
Future<void> setAdminLog(AdminLog log, {DocumentReference<AdminLog>? doc}) async => await (doc ?? adminLogsCollection.doc()).set(log);
Future<void> removeAdminLog(String id) async => await adminLogsCollection.doc(id).delete();
Future<void> logAdminAction(AdminAccount admin, String action) async {
  DocumentReference<AdminLog> doc = adminLogsCollection.doc();

  AdminLog log = AdminLog(id: doc.id, adminId: admin.id, adminName: admin.fullName, action: action, loggedAt: Timestamp.now(), createdAt: Timestamp.now(), updatedAt: Timestamp.now());

  await setAdminLog(log, doc: doc);
}
