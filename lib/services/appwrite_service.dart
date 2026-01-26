import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppWriteService {
  static Client client = Client();
  static late Storage storage;
  static String appwriteEndPoint = dotenv.env['APP_WRITE_ENDPOINT']!;
  static String appwriteProjectId = dotenv.env['APP_WRITE_PROJECT_ID']!;
  static String appwriteBucketId = dotenv.env['APP_WRITE_BUCKET_ID']!;
  static void init() {
    client.setEndpoint(appwriteEndPoint).setProject(appwriteProjectId);
    storage = Storage(client);
  }

  static Future<String?> uploadImage(io.File file) async {
    try {
      debugPrint('Uploading file: ${file.path}');
      final response = await AppWriteService.storage.createFile(
        bucketId: appwriteBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: file.path,
          filename: file.uri.pathSegments.last,
        ),
      );
      final fileUrl =
          '${AppWriteService.client.endPoint}/storage/buckets/$appwriteBucketId/files/${response.$id}/view?project=$appwriteProjectId';
      return fileUrl;
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }
}
