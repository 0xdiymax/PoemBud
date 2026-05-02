# MVP 实现记录

## 已完成范围

本次按 PRD 的单机版方向完成 MVP 主路径：

- 不接入 AI，不展示 AI 评测文案。
- 运行时不请求诗词网络接口。
- 接入本地 39 首诗词库。
- 生成并登记 39 首本地范读音频状态。
- 诗库支持搜索、分类列表、全部诗词、我的收藏。
- 学诗页支持动态诗文、拼音开关、收藏、赏析入口、范读。
- 跟读页改为本地录音练习，支持切换诗句、保存记录、回放最近录音。
- 闯关页改为基于任意本地诗词动态生成补字题。
- 成长报告改为使用本地学习记录聚合。
- 设置页支持拼音默认显示、声音开关、字号和清空本地数据。

## 关键文件

| 文件 | 说明 |
| --- | --- |
| `entry/src/main/ets/data/OfflinePoemLibrary.ets` | ArkTS 静态离线诗库，供页面直接 import。 |
| `entry/src/main/resources/rawfile/offline_poem_library.json` | 离线诗库源数据和授权来源说明。 |
| `entry/src/main/resources/rawfile/poem_*.m4a` | 本地范读音频文件。 |
| `entry/src/main/ets/model/PoemBudStore.ets` | 本地持久化状态、每日记录、每首诗进度、跟读历史、设置。 |
| `entry/src/main/ets/pages/Index.ets` | 页面、路由、搜索、分类、学习、跟读、闯关、报告。 |
| `entry/src/main/resources/base/profile/router_map.json` | 新增 `poemList` 和 `settings` 路由。 |

## 音频说明

现有 4 首诗保留项目内已有音频：

- `poem_jingyesi.m4a`
- `poem_dengguanquelou.m4a`
- `poem_wanglushanpubu.m4a`
- `poem_yonge.m4a`

其余 35 首使用 macOS 本地中文 TTS `Tingting` 生成 m4a 文件，作为开发期离线素材写入 rawfile。App 运行时只播放本地 rawfile，不调用网络或 AI 服务。

## 状态模型

新增本地状态：

- `dailyRecords`：每日学习分钟、打开诗词、听赏、跟读、闯关、星星。
- `poemProgressRecords`：每首诗打开次数、听赏次数、跟读次数、闯关进度和掌握状态。
- `reading.attemptHistory`：多条本地跟读记录。
- `settings`：拼音显示、声音开关、字号。

## 校验结果

- 离线诗库校验通过：39 首诗、27 个分类，无重复 ID，无缺失音频文件。
- `entry/src/main/resources/rawfile` 下已存在 39 个 `poem_*.m4a` 本地音频文件。
- 运行时代码未保留 AI 评测、评分、准确度、清晰度、智能等页面文案。
- `poemList`、`settings` 路由已写入 `router_map.json`。
- `Index.ets`、`PoemBudStore.ets`、`OfflinePoemLibrary.ets` 括号/引号基础结构检查通过。
- 当前机器缺少 `hvigor` 和 `ohpm` 命令，尚未执行完整 HarmonyOS 构建。

## 剩余风险

- 拼音由工具生成，正式上线前需要人工校对多音字和教材版本。
- 逐句讲解目前为规则化占位文案，需要后续补儿童可读释义。
- 闯关题为本地动态补字题，后续应补更稳定的人工题库。
- 本地 TTS 音频适合 MVP 验证，正式版本建议替换为真人范读或更高质量录音。
- 当前未在本机完成鸿蒙构建，因为环境缺少 `hvigor` 命令。
