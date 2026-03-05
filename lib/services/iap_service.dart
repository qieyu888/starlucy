import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'star_gems_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final StarGemsService _gemsService = StarGemsService();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  
  // 购买状态回调
  Function(PurchaseStatus status, String? message, int? gems)? onPurchaseUpdate;
  
  // 内购产品 ID
  static const String product6 = 'xingzuan_6';
  static const String product18 = 'xingzuan_18';
  static const String product28 = 'xingzuan_28';
  
  static const Set<String> _productIds = {
    product6,
    product18,
    product28,
  };
  
  // 产品 ID 对应的星钻数量
  static const Map<String, int> _gemsMap = {
    product6: 60,
    product18: 180,
    product28: 280,
  };

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  /// 初始化内购服务
  Future<void> initialize() async {
    print('🛒 初始化内购服务...');
    
    try {
      // 检查内购是否可用
      _isAvailable = await _iap.isAvailable();
      print('🛒 内购可用性: $_isAvailable');
      
      if (!_isAvailable) {
        print('❌ 内购服务不可用（可能在模拟器上运行）');
        return;
      }

      // 监听购买更新
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          print('🛒 购买流关闭');
          _subscription?.cancel();
        },
        onError: (error) {
          print('❌ 购买流错误: $error');
        },
      );

      // 加载产品信息
      await loadProducts();
      
      // 恢复未完成的购买
      await _restorePurchases();
    } catch (e) {
      print('❌ 初始化内购服务失败: $e');
      _isAvailable = false;
    }
  }

  /// 加载产品信息
  Future<void> loadProducts() async {
    print('🛒 加载产品信息...');
    
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ 未找到的产品 ID: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        print('❌ 加载产品错误: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      print('✅ 成功加载 ${_products.length} 个产品');
      
      for (var product in _products) {
        print('  - ${product.id}: ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('❌ 加载产品异常: $e');
    }
  }

  /// 购买产品
  Future<bool> buyProduct(ProductDetails product) async {
    print('🛒 开始购买: ${product.id}');
    
    if (!_isAvailable) {
      print('❌ 内购服务不可用');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      
      // iOS 使用消耗型产品
      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false, // 手动消耗，确保发放星钻后再消耗
      );
      
      print('🛒 购买请求结果: $success');
      return success;
    } catch (e) {
      print('❌ 购买异常: $e');
      return false;
    }
  }

  /// 处理购买更新
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    print('🛒 收到 ${purchaseDetailsList.length} 个购买更新');
    
    for (var purchaseDetails in purchaseDetailsList) {
      print('🛒 处理购买: ${purchaseDetails.productID}, 状态: ${purchaseDetails.status}');
      
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('⏳ 购买待处理: ${purchaseDetails.productID}');
          onPurchaseUpdate?.call(PurchaseStatus.pending, '正在处理购买...', null);
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print('✅ 购买成功: ${purchaseDetails.productID}');
          
          // 验证购买（生产环境应该在服务器端验证）
          bool valid = await _verifyPurchase(purchaseDetails);
          
          if (valid) {
            // 发放星钻
            final gems = await _deliverProduct(purchaseDetails);
            
            // 标记购买已完成
            if (purchaseDetails.pendingCompletePurchase) {
              await _iap.completePurchase(purchaseDetails);
              print('✅ 购买已完成: ${purchaseDetails.productID}');
            }
            
            // 通知 UI 购买成功
            if (gems != null) {
              onPurchaseUpdate?.call(PurchaseStatus.purchased, '充值成功', gems);
            }
          } else {
            print('❌ 购买验证失败: ${purchaseDetails.productID}');
            onPurchaseUpdate?.call(PurchaseStatus.error, '购买验证失败', null);
          }
          break;
          
        case PurchaseStatus.error:
          print('❌ 购买错误: ${purchaseDetails.error}');
          final errorMessage = purchaseDetails.error?.message ?? '购买失败';
          onPurchaseUpdate?.call(PurchaseStatus.error, errorMessage, null);
          
          // 标记购买已完成（即使失败也要完成）
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;
          
        case PurchaseStatus.canceled:
          print('🚫 购买已取消: ${purchaseDetails.productID}');
          onPurchaseUpdate?.call(PurchaseStatus.canceled, '购买已取消', null);
          
          // 标记购买已完成
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;
      }
    }
  }

  /// 验证购买（简化版，生产环境应该在服务器端验证）
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    print('🔐 验证购买: ${purchaseDetails.productID}');
    
    // 在生产环境中，应该将 purchaseDetails.verificationData 发送到服务器验证
    // 服务器应该：
    // 1. 验证收据的真实性（通过 Apple 的验证 API）
    // 2. 检查是否已经处理过这个交易（防止重复发放）
    // 3. 记录交易日志
    
    // 这里简化处理，只检查基本信息
    if (purchaseDetails.verificationData.localVerificationData.isEmpty) {
      print('❌ 验证数据为空');
      return false;
    }
    
    if (!_productIds.contains(purchaseDetails.productID)) {
      print('❌ 无效的产品 ID: ${purchaseDetails.productID}');
      return false;
    }
    
    print('✅ 购买验证通过');
    return true;
  }

  /// 发放产品（星钻）
  Future<int?> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final gems = _gemsMap[productId];
    
    if (gems == null) {
      print('❌ 未知的产品 ID: $productId');
      return null;
    }
    
    print('💎 发放星钻: $gems');
    
    try {
      // 添加星钻
      await _gemsService.addGems(gems);
      
      // 记录交易（生产环境应该保存到服务器）
      await _recordTransaction(purchaseDetails, gems);
      
      print('✅ 星钻发放成功: $gems');
      return gems;
      
    } catch (e) {
      print('❌ 发放星钻失败: $e');
      return null;
    }
  }

  /// 记录交易
  Future<void> _recordTransaction(PurchaseDetails purchaseDetails, int gems) async {
    // 在生产环境中，应该将交易信息保存到服务器
    // 包括：transactionDate, productID, gems, verificationData 等
    print('📝 记录交易: ${purchaseDetails.productID}, 星钻: $gems');
  }

  /// 恢复购买
  Future<void> _restorePurchases() async {
    print('🔄 恢复未完成的购买...');
    
    try {
      await _iap.restorePurchases();
      print('✅ 恢复购买完成');
    } catch (e) {
      print('❌ 恢复购买失败: $e');
    }
  }

  /// 手动恢复购买（用户主动触发）
  Future<void> restorePurchases() async {
    print('🔄 用户触发恢复购买...');
    await _restorePurchases();
  }

  /// 清理资源
  void dispose() {
    print('🛒 清理内购服务');
    _subscription?.cancel();
  }
}
