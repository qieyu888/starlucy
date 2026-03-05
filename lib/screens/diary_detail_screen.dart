import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import 'edit_diary_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final StorageService _storageService = StorageService();
  late DiaryEntry _currentDiary;

  @override
  void initState() {
    super.initState();
    _currentDiary = widget.diary;
  }

  Future<void> _deleteDiary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '删除日记',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        content: const Text(
          '确定要删除这条日记吗？此操作无法撤销。',
          style: TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '取消',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteDiary(_currentDiary.id);
      if (mounted) {
        Navigator.pop(context, true); // 返回 true 表示已删除
      }
    }
  }

  Future<void> _editDiary() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiaryScreen(diary: _currentDiary),
      ),
    );

    if (result == true && mounted) {
      // 重新加载数据
      final diaries = await _storageService.loadDiaries();
      final updatedDiary = diaries.firstWhere(
        (d) => d.id == _currentDiary.id,
        orElse: () => _currentDiary,
      );
      setState(() {
        _currentDiary = updatedDiary;
      });
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFA78BFA),
                    size: 20,
                  ),
                ),
                title: const Text(
                  '编辑日记',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editDiary();
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                title: const Text(
                  '删除日记',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDiary();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    final dateStr = dateFormat.format(_currentDiary.date);
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[_currentDiary.date.weekday - 1];
    final fullDateStr = '$dateStr $weekday';

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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMoodBadge(),
                            const SizedBox(height: 16),
                            Text(
                              fullDateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentDiary.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B5563),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _currentDiary.content,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
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
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showMoreOptions,
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
                Icons.more_horiz,
                size: 20,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3E8FF).withValues(alpha: 0.5),
            const Color(0xFFFCE7F3).withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: _currentDiary.imageUrl != null
            ? Image.network(
                _currentDiary.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF3E8FF).withValues(alpha: 0.5),
                          const Color(0xFFFCE7F3).withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Color(0xFFA78BFA),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: Color(0xFFA78BFA),
                ),
              ),
      ),
    );
  }

  Widget _buildMoodBadge() {
    final moodConfig = _getMoodConfig(_currentDiary.mood);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: moodConfig['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            moodConfig['emoji'] as String,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            moodConfig['label'] as String,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMoodConfig(String mood) {
    switch (mood) {
      case 'happy':
        return {
          'emoji': '😊',
          'label': '开心',
          'color': const Color(0xFFFBBF24),
        };
      case 'calm':
        return {
          'emoji': '😌',
          'label': '平静',
          'color': const Color(0xFF60A5FA),
        };
      case 'neutral':
        return {
          'emoji': '😐',
          'label': '一般',
          'color': const Color(0xFF94A3B8),
        };
      case 'sad':
        return {
          'emoji': '☁️',
          'label': '低落',
          'color': const Color(0xFF8B5CF6),
        };
      default:
        return {
          'emoji': '😊',
          'label': '开心',
          'color': const Color(0xFFFBBF24),
        };
    }
  }
}
