import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/openai_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'dart:convert';

class AIExamGeneratorSheet extends StatefulWidget {
  final Function(List<Map<String, dynamic>> questions) onQuestionsGenerated;
  final String examType;
  final String penaltyRule;

  const AIExamGeneratorSheet({
    super.key,
    required this.onQuestionsGenerated,
    required this.examType,
    required this.penaltyRule,
  });

  @override
  State<AIExamGeneratorSheet> createState() => _AIExamGeneratorSheetState();
}

class _AIExamGeneratorSheetState extends State<AIExamGeneratorSheet> {
  final _promptController = TextEditingController();
  final _countController = TextEditingController(text: '5');
  bool _isGenerating = false;
  
  String? _selectedFileName;
  String? _extractedFileText;
  String? _base64Image;
  String? _imageMime;

  @override
  void dispose() {
    _promptController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final ext = result.files.single.extension?.toLowerCase();
        
        setState(() {
          _selectedFileName = result.files.single.name;
          _extractedFileText = null; // reset
          _base64Image = null;
          _imageMime = null;
        });

        String text = '';
        if (ext == 'pdf') {
          final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
          text = PdfTextExtractor(document).extractText();
          document.dispose();
        } else if (ext == 'txt') {
          text = await file.readAsString();
        } else if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
          final bytes = await file.readAsBytes();
          _base64Image = base64Encode(bytes);
          _imageMime = ext == 'png' ? 'image/png' : 'image/jpeg';
        }

        setState(() {
          _extractedFileText = text.isNotEmpty ? text : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Fayl oxunarkən xəta baş verdi: $e')),
        );
      }
    }
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    final count = int.tryParse(_countController.text) ?? 5;

    if (prompt.isEmpty && _extractedFileText == null && _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mövzu mətni daxil edin və ya fayl yükləyin (PDF/Şəkil)')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      String finalPrompt = prompt;
      if (finalPrompt.isEmpty && _base64Image != null) {
        finalPrompt = 'Şəkildəki məlumatlardan istifadə edərək suallar yaradın.';
      }
      if (_extractedFileText != null && _extractedFileText!.isNotEmpty) {
        finalPrompt += '\n\nIstinad mətni:\n$_extractedFileText';
      }

      final questions = await OpenAIService.instance.generateExamQuestions(
        topicOrText: finalPrompt,
        count: count,
        examType: widget.examType,
        penaltyRule: widget.penaltyRule,
        base64Image: _base64Image,
        imageMime: _imageMime,
      );

      if (mounted) {
        if (questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sual yaratmaq mümkün olmadı. Yenidən cəhd edin.')),
          );
        } else {
          widget.onQuestionsGenerated(questions);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $count ədəd sual uğurla yaradıldı!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta baş verdi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Text('AI Sual Yaradıcı', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mövzu, dərs mətni və ya hər hansı təlimat yazın, AI sizin üçün avtomatik test sualları yaratsın.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 3, child: Text('Sual Sayı:', style: AppTextStyles.labelLarge)),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _selectedFileName ?? 'Fayl (PDF/TXT) yüklə',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (_selectedFileName != null)
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => setState(() {
                    _selectedFileName = null;
                    _extractedFileText = null;
                    _base64Image = null;
                    _imageMime = null;
                  }),
                )
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Məsələn: Azərbaycan tarixi 19-cu əsr mövzusunda çətin səviyyəli suallar...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: _isGenerating 
                ? const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Yaradılır...' : 'Sualları Yarat'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
