#!/bin/bash

echo "🛒 StoreKit Testing 配置助手"
echo "================================"
echo ""

# 检查是否在 macOS 上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 此脚本仅支持 macOS"
    exit 1
fi

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 未检测到 Xcode，请先安装 Xcode"
    exit 1
fi

echo "✅ 检测到 Xcode"
echo ""

# 检查 StoreKit Configuration 文件
if [ -f "ios/Configuration.storekit" ]; then
    echo "✅ StoreKit Configuration 文件已存在"
else
    echo "❌ 未找到 StoreKit Configuration 文件"
    echo "   请确保 ios/Configuration.storekit 文件存在"
    exit 1
fi

echo ""
echo "📋 配置步骤："
echo ""
echo "1. 打开 Xcode 项目："
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2. 在 Xcode 中配置 StoreKit Testing："
echo "   - 选择 Product > Scheme > Edit Scheme..."
echo "   - 选择 Run > Options"
echo "   - 在 StoreKit Configuration 中选择 'Configuration.storekit'"
echo "   - 点击 Close"
echo ""
echo "3. 运行应用："
echo "   - 在 Xcode 中点击 Run 按钮"
echo "   - 或使用命令: flutter run"
echo ""
echo "4. 测试内购："
echo "   - 打开应用，进入'我的'页面"
echo "   - 点击'充值星钻'"
echo "   - 选择一个产品进行购买"
echo ""
echo "📖 详细文档请查看: STOREKIT_TESTING_GUIDE.md"
echo ""

# 询问是否打开 Xcode
read -p "是否现在打开 Xcode？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 正在打开 Xcode..."
    open ios/Runner.xcworkspace
    echo ""
    echo "✅ Xcode 已打开，请按照上述步骤配置 StoreKit Testing"
else
    echo "👋 稍后可以手动打开 Xcode 进行配置"
fi

echo ""
echo "🎉 配置助手完成！"
