# PLAY-41 环境门禁证据

## 当前结论

状态：**Blocked on external owners**。GitHub `main` 已初始化并通过远端 clean clone 自检；Codemagic clone/job、Apple 身份与实物矩阵仍必须由对应外部 owner 提供真实证据后才能改为 Passed。

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
| Accountable owner | Codemagic team admin |
| App ID | 未连接 |
| Workflow ID | `ios-environment-gate` |
| Build ID / URL | 未运行 |
| Commit SHA | 未运行 |
| Started / finished UTC | 未运行 |
| Result | NOT RUN |
| Cost authorization | 已确认，2026-08-27：仅限个人账户剩余免费额度、单次最多 15 分钟；禁止付费、自动触发、签名和发布。账户类型/余额尚未验证，验证前不得启动 |
| Signing / publishing | 必须保持 `disabled` / `none` |

通过时附上 `build/evidence/environment.json` 的非敏感值，并确认：

```text
Xcode 26.6 (17F113)
Swift 6.3
iOS Simulator SDK/runtime 26.5
iOS deployment target 18.0
CODE SIGNING disabled
```

完整原始日志保留在 Codemagic 受控界面，不提交仓库。仓库证据只记录版本、ID、commit、时间、结果与失败码。

## Apple 身份门禁

| 字段 | 当前状态 | owner / 解除条件 |
|---|---|---|
| Apple membership / agreements | 未验证 | Account Holder 确认 active/current |
| Team ID | 未提供 | Admin 确认，并只写本地/secret store |
| Explicit Bundle ID | 候选 `com.el549.vacuumcoverage` | Admin 确认并注册或先评审替代值 |
| Developer device-signing role | 未验证 | iOS lead 获得最小所需权限 |
| CI signing secret store | 本阶段不启用 | Release/Security 批准后按文档配置 |

## 硬件/场地门禁

以 `Docs/DEVICE_LAB.md` 为真源。当前两台无 LiDAR iPhone、一台 LiDAR Pro、两类吸尘器、支架、卡、测量工具和受控房间均未被现场确认。Hardware/QA owner 必须逐行补齐实际记录或给出具名责任人、到位时点与解除条件。

## 安全与范围确认

- [x] 仓库中不含 Apple/GitHub/Codemagic 密钥、证书、profile 或个人 Team ID。
- [x] Codemagic workflow 不自动触发、不加载 secret、不签名、不发布。
- [x] 未创建 App Store Connect record、TestFlight build 或 App Store submission。
- [x] 未执行付费动作。
- [ ] 外部 owner 已完成全部真实确认并复核证据。
