import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/models/person_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

OutlineInputBorder outlineInputBorder(BuildContext context) => OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      borderRadius: BorderRadius.circular(8),
    );

// List<String> nameSuffixes = [
//   'None',
//   'Jr.', // Junior
//   'Sr.', // Senior
//   'II', // The Second
//   'III', // The Third
//   'IV', // The Fourth
//   'V', // The Fifth
//   'Ph.D.', // Doctor of Philosophy
//   'M.D.', // Doctor of Medicine
//   'D.D.S.', // Doctor of Dental Surgery
//   'Esq.', // Esquire
//   'J.D.', // Juris Doctor
//   'M.B.A.', // Master of Business Administration
//   'DVM', // Doctor of Veterinary Medicine
//   'CPA', // Certified Public Accountant
//   'RN', // Registered Nurse
//   'CFA', // Chartered Financial Analyst
//   'PE', // Professional Engineer
//   'DDS', // Doctor of Dental Surgery
//   'DNP', // Doctor of Nursing Practice
// ];

// List<String> nameSuffixes = [
//   'None',
//   'Jr.', // Junior
//   'Sr.', // Senior
//   'II', // The Second
//   'III', // The Third
//   'IV', // The Fourth
//   'V', // The Fifth
//   'Ph.D.', // Doctor of Philosophy
//   'M.D.', // Doctor of Medicine
//   'D.D.S.', // Doctor of Dental Surgery
//   'Esq.', // Esquire
//   'J.D.', // Juris Doctor
//   'M.B.A.', // Master of Business Administration
//   'D.V.M.', // Doctor of Veterinary Medicine
//   'CPA', // Certified Public Accountant
//   'RN', // Registered Nurse
//   'CFA', // Chartered Financial Analyst
//   'PE', // Professional Engineer
//   'DDS', // Doctor of Dental Surgery
//   'DNP', // Doctor of Nursing Practice
//   'DO', // Doctor of Osteopathic Medicine
//   'OD', // Doctor of Optometry
//   'DMin', // Doctor of Ministry
//   'Th.D.', // Doctor of Theology
//   'Sc.D.', // Doctor of Science
//   'D.Pharm.', // Doctor of Pharmacy
//   'LL.M.', // Master of Laws
//   'Ed.D.', // Doctor of Education
//   'DScPT', // Doctor of Science in Physical Therapy
//   'MA', // Master of Arts
//   'MS', // Master of Science
//   'MPH', // Master of Public Health
//   'M.Ed.', // Master of Education
//   'MPA', // Master of Public Administration
//   'MFA', // Master of Fine Arts
//   'BSN', // Bachelor of Science in Nursing
//   'B.A.', // Bachelor of Arts
//   'B.S.', // Bachelor of Science
//   'Psy.D.', // Doctor of Psychology
//   'LCSW', // Licensed Clinical Social Worker
//   'LCPC', // Licensed Clinical Professional Counselor
//   'RD', // Registered Dietitian
//   'FAIA', // Fellow of the American Institute of Architects
//   'FACP', // Fellow of the American College of Physicians
// ];

List<String> nameSuffixes = [
  'None',
  'Jr.', // Junior
  'Sr.', // Senior
  'II', // The Second
  'III', // The Third
  'IV', // The Fourth
  'V', // The Fifth
  'VI', // The Sixth
  'VII', // The Seventh
  'VIII', // The Eighth
  'IX', // The Ninth
  'X', // The Tenth
];

List<String> genders = [
  'Male',
  'Female'
];
List<String> civilStatuses = [
  'Single',
  'Married',
  'Widow/Widower'
];

List<String> blotterTypes = [
  'Complaint',
  'Incident',
];

List<String> incidentCases = [
  'Criminal',
  'Civil'
];

List<String> incidentStatuses = [
  'Mediated',
  'Concialited',
  'Arbitrated',
  'Dismiss',
  'Certified case',
];

