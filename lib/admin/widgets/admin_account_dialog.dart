import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/dropdown_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminAccountDialog extends StatelessWidget {
  AdminAccountDialog({super.key, this.adminAccount});

  final AdminAccount? adminAccount;

  final GlobalKey<FormState> formKey = GlobalKey();

  late DocumentReference<AdminAccount> doc = adminAccountsCollection.doc(adminAccount?.id);

  late TextEditingController firstName = TextEditingController(text: adminAccount?.firstName);
  late TextEditingController middleName = TextEditingController(text: adminAccount?.middleName);
  late TextEditingController lastName = TextEditingController(text: adminAccount?.lastName);
  late TextEditingController username = TextEditingController(text: adminAccount?.username);
  late TextEditingController email = TextEditingController(text: adminAccount?.email);
  late TextEditingController password = TextEditingController(text: adminAccount?.password);
  late TextEditingController deviceId = TextEditingController(text: adminAccount?.deviceId);
  late TextEditingController position = TextEditingController(text: adminAccount?.position);

  void submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    AdminAccount newAdmin = AdminAccount(id: doc.id, firstName: firstName.text, middleName: middleName.text, lastName: lastName.text, username: username.text, email: email.text, password: password.text, deviceId: deviceId.text, position: position.text);

    await setAdminAccount(newAdmin, doc: doc);

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.user),
      title: const Text('Admin Account'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: ColumnSeparated(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: validate,
                controller: firstName,
                decoration: InputDecoration(
                  labelText: 'First name',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: middleName,
                decoration: InputDecoration(
                  labelText: 'Middle name',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: lastName,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              TextFormField(
                validator: validate,
                controller: deviceId,
                decoration: InputDecoration(
                  labelText: 'ID',
                  border: outlineInputBorder(context),
                  enabledBorder: outlineInputBorder(context),
                ),
              ),
              DropdownFormField(
                controller: position,
                label: 'Position',
                values: const [
                  'Barangay Captain',
                  'Barangay Treasurer',
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () => submit(context),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
