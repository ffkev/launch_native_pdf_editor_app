import 'package:flutter/material.dart';

class AddPdfDialog extends StatefulWidget {
  const AddPdfDialog({super.key});

  @override
  State<AddPdfDialog> createState() => _AddPdfDialogState();
}

class _AddPdfDialogState extends State<AddPdfDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  void _addFromFile() {
    Navigator.of(context).pop({'type': 'file'});
  }

  void _addFromUrl() {
    final url = _urlController.text.trim();
    final fileName = _fileNameController.text.trim();

    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    if (fileName.isEmpty) {
      _showError('Please enter a file name');
      return;
    }

    final finalFileName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';

    Navigator.of(context).pop({
      'type': 'url',
      'url': url,
      'fileName': finalFileName,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Add PDF',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'From Device'),
                Tab(text: 'From URL'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFileTab(),
                  _buildUrlTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload_file,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Select a PDF file from your device',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _addFromFile,
          icon: const Icon(Icons.folder_open),
          label: const Text('Browse Files'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildUrlTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'PDF URL',
            hintText: 'https://example.com/document.pdf',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            labelText: 'File Name',
            hintText: 'My Document',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
            suffixText: '.pdf',
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addFromUrl,
              child: const Text('Download'),
            ),
          ],
        ),
      ],
    );
  }
}