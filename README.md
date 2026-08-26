# iOS Vacuum Coverage

面向“iPhone 固定在手持吸尘器上、实时估算吸尘头几何覆盖范围”的原生 iOS 项目。

当前仓库仅完成 **PLAY-41 环境门禁基线**：工具链、无签名 CI 探针、权限/签名策略、硬件实验清单和故障排查。产品 Xcode 工程与业务代码须在环境门禁通过后由后续阶段创建。

## 不变量

- 产品只表达吸尘头的几何“经过/覆盖”，不宣称地面已经洁净。
- 无 LiDAR iPhone 是完整主路径；LiDAR 只能是可关闭增强。
- tracking 或重定位不可信时不得新增覆盖。
- 默认本地优先，不保存相机帧或家庭图像。
- 未获明确授权，不付费、不注入签名密钥、不上传 TestFlight/App Store、不公开发布构建产物。

## 固定基线

| 项目 | 基线 |
|---|---|
| Xcode | 26.6（build 17F113） |
| Swift compiler / language mode | 6.3 / Swift 6 |
| iOS SDK / Simulator runtime | 26.5 |
| 最低部署版本 | iOS 18.0 |
| Codemagic | `mac_mini_m2`，`xcode: 26.6`，仅手动无签名工作流 |

版本依据与升级规则见 [`Docs/ENVIRONMENT.md`](Docs/ENVIRONMENT.md)。

## 快速自检

在任意已安装 Git、Bash 与 Python 3 的 checkout 中运行：

```bash
bash Scripts/validate_bootstrap.sh
```

在符合基线的 macOS/Xcode 环境中再运行：

```bash
bash Scripts/ci_environment_check.sh
```

第二条命令会验证 Xcode/SDK/Swift/Simulator，并用 `iphonesimulator` SDK 编译一个最小 Swift 模块；不会请求 Apple Team、证书或 provisioning profile。

## 仓库结构

```text
Config/                         本地签名配置示例；真实覆盖文件不入库
Docs/                           环境、权限、硬件、责任与故障文档
Scripts/                        可复现的仓库及 macOS 环境自检
codemagic.yaml                  手动、无签名、无发布的环境门禁工作流
CONTRIBUTING.md                 分支、提交与评审规范
```

## 开始开发前

先查看 [`Docs/OWNERSHIP_AND_GATES.md`](Docs/OWNERSHIP_AND_GATES.md)。只有 Codemagic 首次 job、Apple 身份记录和硬件/场地缺口均达到其中解除条件，PLAY-41 才可关闭并进入后续开发。

## 文档入口

- [`Docs/ENVIRONMENT.md`](Docs/ENVIRONMENT.md)：工具链、Codemagic 连接与 clean-checkout 流程
- [`Docs/ACCESS_AND_SIGNING.md`](Docs/ACCESS_AND_SIGNING.md)：Bundle ID、角色、签名与 secret 注入方案
- [`Docs/DEVICE_LAB.md`](Docs/DEVICE_LAB.md)：真机、吸尘器、支架、标定卡、测量与场地矩阵
- [`Docs/OWNERSHIP_AND_GATES.md`](Docs/OWNERSHIP_AND_GATES.md)：责任人、成本/发布确认点和缺口解除条件
- [`Docs/TROUBLESHOOTING.md`](Docs/TROUBLESHOOTING.md)：仓库、Codemagic、Xcode、签名与硬件故障路径
- [`Docs/EVIDENCE/PLAY-41_ENVIRONMENT_GATE.md`](Docs/EVIDENCE/PLAY-41_ENVIRONMENT_GATE.md)：首次环境 job 的证据记录
