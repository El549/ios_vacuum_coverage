# 责任、成本与阶段门禁

## 1. RACI / 缺口账本

没有姓名时以唯一组织角色作为责任主体；workspace owner 应在 kickoff 把角色映射到具体人员。角色无人承接即视为阻塞，不得由执行代理猜测身份或代替批准。

| 门禁 | Accountable owner | 当前状态 | 解除条件 | 阻断范围 |
|---|---|---|---|---|
| GitHub `main` 可 checkout | Repository admin | PASS：远端 `HEAD` 指向 `refs/heads/main`；仓库专用 Deploy Key 非 force 推送及 clean clone 自检均于 2026-08-27 通过 | 保持 Deploy Key 最小权限；后续协作启用分支保护 | 已解除 |
| 分支保护 | Repository admin | 未配置/未验证 | `main` 禁止 force push/删除；后续有测试后要求评审与状态检查 | 协作合并 |
| Codemagic 仓库连接 | Codemagic account owner | PASS：Personal Account app `6a8f35ff25a250a3a9686cb3` 已连接仓库，并载入 `main` 根目录 YAML | 保持仓库连接；首次 job 验证真实 clone 与 workflow | 已解除 |
| Codemagic 首次 job | Codemagic account owner | PASS：build `6a8f37ab1f98ea6f9e4aa137` 在 commit `7ed4c29…` 上 49 秒完成；artifact、工具链摘要和无签名状态均已核对 | 保留受控原始日志/artifact；后续重跑必须重新授权 | 已解除 |
| Codemagic 成本 | Workspace owner | PASS（本次 job）：Personal Account 免费 macOS 使用量 `0 / 500`，未启用付费订阅；只授权一次最多 15 分钟的无签名任务 | 仅按已授权 workflow 手动启动一次；出现订阅/付费提示立即停止 | 已解除本次 job |
| Apple membership/协议 | Apple Account Holder | PASS（2026-08-27 Account Holder 自述确认）：会员有效、无待接受协议 | 保持会员有效；新协议由 Account Holder 评审处理 | 已解除 |
| Bundle ID | Apple Account Holder/Admin | 候选 `com.el549.vacuumcoverage` | explicit App ID 已确认/注册；冲突则先评审替代值 | 真机工程配置 |
| Team ID / 本地签名 | Apple Admin + iOS lead | 未提供 | Team ID 只进入本地/受控 secret；开发者最小权限可签测试设备 | 真机实验 |
| CI 签名 secret | Release owner + Security owner | 本阶段不需要 | 到批准阶段使用专用 key、secret store、owner/轮换记录 | archive/发布 |
| 设备/硬件/场地 | Hardware owner + QA owner | 全部待现场确认 | `Docs/DEVICE_LAB.md` 每个槽位有真实记录且第二人复核 | PLAY-42 Phase 0 |
| 家庭空间隐私 | Privacy owner | 原则已定义，未签署 | 数据清单/保留/导出决定获批；无相机帧/家庭图像默认不变 | 实验数据保存 |

## 2. 费用确认点

默认设计不需要服务端、数据库、账号系统、域名或第三方运行时 SDK。下列动作在执行前必须由 workspace owner 明确确认费用范围：

- Codemagic 手动 job 或启用自动 trigger。
- Codemagic M4/专用/加速 runner、额外存储或更长构建时长。
- Apple Developer Program 新购/续费（仅 Account Holder 决定）。
- 购买/租赁 iPhone、吸尘器、支架、测量仪、打印或场地。
- 任何付费第三方监控、分析、崩溃、云存储或测试服务。

未确认时的默认动作是准备配置并停止，不通过试运行来“看看是否收费”。本仓库 Codemagic workflow 无自动触发，单次上限 15 分钟。

## 3. 发布确认点

以下每一步都是独立写操作，前一步的授权不能推导出后一步：

1. 创建 Apple App ID / App Store Connect record。
2. 创建 development/distribution certificate 或 provisioning profile。
3. 生成 signed archive。
4. 上传 internal TestFlight。
5. 邀请 external testers / 送 Beta Review。
6. 提交 App Store Review。
7. 在 App Store 公开上线。

PLAY-41 只允许步骤 1 中“确认/注册 explicit App ID”（由 Apple Admin 执行）以及无签名 Simulator job；其余默认禁止。

## 4. PLAY-41 退出检查

- [x] GitHub 默认分支 `main` 可从 clean environment checkout。
- [x] `bash Scripts/validate_bootstrap.sh` 在 clean checkout 通过。
- [x] Codemagic 已连接仓库，固定 workflow 对同一 commit 成功。
- [x] 证据页记录 Xcode、Swift、SDK、macOS、build ID/URL、commit 和结果。
- [ ] Apple Team owner、Bundle ID 结果、最小角色与 secret store 已确认。
- [ ] 三类 iPhone、两类吸尘器、支架、卡、测量和场地全部可用，或每个缺口具名到人并有到位时点/解除条件。
- [x] 费用、签名、TestFlight、App Store 与公开发布均无未授权动作。

未全部勾选时，工单保持 `in_progress` 或 `blocked`，不得标记已完成或推动后续阶段。
