# Apple 身份、权限、签名与密钥

## 1. 当前记录

| 项目 | 当前决定 / 状态 | 责任人 | 解除条件 |
|---|---|---|---|
| 产品名 / module | `Vacuum Coverage` / `VacuumCoverage` | Product owner | 后续产品评审可改名，但需同步工程与文档 |
| Bundle ID | 基线为 `com.el549.vacuumcoverage` | Apple Account Holder 或 Admin | 在 Apple Developer 中确认未占用并注册 explicit App ID；若冲突，先评审新值再改仓库 |
| Apple Team ID | **未提供，不得猜测或提交个人 Team** | Apple Account Holder 或 Admin | 从 Membership details 读取 10 字符 Team ID，写入个人 `Config/Signing.local.xcconfig` 或受控 CI secret，不写 Git/工单 |
| Apple Developer Program | **成员资格与协议状态未验证** | Account Holder | 会员有效，最新协议已接受 |
| App Store Connect record | 本阶段不创建 | Release owner | 到发布准备阶段且取得明确授权后再创建 |
| Codemagic Apple integration | 本阶段不连接 | Codemagic team admin + Release owner | 只有真机签名/archive 阶段在批准后配置 |

Apple 说明 explicit App ID 必须与 Xcode bundle ID 一致，注册要求 Account Holder 或 Admin：[Register an App ID](https://developer.apple.com/help/account/identifiers/register-an-app-id/)。角色和 Certificates, Identifiers & Profiles 权限以 Apple 当前矩阵为准：[Apple Developer Program Roles](https://developer.apple.com/help/account/access/roles)。

## 2. 最小权限责任表

| 动作 | 最小责任角色 / 授权 | 本阶段是否执行 |
|---|---|---|
| 接受协议、续费 | Account Holder | 否；只确认状态 |
| 注册/修改 explicit App ID | Account Holder 或 Admin | 仅在管理员确认 Bundle ID 后执行 |
| 本地真机开发签名 | Developer，并按组织设置获得 Certificates, Identifiers & Profiles / automatic signing 权限 | 否；等待设备实验 |
| 创建 team App Store Connect API key | Account Holder 或 Admin | 否 |
| Codemagic Developer Portal 集成 | Codemagic team admin + 已批准的 Apple key | 否 |
| 创建 distribution certificate/profile | Release owner 授权；Apple/Codemagic 角色满足官方要求 | 否，直到 release 阶段 |
| TestFlight/App Store 上传 | 明确的单次发布授权 + 合适 App Store Connect 角色 | 严禁 |

Apple API key 的官方入口与一次性下载/撤销规则见 [App Store Connect API](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api/)。Codemagic 建议为其创建专用 App Store Connect key，并在 Team integration 中保存 `.p8`：[Signing iOS apps](https://docs.codemagic.io/yaml-code-signing/signing-ios/)。

## 3. 本地开发签名

1. 复制 `Config/Signing.local.xcconfig.example` 为 `Config/Signing.local.xcconfig`。
2. Apple Admin 确认 explicit App ID 后保留或修改 `PRODUCT_BUNDLE_IDENTIFIER`。
3. 开发者只在本地覆盖文件填入组织 Team ID，并使用 Xcode automatic signing。
4. 覆盖文件已在 `.gitignore`；提交前运行 `bash Scripts/validate_bootstrap.sh`。
5. Simulator CI 永远传递/保持 `CODE_SIGNING_ALLOWED=NO`，缺 Team ID 不得阻断无签名测试。

后续 Xcode 工程应从 versioned base config 引入本地覆盖；不得把个人 Team ID 写进 `.pbxproj`。

## 4. 未来 CI 签名注入方案

本阶段的环境 job 不读取任何 secret。只有真机/archive 工作获得批准后，才采用以下方案：

- 首选：Codemagic Team integrations > Developer Portal 中保存专用 App Store Connect API key。
- 备选 secret group 名：`appstore_credentials`；变量名仅为 `APP_STORE_CONNECT_KEY_IDENTIFIER`、`APP_STORE_CONNECT_ISSUER_ID`、`APP_STORE_CONNECT_PRIVATE_KEY`。
- 所有敏感值在 Codemagic UI 标记为 Secret；`.p8` 只可下载一次，离线恢复副本进入组织密码库/密钥库。
- 手工 certificate/profile 仅在不能使用 portal integration 且经 Release/Security 批准时采用；`.p12` 密码与文件分开保存。
- workflow 只能引用 secret 名，不能打印值、执行 `env`、开启 `set -x` 或把 Keychain/配置文件收为 artifact。

Codemagic 环境变量组与 Secret 标记规则见 [Environment variable groups](https://docs.codemagic.io/partials/environment-variable-groups/)。

## 5. 轮换、泄露与撤销

- 每个 key 有 owner、用途、创建日、最后使用日和轮换/撤销记录，且只服务本项目 CI。
- 人员离开、权限变化、日志误打、设备丢失或疑似外泄时立即停止 workflow；Apple Admin 撤销 key/certificate，Codemagic Admin 删除 integration/secret，再审计构建 artifacts。
- 轮换使用新 key 验证成功后才撤销旧 key，除非发生泄露（此时先撤销）。
- 工单与仓库只能记录 Key ID 的非敏感引用是否已配置，不记录 Issuer ID、私钥内容、证书密码或 Team ID 值。

## 6. 发布边界

签名能力不等于发布授权。创建 archive、上传 TestFlight、创建外部测试组、提交审核或 App Store 上线分别需要明确确认。PLAY-41 只允许无签名 Simulator 环境验证；任何发布动作都超出本阶段范围。
