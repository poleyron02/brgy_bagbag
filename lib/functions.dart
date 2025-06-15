import 'dart:convert';

import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/models/forms/indigency.dart';
import 'package:brgy_bagbag/models/incident_report.dart';
import 'package:brgy_bagbag/models/person_position.dart';
import 'package:brgy_bagbag/models/resident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;

void showSnackBar(BuildContext context, String message) {
  SnackBar snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String? validate(String? value) {
  if (value == null) return 'Required';
  if (value.isEmpty) return 'Required';
  return null;
}

String? validateContactNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }

  // Check if the value contains only digits
  final RegExp digitOnly = RegExp(r'^\d+$');
  if (!digitOnly.hasMatch(value)) {
    return 'Contact number should contain only digits';
  }

  // Check if the length is exactly 10 (or adjust for your required length)
  if (value.length != 10) {
    return 'Contact number should be exactly 10 digits';
  }

  return null; // Return null if the contact number is valid
}

extension FormatTimestampToString on Timestamp {
  String format({bool showTime = true}) {
    DateTime dateTime = toDate();
    DateFormat formatter = DateFormat('MMMM d, yyyy${showTime ? ' h:mm a' : ''}');
    return formatter.format(dateTime);
  }

  int getElapsedYearsSince() {
    final DateTime date = toDate();
    final DateTime now = DateTime.now();

    int yearsElapsed = now.year - date.year;

    // Check if the current date is before the date of the same month and day as the original timestamp
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      yearsElapsed--;
    }

    return yearsElapsed;
  }
}

extension FormatDateTimeToString on DateTime {
  String format({bool showTime = true}) {
    DateFormat formatter = DateFormat('MMMM d, yyyy${showTime ? ' h:mm a' : ''}');
    return formatter.format(this);
  }
}

extension MoreToStrings on String {
  String toSnakeCase() {
    String snakeCased = replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]}_${m[2]}').replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();

    return snakeCased;
  }
}

void sendEmailVerification(BuildContext context, User user) async {
  try {
    await user.sendEmailVerification();
    SnackBar snackBar = const SnackBar(content: Text('A verification link was sent to your email account'));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (e) {
    SnackBar snackBar = SnackBar(
      content: const Text('There was a problem sending the verification link'),
      action: SnackBarAction(
        label: 'TRY AGAIN',
        onPressed: () => sendEmailVerification(context, user),
      ),
    );
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future<void> downloadIncidentReport(IncidentReport report) async {
  final pdf = pw.Document();

  // Load the Times font
  final ttf = await PdfGoogleFonts.tinosRegular();
  final ttfBold = await PdfGoogleFonts.tinosBold();
  final ttfItalic = await PdfGoogleFonts.tinosItalic();

  final bagbagImg = await rootBundle.load('images/logo.png');
  final bagbagBytes = bagbagImg.buffer.asUint8List();
  final qcImg = await rootBundle.load('images/qclogo.png');
  final qcBytes = qcImg.buffer.asUint8List();

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              children: [
                pw.SizedBox.square(
                  dimension: 100,
                  child: pw.Image(pw.MemoryImage(bagbagBytes)),
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'Republic of the Philippines\nPROVINCE OF Mentro Manila\nMUNICIPALITY OF Quezon City',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            font: ttf,
                          ),
                        ),
                        pw.Text(
                          'BARANGAY BAGBAG',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontBold: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline,
                            // fontStyle: pw.FontStyle.italic,
                            // fontItalic: ttfItalic,
                            font: ttf,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          'OFFICE OF THE BARANGAY HEAD',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontBold: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                            // fontStyle: pw.FontStyle.italic,
                            // fontItalic: ttfItalic,
                            font: ttf,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox.square(
                  dimension: 100,
                  child: pw.Image(pw.MemoryImage(qcBytes)),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            pw.Center(
              child: pw.Text(
                'INCIDENT REPORT',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  fontBold: ttfBold,
                ),
              ),
            ),

            pw.SizedBox(height: 40),

            // Report Details
            pw.Text('Incident Report ID: ${report.id}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            // pw.Text('Status: ${report.status}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            // pw.Text('Blotter Type: ${report.blotterType}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            // pw.Text('Incident Case: ${report.incidentCase}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            pw.Text('Title: ${report.title}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            pw.Text('Location: ${report.location}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            pw.Text('Date/Time Reported: ${DateFormat.yMMMMd().format(report.occurredAt.toDate())} at ${DateFormat.jm().format(report.occurredAt.toDate())}', style: pw.TextStyle(fontSize: 12, font: ttf)),
            pw.SizedBox(height: 20),

            // Complainants
            pw.Text('Complainants:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, fontBold: ttfBold, font: ttf)),
            pw.SizedBox(height: 10),
            ...report.complainants.map((person) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${person.name} (${person.gender})', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Birthday: ${DateFormat.yMMMMd().format(person.birthday.toDate())}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Address: ${person.address}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Description: ${person.description}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.SizedBox(height: 10),
                  ],
                )),
            pw.SizedBox(height: 20),

            // Offenders
            pw.Text('Offenders:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, fontBold: ttfBold, font: ttf)),
            pw.SizedBox(height: 10),
            ...report.offenders.map((person) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${person.name} (${person.gender})', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Birthday: ${DateFormat.yMMMMd().format(person.birthday.toDate())}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Address: ${person.address}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.Text('Description: ${person.description}', style: pw.TextStyle(fontSize: 14, font: ttf)),
                    pw.SizedBox(height: 10),
                  ],
                )),
            pw.SizedBox(height: 20),

            // Narrative
            pw.Text('Narrative of the Incident:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, fontBold: ttfBold, font: ttf)),
            pw.SizedBox(height: 10),
            pw.Text(report.narrative, style: pw.TextStyle(fontSize: 14, font: ttf)),
            // pw.SizedBox(height: 20),

            // Footer
            // pw.Text('Report Created At: ${DateFormat.yMMMMd().format(report.createdAt.toDate())} at ${DateFormat.jm().format(report.createdAt.toDate())}', style: pw.TextStyle(fontSize: 12, font: ttf)),
          ],
        );
      },
    ),
  );

  // Use Printing package to save or print the PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'incident_report_${report.id}.pdf',
  );
}

