import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import 'diary_detail_screen.dart';
import 'search_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;
  
  const HomeScreen({super.key, this.refreshNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  List<DiaryEntry> _diaries = [];
  List<DiaryEntry> _filteredDiaries = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late AnimationController _fabController;

  final List<Map<String, dynamic>> _filters = [
    {'label': '全部', 'value': 'all', 'icon': Icons.grid_view_rounded},
    {'label': '开心', 'value': 'happy', 'icon': Icons.sentiment_satisfied_alt},
    {'label': '平静', 'value': 'calm', 'icon': Icons.self_improvement},
    {'label': '一般', 'value': 'neutral', 'icon': Icons.sentiment_neutral},
    {'label': '低落', 'value': 'sad', 'icon': Icons.cloud_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadDiaries();
    widget.refreshNotifier?.addListener(_onRefresh);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    _fabController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final diaries = await _storageService.loadDiaries();
    if (mounted) {
      setState(() {
        _diaries = diaries;
        _filterDiaries();
        _isLoading = false;
      });
    }
  }

  void _filterDiaries() {
    if (_selectedFilter == 'all') {
      _filteredDiaries = _diaries;
    } else {
      _filteredDiaries = _diaries.where((d) => d.mood == _selectedFilter).toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterDiaries();
    });
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(),
                    _buildStats(),
                    _buildFilterTabs(),
                    Expanded(child: _buildMasonryGrid()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '碎碎念',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4B5563),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TODAY · ${DateFormat('MM月dd日').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF5F3FF),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadDiaries();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF5F3FF),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                    size: 18,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadDiaries();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalCount = _diaries.length;
    final thisWeekCount = _diaries.where((d) {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      return d.date.isAfter(weekAgo);
    }).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.auto_stories,
              label: '总记录',
              value: '$totalCount',
              color: const Color(0xFFA78BFA),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFF5F3FF),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_fire_department,
              label: '本周',
              value: '$thisWeekCount',
              color: const Color(0xFFF472B6),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFF5F3FF),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_emotions,
              label: '心情',
              value: _getMoodEmoji(),
              color: const Color(0xFFFBBF24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  String _getMoodEmoji() {
    if (_diaries.isEmpty) return '😊';
    final latestMood = _diaries.first.mood;
    switch (latestMood) {
      case 'happy':
        return '😊';
      case 'calm':
        return '😌';
      case 'neutral':
        return '😐';
      case 'sad':
        return '☁️';
      default:
        return '😊';
    }
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _onFilterChanged(filter['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFF5F3FF),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasonryGrid() {
    if (_filteredDiaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all' ? '还没有记录哦' : '暂无该心情的记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _filteredDiaries.length,
      itemBuilder: (context, index) {
        return _buildMasonryCard(_filteredDiaries[index], index);
      },
    );
  }

  Widget _buildMasonryCard(DiaryEntry diary, int index) {
    final dateFormat = DateFormat('MM/dd');
    final dateStr = dateFormat.format(diary.date);
    
    final hasImage = diary.imageUrl != null && diary.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(diary: diary),
          ),
        );
        
        // 如果返回 true，表示有更新或删除，需要刷新列表
        if (result == true) {
          _loadDiaries();
        }
      },
      child: Hero(
        tag: 'diary_${diary.id}',
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage) _buildCardImage(diary.imageUrl!),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _buildMoodIcon(diary.mood),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        diary.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        diary.content,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          height: 1.5,
                        ),
                        maxLines: hasImage ? 3 : 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
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
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFA78BFA).withValues(alpha: 0.5),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // 图片加载失败，返回空容器（不显示图片）
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMoodIcon(String mood) {
    String emoji;
    Color color;
    
    switch (mood) {
      case 'happy':
        emoji = '😊';
        color = const Color(0xFFFBBF24);
        break;
      case 'calm':
        emoji = '😌';
        color = const Color(0xFF60A5FA);
        break;
      case 'neutral':
        emoji = '😐';
        color = const Color(0xFF94A3B8);
        break;
      case 'sad':
        emoji = '☁️';
        color = const Color(0xFF8B5CF6);
        break;
      default:
        emoji = '😊';
        color = const Color(0xFFFBBF24);
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
