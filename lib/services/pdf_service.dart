import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdflink/models/pdf_item.dart';
import 'package:pdflink/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfService {
  final StorageService _storageService = StorageService();

  Future<List<PdfItem>> getPdfItems() async {
    return await _storageService.getPdfItems();
  }

  Future<PdfItem?> pickAndAddPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final sourceFile = File(file.path!);
          final appDir = await getApplicationDocumentsDirectory();
          final pdfDir = Directory('${appDir.path}/pdfs');
          
          if (!await pdfDir.exists()) {
            await pdfDir.create(recursive: true);
          }

          final fileName = file.name;
          final targetPath = '${pdfDir.path}/$fileName';
          final targetFile = await sourceFile.copy(targetPath);

          final pdfItem = PdfItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: fileName,
            path: targetFile.path,
            size: await targetFile.length(),
            dateAdded: DateTime.now(),
          );

          await _storageService.savePdfItem(pdfItem);
          return pdfItem;
        }
      }
    } catch (e) {
      throw Exception('Failed to pick PDF: $e');
    }
    return null;
  }

  Future<PdfItem?> downloadAndAddPdf(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory('${appDir.path}/pdfs');
        
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }

        final targetPath = '${pdfDir.path}/$fileName';
        final file = File(targetPath);
        await file.writeAsBytes(response.bodyBytes);

        final pdfItem = PdfItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          path: file.path,
          size: response.bodyBytes.length,
          dateAdded: DateTime.now(),
        );

        await _storageService.savePdfItem(pdfItem);
        return pdfItem;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  Future<bool> openPdfWithNativeViewer(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('No PDF viewer app found');
      }
    } catch (e) {
      throw Exception('Failed to open PDF: $e');
    }
  }

  Future<void> deletePdfItem(String id) async {
    final items = await getPdfItems();
    final item = items.firstWhere((item) => item.id == id);
    
    final file = File(item.path);
    if (await file.exists()) {
      await file.delete();
    }
    
    await _storageService.deletePdfItem(id);
  }

  Future<void> renamePdfItem(String id, String newName) async {
    final items = await getPdfItems();
    final item = items.firstWhere((item) => item.id == id);
    
    if (!newName.toLowerCase().endsWith('.pdf')) {
      newName = '$newName.pdf';
    }
    
    final oldFile = File(item.path);
    final directory = oldFile.parent;
    final newPath = '${directory.path}/$newName';
    final newFile = await oldFile.rename(newPath);
    
    final updatedItem = PdfItem(
      id: item.id,
      name: newName,
      path: newFile.path,
      size: item.size,
      dateAdded: item.dateAdded,
      thumbnailPath: item.thumbnailPath,
    );
    
    await _storageService.updatePdfItem(updatedItem);
  }
}