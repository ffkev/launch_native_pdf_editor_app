import 'package:flutter/material.dart';
import 'package:pdflink/models/pdf_item.dart';
import 'package:pdflink/screens/sample_pdfs_screen.dart';
import 'package:pdflink/services/pdf_service.dart';
import 'package:pdflink/widgets/add_pdf_dialog.dart';
import 'package:pdflink/widgets/pdf_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PdfService _pdfService = PdfService();
  List<PdfItem> _pdfItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPdfItems();
  }

  Future<void> _loadPdfItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _pdfService.getPdfItems();
      setState(() => _pdfItems = items);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load PDFs: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPdf() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => const AddPdfDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        PdfItem? newPdf;

        if (result['type'] == 'file') {
          newPdf = await _pdfService.pickAndAddPdf();
        } else if (result['type'] == 'url') {
          newPdf = await _pdfService.downloadAndAddPdf(
            result['url'],
            result['fileName'],
          );
        }

        if (newPdf != null) {
          setState(() => _pdfItems.add(newPdf!));
          _showSuccessSnackBar('PDF added successfully');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to add PDF: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openPdf(PdfItem item) async {
    try {
      final success = await _pdfService.openPdfWithNativeViewer(item.path);
      if (!success) {
        _showErrorSnackBar('Failed to open PDF. No compatible app found.');
      }
    } catch (e) {
      print('Error opening PDF: $e');
      _showErrorSnackBar('Error opening PDF: $e');
    }
  }

  Future<void> _deletePdf(String id) async {
    try {
      await _pdfService.deletePdfItem(id);
      setState(() => _pdfItems.removeWhere((item) => item.id == id));
      _showSuccessSnackBar('PDF deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete PDF: $e');
    }
  }

  Future<void> _renamePdf(String id, String newName) async {
    try {
      await _pdfService.renamePdfItem(id, newName);
      await _loadPdfItems();
      _showSuccessSnackBar('PDF renamed successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to rename PDF: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _openSamplePdfs() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const SamplePdfsScreen()),
    );

    if (result == true) {
      _loadPdfItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDFLink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: _openSamplePdfs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdfItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No PDFs found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first PDF',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pdfItems.length,
                  itemBuilder: (context, index) {
                    final item = _pdfItems[index];
                    return PdfListItem(
                      item: item,
                      onTap: () => _openPdf(item),
                      onDelete: () => _deletePdf(item.id),
                      onRename: (newName) => _renamePdf(item.id, newName),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPdf,
        child: const Icon(Icons.add),
      ),
    );
  }
}
