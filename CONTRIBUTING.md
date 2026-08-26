# Contributing

## 分支

- 默认分支：`main`。
- 日常分支：`feat/PLAY-<number>-<slug>`、`fix/PLAY-<number>-<slug>`、`docs/PLAY-<number>-<slug>` 或 `chore/PLAY-<number>-<slug>`。
- 一个分支只处理一个可审查目标；不得把密钥、设备 UDID、家庭地图、相机帧或原始实验视频加入 Git。
- 除仓库初始化外，不直接在 `main` 上开发；合并前保持与 `main` 可重放。

## 提交

使用 Conventional Commits 风格，并在主题或正文关联 Multica issue：

```text
feat(mapping): add boundary draft validator (PLAY-42)
fix(ci): reject unpinned Xcode image (PLAY-41)
docs(lab): record non-LiDAR device gate (PLAY-41)
```

主题使用祈使语气、控制在 72 字符左右。纯机械格式化与行为变更分开提交。禁止使用“WIP”“misc”“fix stuff”作为最终提交主题。

## 合并门禁

每次提交至少执行：

```bash
bash Scripts/validate_bootstrap.sh
```

涉及 Apple 工具链、CI 或 Xcode 配置时，还必须在固定 macOS/Xcode 环境执行：

```bash
bash Scripts/ci_environment_check.sh
```

PR/评审说明必须列出执行命令、结果、证据 commit 和受影响 ADR/门禁。Simulator 结果不得替代 ARKit、精度、热状态或真机能力结论。

## 版本和配置变更

- Xcode、Swift、SDK、deployment target 或 Codemagic image 的升级单独提交。
- 升级前同时核对 Apple 与 Codemagic 官方支持页，并更新 `Docs/ENVIRONMENT.md`、脚本断言及证据记录。
- `Team ID`、证书、profile、`.p8` 和密码只进入个人 Keychain 或受控 CI secret store；不得提交本地签名覆盖文件。
- 任何发布、TestFlight、App Store Connect 上传、付费 runner 或新增联网服务必须取得单独的明确授权。
