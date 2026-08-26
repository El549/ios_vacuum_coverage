# 开发与 Codemagic 环境

## 1. 固定工具链

本阶段锁定以下稳定组合：

| 层 | 固定值 | 验证方式 |
|---|---|---|
| Xcode | 26.6（17F113） | `xcodebuild -version` |
| Swift | compiler 6.3；后续项目使用 Swift 6 language mode | `xcrun swiftc --version` |
| iOS SDK | 26.5 | `xcrun --sdk iphonesimulator --show-sdk-version` |
| deployment target | iOS 18.0 | 后续 Xcode build settings 与 CI 参数 |
| Xcode 可安装 macOS | Tahoe 26.2–26.x | `sw_vers -productVersion` |
| Codemagic image | `mac_mini_m2` + `xcode: 26.6`；当前镜像记录为 macOS 26.5.1 | `codemagic.yaml` + job 日志 |

官方依据：

- [Apple：Xcode SDK 与系统要求](https://developer.apple.com/xcode/system-requirements)
- [Apple：Xcode 26.6 Release Notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26_6-release-notes)
- [Codemagic：Xcode 26.6.x 镜像规格](https://docs.codemagic.io/specs-macos/xcode-26-6/)
- [Codemagic：Xcode 更新策略](https://docs.codemagic.io/specs/xcode-update-policy/)

`latest` 与 `edge` 会漂移，门禁禁止使用。升级必须是独立评审：先核对两方官方页面，再同步修改 `README.md`、`codemagic.yaml`、`Scripts/ci_environment_check.sh` 和证据记录。

## 2. 本地节点与职责边界

Multica 当前执行节点为 Linux x86_64，不提供 Xcode、iOS SDK 或 Simulator。因此它只能验证仓库结构、脚本语法、YAML 与 secret 纪律，不能为 Apple 工具链或 ARKit 能力签字。

```bash
bash Scripts/validate_bootstrap.sh
```

真正的 Apple 工具链验证必须在固定 Codemagic image 或组织批准的 Apple Silicon Mac 上运行：

```bash
bash Scripts/ci_environment_check.sh
```

该脚本执行以下硬门禁：

1. 精确匹配 Xcode 26.6 / 17F113。
2. 验证 macOS 26.2+、Swift 6.3 与 iOS Simulator SDK/runtime 26.5。
3. 输出可审计的版本和 Simulator 设备列表。
4. 使用 `arm64-apple-ios18.0-simulator` target 编译最小 Swift module。
5. 全程不签名、不访问 Apple Team、不创建 archive、不上传任何内容。

## 3. Codemagic 连接和首次运行

根目录的 `codemagic.yaml` 符合官方 YAML 入口约定，workflow ID 为 `ios-environment-gate`。它故意不配置 `triggering`、secret groups、`ios_signing` 或 `publishing`，因此只能由有权限的人手动启动，不会因 push 自动消耗额度或发布。

官方参考：

- [Codemagic：使用 codemagic.yaml](https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/)
- [Codemagic：iOS Simulator 无签名构建](https://docs.codemagic.io/yaml-code-signing/ios-simulator-builds/)
- [Codemagic：Builds API](https://docs.codemagic.io/rest-api/builds/)

连接步骤（责任人：Codemagic team admin）：

1. 在 Codemagic 中连接 `https://github.com/El549/ios_vacuum_coverage`，只授予读取代码和必要 webhook 管理范围；本阶段不需要 Apple 集成。
2. 确认 app 使用仓库根目录 `codemagic.yaml`，默认分支选择 `main`。
3. 在启动前由 workspace owner 确认团队仍有可用免费额度或已明确批准本次 15 分钟上限；没有确认则不得点击 Start new build。
4. 手动选择 `main` 与 `ios-environment-gate`，记录 app ID、build ID、commit SHA、开始/完成时间和结果。
5. 下载 `build/evidence/**` 并把非敏感摘要填写到 `Docs/EVIDENCE/PLAY-41_ENVIRONMENT_GATE.md`；不要提交包含 token、个人路径或账户信息的完整日志。
6. 从 clean clone 在同一 commit 重跑一次，或在首次 job 中确认 Codemagic 实际执行的是全新 clone；只有可重复成功才解除门禁。

Codemagic YAML workflow ID 直接使用键名 `ios-environment-gate`。若通过 REST API 启动，还必须由管理员把 `CM_API_TOKEN` 放入调用方 secret store，并提供 app ID；token 永远不写入命令历史、工单或仓库。

## 4. clean checkout 验证

默认分支创建后，在新的空目录执行：

```bash
git clone https://github.com/El549/ios_vacuum_coverage.git
cd ios_vacuum_coverage
git switch main
bash Scripts/validate_bootstrap.sh
git status --short
```

验收：HEAD 可解析、脚本成功、`git status --short` 为空。macOS 验证者随后运行 `bash Scripts/ci_environment_check.sh`，生成物只能位于被忽略的 `build/evidence/`。

## 5. 何时可以升级或降级

- Apple/Codemagic 移除 26.6：Engineering owner 提交单独升级变更，附官方镜像证据和回滚版本。
- Xcode patch build 改变：先检查 release notes；不得放宽为 `26.6.*` 后静默继续。
- Simulator runtime 缺失：失败并查看镜像规格，不自动下载（可能产生额外时间/费用）。
- API 仅存在于 beta：不得纳入稳定基线，记录 replacement 或降级路径。
