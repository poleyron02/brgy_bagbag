import 'dart:typed_data';

import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/storage_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ImagePicker extends StatelessWidget {
  ImagePicker({
    super.key,
    this.dimension = 100,
    required this.ref,
    required this.name,
    required this.controller,
    this.errorColor,
  });

  final double dimension;
  final String ref;
  final String name;
  final TextEditingController controller;
  final Color? errorColor;

  final CustomNotifier<UploadTask> uploadTask = CustomNotifier(null);

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;
    try {
      Uint8List bytes = result.files.single.bytes!;
      UploadTask task = setFile(ref: ref, name: name, bytes: bytes);
      uploadTask.set(task);
      task.whenComplete(
        () async {
          String url = await getDownloadUrl(ref: ref, name: name);
          controller.text = url;
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          border: Border.all(
            color: errorColor ?? Theme.of(context).colorScheme.secondaryContainer,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ValueListenableBuilder(
          valueListenable: uploadTask,
          builder: (context, uploadTaskValue, child) {
            if (uploadTaskValue == null) {
              return ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, controllerValue, child) {
                  if (controllerValue.text.isEmpty) {
                    return GestureDetector(
                      onTap: pickImage,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(TablerIcons.image_in_picture),
                            Text('Choose image'),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        controllerValue.text,
                        fit: BoxFit.cover,
                      ),
                      Container(color: const Color.fromARGB(100, 0, 0, 0)),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(TablerIcons.image_in_picture),
                          label: const Text('Replace image'),
                          onPressed: pickImage,
                          style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return StreamBuilder(
              stream: uploadTaskValue.snapshotEvents,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.state == TaskState.success) {
                  return Stack(
                    children: [
                      Image.network(
                        controller.text,
                        fit: BoxFit.cover,
                      ),
                      Container(color: const Color.fromARGB(100, 0, 0, 0)),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(TablerIcons.image_in_picture),
                          label: const Text('Replace image'),
                          onPressed: pickImage,
                          style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: CircularProgressIndicator(value: snapshot.data!.bytesTransferred / snapshot.data!.totalBytes),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
