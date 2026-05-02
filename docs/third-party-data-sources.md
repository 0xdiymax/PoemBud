# 第三方数据源与授权说明

## 1. 结论

本项目单机版建议采用“开发期拉取、运行时内置”的方式使用诗词数据：

- 运行时不请求任何网络接口。
- 开发期从开源诗词数据仓库抽取内容。
- 抽取后转为本工程内的 `rawfile` 静态 JSON。
- App 发版时随包携带数据。

已新增离线数据文件：

`entry/src/main/resources/rawfile/offline_poem_library.json`

当前包含 39 首儿童启蒙常用诗词和 27 个本地分类。

## 2. 参考仓库判断

### 2.1 `liruifengv/we-drawing`

仓库地址：[https://github.com/liruifengv/we-drawing](https://github.com/liruifengv/we-drawing)

判断：

- 这个项目定位是“每天一句中国古诗词，生成 AI 图片”。
- README 写明诗词由“今日诗词”API 提供，图片由文生图 API 生成。
- 仓库本身不适合作为离线诗词数据源。
- license 为 MIT，但我们不需要复制它的代码。

结论：不采用该仓库作为 PoemBud 的诗词数据来源。

### 2.2 `meetqy/aspoem`

仓库地址：[https://github.com/meetqy/aspoem](https://github.com/meetqy/aspoem)

判断：

- 这是中文诗词阅读网站，支持拼音、注释、译文、赏析等能力。
- README 写明它需要先下载 `chinese-poetry` 仓库，再运行 `pnpm gen:markdown` 生成 Markdown。
- 当前仓库本身不是完整诗词数据仓库，更像站点和数据处理工具。
- README 标注遵守 AGPL-3.0，因此不建议复制它的业务代码或脚本进本项目。

结论：只参考“从 chinese-poetry 生成本地内容”的思路，不复制 `aspoem` 代码。

### 2.3 `chinese-poetry/chinese-poetry`

仓库地址：[https://github.com/chinese-poetry/chinese-poetry](https://github.com/chinese-poetry/chinese-poetry)

判断：

- 这是 `aspoem` README 指向的上游诗词数据源。
- 数据以 JSON 文件组织，适合开发期抽取为本地静态数据。
- license 为 MIT。

本次已参考：

- `蒙学/tangshisanbaishou.json`
- `蒙学/qianjiashi.json`
- `水墨唐诗/shuimotangshi.json`

并补充整理儿童启蒙常用诗词，统一输出到：

`entry/src/main/resources/rawfile/offline_poem_library.json`

## 3. 授权处理建议

如果后续继续使用 `chinese-poetry` 数据，建议在 App 内“设置 -> 关于 -> 开源许可”中展示：

```text
Poetry data partly derived from chinese-poetry/chinese-poetry.
Copyright (c) 2016 JackeyGao.
Licensed under the MIT License.
https://github.com/chinese-poetry/chinese-poetry
```

如果只使用少量人工整理的公版诗词正文，也建议保留数据来源说明，方便后续维护和审核。

## 4. 当前离线数据文件结构

```json
{
  "schemaVersion": 1,
  "runtimeMode": "offline",
  "sourceRepositories": [],
  "categories": [],
  "poems": []
}
```

每首诗字段：

| 字段 | 说明 |
| --- | --- |
| `id` | 本地唯一 ID |
| `title` | 诗名 |
| `subtitle` | 可选副标题，如“其二” |
| `dynasty` | 朝代 |
| `author` | 作者 |
| `lines` | 正文数组 |
| `pinyin` | 拼音数组，与 `lines` 一一对应 |
| `categories` | 分类 ID 数组 |
| `tags` | 当前等同于分类，便于后续搜索 |
| `difficulty` | 1-4 难度 |
| `gradeBand` | 建议学习阶段 |
| `source` | 数据来源标记 |
| `searchableText` | 本地搜索用聚合文本 |

## 5. 后续数据扩展流程

1. 从 MIT 数据源或人工整理表中选诗。
2. 转为简体正文。
3. 生成拼音。
4. 人工校对正文、标点、多音字。
5. 补分类、难度、年级建议。
6. 写入 `offline_poem_library.json`。
7. 更新开源许可说明。
8. 在 App 内通过本地加载器读取。

## 6. 数据风险

| 风险 | 说明 | 处理方式 |
| --- | --- | --- |
| 诗文版本差异 | 同一首诗可能有异文、教材版本不同。 | 以目标教材版本为准人工校对。 |
| 繁简转换差异 | 上游部分数据为繁体。 | 本地转简体后人工抽查。 |
| 拼音多音字 | 工具生成拼音可能不符合诗句语境。 | 正式上线前逐首校对。 |
| 授权遗漏 | MIT 数据源要求保留版权和许可声明。 | 在文档和 App 关于页保留 notice。 |
