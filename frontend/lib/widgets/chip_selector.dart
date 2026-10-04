import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ChipSelector extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> suggestions;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final String addHint;

  const ChipSelector({
    super.key,
    required this.title,
    this.subtitle,
    required this.suggestions,
    required this.selected,
    required this.onChanged,
    this.addHint = 'Add custom...',
  });

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  final TextEditingController _customController = TextEditingController();

  void _toggle(String item) {
    final updated = List<String>.from(widget.selected);
    if (updated.contains(item)) {
      updated.remove(item);
    } else {
      updated.add(item);
    }
    widget.onChanged(updated);
  }

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isNotEmpty && !widget.selected.contains(text)) {
      final updated = List<String>.from(widget.selected)..add(text);
      widget.onChanged(updated);
      _customController.clear();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = <String>{...widget.suggestions, ...widget.selected}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.slate800,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.slate500,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allItems.map((item) {
            final isSelected = widget.selected.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (_) => _toggle(item),
              selectedColor: AppTheme.primary.withAlpha(30),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryDark : AppTheme.slate700,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.slate200,
                width: 1,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: widget.addHint,
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.slate400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onSubmitted: (_) => _addCustom(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addCustom,
              icon: const Icon(Icons.add, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
