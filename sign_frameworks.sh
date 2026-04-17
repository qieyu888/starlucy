#!/bin/bash

# ============================================================
# Flutter Framework 签名脚本
# 签名证书: Apple Distribution: Qingtan Information Technology
#           (Lianyungang) Co., Ltd (D6HPYF3398)
# ============================================================

CERT_IDENTITY="Apple Distribution: Qingtan Information Technology (Lianyungang) Co., Ltd (D6HPYF3398)"
FRAMEWORKS_DIR="Flutter/Release/Release"

echo "🔐 开始签名 Flutter Frameworks..."
echo "📋 证书: $CERT_IDENTITY"
echo "📁 目录: $FRAMEWORKS_DIR"
echo ""

# 检查目录是否存在
if [ ! -d "$FRAMEWORKS_DIR" ]; then
  echo "❌ 错误: 找不到 $FRAMEWORKS_DIR"
  echo "请先运行: flutter build ios-framework --release --output=Flutter/Release"
  exit 1
fi

# 签名所有 xcframework
SIGNED=0
FAILED=0

for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
  name=$(basename "$xcframework")

  # Flutter.xcframework 由 Flutter 官方预签名，跳过
  if [ "$name" = "Flutter.xcframework" ]; then
    echo "⏭️  跳过: $name（Flutter 官方签名，无需重签）"
    echo ""
    continue
  fi

  echo "✍️  签名: $name"

  # 对 xcframework 内所有 .framework 签名
  find "$xcframework" -name "*.framework" | while read framework; do
    echo "   → $(basename $framework)"
    codesign --force --sign "$CERT_IDENTITY" \
             --timestamp \
             --options runtime \
             "$framework"
    if [ $? -ne 0 ]; then
      echo "   ❌ 签名失败: $framework"
    else
      echo "   ✅ 签名成功"
    fi
  done

  # 对 xcframework 本身签名
  codesign --force --sign "$CERT_IDENTITY" \
           --timestamp \
           --options runtime \
           "$xcframework"
  if [ $? -eq 0 ]; then
    echo "   ✅ $name 签名完成"
    SIGNED=$((SIGNED + 1))
  else
    echo "   ❌ $name 签名失败"
    FAILED=$((FAILED + 1))
  fi
  echo ""
done

echo "============================================"
echo "✅ 签名完成: $SIGNED 个"
if [ $FAILED -gt 0 ]; then
  echo "❌ 签名失败: $FAILED 个"
fi
echo "============================================"
echo ""
echo "📦 下一步: 将 Flutter/Release/Release/ 目录下的所有"
echo "   .xcframework 拷贝到宿主 iOS 项目中"
echo ""
echo "🔍 验证签名命令:"
echo "   codesign -dv --verbose=4 Flutter/Release/Release/App.xcframework"
