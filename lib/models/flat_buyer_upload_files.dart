import 'package:file_picker/file_picker.dart';

class BuyerUploadFiles {
  String? name;
  int? index;
  PlatformFile? imageData;

  BuyerUploadFiles({
    this.name,
    this.index,
    this.imageData,
  });

  factory BuyerUploadFiles.fromJson(Map<String, dynamic> json) =>
      BuyerUploadFiles(
        name: json["name"],
        index: json["index"],
        imageData: json["imageData"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "index": index,
        "imageData": imageData,
      };
}