Future<void> printCertificate({required String title, required String content, required String fileName, required List<PersonPosition> persons}) async {
  Uint8List bytes = await createCertificate(title: title, content: content, persons: persons);
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => bytes,
    name: '$fileName.pdf',
  );
}

Future<Uint8List> createCertificate({required String title, required String content, required List<PersonPosition> persons}) async {
  final pdf = pw.Document();

  // Load the Times font
  final ttf = await PdfGoogleFonts.tinosRegular();
  final ttfBold = await PdfGoogleFonts.tinosBold();
  final ttfItalic = await PdfGoogleFonts.tinosItalic();

  final bagbagImg = await rootBundle.load('images/logo.png');
  final bagbagBytes = bagbagImg.buffer.asUint8List();
  final qcImg = await rootBundle.load('images/qclogo.png');
  final qcBytes = qcImg.buffer.asUint8List();

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              children: [
                pw.SizedBox.square(
                  dimension: 100,
                  child: pw.Image(pw.MemoryImage(bagbagBytes)),
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'Republic of the Philippines\nPROVINCE OF Mentro Manila\nMUNICIPALITY OF Quezon City',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            font: ttf,
                          ),
                        ),
                        pw.Text(
                          'BARANGAY BAGBAG',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontBold: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline,
                            // fontStyle: pw.FontStyle.italic,
                            // fontItalic: ttfItalic,
                            font: ttf,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          'OFFICE OF THE BARANGAY HEAD',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontBold: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                            // fontStyle: pw.FontStyle.italic,
                            // fontItalic: ttfItalic,
                            font: ttf,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox.square(
                  dimension: 100,
                  child: pw.Image(pw.MemoryImage(qcBytes)),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  fontBold: ttfBold,
                ),
              ),
            ),

            pw.SizedBox(height: 40),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: List.generate(
                      persons.length,
                      (index) => pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.RichText(
                            textAlign: pw.TextAlign.center,
                            text: formatText(input: '*${persons[index].name}*\n${persons[index].position}', font: ttf, bold: ttfBold, italic: ttfItalic),
                          ),
                          if (index < persons.length - 1) pw.SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.RichText(
                    text: formatText(
                      font: ttf,
                      bold: ttfBold,
                      italic: ttfItalic,
                      fontSize: 14,
                      input: content,
                    ),
                  ),
                ),
              ],
            ),

            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.RichText(text: formatText(input: 'CTC NO.\nISSUED ON: *${Timestamp.now().format().toUpperCase()}*\nISSUED AT: *BAGBAG QUEZON CITY, METRO MANILA*\nO.R. NO.', font: ttf, bold: ttfBold, italic: ttfItalic)),
                      ],
                    ),
                  ),
                  pw.RichText(
                    textAlign: pw.TextAlign.center,
                    text: formatText(input: '*REX V. AMBITA*\nPUNONG BARANGAY', font: ttf, bold: ttfBold, italic: ttfItalic),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
  // Use Printing package to save or print the PDF
  // await Printing.layoutPdf(
  //   onLayout: (PdfPageFormat format) async => ,
  //   name: '$fileName.pdf',
  // );
}

