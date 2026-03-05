import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/feed_item.dart';

class SquareScreen extends StatefulWidget {
  const SquareScreen({super.key});

  @override
  State<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends State<SquareScreen> {
  String _sortBy = 'default'; // 'default', 'likes', 'latest'
  
  final List<FeedItem> _allFeeds = [
    FeedItem(
      id: '1',
      userName: '茉莉酱',
      text: '早起给自己准备了一份元气早餐，阳光透过窗帘洒进来，美好的一天开始了。',
      imageUrl: 'https://images.unsplash.com/photo-1494390248081-4e521a5940db?w=500&q=80',
      likes: 128,
      category: 'food',
    ),
    FeedItem(
      id: '2',
      userName: '云朵收集者',
      text: '捕捉到一只形状像猫的云，大自然的艺术真是奇妙。',
      imageUrl: 'https://images.unsplash.com/photo-1513002749550-c59d786b8e6c?w=500&q=80',
      likes: 256,
      category: 'healing',
    ),
    FeedItem(
      id: '3',
      userName: '盐系少女',
      text: '极简的生活，让内心更丰盈。',
      imageUrl: 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=500&q=80',
      likes: 189,
      category: 'gentle',
    ),
    FeedItem(
      id: '4',
      userName: '风的影子',
      text: '在山谷里听到了回声，那是大自然在回应我的呼唤。',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&q=80',
      likes: 342,
      category: 'travel',
    ),
    FeedItem(
      id: '5',
      userName: '午后阳光',
      text: '咖啡馆的下午茶时光，慢下来享受生活。',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&q=80',
      likes: 215,
      category: 'food',
    ),
    FeedItem(
      id: '6',
      userName: '花间词',
      text: '春天的花开得正好，粉色的樱花像云朵一样。',
      imageUrl: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=500&q=80',
      likes: 432,
      category: 'healing',
    ),
    FeedItem(
      id: '7',
      userName: '城市漫步',
      text: '夜晚的城市灯火通明，每一盏灯都是一个故事。',
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=500&q=80',
      likes: 178,
      category: 'travel',
    ),
    FeedItem(
      id: '8',
      userName: '书香气',
      text: '在图书馆度过了一个安静的下午。',
      imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=500&q=80',
      likes: 156,
      category: 'gentle',
    ),
    FeedItem(
      id: '9',
      userName: '海风',
      text: '海边的日落，橙色的天空美得让人窒息。',
      imageUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=500&q=80',
      likes: 567,
      category: 'travel',
    ),
    FeedItem(
      id: '10',
      userName: '雨后彩虹',
      text: '雨后的空气格外清新，看到了双彩虹！',
      imageUrl: 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=500&q=80',
      likes: 389,
      category: 'healing',
    ),
    FeedItem(
      id: '11',
      userName: '美食家',
      text: '今天做了一道新菜，色香味俱全。',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500&q=80',
      likes: 298,
      category: 'food',
    ),
    FeedItem(
      id: '12',
      userName: '植物爱好者',
      text: '我的多肉植物开花了，好可爱！',
      imageUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=500&q=80',
      likes: 234,
      category: 'gentle',
    ),
    FeedItem(
      id: '13',
      userName: '旅行者',
      text: '在古镇的小巷里迷路，却发现了最美的风景。',
      imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=500&q=80',
      likes: 445,
      category: 'travel',
    ),
    FeedItem(
      id: '14',
      userName: '音乐人',
      text: '弹吉他的夜晚，音乐是最好的陪伴。',
      imageUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&q=80',
      likes: 312,
      category: 'gentle',
    ),
    FeedItem(
      id: '15',
      userName: '摄影师',
      text: '捕捉光影的瞬间，记录生活的美好。',
      imageUrl: 'https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=500&q=80',
      likes: 521,
      category: 'healing',
    ),
  ];

  List<FeedItem> _filteredFeeds = [];
  int _selectedCategory = 0;
  final List<Map<String, dynamic>> _categories = [
    {'label': '全部心情', 'icon': Icons.grid_view_rounded, 'value': 'all'},
    {'label': '温柔瞬间', 'icon': Icons.favorite_border, 'value': 'gentle'},
    {'label': '治愈摄影', 'icon': Icons.camera_alt_outlined, 'value': 'healing'},
    {'label': '美食记录', 'icon': Icons.restaurant_outlined, 'value': 'food'},
    {'label': '旅行日记', 'icon': Icons.flight_outlined, 'value': 'travel'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredFeeds = _allFeeds;
  }

  void _filterFeeds(int index) {
    setState(() {
      _selectedCategory = index;
      final categoryValue = _categories[index]['value'] as String;
      
      if (categoryValue == 'all') {
        _filteredFeeds = _allFeeds;
      } else {
        _filteredFeeds = _allFeeds.where((feed) => feed.category == categoryValue).toList();
      }
      
      _applySorting();
    });
  }

  void _applySorting() {
    if (_sortBy == 'likes') {
      _filteredFeeds.sort((a, b) => b.likes.compareTo(a.likes));
    } else if (_sortBy == 'latest') {
      _filteredFeeds = _filteredFeeds.reversed.toList();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.tune, color: Color(0xFFA78BFA), size: 24),
                  SizedBox(width: 12),
                  Text(
                    '排序方式',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              icon: Icons.auto_awesome,
              title: '默认排序',
              subtitle: '按推荐顺序展示',
              value: 'default',
            ),
            _buildFilterOption(
              icon: Icons.favorite,
              title: '最多点赞',
              subtitle: '按点赞数从高到低',
              value: 'likes',
            ),
            _buildFilterOption(
              icon: Icons.access_time,
              title: '最新发布',
              subtitle: '按发布时间排序',
              value: 'latest',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _sortBy == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = value;
          _filterFeeds(_selectedCategory);
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFA78BFA) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFA78BFA),
                size: 24,
              ),
          ],
        ),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              Expanded(child: _buildFeedGrid()),
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
                '星云广场',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '发现 ${_filteredFeeds.length} 条精彩内容',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
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
                Icons.tune,
                color: const Color(0xFFA78BFA).withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: _showFilterOptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _filterFeeds(index),
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
                    color: isSelected ? Colors.transparent : const Color(0xFFF5F3FF),
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
                      category['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['label'] as String,
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

  Widget _buildFeedGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _filteredFeeds.length,
      itemBuilder: (context, index) {
        return _buildFeedCard(_filteredFeeds[index]);
      },
    );
  }

  Widget _buildFeedCard(FeedItem feed) {
    final textLines = feed.text.length > 30 ? 3 : 2;
    
    return GestureDetector(
      onTap: () => _showFeedDetail(feed),
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
              color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
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
              _buildFeedImage(feed.imageUrl),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      feed.text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                      maxLines: textLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  feed.userName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 14, color: Color(0xFFF472B6)),
                            const SizedBox(width: 4),
                            Text(
                              _formatLikes(feed.likes),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF472B6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedImage(String imageUrl) {
    return AspectRatio(
      aspectRatio: 1.0,
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
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFA78BFA).withValues(alpha: 0.5),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  String _formatLikes(int likes) {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }

  void _showFeedDetail(FeedItem feed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showMoreOptions(feed),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        feed.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feed.userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const Text(
                              '刚刚',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      feed.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Color(0xFFF472B6), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${feed.likes} 人喜欢',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(FeedItem feed) {
    Navigator.pop(context); // 关闭详情页
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
                    color: const Color(0xFF64748B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.block,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                title: const Text(
                  '拉黑用户',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                subtitle: const Text(
                  '不再看到该用户的内容',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(feed);
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
                    Icons.flag_outlined,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                title: const Text(
                  '举报内容',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                subtitle: const Text(
                  '举报不当内容',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(feed);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _blockUser(FeedItem feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '拉黑用户',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        content: Text(
          '确定要拉黑 ${feed.userName} 吗？拉黑后将不再看到该用户的内容。',
          style: const TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已拉黑 ${feed.userName}'),
                  backgroundColor: const Color(0xFF64748B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  void _reportContent(FeedItem feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(Icons.flag_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text(
              '举报内容',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请选择举报原因：',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildReportOption('垃圾广告'),
            _buildReportOption('色情低俗'),
            _buildReportOption('违法违规'),
            _buildReportOption('侵权内容'),
            _buildReportOption('其他原因'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已提交举报：$reason'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              reason,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
