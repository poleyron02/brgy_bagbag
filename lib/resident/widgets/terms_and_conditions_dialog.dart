import 'package:brgy_bagbag/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(16),
      icon: const Icon(TablerIcons.contract),
      title: const Text('Terms & Conditions'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: RichText(
            text: formatTextSpan(input: '''*Terms and Conditions*

*1. Acceptance of Terms*
By accessing and using the Barangay Bagbag Web App, you agree to comply with and be bound by these Terms and Conditions. If you do not agree, please do not use this platform.

*2. Use of the Web App*
You agree to use the web app only for lawful purposes and in a manner that does not infringe the rights of, or restrict or inhibit the use of, the platform by any third party.

*3. User Accounts*
Certain features of the web app may require you to create an account. You are responsible for maintaining the confidentiality of your account information and are fully responsible for all activities that occur under your account.

*4. Data Privacy*
We are committed to protecting your personal information. All data collected through the web app is handled in accordance with applicable data protection laws. Your data will be used only for the purposes of delivering services, improving user experience, and complying with legal requirements. We will not share your data with third parties without your consent, except as required by law.

*5. Data Collection and Use*
The web app collects personal information such as names, addresses, contact numbers, and other relevant details necessary to provide services. By using the web app, you consent to the collection and use of your data as outlined in our Privacy Policy.

*6. Cookies*
The web app may use cookies to enhance user experience. By continuing to use the app, you consent to the use of cookies.

*7. Content*
All content provided on the web app, including text, graphics, and other material, is for informational purposes only. While we strive to keep the information accurate and up-to-date, we make no warranties about the completeness, reliability, or accuracy of the content.

*8. Limitation of Liability*
Barangay Bagbag is not liable for any direct, indirect, incidental, consequential, or punitive damages arising out of your use of, or inability to use, the web app.

*9. Changes to Terms*
We may revise these Terms and Conditions at any time without notice. By using the web app, you agree to be bound by the current version of these Terms and Conditions.

*10. Governing Law*
These Terms and Conditions are governed by the laws of the Philippines. Any disputes arising from these terms will be resolved in accordance with the local jurisdiction.

*11. Contact Information*
If you have any questions or concerns regarding these Terms and Conditions or our data privacy practices, please contact us at [Barangay Bagbag Contact Information].

By using the Barangay Bagbag Web App, you acknowledge that you have read, understood, and agree to these Terms and Conditions.
'''),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Don't agree
          },
          child: const Text('Disagree'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Agree
          },
          child: const Text('Agree'),
        ),
      ],
    );
  }
}
