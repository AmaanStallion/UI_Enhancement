import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';

class RemoveTempFile {
  Future<String?> removeRecentTempFile({required String fileName}) async {
    print('------------');
    print(fileName);
    print('------------');
    try {
      Map<String, String> data = {
        "temporary_file_name": fileName,
      };

      var response = await apiNetworkHandler.post(AppUrl.deleteTempFile, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // final dataModel = projectBudgetFromJson(response.body);

        // if (dataModel.response?.errorCode == "0") {
        // } else {
        //   // Handle error when errorCode is not "0"
        // }
      } else {
        // Handle error for non-200/201 status codes
      }
    } catch (e) {
      // Handle exceptions here if needed
      // throw SomeCustomException('Exception occurred: $e');
    } finally {
      // ignore: use_build_context_synchronously
    }
    return null;
  }
}
