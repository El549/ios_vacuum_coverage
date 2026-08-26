# PLAY-41 环境门禁证据

## 当前结论

状态：**Blocked on external owners**。GitHub `main`、首次 Codemagic 无签名环境 job、Apple 会员与协议门禁已通过，explicit Bundle ID 名称也已获批；Apple Team、Bundle ID 注册、真机签名能力与实物矩阵仍必须由对应外部 owner 提供真实证据后才能改为 Passed。

## 仓库基线

| 字段 | 记录 |
|---|---|
| Remote | `https://github.com/El549/ios_vacuum_coverage.git` |
| Default branch | `main`；远端 `HEAD` 已验证指向 `refs/heads/main`，2026-08-27 |
| Bootstrap commit | `d637eed7fd261b78c051a593c07c4586bcb9a716`（root commit） |
| Published bootstrap baseline | `0b509ffe460df09d35f9925c3e816aeaee4a70dd` |
| Clean clone verifier | Codex · 美国节点，仓库专用 Deploy Key |
| `validate_bootstrap.sh` | PASS，本地与远端 clean clone，2026-08-27，Linux 5.15.0-142-generic x86_64 |
| Remote write probe | PASS：dry-run 后执行非 force push；GitHub Deploy Key 指纹 `SHA256:v1cl42C/Ad3nSTiTEV10b36nWDIDi7f74eG19bKn/i8` |

## Codemagic 首次 job

| 字段 | 记录 |
|---|---|
| Accountable owner | Codemagic account owner |
| App ID | `6a8f35ff25a250a3a9686cb3`（Personal Account） |
| Repository / YAML discovery | PASS：`main` 根目录 `codemagic.yaml` 已载入，2026-08-27 |
| Workflow ID | `ios-environment-gate` |
| Build ID / URL | [`6a8f37ab1f98ea6f9e4aa137`](https://codemagic.io/app/6a8f35ff25a250a3a9686cb3/build/6a8f37ab1f98ea6f9e4aa137) |
| Commit SHA | `7ed4c29f1861ede0f95e6d4f32c1da91a5203562` |
| Started / finished UTC | 2026-08-26 19:00–19:01 UTC（UI 显示总时长 49 秒；精确时间待原始 build metadata） |
| Machine | Mac mini M2 |
| Result | PASS：状态 `finished`；source fetch、repository baseline、unsigned Simulator probe 与 cleanup 均通过 |
| Artifact | PASS：`ios_vacuum_coverage_1_artifacts.zip`，14,702 bytes，SHA-256 `ae2a29ea6f132e1c283d64b42a00906a1d66f9f5c24c13ad99364456ad1e2e9e`；CRC、路径与 secret 扫描通过 |
| Cost authorization | 已确认并验证，2026-08-27：Personal Account 免费 macOS 使用量 `0 / 500`，页面显示 `Enable subscription`（未启用付费订阅）；仅允许运行一次最多 15 分钟任务，禁止付费、自动触发、签名和发布 |
| Signing / publishing | PASS：workflow 未配置 signing 或 publishing；未授权任何发布目标 |

附件中的 `build/evidence/environment.json`（SHA-256 `aed27bfaf2945481861052d004772dece0106c6b4f4cce496f472253844e0b81`）及配套文本证据确认：

```text
Xcode 26.6 (17F113)
macOS 26.5.1
Swift 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)
iOS Simulator SDK/runtime 26.5
iOS deployment target 18.0
CODE SIGNING disabled
```

Simulator 清单包含可用的 iOS 26.5 runtime 与 iPhone 17 系列设备；Swift module 产物证明 `arm64-apple-ios18.0-simulator` 编译步骤完成。完整原始日志和二进制 artifact 保留在 Codemagic/工单受控界面，不提交仓库。仓库只记录非敏感摘要与校验值。

## Apple 身份门禁

| 字段 | 当前状态 | owner / 解除条件 |
|---|---|---|
| Apple membership / agreements | PASS（Account Holder 于 2026-08-27 在 PLAY-41 工单自述确认）：会员有效、无待接受协议 | 保持会员有效；出现新协议时由 Account Holder 评审处理 |
| Team ID | 未提供 | Admin 确认，并只写本地/secret store |
| Explicit Bundle ID | 名称已批准：`com.el549.vacuumcoverage`（Account Holder 于 2026-08-27 在 PLAY-41 工单确认）；尚未注册 | Account Holder 注册 explicit App ID 并确认成功；若冲突则先评审替代值 |
| Developer device-signing role | 未验证 | iOS lead 获得最小所需权限 |
| CI signing secret store | 本阶段不启用 | Release/Security 批准后按文档配置 |

上述会员结论仅记录 Account Holder 的非敏感确认；仓库和工单均不保存 Apple Account、Team ID、验证码、证书、私钥或 provisioning profile。

## 硬件/场地门禁

以 `Docs/DEVICE_LAB.md` 为真源。当前两台无 LiDAR iPhone、一台 LiDAR Pro、两类吸尘器、支架、卡、测量工具和受控房间均未被现场确认。Hardware/QA owner 必须逐行补齐实际记录或给出具名责任人、到位时点与解除条件。

## 安全与范围确认

- [x] 仓库中不含 Apple/GitHub/Codemagic 密钥、证书、profile 或个人 Team ID。
- [x] Codemagic workflow 不自动触发、不加载 secret、不签名、不发布。
- [x] 未创建 App Store Connect record、TestFlight build 或 App Store submission。
- [x] 未执行付费动作。
- [ ] 外部 owner 已完成全部真实确认并复核证据。