List<String> validPhilippineIDs = [
  'Passport',
  'Driver’s License',
  'Unified Multi-Purpose ID (UMID)',
  'Philippine Identification (PhilID or National ID)',
  'Social Security System (SSS) ID',
  'Government Service Insurance System (GSIS) eCard',
  'Professional Regulation Commission (PRC) ID',
  'Voter’s ID',
  'Postal ID',
  'Tax Identification Number (TIN) ID',
  'PhilHealth ID',
  'Overseas Workers Welfare Administration (OWWA) ID',
  'OFW ID',
  'Alien Certificate of Registration (ACR) I-Card',
  'Senior Citizen ID',
  'Persons with Disabilities (PWD) ID',
  'NBI Clearance',
  'Police Clearance',
  'Barangay Certification/ID',
  'School ID (for students)',
  'Seaman’s Book',
  'Marriage Certificate (for proof of identity when required)',
];

List<String> residentStatuses = [
  'Pending',
  'Approved',
  'Declined',
];

List<String> residentTypes = [
  'Resident',
  'Non-resident',
];

Map<String, String> collectionNames = {
  concernsName: 'Concern',
  indigenciesName: 'Indigency',
  legalConsultationName: 'Legal Consultation',
  businessClearancesName: 'Barangay Business Clearance',
  businessClearanceIdName: 'Business Clearance ID',
};

Map<String, IconData> collectionIcons = {
  concernsName: TablerIcons.bubble,
  indigenciesName: TablerIcons.certificate_2,
  legalConsultationName: TablerIcons.contract,
  businessClearancesName: TablerIcons.building,
  businessClearanceIdName: TablerIcons.id_badge_2,
};

List<PersonPosition> personPositions = [
  PersonPosition(name: 'REX V. AMBITA', position: 'Punong Barangay'),
  PersonPosition(name: 'REYNALDO T. LLEGADO', position: 'Peace and Order'),
  PersonPosition(name: 'JAYSON SJ. PALIZA', position: 'Women, Family, & Youth Sports Development'),
  PersonPosition(name: 'BETTY L. VITANGCOL', position: 'Health and Education'),
  PersonPosition(name: 'JESUS DP. VILLAMOR', position: 'Agricultural and Environmental Protection'),
  PersonPosition(name: 'AARON KYLE R. MELGAR', position: 'Appropriation'),
  PersonPosition(name: 'LORD MICHAEL ANTHONY A. CANLAS', position: 'Infrastructure'),
  PersonPosition(name: 'ROLANDO H. MEJILA', position: 'Secretary'),
  PersonPosition(name: 'EVARISTA GRATELA PELAYO', position: 'Treasurer'),
];

ValueNotifier<bool> isAdminLogin = ValueNotifier(false);

Color primaryColor = const Color.fromARGB(255, 21, 165, 73);

ValueNotifier<bool> darkMode = ValueNotifier(false);

List<String> bagbagStreets = [
  'Abbey Road',
  'Alipio',
  'Apollo',
  'Armando',
  'Babina',
  'Bernarty',
  'Bicol Compound',
  'Biglang-awa',
  'Blas Roque',
  'Callejon',
  'Camp Grezar',
  'Carreon',
  'Celina Drive',
  'Coronel Compound',
  'Daniac',
  'De Asis',
  'Don Julio Gregorio',
  'Dupax',
  'Franco',
  'Francisco',
  'Gawad Kalinga',
  'Goldhill',
  'Goodwill II',
  'Goodwill Town Homes',
  'Ibayo I Cleofas',
  'Katipunan Kanan',
  'Katipunan Kaliwa',
  'Kingspoint',
  'Likas',
  'Magno',
  'Maloles',
  'Manggahan',
  'Mangilog',
  'Mantikaan',
  'Marides',
  'Narra',
  'Old Paliguan',
  'Oro Compound',
  'Parokya Road',
  'Pinera Compound',
  'Princess Homes',
  'Quirino Highway',
  'Remarville',
  'Remarville Ave',
  'Richland V',
  'Road 1',
  'Road 2',
  'Road 3',
  'Road 4',
  'San Pedro 9',
  'Santos Compound',
  'Sementeryo',
  'Sinag-Tala',
  'Sinforosa',
  'St. Michael',
  'Uping',
  'Urcia',
  'Urbano',
  'Wings Bungad',
  'Wings Gitna',
  'Wings Itaas',
];
