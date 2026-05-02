# PoemBud 单机版产品流程

## 1. 信息架构

```mermaid
flowchart TD
  A["启动 App"] --> B["加载本地 PoemBudData"]
  B --> C["底部 Tab"]

  C --> H["首页"]
  C --> L["诗库"]
  C --> S["学习"]
  C --> M["我的"]

  H --> H1["轮播推荐"]
  H --> H2["今日推荐"]
  H --> H3["热门古诗"]
  H --> H4["学习进度"]
  H --> H5["跟读练习"]

  L --> L1["搜索"]
  L --> L2["全部诗词"]
  L --> L3["分类诗单"]
  L --> L4["我的收藏"]
  L --> L5["最近学习"]

  S --> S1["诗文学习"]
  S1 --> S2["本地范读"]
  S1 --> S3["拼音开关"]
  S1 --> S4["逐句赏析"]
  S1 --> S5["收藏"]
  S1 --> S6["背诵闯关"]
  S1 --> S7["跟读练习"]

  M --> M1["本地学习档案"]
  M --> M2["学习统计"]
  M --> M3["成就"]
  M --> M4["收藏管理"]
  M --> M5["学习报告"]
  M --> M6["设置"]

  H1 --> P["学诗页"]
  H2 --> P
  H3 --> P
  L2 --> P
  L3 --> PL["诗词列表"]
  L4 --> PL
  L5 --> P
  PL --> P
  H4 --> G["成长报告"]
  M5 --> G
  M6 --> ST["设置页"]
  H5 --> R["跟读页"]
  S6 --> Q["闯关页"]
  S7 --> R
```

## 2. 学习闭环

```mermaid
flowchart LR
  A["发现诗词"] --> B["进入学诗页"]
  B --> C["听本地范读"]
  B --> D["看拼音和赏析"]
  B --> E["收藏"]
  B --> F["本地跟读"]
  B --> G["背诵闯关"]

  C --> C1["记录听赏"]
  F --> F1["选择诗句"]
  F1 --> F2["录音"]
  F2 --> F3["保存本地录音"]
  F3 --> F4["按完成度发星星"]
  G --> G1["补字答题"]
  G1 --> G2{"是否正确"}
  G2 -->|正确| G3["解锁下一关"]
  G2 -->|错误| G4["重试"]

  C1 --> H["更新本地进度"]
  F4 --> H
  G3 --> H
  E --> I["更新收藏"]
  H --> J["成长报告和我的页"]
```

## 3. 路由流程

```mermaid
flowchart TD
  A["Index Navigation"] --> B["Tabs"]
  B --> C["HomePage"]
  B --> D["CollectionPage"]
  B --> E["StudyPage showTopBar=false"]
  B --> F["ProfilePage"]

  C -->|"push poem"| G["PoemRouteEntry"]
  D -->|"push poem"| G
  D -->|"push poemList"| L["PoemListRouteEntry"]
  F -->|"push poemList"| L
  E -->|"push challenge"| H["ChallengeRouteEntry"]
  E -->|"push reading"| I["ReadingRouteEntry"]
  C -->|"push reading"| I
  C -->|"push growth"| J["GrowthRouteEntry"]
  F -->|"push growth"| J
  F -->|"push settings"| S["SettingsRouteEntry"]
  C -->|"push info"| K["InfoRouteEntry"]
  D -->|"push info"| K
  E -->|"push info"| K
  F -->|"push info"| K

  G --> G1["StudyPage showTopBar=true"]
  L --> L1["PoemListPage"]
  H --> H1["ChallengePage"]
  I --> I1["ReadingPracticePage"]
  J --> J1["GrowthPage"]
  S --> S1["SettingsPage"]
  K --> K1["InfoPage"]
```

## 4. 数据写入流程

```mermaid
flowchart TD
  A["用户操作"] --> B{"操作类型"}

  B -->|"创建本地档案"| C["signInLocalProfile"]
  B -->|"打开诗文"| D["openPoemLearning"]
  B -->|"听范读"| E["recordPoemListening"]
  B -->|"收藏/取消收藏"| F["toggleFavoritePoem"]
  B -->|"完成跟读"| G["recordReadingResult"]
  B -->|"完成闯关"| H["completeChallenge"]
  B -->|"下一关"| I["advanceChallengeLevel"]
  B -->|"设置变更"| J["updateSettings"]
  B -->|"清空本地数据"| K["resetLocalStudyData"]

  C --> Z["PoemBudStore.save"]
  D --> Z
  E --> Z
  F --> Z
  G --> Z
  H --> Z
  I --> Z
  J --> Z
  K --> Z

  Z --> Y["Preferences 持久化"]
  Y --> X["AppStorage/页面刷新"]
```

## 5. 功能分层

| 优先级 | 已落地能力 |
| --- | --- |
| P0 | 离线诗库、本地范读、学诗详情、收藏、跟读录音、本地进度、无联网诗词接口 |
| P1 | 搜索、分类诗单、全部诗词、我的收藏、动态闯关、成长报告 |
| P2 | 拼音默认开关、声音开关、字号、清空本地学习数据、成就和诗单入口 |

## 6. 数据来源流程

```mermaid
flowchart LR
  A["开发期整理数据"] --> B["offline_poem_library.json"]
  B --> C["生成 OfflinePoemLibrary.ets"]
  C --> D["页面直接 import 静态诗库"]
  B --> E["rawfile 本地音频"]
  D --> F["运行时离线使用"]
  E --> F
```
