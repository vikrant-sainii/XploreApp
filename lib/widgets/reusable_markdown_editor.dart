import 'package:flutter/material.dart';
import 'package:markdown_live/markdown_live.dart';

class ReusableMarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final double minHeight;
  final ValueChanged<String>? onChanged;

  const ReusableMarkdownEditor({
    super.key,
    required this.controller,
    this.hintText = "Write detailed description using Markdown...",
    this.label,
    this.minHeight = 160.0,
    this.onChanged,
  });

  @override
  State<ReusableMarkdownEditor> createState() => _ReusableMarkdownEditorState();
}

class _ReusableMarkdownEditorState extends State<ReusableMarkdownEditor> {
  late MarkdownLiveController _markdownLiveController;
  final List<String> _undoHistory = [];
  final List<String> _redoHistory = [];
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _markdownLiveController = MarkdownLiveController(text: widget.controller.text);
    _markdownLiveController.theme = MarkdownLiveTheme.light();
    _undoHistory.add(widget.controller.text);

    _markdownLiveController.addListener(_onMarkdownChanged);
    widget.controller.addListener(_onExternalControllerChanged);
  }

  void _onMarkdownChanged() {
    if (_isInternalUpdate) return;
    final text = _markdownLiveController.text;
    if (widget.controller.text != text) {
      _isInternalUpdate = true;
      widget.controller.text = text;
      _isInternalUpdate = false;

      if (_undoHistory.isEmpty || _undoHistory.last != text) {
        _undoHistory.add(text);
        if (_undoHistory.length > 30) _undoHistory.removeAt(0);
        _redoHistory.clear();
      }
      widget.onChanged?.call(text);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  void _onExternalControllerChanged() {
    if (_isInternalUpdate) return;
    if (_markdownLiveController.text != widget.controller.text) {
      _isInternalUpdate = true;
      _markdownLiveController.text = widget.controller.text;
      _isInternalUpdate = false;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }


  @override
  void dispose() {
    _markdownLiveController.removeListener(_onMarkdownChanged);
    widget.controller.removeListener(_onExternalControllerChanged);
    _markdownLiveController.dispose();
    super.dispose();
  }

  void _handleUndo() {
    if (_undoHistory.length > 1) {
      _isInternalUpdate = true;
      final current = _undoHistory.removeLast();
      _redoHistory.add(current);
      final previous = _undoHistory.last;
      _markdownLiveController.text = previous;
      widget.controller.text = previous;
      _isInternalUpdate = false;
      widget.onChanged?.call(previous);
      setState(() {});
    }
  }

  void _handleRedo() {
    if (_redoHistory.isNotEmpty) {
      _isInternalUpdate = true;
      final next = _redoHistory.removeLast();
      _undoHistory.add(next);
      _markdownLiveController.text = next;
      widget.controller.text = next;
      _isInternalUpdate = false;
      widget.onChanged?.call(next);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUndo = _undoHistory.length > 1;
    final canRedo = _redoHistory.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: MarkdownLiveToolbar(
                            controller: _markdownLiveController,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(height: 18, width: 1, color: Colors.grey.shade300),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.undo, size: 16, color: canUndo ? const Color(0xFF191C32) : Colors.grey.shade400),
                        tooltip: "Undo",
                        onPressed: canUndo ? _handleUndo : null,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: Icon(Icons.redo, size: 16, color: canRedo ? const Color(0xFF191C32) : Colors.grey.shade400),
                        tooltip: "Redo",
                        onPressed: canRedo ? _handleRedo : null,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                // Editor
                Container(
                  constraints: BoxConstraints(minHeight: widget.minHeight),
                  padding: const EdgeInsets.all(12),
                  child: MarkdownLiveEditor(
                    controller: _markdownLiveController,
                    theme: MarkdownLiveTheme.light(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
