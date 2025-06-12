import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:owner/constant/show_toast_dialog.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class FileHandleApi {
  // save pdf file function
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    // final dir = await getExternalStorageDirectory();
    // print("=============Path==${dir?.path}");
    // final file = File('${dir?.path}/$name');
    final file = File('/storage/emulated/0/Download/$name');
    if (await file.exists()) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Invoice already downloaded.");
    } else {
      await file.writeAsBytes(bytes);
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Invoice successfully downloaded.");
    }
    // try {
    //   await file.writeAsBytes(bytes);
    //   ShowToastDialog.closeLoader();
    //   ShowToastDialog.showToast("Invoice successfully downloaded.");
    // } on Exception catch (e) {
    //   print("===========${e}");
    //   // ShowToastDialog.closeLoader();
    //   // file.delete();
    //   // if (e.toString().split(":").first == "PathExistsException") {
    //   //   ShowToastDialog.showToast("Invoice already downloaded.");
    //   // }
    // }
    return file;
  }

  // open pdf file function
  static Future openFile({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();
    final dir = await getExternalStorageDirectory();
    // print("=============Path==${dir?.path}");
    final file = File('${dir?.path}/$name');
    await file.writeAsBytes(bytes);
    final url = file.path;

    await OpenFile.open(url);
  }
}
