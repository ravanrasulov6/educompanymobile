import 'package:flutter/material.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamera (Deaktiv edilib)')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Windows-da Developer Mode açıq olmadığı üçün Kamera Skaneri müvəqqəti söndürülüb.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
