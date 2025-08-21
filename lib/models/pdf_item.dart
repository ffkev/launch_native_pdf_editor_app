class PdfItem {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime dateAdded;
  final String? thumbnailPath;

  const PdfItem({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.dateAdded,
    this.thumbnailPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'size': size,
    'dateAdded': dateAdded.toIso8601String(),
    'thumbnailPath': thumbnailPath,
  };

  factory PdfItem.fromJson(Map<String, dynamic> json) => PdfItem(
    id: json['id'],
    name: json['name'],
    path: json['path'],
    size: json['size'],
    dateAdded: DateTime.parse(json['dateAdded']),
    thumbnailPath: json['thumbnailPath'],
  );

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}