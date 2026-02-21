import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/faq_model.dart';
import '../core/services/openai_service.dart';

/// Manages FAQ operations — CRUD + AI generation
class FaqProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<FaqModel> _faqs = [];
  List<Map<String, String>> _aiGeneratedFaqs = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<FaqModel> get faqs => _filteredFaqs;
  List<Map<String, String>> get aiGeneratedFaqs => _aiGeneratedFaqs;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<FaqModel> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'all' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Load FAQs for a section
  Future<void> loadFaqs(String sectionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('topic_faqs')
          .select()
          .eq('section_id', sectionId)
          .order('order_index');

      _faqs = (response as List)
          .map((j) => FaqModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading FAQs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a FAQ manually
  Future<bool> addFaq({
    required String sectionId,
    required String question,
    required String answer,
    String category = 'general',
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    try {
      final response = await _supabase.from('topic_faqs').insert({
        'section_id': sectionId,
        'question': question,
        'answer': answer,
        'category': category,
        'order_index': _faqs.length,
        'created_by': userId,
      }).select().single();

      _faqs.add(FaqModel.fromJson(response));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding FAQ: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a FAQ
  Future<bool> deleteFaq(String faqId) async {
    try {
      await _supabase.from('topic_faqs').delete().eq('id', faqId);
      _faqs.removeWhere((f) => f.id == faqId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting FAQ: $e');
      return false;
    }
  }

  /// Mark FAQ as helpful
  Future<void> markHelpful(String faqId) async {
    try {
      await _supabase.rpc('increment_helpful_count', params: {'faq_id': faqId});
      final index = _faqs.indexWhere((f) => f.id == faqId);
      if (index >= 0) {
        _faqs[index] = FaqModel(
          id: _faqs[index].id,
          sectionId: _faqs[index].sectionId,
          question: _faqs[index].question,
          answer: _faqs[index].answer,
          category: _faqs[index].category,
          orderIndex: _faqs[index].orderIndex,
          helpfulCount: _faqs[index].helpfulCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      // Fallback: increment locally even if RPC doesn't exist
      final index = _faqs.indexWhere((f) => f.id == faqId);
      if (index >= 0) {
        _faqs[index] = FaqModel(
          id: _faqs[index].id,
          sectionId: _faqs[index].sectionId,
          question: _faqs[index].question,
          answer: _faqs[index].answer,
          category: _faqs[index].category,
          orderIndex: _faqs[index].orderIndex,
          helpfulCount: _faqs[index].helpfulCount + 1,
        );
        notifyListeners();
      }
    }
  }

  /// Generate FAQs using AI
  Future<void> generateFaqsWithAI({
    required String sectionTitle,
    required List<String> lessonTitles,
    int count = 15,
  }) async {
    _isGenerating = true;
    _aiGeneratedFaqs = [];
    notifyListeners();

    try {
      _aiGeneratedFaqs = await OpenAIService.instance.generateFaqs(
        sectionTitle: sectionTitle,
        lessonTitles: lessonTitles,
        count: count,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error generating FAQs: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Save AI-generated FAQs to database
  Future<bool> saveAIGeneratedFaqs(String sectionId) async {
    final userId = _supabase.auth.currentUser?.id;

    try {
      final inserts = _aiGeneratedFaqs.asMap().entries.map((entry) => {
            'section_id': sectionId,
            'question': entry.value['question'],
            'answer': entry.value['answer'],
            'category': entry.value['category'] ?? 'general',
            'order_index': _faqs.length + entry.key,
            'created_by': userId,
          }).toList();

      await _supabase.from('topic_faqs').insert(inserts);
      _aiGeneratedFaqs = [];
      await loadFaqs(sectionId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error saving AI FAQs: $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove one AI-generated FAQ from preview
  void removeAIFaq(int index) {
    _aiGeneratedFaqs.removeAt(index);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
