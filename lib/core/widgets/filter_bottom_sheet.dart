import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/haptic_service.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedLevel = 'Bütün səviyyələr';
  double _minRating = 0.0;
  final List<String> _selectedCategories = [];

  final List<String> _levels = [
    'Bütün səviyyələr',
    'Başlanğıc',
    'Orta',
    'Yüksək'
  ];

  final List<String> _categories = [
    'Mobil',
    'Dizayn',
    'Python',
    'Biznes',
    'Marketing',
    'Ofis'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtrlər', style: AppTextStyles.headlineMedium),
                        TextButton(
                          onPressed: () {
                            HapticService.light();
                            setState(() {
                              _selectedLevel = 'Bütün səviyyələr';
                              _minRating = 0.0;
                              _selectedCategories.clear();
                            });
                          },
                          child: const Text('Təmizlə', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Level Section
                    Text('Səviyyə', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _levels.map((level) {
                        final isSelected = _selectedLevel == level;
                        return ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              HapticService.light();
                              setState(() => _selectedLevel = level);
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Rating Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Minimum Reytinq', style: AppTextStyles.titleLarge),
                        Text('${_minRating.toStringAsFixed(1)} ★', 
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent)),
                      ],
                    ),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != _minRating) HapticService.light();
                        setState(() => _minRating = val);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Categories Section
                    Text('Kateqoriyalar', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategories.contains(cat);
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            HapticService.light();
                            setState(() {
                              if (val) {
                                _selectedCategories.add(cat);
                              } else {
                                _selectedCategories.remove(cat);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  top: 24, 
                  bottom: 24 + MediaQuery.of(context).padding.bottom
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Ləğv et'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticService.heavy();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Tətbiq et', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
