import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/openai_config.dart';

/// AI service using Groq API (OpenAI-compatible format)
/// Used for FAQ generation, student Q&A, and course descriptions
class OpenAIService {
  OpenAIService._();
  static final OpenAIService instance = OpenAIService._();

  /// Groq API URL — use CORS proxy on web
  String get _apiUrl {
    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(GeminiConfig.chatUrl)}';
    }
    return GeminiConfig.chatUrl;
  }

  /// Call Groq API (OpenAI-compatible)
  Future<String?> _callAI({
    required String systemPrompt,
    required String userPrompt,
    String? base64Image,
    String? imageMime,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    const maxRetries = 2;

    String finalModel = base64Image != null ? 'llama-3.2-90b-vision-preview' : GeminiConfig.model;

    dynamic userContent;
    if (base64Image != null) {
      userContent = [
        {'type': 'text', 'text': userPrompt},
        {
          'type': 'image_url',
          'image_url': {'url': 'data:$imageMime;base64,$base64Image'}
        }
      ];
    } else {
      userContent = userPrompt;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${GeminiConfig.apiKey}',
          },
          body: jsonEncode({
            'model': finalModel,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userContent},
            ],
            'max_tokens': maxTokens,
            'temperature': temperature,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'] as String;
        } else if (response.statusCode == 429) {
          debugPrint('Groq rate limited (attempt ${attempt + 1})');
          await Future.delayed(Duration(seconds: (attempt + 1) * 3));
          continue;
        } else {
          debugPrint('Groq error: ${response.statusCode} ${response.body}');
          return null;
        }
      } catch (e) {
        debugPrint('Groq exception: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return null;
      }
    }
    return null;
  }

  /// Generate FAQs
  Future<List<Map<String, String>>> generateFaqs({
    required String sectionTitle,
    required List<String> lessonTitles,
    int count = 15,
  }) async {
    final content = await _callAI(
      systemPrompt:
          'Sən təhsil platforması üçün FAQ yaradıcısısan. Yalnız Azərbaycan dilində. Yalnız JSON array qaytar.',
      userPrompt: '''
$count ədəd FAQ yarat.
Bölmə: $sectionTitle
Dərslər: ${lessonTitles.join(', ')}
Format: [{"question":"...","answer":"...","category":"general|technical|practical"}]
''',
      maxTokens: GeminiConfig.faqMaxTokens,
    );

    if (content != null) {
      try {
        final jsonStr = _extractJson(content);
        final parsed = jsonDecode(jsonStr) as List;
        return parsed
            .map((item) => <String, String>{
                  'question': item['question'] as String,
                  'answer': item['answer'] as String,
                  'category': item['category'] as String? ?? 'general',
                })
            .toList();
      } catch (e) {
        debugPrint('JSON parse error: $e');
      }
    }
    return [];
  }

  /// Answer student question
  Future<String> answerQuestion({
    required String lessonTitle,
    required String sectionTitle,
    required String question,
    String? courseTitle,
  }) async {
    final content = await _callAI(
      systemPrompt: 'Sən təhsil köməkçisisən. Azərbaycan dilində cavab ver.',
      userPrompt: '''
Kurs: ${courseTitle ?? 'Naməlum'}, Bölmə: $sectionTitle, Dərs: $lessonTitle
Sual: $question
2-5 cümlə cavab ver.
''',
      maxTokens: GeminiConfig.qaMaxTokens,
      temperature: 0.5,
    );
    return content ?? 'Bağışlayın, hazırda cavab verə bilmirəm.';
  }

  /// Generate course description
  Future<String> generateCourseDescription({
    required String courseTitle,
    String? category,
    List<String>? sectionTitles,
  }) async {
    final content = await _callAI(
      systemPrompt:
          'Sən kurs təsviri yaradıcısısan. Azərbaycan dilində yaz. Yalnız təsviri qaytar.',
      userPrompt: '''
Kurs: $courseTitle
${category != null ? 'Kateqoriya: $category' : ''}
${sectionTitles != null && sectionTitles.isNotEmpty ? 'Bölmələr: ${sectionTitles.join(", ")}' : ''}
3-5 cümlə peşəkar təsvir yaz.
''',
      maxTokens: 300,
    );
    return content ?? '';
  }

  /// Generate Exam Questions
  Future<List<Map<String, dynamic>>> generateExamQuestions({
    required String topicOrText,
    int count = 5,
    String? examType,
    String? penaltyRule,
    String? base64Image,
    String? imageMime,
  }) async {
    final typeText = examType != null ? 'İmtahan tipi: $examType.' : '';
    final penaltyText = penaltyRule != null ? 'Silinmə məntiqi: $penaltyRule.' : '';
    
    final content = await _callAI(
      systemPrompt:
          'Sən imtahan sualları yaradıcısısan. Verilən mövzu və ya mətnə uyğun suallar yarat. Yalnız Azərbaycan dilində. Sualları tamamilə Markdown formatında (qalın, əyri, qrafik linkləri, tablolar dəstəyi ilə) formalaşdır. Çoxdan seçməli (4 variantlı) suallar yaradaraq yalnız təmiz JSON array qaytar. $typeText $penaltyText',
      userPrompt: '''
Aşağıdakı mövzu/mətn əsasında $count ədəd test sualı yarat.
Səviyyəni seçilmiş imtahan tipinə və silinmə məntiqinə uyğunlaşdır. Mövzu tələb edərsə markdown vasitəsilə kiçik cədvəl və ya nümunə kod/riyazi düstur əlavə et. 
Mövzu/Mətn: $topicOrText
Format dəqiq bu cür olmalıdır (başqa heç nə yazma):
[
  {
    "question": "Sual mətni **Qalın formatda** ola bilər...",
    "options": ["A variantı", "B variantı", "C variantı", "D variantı"],
    "correctIndex": 0 // düzgün cavabın indeksi (0, 1, 2 və ya 3)
  }
]
''',
      base64Image: base64Image,
      imageMime: imageMime,
      maxTokens: 2500,
    );

    if (content != null) {
      try {
        final jsonStr = _extractJson(content);
        final parsed = jsonDecode(jsonStr) as List;
        return parsed.map((item) => <String, dynamic>{
          'question': item['question'],
          'options': List<String>.from(item['options'] as List),
          'correctIndex': item['correctIndex'],
        }).toList();
      } catch (e) {
        debugPrint('JSON parse error (Exam): $e');
      }
    }
    return [];
  }

  /// Grade Assignment Submission
  Future<Map<String, dynamic>> gradeAssignment({
    required String assignmentTitle,
    required String assignmentDescription,
    required String studentAnswer,
  }) async {
    final content = await _callAI(
      systemPrompt:
          'Sən təcrübəli müəllimsən. Tələbənin tapşırığa verdiyi cavabı yoxlayıb dərəcələndirəcəksən. Yalnız JSON format qaytar.',
      userPrompt: '''
Tapşırıq başlığı: $assignmentTitle
Tapşırıq təsviri: $assignmentDescription
Tələbənin cavabı: $studentAnswer

Tələbənin cavabını yoxla. 0-dan 100-ə qədər bal ver və Azərbaycan dilində konstruktiv feedback (rəy) yaz.
Format dəqiq bu cür olmalıdır (başqa heç nə yazma):
{
  "score": 85,
  "feedback": "Sənin cavabın yaxşıdır, lakin..."
}
''',
      maxTokens: 800,
    );

    if (content != null) {
      try {
        final jsonStr = _extractJson(content);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        return parsed;
      } catch (e) {
        debugPrint('JSON parse error (Grading): $e');
      }
    }
    return {'score': 0, 'feedback': 'Sistem xətası: Yoxlama uğursuz oldu.'};
  }

  String _extractJson(String content) {
    var cleaned = content.trim();
    if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
    else if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
    return cleaned.trim();
  }
}