pw.TextSpan formatText({
  required String input,
  required pw.Font font,
  required pw.Font bold,
  required pw.Font italic,
  double fontSize = 12,
}) {
  final boldRegex = RegExp(r'\*(.*?)\*');
  const specialChar = '#'; // Special character to trigger WidgetSpan

  List<pw.InlineSpan> spans = [];
  int currentIndex = 0;

  // Process bold text
  input.replaceAllMapped(boldRegex, (match) {
    if (match.start > currentIndex) {
      _addTextAndSpecialCharSpans(input.substring(currentIndex, match.start), spans, font, specialChar);
    }
    spans.add(pw.TextSpan(
      text: match.group(1),
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        font: bold,
        decoration: pw.TextDecoration.underline,
      ),
    ));
    currentIndex = match.end;
    return '';
  });

  // Add remaining text after the last match
  if (currentIndex < input.length) {
    _addTextAndSpecialCharSpans(input.substring(currentIndex), spans, font, specialChar);
  }

  return pw.TextSpan(
    children: spans,
    style: pw.TextStyle(
      height: 2,
      fontSize: fontSize,
      font: font,
      fontNormal: font,
      fontBold: bold,
      fontItalic: italic,
    ),
  );
}

TextSpan formatTextSpan({
  required String input,
  double fontSize = 12,
}) {
  final boldRegex = RegExp(r'\*(.*?)\*');
  const specialChar = '#'; // Special character to trigger WidgetSpan

  List<InlineSpan> spans = [];
  int currentIndex = 0;

  // Process bold text
  input.replaceAllMapped(boldRegex, (match) {
    if (match.start > currentIndex) {
      _addTextSpanAndSpecialCharSpans(input.substring(currentIndex, match.start), spans, specialChar);
    }
    spans.add(TextSpan(
      text: match.group(1),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    ));
    currentIndex = match.end;
    return '';
  });

  // Add remaining text after the last match
  if (currentIndex < input.length) {
    _addTextSpanAndSpecialCharSpans(input.substring(currentIndex), spans, specialChar);
  }

  return TextSpan(
    children: spans,
    style: TextStyle(
      height: 2,
      fontSize: fontSize,
    ),
  );
}

void _addTextSpanAndSpecialCharSpans(String text, List<InlineSpan> spans, String specialChar) {
  text.split(specialChar).asMap().forEach((index, part) {
    if (index > 0) {
      spans.add(
        const WidgetSpan(
          child: SizedBox(width: 40.0),
        ),
      );
    }
    if (part.isNotEmpty) {
      spans.add(TextSpan(text: part));
    }
  });
}

void _addTextAndSpecialCharSpans(String text, List<pw.InlineSpan> spans, pw.Font font, String specialChar) {
  text.split(specialChar).asMap().forEach((index, part) {
    if (index > 0) {
      spans.add(
        pw.WidgetSpan(
          child: pw.SizedBox(width: 40.0),
        ),
      );
    }
    if (part.isNotEmpty) {
      spans.add(pw.TextSpan(text: part, style: pw.TextStyle(font: font)));
    }
  });
}

