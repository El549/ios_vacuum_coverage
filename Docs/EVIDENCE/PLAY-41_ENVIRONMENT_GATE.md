# PLAY-41 环境门禁证据

## 当前结论

状态：**Awaiting external confirmation**。仓库工件可在 Linux 本地验证，但 GitHub 远端初始化、Codemagic clone/job、Apple 身份与实物矩阵必须由对应外部 owner 提供真实证据后才能改为 Passed。

## 仓库基线

| 字段 | 记录 |
|---|---|
| Remote | `https://github.com/El549/ios_vacuum_coverage.git` |
| Default branch | `main`（待远端 HEAD 验证） |
| Bootstrap commit | 待实际 push 后填写完整 SHA |
| Clean clone verifier | Repository admin / independent reviewer |
| `validate_bootstrap.sh` | 本地结果待提交 SHA 固定后填写 |

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
| Cost authorization | 未确认；不得启动 |
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
