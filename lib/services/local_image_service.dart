//stores cat images so we don't have to use firebase storage and $$

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalImageService {
  static Future<String> saveCatImage(String temporaryPath) async {
    final directory = await getApplicationDocumentsDirectory();

    final imageDirectory = Directory('${directory.path}/cat_images');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final filename =
        'cat_${DateTime.now().microsecondsSinceEpoch}.jpg';

    final savedImage = await File(temporaryPath).copy(
      '${imageDirectory.path}/$filename',
    );

    return savedImage.path;
  }
}