Future<void> showExportDialog(BuildContext context) async {
  String? selectedCategory;
  String? exportType = 'pdf';

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Export Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Category'),
                  value: selectedCategory,
                  items: [
                    'Adult',
                    'All resident',
                    'Female',
                    'Male',
                    'Minor',
                    'Senior',
                    'Teenager',
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selectedCategory = value;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('PDF'),
                        value: 'pdf',
                        groupValue: exportType,
                        onChanged: (String? value) {
                          setState(() {
                            exportType = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Excel'),
                        value: 'excel',
                        groupValue: exportType,
                        onChanged: (String? value) {
                          setState(() {
                            exportType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedCategory == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        _exportData(selectedCategory!, exportType!);
                      },
                child: const Text('Export'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _exportData(String category, String exportType) async {
  List<Resident> residents = await _fetchResidentsByCategory(category);

  if (exportType == 'pdf') {
    await _generatePdf(residents);
  } else if (exportType == 'excel') {
    await _generateCsv(residents);
  }
}

Future<List<Resident>> _fetchResidentsByCategory(String category) async {
  final QuerySnapshot<Resident> snapshot = await residentsCollection.get();
  List<Resident> filteredResidents = [];

  final DateTime now = DateTime.now();

  for (var doc in snapshot.docs) {
    Resident resident = doc.data();
    int age = now.year - resident.birthday.toDate().year;

    switch (category) {
      case 'Infants':
        if (age < 2) filteredResidents.add(resident);
        break;
      case 'Children':
        if (age >= 2 && age <= 12) filteredResidents.add(resident);
        break;
      case 'Teens':
        if (age >= 13 && age <= 19) filteredResidents.add(resident);
        break;
      case 'Adult':
        if (age >= 20 && age <= 59) filteredResidents.add(resident);
        break;
      case 'Senior':
        if (age >= 60) filteredResidents.add(resident);
        break;
      case 'Female':
        if (resident.gender.toLowerCase() == 'female') filteredResidents.add(resident);
        break;
      case 'Male':
        if (resident.gender.toLowerCase() == 'male') filteredResidents.add(resident);
        break;
      case 'All resident':
        filteredResidents.add(resident);
        break;
    }
  }

  return filteredResidents;
}

Future<void> _generateCsv(List<Resident> residents) async {
  List<List<String>> rows = [];

  // Header row
  rows.add([
    "ID",
    "Status",
    // "Reason for Decline",
    "User ID",
    "First Name",
    "Middle Name",
    "Last Name",
    "Suffix",
    "Gender",
    "Birthday",
    "Contact Number",
    // "Address",
    "Place of Birth",
    "Occupation",
    "Is Voter",
    // "Purok Number",
    "Resident Since",
    // "First Valid ID",
    // "Second Valid ID",
    "Created At"
  ]);

  // Data rows
  for (var resident in residents) {
    rows.add([
      resident.id,
      resident.status,
      // resident.reasonForDecline ?? '',
      resident.userId,
      resident.firstName,
      resident.middleName ?? '',
      resident.lastName,
      resident.suffix,
      resident.gender,
      resident.birthday.toDate().toIso8601String(),
      resident.contactNumber,
      // resident.address,
      resident.placeOfBirth,
      resident.occupation,
      resident.isVoter ? 'Yes' : 'No',
      // resident.purokNumber,
      resident.residentSince,
      // resident.firstValidId.type,
      // resident.secondValidId.type,
      resident.createdAt.toDate().toIso8601String(),
    ]);
  }

  // Convert rows to CSV string
  String csv = const ListToCsvConverter().convert(rows);

  // Trigger download
  final bytes = utf8.encode(csv);
  final blob = html.Blob([
    bytes
  ]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "residents_${DateTime.now().toIso8601String()}.csv")
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> _generatePdf(List<Resident> residents) async {
  final pdf = pw.Document();

  // final fontData = await rootBundle.load("assets/fonts/TimesNewRoman.ttf");
  // final font = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.legal.landscape,
      margin: const pw.EdgeInsets.all(10),
      build: (pw.Context context) {
        return pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(),
          headers: [
            'ID',
            'Status',
            // 'Reason for Decline',
            // 'User ID',
            'First Name',
            'Middle Name',
            'Last Name',
            'Suffix',
            'Gender',
            'Birthday',
            'Contact Number',
            // 'Address',
            'Place of Birth',
            'Occupation',
            'Is Voter',
            // 'Purok Number',
            'Resident Since',
            // 'First Valid ID',
            // 'Second Valid ID',
            'Created At'
          ],
          data: residents.map((resident) {
            return [
              resident.id,
              resident.status,
              // resident.reasonForDecline ?? '',
              // resident.userId,
              resident.firstName,
              resident.middleName ?? '',
              resident.lastName,
              resident.suffix,
              resident.gender,
              resident.birthday.format(showTime: false),
              resident.contactNumber,
              // resident.address,
              resident.placeOfBirth,
              resident.occupation,
              resident.isVoter ? 'Yes' : 'No',
              // resident.purokNumber,
              resident.residentSince,
              // resident.firstValidId.id,
              // resident.secondValidId.id,
              resident.createdAt.toDate().toIso8601String(),
            ];
          }).toList(),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          cellAlignments: {
            0: pw.Alignment.center,
            1: pw.Alignment.centerLeft,
            // 2: pw.Alignment.centerLeft,
            // 3: pw.Alignment.centerLeft,
            4: pw.Alignment.centerLeft,
            5: pw.Alignment.centerLeft,
            6: pw.Alignment.centerLeft,
            7: pw.Alignment.centerLeft,
            8: pw.Alignment.center,
            9: pw.Alignment.center,
            10: pw.Alignment.centerLeft,
            // 11: pw.Alignment.centerLeft,
            12: pw.Alignment.centerLeft,
            13: pw.Alignment.centerLeft,
            14: pw.Alignment.center,
            15: pw.Alignment.centerLeft,
            16: pw.Alignment.center,
            // 17: pw.Alignment.centerLeft,
            // 18: pw.Alignment.centerLeft,
            19: pw.Alignment.center,
          },
        );
      },
    ),
  );

  Uint8List bytes = await pdf.save();

  // Trigger download
  final blob = html.Blob([
    bytes
  ], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "residents_${DateTime.now().toIso8601String()}.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}
