import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

UploadTask setFile({required String ref, required String name, required Uint8List bytes}) {
  return storage.ref(ref).child(name).putData(bytes);
}

void removeFile({required String ref, required String name}) async {
  await storage.ref(ref).child(name).delete();
}

Future<String> getDownloadUrl({required String ref, required String name}) async {
  return storage.ref(ref).child(name).getDownloadURL();
}
