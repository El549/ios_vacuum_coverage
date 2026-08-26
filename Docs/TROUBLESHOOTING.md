# 环境门禁故障排查

## 1. 仓库没有默认分支或 `multica repo checkout` 报 no usable refs

症状：远端是空仓库，`HEAD` 没有指向任何 `refs/heads/*`。

处理：Repository admin 使用已认证的 GitHub 身份把本 bootstrap commit 推到 `main`，再在 GitHub 设置 `main` 为默认分支。之后执行：

```bash
git ls-remote --symref https://github.com/El549/ios_vacuum_coverage.git HEAD
```

期望首行包含 `ref: refs/heads/main HEAD`。不要删除 Multica 共享 bare cache，也不要伪造本地 remote ref；修复真源后重试 clean checkout。

## 2. GitHub push 报 authentication required / 403

- 这是权限或凭据缺口，不是分支名错误。
- 由 Repository admin 给执行身份最小写权限，或由管理员亲自推送附件中的 bootstrap commit。
- 不把 Personal Access Token 写进 remote URL、shell history、工单或仓库；优先 GitHub App/受控 credential helper。
- 权限就绪后先 `git push --dry-run origin main`，再执行实际 push。

## 3. Codemagic 找不到仓库或 YAML workflow

1. 确认 Codemagic app 指向精确仓库和 `main`。
2. 确认 `codemagic.yaml` 位于仓库根目录、文件名大小写正确。
3. 由连接仓库的 team admin 更新 GitHub App repository access/webhook。
4. 本地运行 `bash Scripts/validate_bootstrap.sh` 排除 YAML 结构错误。
5. 本阶段不要为了“让它跑”改用 Workflow Editor、自动 trigger 或签名 workflow；先修复 clone/YAML 真因。

## 4. Xcode / build / SDK 不匹配

- `xcodebuild -version` 必须为 26.6 / 17F113。
- `xcrun --sdk iphonesimulator --show-sdk-version` 必须为 26.5。
- Codemagic 应设置 `xcode: 26.6`，不能用 `latest`/`edge`。
- 若官方 patch 替换，先按 `Docs/ENVIRONMENT.md` 的升级流程更新全部断言和证据，不临时放宽脚本。

## 5. Simulator runtime 或设备列表为空

查看 `xcrun simctl list runtimes available` 与 `xcrun simctl list devices available`。若 iOS 26.5 runtime 不存在，先核对 [Codemagic Xcode 26.6 image](https://docs.codemagic.io/specs-macos/xcode-26-6/)；不要在共享 job 中自动下载 runtime。镜像问题由 Codemagic admin 处理，工具链升级走单独评审。

## 6. 无签名探针却请求 Team/profile

环境 workflow 只调用 `swiftc` 编译 Simulator module，正常情况下完全不需要签名。若日志出现 provisioning/certificate：

1. 停止 job，确认执行的是 `ios-environment-gate`。
2. 检查 YAML 是否被加入 `ios_signing`、secret group 或 archive/publishing step。
3. 不通过注入个人 Team/certificate 绕过；恢复本仓库基线再运行。

## 7. Secret 疑似进入 Git/日志/artifact

立即停止 workflow，不继续下载或转发 artifact。通知 Security owner 与 Apple/Codemagic admin：撤销相关 key/certificate、删除 integration/secret、审计历史构建与 Git 对象，再用新 key 验证。仅从最新提交删除文件不等于清除历史；历史重写属于破坏性操作，必须由 Repository admin 明确批准并协调所有 clone。

## 8. 真机、支架或场地缺口

在 `Docs/DEVICE_LAB.md` 对应行记录具体责任人、到位时点和客观解除条件。不得用 Simulator、另一台同型号设备、未经校验的打印卡或 ARKit 自身测量替代独立真值。支架松动、过热或安全风险必须停测。

## 9. 升级/求助时应附什么

仅附非敏感信息：commit SHA、Codemagic build ID/URL、workflow ID、Xcode/Swift/SDK/macOS 版本、失败步骤、错误末尾的最小片段和已执行的排查项。先删除 token、邮箱、个人路径、Team ID、UDID、序列号和家庭空间数据。
