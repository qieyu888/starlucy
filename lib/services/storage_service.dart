import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String _diariesKey = 'diaries';

  Future<List<DiaryEntry>> loadDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diariesJson = prefs.getString(_diariesKey);
    
    if (diariesJson == null) {
      return _getDefaultDiaries();
    }
    
    try {
      final List<dynamic> decoded = json.decode(diariesJson);
      return decoded.map((item) => DiaryEntry.fromJson(item)).toList();
    } catch (e) {
      return _getDefaultDiaries();
    }
  }

  Future<void> saveDiaries(List<DiaryEntry> diaries) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      diaries.map((diary) => diary.toJson()).toList(),
    );
    await prefs.setString(_diariesKey, encoded);
  }

  Future<void> deleteDiary(String id) async {
    final diaries = await loadDiaries();
    diaries.removeWhere((diary) => diary.id == id);
    await saveDiaries(diaries);
  }

  Future<void> updateDiary(DiaryEntry updatedDiary) async {
    final diaries = await loadDiaries();
    final index = diaries.indexWhere((d) => d.id == updatedDiary.id);
    if (index != -1) {
      diaries[index] = updatedDiary;
      await saveDiaries(diaries);
    }
  }

  List<DiaryEntry> _getDefaultDiaries() {
    final now = DateTime.now();
    return [
      DiaryEntry(
        id: '1',
        title: '春日午后的茶',
        content: '白瓷杯里的花果茶冒着热气，书页翻动的声音格外好听。阳光透过窗帘洒在桌面上，形成斑驳的光影。这样的午后，时间仿佛都慢了下来。',
        date: now.subtract(const Duration(days: 1)),
        mood: 'happy',
        imageUrl: 'https://images.unsplash.com/photo-1544787210-2211d44b5639?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '2',
        title: '草莓味的黄昏',
        content: '今天的晚霞是草莓色的，云朵像蓬松的棉花糖。站在阳台上，微风拂过脸颊，带来一丝凉意。',
        date: now.subtract(const Duration(days: 2)),
        mood: 'calm',
        imageUrl: 'https://images.unsplash.com/photo-1476610182048-b716b8518aae?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '3',
        title: '路边的小野花',
        content: '哪怕是在石缝里，也在努力地向着阳光生长呢。生命的韧性总是让人感动。',
        date: now.subtract(const Duration(days: 3)),
        mood: 'happy',
        imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '4',
        title: '雨后的清晨',
        content: '昨夜下了一场雨，早上起来空气格外清新。树叶上还挂着晶莹的水珠，在阳光下闪闪发光。深呼吸，感觉整个人都被洗涤了一遍。',
        date: now.subtract(const Duration(days: 4)),
        mood: 'calm',
      ),
      DiaryEntry(
        id: '5',
        title: '咖啡馆的邂逅',
        content: '在咖啡馆偶遇了多年未见的老友，聊了很久。时光荏苒，但友谊依旧。点了一杯拿铁，听着轻柔的音乐，度过了美好的下午。',
        date: now.subtract(const Duration(days: 5)),
        mood: 'happy',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '6',
        title: '图书馆的一天',
        content: '在图书馆待了一整天，看完了一本心仪已久的书。周围很安静，只有翻书的沙沙声。这种专注的感觉真好。',
        date: now.subtract(const Duration(days: 6)),
        mood: 'calm',
      ),
      DiaryEntry(
        id: '7',
        title: '有点累',
        content: '今天工作很忙，感觉有点疲惫。不过还是要继续加油。',
        date: now.subtract(const Duration(days: 7)),
        mood: 'neutral',
      ),
      DiaryEntry(
        id: '8',
        title: '周末的慵懒时光',
        content: '睡到自然醒，然后窝在沙发里看了一整天的电影。偶尔这样放空自己也挺好的。点了外卖，不用做饭的周末真幸福。',
        date: now.subtract(const Duration(days: 8)),
        mood: 'happy',
      ),
      DiaryEntry(
        id: '9',
        title: '夜晚的思考',
        content: '深夜了，还是睡不着。想了很多事情，关于未来，关于梦想。有时候觉得迷茫，但还是要相信明天会更好。',
        date: now.subtract(const Duration(days: 9)),
        mood: 'sad',
      ),
      DiaryEntry(
        id: '10',
        title: '公园散步',
        content: '傍晚去公园散步，看到很多人在锻炼。有跑步的，有跳广场舞的，还有遛狗的。生活气息很浓，让人感到温暖。',
        date: now.subtract(const Duration(days: 10)),
        mood: 'calm',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '11',
        title: '美食探店',
        content: '今天去了一家新开的餐厅，环境很好，菜品也很精致。拍了好多照片，准备发朋友圈。和朋友一起分享美食的时光总是快乐的。',
        date: now.subtract(const Duration(days: 11)),
        mood: 'happy',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '12',
        title: '音乐会',
        content: '去听了一场音乐会，现场的氛围太棒了。音乐响起的那一刻，所有的烦恼都消失了。',
        date: now.subtract(const Duration(days: 12)),
        mood: 'happy',
      ),
      DiaryEntry(
        id: '13',
        title: '平淡的一天',
        content: '今天没什么特别的事情，就是普通的一天。上班、下班、吃饭、睡觉。',
        date: now.subtract(const Duration(days: 13)),
        mood: 'neutral',
      ),
      DiaryEntry(
        id: '14',
        title: '海边的风',
        content: '周末去了海边，海风吹在脸上，带着咸咸的味道。看着海浪一波一波地涌来，心情也跟着平静下来。捡了几个贝壳，准备带回家做纪念。',
        date: now.subtract(const Duration(days: 14)),
        mood: 'calm',
        imageUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?auto=format&fit=crop&w=800&q=80',
      ),
      DiaryEntry(
        id: '15',
        title: '下雨天',
        content: '又是下雨天，心情有点低落。窗外雨声淅淅沥沥，让人感到有些忧郁。',
        date: now.subtract(const Duration(days: 15)),
        mood: 'sad',
      ),
    ];
  }
}
