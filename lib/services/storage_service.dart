import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdflink/models/pdf_item.dart';

class StorageService {
  static const String _fileName = 'pdf_items.json';

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<PdfItem>> getPdfItems() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => PdfItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePdfItem(PdfItem item) async {
    final items = await getPdfItems();
    items.add(item);
    await _savePdfItems(items);
  }

  Future<void> updatePdfItem(PdfItem updatedItem) async {
    final items = await getPdfItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await _savePdfItems(items);
    }
  }

  Future<void> deletePdfItem(String id) async {
    final items = await getPdfItems();
    items.removeWhere((item) => item.id == id);
    await _savePdfItems(items);
  }

  Future<void> _savePdfItems(List<PdfItem> items) async {
    final file = await _localFile;
    final jsonData = items.map((item) => item.toJson()).toList();
    await file.writeAsString(json.encode(jsonData));
  }
}