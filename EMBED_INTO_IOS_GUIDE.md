# 将心陌嵌入宿主 iOS 项目指南

## 已生成的 Frameworks

位置：`Flutter/Release/Release/`

| Framework | 说明 |
|-----------|------|
| App.xcframework | Flutter 业务代码 |
| Flutter.xcframework | Flutter 引擎 |
| geocoding_ios.xcframework | 地理编码插件 |
| geolocator_apple.xcframework | 定位插件 |
| image_picker_ios.xcframework | 图片选择插件 |
| in_app_purchase_storekit.xcframework | 内购插件 |
| shared_preferences_foundation.xcframework | 本地存储插件 |

签名证书：Apple Distribution: Qingtan Information Technology (Lianyungang) Co., Ltd (D6HPYF3398)

---

## 集成步骤

### 1. 拷贝 Frameworks

将 `Flutter/Release/Release/` 下所有 `.xcframework` 拷贝到宿主项目目录，例如：

```
HostApp/
└── Frameworks/
    ├── App.xcframework
    ├── Flutter.xcframework
    ├── geocoding_ios.xcframework
    ├── geolocator_apple.xcframework
    ├── image_picker_ios.xcframework
    ├── in_app_purchase_storekit.xcframework
    └── shared_preferences_foundation.xcframework
```

### 2. 在 Xcode 中添加 Frameworks

1. 打开宿主项目的 `.xcodeproj`
2. 选中 Target → **General** 标签
3. 滚动到 **Frameworks, Libraries, and Embedded Content**
4. 点击 `+`，选择 **Add Other... → Add Files...**
5. 选中所有 `.xcframework`
6. 将所有 framework 的 Embed 设置为 **Embed & Sign**

### 3. 配置 Build Settings

在宿主项目 Target → **Build Settings** 中：

```
FRAMEWORK_SEARCH_PATHS = $(PROJECT_DIR)/Frameworks
```

### 4. 配置签名（关键！）

在宿主项目 Target → **Build Settings** → **Signing** 中：

```
CODE_SIGN_IDENTITY = Apple Distribution: Qingtan Information Technology (Lianyungang) Co., Ltd (D6HPYF3398)
DEVELOPMENT_TEAM = D6HPYF3398
CODE_SIGN_STYLE = Manual
PROVISIONING_PROFILE_SPECIFIER = <你的 Distribution Provisioning Profile 名称>
```

### 5. 添加 Run Script（确保提交 AppStore 时签名正确）

在宿主项目 Target → **Build Phases** → 点击 `+` → **New Run Script Phase**，添加以下脚本：

```bash
CERT="Apple Distribution: Qingtan Information Technology (Lianyungang) Co., Ltd (D6HPYF3398)"
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

find "$FRAMEWORKS_DIR" -name "*.framework" | while read framework; do
  # Flutter.xcframework 由官方预签名，跳过
  if [[ "$framework" == *"Flutter.framework"* ]]; then
    echo "⏭️ 跳过 Flutter.framework（官方签名）"
    continue
  fi
  codesign --force --sign "$CERT" \
           --timestamp \
           --options runtime \
           "$framework"
done
```

> ⚠️ 将此 Run Script 放在 **Embed Frameworks** 步骤之后

### 6. 在宿主 App 中启动 Flutter

在 `AppDelegate.swift` 中：

```swift
import UIKit
import Flutter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var flutterEngine: FlutterEngine?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 预热 Flutter Engine
        flutterEngine = FlutterEngine(name: "xinmo_engine")
        flutterEngine?.run()
        return true
    }
}
```

在需要展示 Flutter 页面的地方：

```swift
import Flutter

func showFlutterViewController() {
    guard let engine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine else { return }
    let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    flutterVC.modalPresentationStyle = .fullScreen
    present(flutterVC, animated: true)
}
```

---

## 重新打包流程（每次更新代码后）

```bash
# 1. 构建
flutter build ios-framework --release --output=Flutter/Release

# 2. 签名
./sign_frameworks.sh

# 3. 将 Flutter/Release/Release/ 下的 xcframework 替换到宿主项目
```

---

## 常见 AppStore 审核报错及解决

### 错误：`IPA contains unsigned frameworks`
→ 确保 Run Script 在 Embed Frameworks 之后执行，并且签名证书名称完全一致

### 错误：`Invalid Code Signing`
→ 检查 `DEVELOPMENT_TEAM = D6HPYF3398` 是否正确设置

### 错误：`Framework contains simulator slices`
→ 提交 AppStore 时只需要 `ios-arm64` 切片，可以用以下命令移除模拟器切片：

```bash
# 移除模拟器切片（仅在提交 AppStore 时需要）
for xcframework in Flutter/Release/Release/*.xcframework; do
  rm -rf "$xcframework/ios-arm64_x86_64-simulator"
done
```

> ⚠️ 移除后本地模拟器将无法运行，建议保留完整版本用于开发，提交时再处理

---

## 验证签名

```bash
# 验证单个 framework
codesign -dv Flutter/Release/Release/App.xcframework/ios-arm64/App.framework

# 期望输出包含：
# TeamIdentifier=D6HPYF3398
# Authority=Apple Distribution: Qingtan Information Technology (Lianyungang) Co., Ltd
```
