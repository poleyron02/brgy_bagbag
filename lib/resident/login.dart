import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/resident/home.dart';
import 'package:brgy_bagbag/resident/register.dart';
import 'package:brgy_bagbag/resident/widgets/terms_and_conditions_dialog.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ResidentLoginPage extends StatelessWidget {
  ResidentLoginPage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isPortrait = constraints.maxWidth < constraints.maxHeight;

        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: isPortrait ? const EdgeInsets.all(16) : null,
                width: isPortrait ? null : 500,
                child: Form(
                  key: formKey,
                  child: ColumnSeparated(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(dimension: 400, child: Image.asset('images/logo.png')),
                      TextFormField(
                        controller: email,
                        validator: validate,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(TablerIcons.mail),
                          labelText: 'Email',
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
                            try {
                              await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
                              if (context.mounted) Navigator.pop(context);
                            } on FirebaseAuthException catch (e) {
                              String message = '';
                              if (e.code == 'user-not-found') {
                                message = 'No user found for that email.';
                              } else if (e.code == 'wrong-password') {
                                message = 'Wrong password provided for that user.';
                              } else {
                                message = e.code;
                              }

                              SnackBar snackBar = SnackBar(content: Text(message));
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                            textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          child: const Text('SIGN IN'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResidentRegisterPage()));

                            bool? result = await showDialog(
                              context: context,
                              builder: (context) => const TermsAndConditionsDialog(),
                            );

                            if (result != null && !result && context.mounted) Navigator.pop(context);
                          },
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                            textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                          ),
                          child: const Text('CREATE AN ACCOUNT'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            if (email.text.isEmpty) {
                              showSnackBar(context, 'Email must not be empty.');
                              return;
                            }
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                              if (context.mounted) showSnackBar(context, 'Successfully sent a password reset link to your email.');
                            } on FirebaseAuthException catch (e) {
                              if (context.mounted) showSnackBar(context, '${e.message}');
                            }
                          },
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                            textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                          ),
                          child: const Text('FORGOT PASSWORD'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResidentTopPage()));
                          },
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                            textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                          ),
                          child: const Text('BACK TO HOME'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
