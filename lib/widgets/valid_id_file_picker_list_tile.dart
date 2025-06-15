import 'package:brgy_bagbag/functions.dart';
import 'package:brgy_bagbag/globals.dart';
import 'package:brgy_bagbag/models/custom_notifier.dart';
import 'package:brgy_bagbag/storage_helper.dart';
import 'package:brgy_bagbag/widgets/column_separated.dart';
import 'package:brgy_bagbag/widgets/row_separated.dart';
import 'package:brgy_bagbag/widgets/show_image_list_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

class ValidIdFilePickerListTile extends StatelessWidget {
  ValidIdFilePickerListTile({
    super.key,
    // required this.idType,
    required this.path,
    this.label,
  });

  // final TextEditingController idType;
  final TextEditingController path;
  final String? label;

  final ValueNotifier<String> fileName = ValueNotifier('');

  final CustomNotifier<UploadTask> uploadTask = CustomNotifier(null);

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: validate,
      initialValue: path.text,
      builder: (field) => ValueListenableBuilder(
        valueListenable: uploadTask,
        builder: (context, value, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                valueListenable: path,
                builder: (context, controllerValue, child) {
                  return ListTile(
                    leading: const Icon(TablerIcons.id),
                    title: Text(label ?? 'Government Valid ID'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ColumnSeparated(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ValueListenableBuilder(
                          //     valueListenable: idType,
                          //     builder: (context, idTypeValue, child) {
                          //       return FormField(
                          //         validator: validate,
                          //         initialValue: idType.text,
                          //         builder: (field) => Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: [
                          //             DropdownButton(
                          //               isDense: true,
                          //               isExpanded: true,
                          //               hint: const Text('Choose ID Type'),
                          //               underline: Container(),
                          //               value: idTypeValue.text.isEmpty ? null : idTypeValue.text,
                          //               onChanged: (value) {
                          //                 idType.text = value!;
                          //                 field.didChange(value);
                          //               },
                          //               items: List.generate(
                          //                 validPhilippineIDs.length,
                          //                 (index) => DropdownMenuItem(
                          //                   value: validPhilippineIDs[index],
                          //                   child: Text(validPhilippineIDs[index]),
                          //                 ),
                          //               ),
                          //             ),
                          //             if (field.hasError)
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   field.errorText ?? '',
                          //                   style: TextStyle(
                          //                     fontSize: 12,
                          //                     color: Theme.of(context).colorScheme.error,
                          //                   ),
                          //                 ),
                          //               ),
                          //           ],
                          //         ),
                          //       );
                          //     }),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RowSeparated(
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                                          if (result == null) return;

                                          String name = const Uuid().v1();

                                          UploadTask uploadTask = setFile(ref: 'valid_id', name: name, bytes: result.files.single.bytes!);
                                          this.uploadTask.set(uploadTask);
                                          fileName.value = result.files.single.name;
                                          uploadTask.whenComplete(
                                            () async {
                                              String path = await getDownloadUrl(ref: 'valid_id', name: name);
                                              this.path.text = path;
                                              field.didChange(path);
                                            },
                                          );
                                        },
                                        // style: ButtonStyle(
                                        //   textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                                        //   padding: const WidgetStatePropertyAll(EdgeInsets.all(24)),
                                        //   side: WidgetStatePropertyAll(BorderSide(color: !field.hasError ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.error)),
                                        //   foregroundColor: !field.hasError ? null : WidgetStatePropertyAll(Theme.of(context).colorScheme.error),
                                        // ),
                                        child: ValueListenableBuilder(
                                          valueListenable: fileName,
                                          builder: (context, value, child) {
                                            return Text(value.isEmpty ? 'SELECT FILE' : value);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: path,
                                    builder: (context, value, child) {
                                      if (value.text.isEmpty) return Container();
                                      return IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ImageDialog(
                                              label: fileName.value,
                                              url: value.text,
                                            ),
                                          );
                                        },
                                        icon: const Icon(TablerIcons.eye),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    field.errorText ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: value != null && value.snapshot.state != TaskState.success
                        ? StreamBuilder(
                            stream: value.snapshotEvents,
                            builder: (context, snapshot) {
                              return CircularProgressIndicator(value: !snapshot.hasData ? 0 : snapshot.data!.bytesTransferred / snapshot.data!.totalBytes);
                            },
                          )
                        : controllerValue.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  path.clear();
                                  fileName.value = '';
                                  uploadTask.remove();
                                },
                                icon: const Icon(TablerIcons.x),
                              ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
