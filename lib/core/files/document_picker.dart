import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ملف اختاره المستخدم (لسه ما اترفعش).
class PickedDocument {
  final String name;
  final String path;
  final int sizeBytes;

  const PickedDocument({
    required this.name,
    required this.path,
    required this.sizeBytes,
  });
}

/// الواجهة. لو غيّرنا الـ package بنغيّر التنفيذ بس.
abstract class DocumentPicker {
  Future<List<PickedDocument>> pickDocuments();
}

class FilePickerDocumentPicker implements DocumentPicker {
  @override
  Future<List<PickedDocument>> pickDocuments() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );

    final documents = <PickedDocument>[];
    for (final file in files) {
      final path = file.path;
      if (path == null) continue;
      documents.add(
        PickedDocument(
          name: file.name,
          path: path,
          sizeBytes: await file.length() ?? 0,
        ),
      );
    }
    return documents;
  }
}

final documentPickerProvider = Provider<DocumentPicker>((ref) {
  return FilePickerDocumentPicker();
});