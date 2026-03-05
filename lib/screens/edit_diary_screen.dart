import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class EditDiaryScreen extends StatefulWidget {
  final DiaryEntry diary;

  const EditDiaryScreen({super.key, required this.diary});

  @override
  State<EditDiaryScreen> createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends State<EditDiaryScreen> {
  late TextEditingController _contentController;
  late String _selectedMood;
  final StorageService _storageService = StorageService();
  bool _isSaving = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': '开心', 'value': 'happy'},
    {'emoji': '😌', 'label': '平静', 'value': 'calm'},
    {'emoji': '😐', 'label': '一般', 'value': 'neutral'},
    {'emoji': '☁️', 'label': '低落', 'value': 'sad'},
  ];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.diary.content);
    _selectedMood = widget.diary.mood;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容不能为空')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedDiary = DiaryEntry(
      id: widget.diary.id,
      title: content.length > 10 ? '${content.substring(0, 10)}...' : content,
      content: content,
      date: widget.diary.date,
      mood: _selectedMood,
      imageUrl: widget.diary.imageUrl,
    );

    await _storageService.updateDiary(updatedDiary);

    if (mounted) {
      Navigator.pop(context, true); // 返回 true 表示已更新
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFDF2F8),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMoodSelector(),
                      const SizedBox(height: 24),
                      _buildContentInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '编辑日记',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _isSaving ? null : _saveChanges,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _isSaving
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                      ),
                color: _isSaving ? Colors.grey[300] : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isSaving
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '现在的心情',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = mood['value']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFA78BFA) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFA78BFA).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      mood['emoji']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood['label']!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 15,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4B5563),
        ),
        decoration: const InputDecoration(
          hintText: '这一刻的想法是...',
          hintStyle: TextStyle(
            color: Color(0xFFCBD5E1),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(24),
        ),
      ),
    );
  }
}
