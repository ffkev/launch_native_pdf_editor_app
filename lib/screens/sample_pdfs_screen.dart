import 'package:flutter/material.dart';
import 'package:pdflink/data/sample_pdfs.dart';
import 'package:pdflink/services/pdf_service.dart';

class SamplePdfsScreen extends StatefulWidget {
  const SamplePdfsScreen({super.key});

  @override
  State<SamplePdfsScreen> createState() => _SamplePdfsScreenState();
}

class _SamplePdfsScreenState extends State<SamplePdfsScreen> {
  final PdfService _pdfService = PdfService();
  final Set<int> _downloadingItems = {};

  Future<void> _downloadPdf(int index, String url, String fileName) async {
    setState(() => _downloadingItems.add(index));

    try {
      await _pdfService.downloadAndAddPdf(url, fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName downloaded successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _downloadingItems.remove(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample PDFs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Sample PDFs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try these sample PDF URLs to test the download functionality:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: SamplePdfs.validPdfUrls.length,
                itemBuilder: (context, index) {
                  final url = SamplePdfs.validPdfUrls[index];
                  final fileName = 'sample_pdf_${index + 1}.pdf';
                  final isDownloading = _downloadingItems.contains(index);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.cloud_download,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text('Sample PDF ${index + 1}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            url,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => _downloadPdf(index, url, fileName),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}