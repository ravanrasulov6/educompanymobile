import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MarkdownEditorField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double minHeight;

  const MarkdownEditorField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    required this.hintText,
    this.minHeight = 120,
  });

  @override
  State<MarkdownEditorField> createState() => _MarkdownEditorFieldState();
}

class _MarkdownEditorFieldState extends State<MarkdownEditorField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertFormat(String prefix, String suffix) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    // Default to at least placing the cursor after the prefix
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      final newText = text + prefix + suffix;
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: newText.length - suffix.length);
      return;
    }

    final start = selection.start;
    final end = selection.end;
    
    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
    
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: start + prefix.length + selectedText.length);
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      color: AppColors.lightTextPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
            ),
            child: Wrap(
              spacing: 0,
              children: [
                _buildToolbarButton(Icons.format_bold, 'Qalın (Bold)', () => _insertFormat('**', '**')),
                _buildToolbarButton(Icons.format_italic, 'Əyri (Italic)', () => _insertFormat('*', '*')),
                _buildToolbarButton(Icons.format_strikethrough, 'Xətli', () => _insertFormat('~~', '~~')),
                const SizedBox(width: 8, height: 28, child: VerticalDivider(width: 1)),
                _buildToolbarButton(Icons.title, 'Başlıq', () => _insertFormat('\n### ', '')),
                _buildToolbarButton(Icons.format_list_bulleted, 'Siyahı', () => _insertFormat('\n- ', '')),
                _buildToolbarButton(Icons.format_list_numbered, 'Nömrəli Siyahı', () => _insertFormat('\n1. ', '')),
                const SizedBox(width: 8, height: 28, child: VerticalDivider(width: 1)),
                _buildToolbarButton(Icons.format_quote, 'Sitat (Quote)', () => _insertFormat('\n> ', '')),
                _buildToolbarButton(Icons.code, 'Kod', () => _insertFormat('`', '`')),
                _buildToolbarButton(Icons.link, 'Link', () => _insertFormat('[', '](url)')),
                _buildToolbarButton(Icons.image, 'Şəkil və ya Qrafik (URL)', () => _insertFormat('![alt](', ')')),
              ],
            ),
          ),
          
          // Text Area
          Container(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            child: TextField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(
                fontFamily: 'monospace', // markdown editing looks better in monospace
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
