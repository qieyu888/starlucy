import 'package:shared_preferences/shared_preferences.dart';

class StarGemsService {
  static const String _gemsKey = 'star_gems';
  static const int _initialGems = 60; // 新用户赠送 60 星钻
  static const int _costPerMessage = 10; // 每条消息消耗 10 星钻

  Future<int> getGems() async {
    final prefs = await SharedPreferences.getInstance();
    final gems = prefs.getInt(_gemsKey);
    
    // 首次使用，赠送初始星钻
    if (gems == null) {
      await prefs.setInt(_gemsKey, _initialGems);
      return _initialGems;
    }
    
    return gems;
  }

  Future<void> addGems(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentGems = await getGems();
    await prefs.setInt(_gemsKey, currentGems + amount);
  }

  Future<bool> consumeGems(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentGems = await getGems();
    
    print('🔷 星钻消耗: 当前余额=$currentGems, 消耗=$amount');
    
    if (currentGems >= amount) {
      final newGems = currentGems - amount;
      await prefs.setInt(_gemsKey, newGems);
      print('✅ 星钻扣除成功: 新余额=$newGems');
      return true;
    }
    
    print('❌ 星钻不足: 需要=$amount, 当前=$currentGems');
    return false;
  }

  Future<bool> canSendMessage() async {
    final gems = await getGems();
    return gems >= _costPerMessage;
  }

  int get costPerMessage => _costPerMessage;
}
