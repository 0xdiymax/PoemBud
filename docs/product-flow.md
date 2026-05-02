# PoemBud 产品流程

## 1. 总体信息架构

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
  H --> H6["阅读练习"]

  L --> L1["我的收藏"]
  L --> L2["诗单分类"]
  L --> L3["最近学习"]

  S --> S1["诗文学习"]
  S1 --> S2["范读播放"]
  S1 --> S3["收藏"]
  S1 --> S4["逐句讲解"]
  S1 --> S5["背一背"]
  S1 --> S6["跟读练习"]

  M --> M1["本地学习档案"]
  M --> M2["统计数据"]
  M --> M3["我的勋章"]
  M --> M4["我的诗单"]
  M --> M5["学习报告"]
  M --> M6["服务入口"]

  H1 --> P["诗文详情"]
  H2 --> P
  H3 --> P
  L1 --> P
  L3 --> P
  H4 --> G["成长报告"]
  M5 --> G
  H5 --> R["跟读页"]
  S6 --> R
  S5 --> Q["闯关页"]
```

## 2. 学习主闭环

```mermaid
flowchart LR
  A["发现诗词"] --> B["进入学诗页"]
  B --> C["听范读"]
  B --> D["读讲解"]
  B --> E["收藏"]
  B --> F["跟读练习"]
  B --> G["背诵闯关"]

  C --> C1["记录听赏"]
  F --> F1["录音"]
  F1 --> F2["评分"]
  F2 --> F3["发放星星"]
  G --> G1["答题"]
  G1 --> G2{"是否正确"}
  G2 -->|正确| G3["发放闯关奖励"]
  G2 -->|错误| G4["重试/提示"]

  C1 --> H["更新学习进度"]
  F3 --> H
  G3 --> H
  E --> I["更新收藏"]
  H --> J["成长报告/我的页展示"]
```

当前实现中：

- “听范读”会调用 `recordPoemListening`，更新最近学习、已学诗、学习分钟和连续学习数据。
- “跟读练习”会调用录音工具保存文件，再调用 `recordReadingResult` 写入分数、星星和成就。
- “背诵闯关”会在答对后调用 `completeChallenge`，更新闯关星、掌握诗数和成就。
- “收藏”会调用 `toggleFavoritePoem`，更新本地收藏 ID 列表。

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
  E -->|"push challenge"| H["ChallengeRouteEntry"]
  E -->|"push reading"| I["ReadingRouteEntry"]
  C -->|"push reading"| I
  C -->|"push growth"| J["GrowthRouteEntry"]
  F -->|"push growth"| J
  C -->|"push info"| K["InfoRouteEntry"]
  D -->|"push info"| K
  E -->|"push info"| K
  F -->|"push info"| K

  G --> G1["StudyPage showTopBar=true"]
  H --> H1["ChallengePage"]
  I --> I1["ReadingPracticePage"]
  J --> J1["GrowthPage"]
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

  C --> Z["PoemBudStore.save"]
  D --> Z
  E --> Z
  F --> Z
  G --> Z
  H --> Z
  I --> Z

  Z --> Y["Preferences 持久化"]
  Y --> X["AppStorage/页面刷新"]
```

## 5. 目标流程与当前缺口

### 5.1 诗库检索流程

目标流程：

```mermaid
flowchart LR
  A["进入诗库"] --> B["搜索/筛选/分类"]
  B --> C["诗词列表"]
  C --> D["播放试听"]
  C --> E["进入学诗"]
  C --> F["收藏/取消收藏"]
```

当前状态：

- 只有分类卡和最近学习列表。
- 搜索、筛选、分类详情页、全部收藏页未实现。
- 分类点击进入通用说明页。

### 5.2 AI 跟读流程

目标流程：

```mermaid
sequenceDiagram
  participant U as 用户
  participant App as App
  participant Recorder as 录音模块
  participant AI as 发音评测服务
  participant Store as 本地数据

  U->>App: 点击开始朗读
  App->>Recorder: 请求麦克风并开始录音
  Recorder-->>App: 返回实时音量/录音状态
  U->>App: 点击停止
  App->>Recorder: 保存录音文件
  App->>AI: 提交音频、诗句文本、拼音
  AI-->>App: 返回总分、逐字分、建议
  App->>Store: 保存本次跟读记录
  App-->>U: 展示评分、逐字准确度、星级奖励
```

当前状态：

- 已有麦克风录音和本地文件保存。
- 没有真实 AI 评分，分数固定为 92。
- 没有真实实时波形，只有静态波形数组。
- 没有多次跟读历史。

### 5.3 闯关流程

目标流程：

```mermaid
flowchart TD
  A["进入闯关"] --> B["读取当前关卡"]
  B --> C["展示题目和奖励"]
  C --> D["用户作答"]
  D --> E{"答案正确"}
  E -->|是| F["发放星星/宝箱/卡片"]
  F --> G["解锁下一关"]
  G --> H["更新成长报告和成就"]
  E -->|否| I["提示错误"]
  I --> J["重试/使用提示"]
```

当前状态：

- 已支持补字题、正确/错误反馈和下一关。
- 题目与关卡没有真正绑定，下一关可能重复同题。
- 没有关卡上限、宝箱、解锁卡片、提示消耗等规则。

### 5.4 成长报告流程

目标流程：

```mermaid
flowchart LR
  A["学习行为"] --> B["每日记录"]
  B --> C["周报聚合"]
  B --> D["连续学习计算"]
  B --> E["掌握诗词计算"]
  B --> F["勋章规则计算"]
  C --> G["成长报告"]
  D --> G
  E --> G
  F --> G
  G --> H["分享/家长查看"]
```

当前状态：

- 成长页已经有展示框架。
- 统计主要来自聚合字段，没有每日历史。
- 周期、曲线、勋章、目标多数是静态或简化计算。

## 6. 建议落地流程

```mermaid
flowchart TD
  A["第一阶段：数据和内容"] --> B["拆分诗词内容库"]
  B --> C["补齐目标图诗词和分类"]
  C --> D["增加 per-poem 进度和每日记录"]

  D --> E["第二阶段：核心功能"]
  E --> F["诗库搜索/分类/全部列表"]
  E --> G["真实或可替换的跟读评测接口"]
  E --> H["闯关题库和关卡规则"]

  H --> I["第三阶段：体验增强"]
  I --> J["写一写/赏析/逐字拼音"]
  I --> K["勋章墙和奖励规则"]
  I --> L["家长中心/设置/帮助反馈"]

  L --> M["第四阶段：报告和运营"]
  M --> N["周报历史曲线"]
  M --> O["分享学习报告"]
  M --> P["复习推荐和提醒"]
```
