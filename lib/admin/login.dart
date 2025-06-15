import 'package:brgy_bagbag/admin/home.dart';
import 'package:brgy_bagbag/db_helper.dart';
import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/admin_account.dart';
import 'package:brgy_bagbag/models/admin_log.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminLoginPage extends StatelessWidget {
  AdminLoginPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: ColumnSeparated(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(dimension: 400, child: Image.asset('images/logo.png')),
                  TextFormField(
                    controller: username,
                    validator: validate,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(TablerIcons.user),
                      labelText: 'Username',
                      border: outlineInputBorder(context),
                      enabledBorder: outlineInputBorder(context),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: obscurePassword,
                    builder: (context, value, child) {
                      return TextFormField(
                        controller: password,
                        validator: validate,
                        obscureText: value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(TablerIcons.lock_password),
                          labelText: 'Password',
                          border: outlineInputBorder(context),
                          enabledBorder: outlineInputBorder(context),
                          suffixIcon: GestureDetector(
                            onTap: () => obscurePassword.value = !obscurePassword.value,
                            child: Icon(value ? TablerIcons.eye : TablerIcons.eye_filled),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // isAdminLogin.value = true;
                        AdminAccount? admin = await loginAdmin(username.text, password.text);
                        if (admin == null) {
                          if (context.mounted) showSnackBar(context, 'No admin found.');
                          return;
                        }

                        await logAdminAction(admin, 'Logged in');

                        if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomePage(admin: admin)));
                      },
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      child: const Text('SIGN IN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
