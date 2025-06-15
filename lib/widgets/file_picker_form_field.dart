import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/storage_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FilePickerFormField extends StatelessWidget {
  FilePickerFormField({
    super.key,
    this.leading,
    this.type = FileType.any,
    required this.ref,
    required this.label,
    required this.controller,
  });

  final Widget? leading;
  final FileType type;
  final String ref;
  final String label;
  final TextEditingController controller;
  final TextEditingController fileName = TextEditingController();

  final CustomNotifier<UploadTask> uploadTask = CustomNotifier(null);

  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: controller.text,
      validator: validate,
      builder: (field) {
        return ValueListenableBuilder(
          valueListenable: uploadTask,
          builder: (context, value, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: leading,
                  title: Text(label),
                  subtitle: ValueListenableBuilder(
                    valueListenable: fileName,
                    builder: (context, fileNameValue, child) {
                      return Text(
                        'File: ${fileNameValue.text.isEmpty ? 'N/A' : fileNameValue.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: type);
                    if (result == null) return;

                    String name = const Uuid().v1();

                    UploadTask uploadTask = setFile(ref: ref, name: name, bytes: result.files.single.bytes!);
                    this.uploadTask.set(uploadTask);
                    uploadTask.whenComplete(
                      () async {
                        String path = await getDownloadUrl(ref: ref, name: name);
                        field.didChange(path);
                        controller.text = path;
                        fileName.text = result.files.single.name;
                      },
                    );
                  },
                ),
                if (value != null)
                  StreamBuilder(
                    stream: value.snapshotEvents,
                    builder: (context, snapshot) {
                      return Visibility(
                        visible: !snapshot.hasData ? true : snapshot.data!.state != TaskState.success,
                        child: LinearProgressIndicator(
                          value: !snapshot.hasData ? 0 : snapshot.data!.bytesTransferred / snapshot.data!.totalBytes,
                        ),
                      );
                    },
                  ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      field.errorText ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
