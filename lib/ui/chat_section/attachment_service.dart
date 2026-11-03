import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';

class AttachmentService {
  static final _imagePicker = ImagePicker();

  /// Take a photo using the camera
  static Future<ChatAttachment?> takePhoto() async {
    try {
      final XFile? photo =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final size = await photo.length();
        return ChatAttachment(
          filePath: photo.path,
          fileName: photo.name,
          fileType: 'image',
          fileSize: size,
          uploadedAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick image(s) from the gallery
  static Future<List<ChatAttachment>> pickFromGallery() async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage();
      final List<ChatAttachment> result = [];
      for (final photo in photos) {
        final size = await photo.length();
        result.add(ChatAttachment(
          filePath: photo.path,
          fileName: photo.name,
          fileType: 'image',
          fileSize: size,
          uploadedAt: DateTime.now(),
        ));
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Pick any document/file
  static Future<List<ChatAttachment>> pickDocuments() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );
      if (result != null) {
        return result.files
            .map((file) => ChatAttachment(
                  filePath: file.path ?? '',
                  fileName: file.name,
                  fileType: getFileType(file.name),
                  fileSize: file.size,
                  uploadedAt: DateTime.now(),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Pick image(s) — kept for backward compatibility
  static Future<List<ChatAttachment>> pickImages() async {
    return pickFromGallery();
  }

  // Pick video(s)
  static Future<List<ChatAttachment>> pickVideos() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );
      if (result != null) {
        return result.files
            .map((file) => ChatAttachment(
                  filePath: file.path ?? '',
                  fileName: file.name,
                  fileType: 'video',
                  fileSize: file.size,
                  uploadedAt: DateTime.now(),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Pick file(s) — kept for backward compat
  static Future<List<ChatAttachment>> pickFiles() async {
    return pickDocuments();
  }

  static String getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return 'image';
    if (['mp4', 'avi', 'mov', 'mkv', 'flv'].contains(ext)) return 'video';
    return 'file';
  }
}
