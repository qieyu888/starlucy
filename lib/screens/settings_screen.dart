import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/storage_service.dart';
import '../services/star_gems_service.dart';
import '../services/iap_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ValueNotifier<int>? gemsRefreshNotifier;
  
  const SettingsScreen({super.key, this.gemsRefreshNotifier});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final StarGemsService _gemsService = StarGemsService();
  final IAPService _iapService = IAPService();
  final AuthService _authService = AuthService();
  int _totalDays = 0;
  int _starGems = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadGems();
    widget.gemsRefreshNotifier?.addListener(_onGemsRefresh);
    
    // 监听内购状态更新
    _iapService.onPurchaseUpdate = _handlePurchaseUpdate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
    _loadGems();
  }

  void _onGemsRefresh() {
    print('🔔 收到星钻刷新通知');
    _loadGems();
  }

  @override
  void dispose() {
    widget.gemsRefreshNotifier?.removeListener(_onGemsRefresh);
    _iapService.onPurchaseUpdate = null;
    super.dispose();
  }

  void _handlePurchaseUpdate(PurchaseStatus status, String? message, int? gems) {
    print('📱 收到购买状态更新: $status, $message, $gems');
    
    if (!mounted) return;
    
    switch (status) {
      case PurchaseStatus.pending:
        // 显示加载中
        break;
        
      case PurchaseStatus.purchased:
        // 购买成功，刷新星钻余额
        _loadGems();
        widget.gemsRefreshNotifier?.value++;
        
        // 显示成功对话框
        if (gems != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 60, height: 60, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF472B6)]), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 32)),
                  const SizedBox(height: 16),
                  const Text('充值成功', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  Text('已获得 $gems 星钻', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定', style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)))],
            ),
          );
        }
        break;
        
      case PurchaseStatus.error:
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? '购买失败'), backgroundColor: const Color(0xFFEF4444)),
        );
        break;
        
      case PurchaseStatus.canceled:
        // 用户取消，不显示提示
        break;
        
      default:
        break;
    }
  }

  Future<void> _loadStats() async {
    final diaries = await _storageService.loadDiaries();
    if (mounted) {
      setState(() {
        _totalDays = diaries.length;
      });
    }
  }

  Future<void> _loadGems() async {
    final gems = await _gemsService.getGems();
    print('💎 设置页面加载星钻余额: $gems');
    if (mounted) {
      setState(() {
        _starGems = gems;
      });
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildStatsCard(),
                const SizedBox(height: 24),
                _buildSettingsSection(),
                const SizedBox(height: 16),
                _buildAccountSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4B5563),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '个人中心与设置',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.auto_stories, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  Text('$_totalDays', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                  const SizedBox(height: 6),
                  const Text('记录的心迹', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(width: 1, height: 80, color: Colors.white.withValues(alpha: 0.3)),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.diamond, size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  Text('$_starGems', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                  const SizedBox(height: 6),
                  const Text('星钻余额', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text('功能设置', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1),
              boxShadow: [BoxShadow(color: const Color(0xFFA78BFA).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                _buildSettingItem(icon: Icons.diamond_outlined, title: '充值星钻', subtitle: '充值后可与 AI 聊天', onTap: () => _showRechargeDialog(), isFirst: true),
                _buildDivider(),
                _buildSettingItem(icon: Icons.feedback_outlined, title: '意见反馈', subtitle: '告诉我们你的想法', onTap: () => _showFeedback()),
                _buildDivider(),
                _buildSettingItem(icon: Icons.block, title: '黑名单管理', subtitle: '管理已拉黑的用户', onTap: () => _showBlockList()),
                _buildDivider(),
                _buildSettingItem(icon: Icons.shield_outlined, title: '隐私协议', subtitle: '了解我们如何保护你的隐私', onTap: () => _showPrivacyPolicy()),
                _buildDivider(),
                _buildSettingItem(icon: Icons.description_outlined, title: '用户协议', subtitle: '查看服务条款', onTap: () => _showUserAgreement(), isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text('账户管理', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1),
              boxShadow: [BoxShadow(color: const Color(0xFFA78BFA).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                _buildSettingItem(icon: Icons.logout, title: '退出登录', subtitle: '退出当前账户', onTap: () => _showLogoutDialog(), isFirst: true),
                _buildDivider(),
                _buildSettingItem(icon: Icons.delete_outline, title: '注销账户', subtitle: '永久删除账户和所有数据', onTap: () => _showDeleteAccountDialog(), isLast: true, isDanger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isFirst = false, bool isLast = false, bool isDanger = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(top: isFirst ? const Radius.circular(24) : Radius.zero, bottom: isLast ? const Radius.circular(24) : Radius.zero),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 22, color: isDanger ? const Color(0xFFEF4444) : const Color(0xFFA78BFA))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF4B5563))), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))])),
              const Icon(Icons.chevron_right, size: 20, color: Color(0xFFE2E8F0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(padding: const EdgeInsets.only(left: 76), child: Container(height: 1, color: const Color(0xFFF5F3FF).withValues(alpha: 0.5)));
  }

  void _showRechargeDialog() {
    print('🛒 点击充值按钮');
    print('🛒 内购可用性: ${_iapService.isAvailable}');
    print('🛒 产品数量: ${_iapService.products.length}');
    
    // 获取产品列表（如果内购不可用，使用模拟数据）
    final products = _iapService.products;
    final bool isSimulatorMode = !_iapService.isAvailable || products.isEmpty;
    
    if (isSimulatorMode) {
      print('⚠️ 使用模拟器模式显示充值页面');
    } else {
      print('✅ 显示真实充值对话框，产品数量: ${products.length}');
    }

    final productInfo = {
      'xingzuan_6': {'gems': 60, 'description': '可发送 6 条消息', 'price': '¥6.00'},
      'xingzuan_18': {'gems': 180, 'description': '可发送 18 条消息', 'price': '¥18.00'},
      'xingzuan_28': {'gems': 280, 'description': '可发送 28 条消息', 'price': '¥28.00'},
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF472B6)]), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.diamond, size: 40, color: Colors.white)),
              const SizedBox(height: 24),
              const Text('充值星钻', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 8),
              Text('当前余额：$_starGems 星钻', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
              const SizedBox(height: 8),
              const Text('每次对话消耗 10 星钻', style: TextStyle(fontSize: 12, color: Color(0xFFF472B6), fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              // 显示产品列表（真实或模拟）
              if (isSimulatorMode)
                // 模拟器模式：显示模拟数据
                ...productInfo.entries.map((entry) {
                  final info = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showSimulatorPurchaseDialog(info['gems'] as int);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF5F3FF), width: 2), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Color(0xFFA78BFA), size: 24),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${info['gems']} 星钻', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))), const SizedBox(height: 2), Text(info['description'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))])),
                            Text(info['price'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
                          ],
                        ),
                      ),
                    ),
                  );
                })
              else
                // 真实模式：显示真实产品
                ...products.map((product) {
                  final info = productInfo[product.id];
                  if (info == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _processPurchase(product);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF5F3FF), width: 2), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Color(0xFFA78BFA), size: 24),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${info['gems']} 星钻', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))), const SizedBox(height: 2), Text(info['description'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))])),
                            Text(product.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimulatorPurchaseDialog(int gems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF472B6)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.diamond, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('确认充值', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
            Text('充值 $gems 星钻', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // 显示处理中
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA78BFA)),
                  ),
                ),
              );
              
              // 模拟处理延迟
              await Future.delayed(const Duration(milliseconds: 800));
              
              // 充值
              await _gemsService.addGems(gems);
              _loadGems();
              widget.gemsRefreshNotifier?.value++;
              
              // 关闭处理中对话框
              if (mounted) Navigator.pop(context);
              
              // 显示成功对话框
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF472B6)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('充值成功', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                        const SizedBox(height: 8),
                        Text('已获得 $gems 星钻', style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定', style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase(ProductDetails product) async {
    print('🛒 开始购买: ${product.id}');
    
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA78BFA)),
        ),
      ),
    );
    
    // 发起购买
    final success = await _iapService.buyProduct(product);
    
    // 关闭加载对话框
    if (mounted) Navigator.pop(context);
    
    if (!success) {
      // 购买请求失败（不是用户取消）
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('购买请求失败，请稍后重试'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
    // 购买结果会通过 onPurchaseUpdate 回调处理
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Icon(Icons.shield_outlined, color: Color(0xFFA78BFA)), SizedBox(width: 12), Text('隐私协议', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))])),
            const SizedBox(height: 24),
            const Expanded(child: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('我们非常重视您的隐私保护。本隐私协议说明了我们如何收集、使用和保护您的个人信息。\n\n1. 信息收集\n我们仅收集您主动提供的信息，包括：\n• 您创建的日记内容\n• 使用应用的基本统计数据\n\n2. 信息使用\n您的信息仅用于：\n• 提供应用的核心功能\n• 改善用户体验\n• 数据备份和恢复\n\n3. 信息保护\n• 所有数据存储在本地设备\n• 我们不会将您的个人信息出售给第三方\n• 采用加密技术保护数据安全\n\n4. 您的权利\n您有权：\n• 随时查看和修改您的信息\n• 导出您的所有数据\n• 删除您的账户和所有数据\n\n5. 联系我们\n如有任何问题，请联系：support@starnote.app\n\n最后更新：2024年3月', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.8)))),
          ],
        ),
      ),
    );
  }

  void _showUserAgreement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Icon(Icons.description_outlined, color: Color(0xFFA78BFA)), SizedBox(width: 12), Text('用户协议', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))])),
            const SizedBox(height: 24),
            const Expanded(child: SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('欢迎使用 StarNote！\n\n1. 服务说明\nStarNote 是一款个人日记记录应用，帮助您记录生活点滴。\n\n2. 用户责任\n• 您对自己的账户安全负责\n• 不得使用本应用从事违法活动\n• 尊重他人隐私和知识产权\n\n3. 内容规范\n• 您创建的内容归您所有\n• 不得发布违法、暴力、色情等不当内容\n• 我们保留删除不当内容的权利\n\n4. 服务变更\n• 我们可能会更新应用功能\n• 重大变更会提前通知用户\n\n5. 免责声明\n• 应用按"现状"提供\n• 我们不对数据丢失负责，请定期备份\n• 不保证服务不中断\n\n6. 协议修改\n我们可能会更新本协议，更新后会在应用内通知。\n\n7. 法律适用\n本协议受中华人民共和国法律管辖。\n\n最后更新：2024年3月', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.8)))),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        content: const Text(
          '确定要退出当前账户吗？\n\n退出后需要重新登录才能使用',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
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
            onPressed: () async {
              Navigator.pop(context);
              
              // 显示加载
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA78BFA)),
                  ),
                ),
              );
              
              // 退出登录
              await _authService.logout();
              
              // 关闭加载
              if (mounted) Navigator.pop(context);
              
              // 跳转到登录页
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              '确定',
              style: TextStyle(
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text(
              '注销账户',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        content: const Text(
          '注销账户后，所有数据将被永久删除且无法恢复，包括：\n\n'
          '• 所有日记记录\n'
          '• 星钻余额\n'
          '• 个人设置\n\n'
          '确定要继续吗？',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
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
              _showFinalDeleteConfirmation();
            },
            child: const Text(
              '确定注销',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '最后确认',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444),
          ),
        ),
        content: const Text(
          '这是最后一次确认\n\n'
          '注销后数据将无法恢复\n\n'
          '真的要注销账户吗？',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '我再想想',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // 显示加载
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                  ),
                ),
              );
              
              // 删除所有数据
              await _authService.deleteAccount();
              
              // 关闭加载
              if (mounted) Navigator.pop(context);
              
              // 跳转到登录页
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              '确定注销',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.feedback_outlined, color: Color(0xFFA78BFA)),
                      const SizedBox(width: 12),
                      const Text(
                        '意见反馈',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '反馈类型',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFeedbackTypeChip('功能建议'),
                      _buildFeedbackTypeChip('问题反馈'),
                      _buildFeedbackTypeChip('其他'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '详细描述',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const TextField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '请详细描述你的问题或建议...',
                        hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('感谢你的反馈！我们会认真处理'),
                            backgroundColor: Color(0xFFA78BFA),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA78BFA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '提交反馈',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackTypeChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {},
      backgroundColor: const Color(0xFFF5F3FF),
      selectedColor: const Color(0xFFA78BFA),
      labelStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
    );
  }

  void _showBlockList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.block, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text(
                    '黑名单管理',
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildBlockedUserItem('示例用户1'),
                  _buildBlockedUserItem('示例用户2'),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '暂无拉黑用户',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedUserItem(String userName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF5F3FF),
          width: 1,
        ),
      ),
      child: Row(
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
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已解除对 $userName 的拉黑'),
                  backgroundColor: const Color(0xFFA78BFA),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              '解除',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
