interface PoemCardModel {
  id: string;
  title: string;
  author: string;
  symbol: string;
  accent: string;
  note?: string;
}

interface PoemLineExplainModel {
  title: string;
  meaning: string;
  symbol: string;
}

interface CategoryModel {
  title: string;
  count: string;
  symbol: string;
  accent: string;
}

interface RecentStudyModel {
  title: string;
  author: string;
  daysAgo: string;
  progress: number;
  accent: string;
  symbol: string;
}

interface BadgeModel {
  title: string;
  symbol: string;
  accent: string;
}

interface GrowthMetricModel {
  label: string;
  value: string;
  symbol: string;
}

class Palette {
  static readonly paper: string = '#F7F2E8';
  static readonly card: string = '#FFFCF6';
  static readonly cardAlt: string = '#F9F4EA';
  static readonly border: string = '#E8DCCB';
  static readonly ink: string = '#244137';
  static readonly muted: string = '#6F7E74';
  static readonly green: string = '#4F8A6B';
  static readonly greenSoft: string = '#DDEBDF';
  static readonly blue: string = '#8CB5D6';
  static readonly blueSoft: string = '#E3EFF8';
  static readonly orange: string = '#E98E57';
  static readonly orangeSoft: string = '#FBE7DA';
  static readonly gold: string = '#D6A34B';
  static readonly goldSoft: string = '#F6E9C8';
  static readonly peach: string = '#F2A287';
  static readonly peachSoft: string = '#FCE9DF';
  static readonly red: string = '#DA6F59';
  static readonly white: string = '#FFFFFF';
}

const FEATURED_POEM: PoemCardModel = {
  id: 'jingyesi',
  title: '静夜思',
  author: '李白',
  symbol: '月',
  accent: Palette.blue
};

const POPULAR_POEMS: PoemCardModel[] = [
  { id: 'jingyesi', title: '静夜思', author: '李白', symbol: '月', accent: Palette.blue },
  { id: 'dengguanquelou', title: '登鹳雀楼', author: '王之涣', symbol: '楼', accent: Palette.orange },
  { id: 'wanglushanpubu', title: '望庐山瀑布', author: '李白', symbol: '瀑', accent: Palette.green },
  { id: 'yonge', title: '咏鹅', author: '骆宾王', symbol: '鹅', accent: Palette.peach }
];

const FAVORITE_POEMS: PoemCardModel[] = [
  { id: 'jingyesi', title: '静夜思', author: '李白', symbol: '月', accent: Palette.blue },
  { id: 'dengguanquelou', title: '登鹳雀楼', author: '王之涣', symbol: '楼', accent: Palette.orange },
  { id: 'chunxiao', title: '春晓', author: '孟浩然', symbol: '春', accent: Palette.green },
  { id: 'wanglushanpubu', title: '望庐山瀑布', author: '李白', symbol: '瀑', accent: Palette.blue }
];

const CATEGORIES: CategoryModel[] = [
  { title: '唐诗', count: '24首诗', symbol: '唐', accent: Palette.green },
  { title: '咏月诗', count: '16首诗', symbol: '月', accent: Palette.blue },
  { title: '春天的诗', count: '18首诗', symbol: '春', accent: Palette.peach },
  { title: '山水田园', count: '20首诗', symbol: '山', accent: Palette.gold }
];

const RECENT_STUDIES: RecentStudyModel[] = [
  { title: '小池', author: '杨万里', daysAgo: '今天学习', progress: 4, accent: Palette.green, symbol: '荷' },
  { title: '清明', author: '杜牧', daysAgo: '昨天学习', progress: 3, accent: Palette.blue, symbol: '清' },
  { title: '山行', author: '杜牧', daysAgo: '2天前学习', progress: 3, accent: Palette.orange, symbol: '秋' },
  { title: '枫桥夜泊', author: '张继', daysAgo: '3天前学习', progress: 2, accent: Palette.peach, symbol: '夜' }
];

const EXPLAINS: PoemLineExplainModel[] = [
  { title: '床前明月光', meaning: '床前洒满了明亮的月光。', symbol: '1' },
  { title: '疑是地上霜', meaning: '我还以为是地上的秋霜。', symbol: '2' },
  { title: '举头望明月', meaning: '抬起头来，望向夜空中的明月。', symbol: '3' },
  { title: '低头思故乡', meaning: '低下头时，便想起远方的家乡。', symbol: '4' }
];

const WEEKLY_METRICS: GrowthMetricModel[] = [
  { label: '学习天数', value: '6天', symbol: '学' },
  { label: '学习古诗', value: '12首', symbol: '诗' },
  { label: '跟读练习', value: '28次', symbol: '读' },
  { label: '获得星星', value: '56颗', symbol: '星' }
];

const BADGES: BadgeModel[] = [
  { title: '勤学好问', symbol: '勤', accent: Palette.blue },
  { title: '诗词小达人', symbol: '诗', accent: Palette.orange },
  { title: '坚持不懈', symbol: '星', accent: Palette.peach },
  { title: '博古通今', symbol: '楼', accent: Palette.green },
  { title: '出口成章', symbol: '章', accent: Palette.red }
];

const PROFILE_BADGES: BadgeModel[] = [
  { title: '诗词小达人', symbol: '诗', accent: Palette.green },
  { title: '勤学好问', symbol: '勤', accent: Palette.blue },
  { title: '博古通今', symbol: '卷', accent: Palette.orange },
  { title: '坚持不懈', symbol: '星', accent: Palette.peach },
  { title: '出口成章', symbol: '章', accent: Palette.red }
];

const ACHIEVEMENTS: string[] = [
  '学完《登鹳雀楼》，获得10颗星星',
  '连续学习7天，获得20颗星星',
  '收藏诗词达到30首，获得30颗星星'
];

const WAVE_BARS: number[] = [10, 18, 28, 42, 24, 18, 32, 48, 34, 16, 12, 26, 38, 22, 14];
const GROWTH_VALUES: number[] = [10, 18, 26, 32, 36];
const CHALLENGE_CHOICES: string[] = ['明', '夜', '月', '故'];

@Entry
@Component
struct Index {
  private navStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;

  @Builder
  pageMap(name: string) {
    if (name === 'reading') {
      ReadingPracticePage({ stack: this.navStack });
    }

    if (name === 'challenge') {
      ChallengePage({ stack: this.navStack });
    }
  }

  @Builder
  tabBuilder(label: string, shortLabel: string, index: number, accent: string) {
    Column({ space: 6 }) {
      Row() {
        Text(shortLabel)
          .fontSize(12)
          .fontColor(this.currentIndex === index ? Palette.white : accent)
          .fontWeight(FontWeight.Bold);
      }
      .width(30)
      .height(30)
      .borderRadius(15)
      .backgroundColor(this.currentIndex === index ? accent : '#F0E7DA')
      .justifyContent(FlexAlign.Center);

      Text(label)
        .fontSize(11)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? Palette.ink : Palette.muted);
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    });
  }

  build() {
    Navigation(this.navStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
          TabContent() {
            HomePage({ stack: this.navStack });
          }
          .tabBar(this.tabBuilder('首页', '首', 0, Palette.green));

          TabContent() {
            CollectionPage();
          }
          .tabBar(this.tabBuilder('诗单', '诗', 1, Palette.orange));

          TabContent() {
            StudyPage({ stack: this.navStack });
          }
          .tabBar(this.tabBuilder('学习', '学', 2, Palette.blue));

          TabContent() {
            GrowthPage();
          }
          .tabBar(this.tabBuilder('成长', '成', 3, Palette.gold));

          TabContent() {
            ProfilePage();
          }
          .tabBar(this.tabBuilder('我的', '我', 4, Palette.peach));
        }
        .backgroundColor(Palette.paper)
        .barMode(BarMode.Fixed)
        .barHeight(78)
        .barWidth('100%')
        .width('100%')
        .height('100%')
        .scrollable(false)
        .onAnimationStart((index: number, targetIndex: number) => {
          this.currentIndex = targetIndex;
        });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Palette.paper);
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap);
  }
}

@Component
struct SectionHeader {
  title: string = '';
  subtitle: string = '';

  build() {
    Column({ space: 4 }) {
      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Palette.ink);

      Text(this.subtitle)
        .fontSize(12)
        .fontColor(Palette.muted);
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%');
  }
}

@Component
struct MonogramBadge {
  symbol: string = '';
  accent: string = Palette.green;
  badgeSize: number = 44;
  fontSize: number = 18;

  build() {
    Row() {
      Text(this.symbol)
        .fontSize(this.fontSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(Palette.white);
    }
    .width(this.badgeSize)
    .height(this.badgeSize)
    .borderRadius(this.badgeSize / 2)
    .backgroundColor(this.accent)
    .justifyContent(FlexAlign.Center);
  }
}

@Component
struct ProgressTrack {
  percent: number = 50;
  color: string = Palette.green;

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width('100%')
        .height(8)
        .borderRadius(8)
        .backgroundColor('#E8DED0');

      Row()
        .width(`${this.percent}%`)
        .height(8)
        .borderRadius(8)
        .backgroundColor(this.color);
    }
    .width('100%');
  }
}

@Component
struct PoemMiniCard {
  item: PoemCardModel = POPULAR_POEMS[0];

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.item.symbol)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.white);
      }
      .width(62)
      .height(62)
      .borderRadius(20)
      .backgroundColor(this.item.accent)
      .justifyContent(FlexAlign.Center);

      Text(this.item.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Palette.ink);

      Text(`[唐] ${this.item.author}`)
        .fontSize(10)
        .fontColor(Palette.muted);
    }
    .width(72)
    .padding({ top: 10, bottom: 8 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct FavoritePoemCard {
  item: PoemCardModel = FAVORITE_POEMS[0];

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.item.symbol)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.white);
      }
      .width(68)
      .height(68)
      .borderRadius(20)
      .backgroundColor(this.item.accent)
      .justifyContent(FlexAlign.Center);

      Text(this.item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Palette.ink);

      Text(`[唐] ${this.item.author}`)
        .fontSize(11)
        .fontColor(Palette.muted);

      Row() {
        Text('继续')
          .fontSize(10)
          .fontColor(Palette.green);
      }
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(12)
      .backgroundColor(Palette.greenSoft);
    }
    .width(74)
    .padding({ top: 14, bottom: 12 })
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct CategoryCard {
  item: CategoryModel = CATEGORIES[0];

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.item.symbol)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.white);
      }
      .width(56)
      .height(56)
      .borderRadius(18)
      .backgroundColor(this.item.accent)
      .justifyContent(FlexAlign.Center);

      Text(this.item.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Palette.ink);

      Text(this.item.count)
        .fontSize(12)
        .fontColor(Palette.muted);
    }
    .width('48%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border })
    .alignItems(HorizontalAlign.Start);
  }
}

@Component
struct ProgressDots {
  active: number = 3;
  total: number = 5;
  color: string = Palette.green;

  build() {
    Row({ space: 6 }) {
      ForEach(new Array(this.total).fill(0), (_dot: number, index: number) => {
        Row()
          .width(index < this.active ? 10 : 8)
          .height(8)
          .borderRadius(4)
          .backgroundColor(index < this.active ? this.color : '#E1D8CC');
      }, (_dot: number, index: number) => `${index}`);
    }
  }
}

@Component
struct RecentStudyRow {
  item: RecentStudyModel = RECENT_STUDIES[0];

  build() {
    Row({ space: 14 }) {
      Row() {
        Text(this.item.symbol)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.white);
      }
      .width(68)
      .height(68)
      .borderRadius(20)
      .backgroundColor(this.item.accent)
      .justifyContent(FlexAlign.Center);

      Column({ space: 8 }) {
        Text(this.item.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Palette.ink);

        Text(`[唐] ${this.item.author}`)
          .fontSize(12)
          .fontColor(Palette.muted);

        ProgressDots({ active: this.item.progress, total: 5, color: this.item.accent });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Column({ space: 10 }) {
        Text(this.item.daysAgo)
          .fontSize(12)
          .fontColor(Palette.muted);

        Row() {
          Text('▶')
            .fontSize(14)
            .fontColor(Palette.green)
            .fontWeight(FontWeight.Bold);
        }
        .width(42)
        .height(42)
        .borderRadius(21)
        .backgroundColor(Palette.greenSoft)
        .justifyContent(FlexAlign.Center);
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding(14)
    .borderRadius(22)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border });
  }
}

@Component
struct ExplainCard {
  item: PoemLineExplainModel = EXPLAINS[0];

  build() {
    Row({ space: 14 }) {
      Row() {
        Text(this.item.symbol)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.green);
      }
      .width(42)
      .height(42)
      .borderRadius(16)
      .backgroundColor(Palette.greenSoft)
      .justifyContent(FlexAlign.Center);

      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Palette.ink);

        Text(this.item.meaning)
          .fontSize(13)
          .fontColor(Palette.muted);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border });
  }
}

@Component
struct ActionCard {
  title: string = '';
  subtitle: string = '';
  symbol: string = '';
  accent: string = Palette.green;
  stack: NavPathStack = new NavPathStack();
  routeName: string = '';

  build() {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.ink);

        Text(this.subtitle)
          .fontSize(12)
          .fontColor(Palette.muted);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      MonogramBadge({ symbol: this.symbol, accent: this.accent, badgeSize: 48, fontSize: 20 });
    }
    .width('48%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border })
    .onClick(() => {
      if (this.routeName.length > 0) {
        this.stack.pushPathByName(this.routeName, undefined);
      }
    });
  }
}

@Component
struct BadgeToken {
  item: BadgeModel = BADGES[0];

  build() {
    Column({ space: 10 }) {
      MonogramBadge({ symbol: this.item.symbol, accent: this.item.accent, badgeSize: 46, fontSize: 18 });

      Text(this.item.title)
        .fontSize(12)
        .fontColor(Palette.ink)
        .maxLines(1);
    }
    .width(64)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct GrowthMetricCard {
  item: GrowthMetricModel = WEEKLY_METRICS[0];

  build() {
    Column({ space: 8 }) {
      MonogramBadge({ symbol: this.item.symbol, accent: Palette.green, badgeSize: 34, fontSize: 14 });

      Text(this.item.label)
        .fontSize(12)
        .fontColor(Palette.muted)
        .textAlign(TextAlign.Center);

      Text(this.item.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Palette.ink);
    }
    .width('24%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct ServiceRow {
  title: string = '';
  subtitle: string = '';
  symbol: string = '';

  build() {
    Row({ space: 12 }) {
      MonogramBadge({ symbol: this.symbol, accent: Palette.greenSoft, badgeSize: 36, fontSize: 14 });

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Palette.ink);

        Text(this.subtitle)
          .fontSize(11)
          .fontColor(Palette.muted);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Text('›')
        .fontSize(18)
        .fontColor(Palette.muted);
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 });
  }
}

@Component
struct DetailTopBar {
  title: string = '';
  trailing: string = '';
  stack: NavPathStack = new NavPathStack();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Palette.ink);

      Row() {
        Row() {
          Text('‹')
            .fontSize(22)
            .fontColor(Palette.green)
            .fontWeight(FontWeight.Bold);
        }
        .width(42)
        .height(42)
        .borderRadius(21)
        .backgroundColor(Palette.card)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.stack.pop();
        });

        Blank();

        if (this.trailing.length > 0) {
          Row() {
            Text(this.trailing)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.green);
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .borderRadius(18)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });
        }
      }
      .width('100%');
    }
    .width('100%');
  }
}

@Component
struct HomePage {
  stack: NavPathStack = new NavPathStack();

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 4 }) {
            Text('诗芽')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('小朋友的古诗词乐园')
              .fontSize(12)
              .fontColor(Palette.muted);
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          Row({ space: 8 }) {
            MonogramBadge({ symbol: '7', accent: Palette.gold, badgeSize: 36, fontSize: 14 });
            MonogramBadge({ symbol: '芽', accent: Palette.green, badgeSize: 36, fontSize: 14 });
          }
        }
        .width('100%');

        Row({ space: 16 }) {
          Column({ space: 12 }) {
            Text('明月松间照\n清泉石上流')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink)
              .lineHeight(34);

            Text('今晚和“小诗童”一起，在月色里读一首好诗。')
              .fontSize(13)
              .fontColor('#38594B');

            Row() {
              Text('今日诗境')
                .fontSize(11)
                .fontColor(Palette.white)
                .fontWeight(FontWeight.Medium);
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(Palette.green);
          }
          .width('60%')
          .alignItems(HorizontalAlign.Start);

          Column({ space: 12 }) {
            Row() {
              Text('月')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FCECC4');
            }
            .width(82)
            .height(82)
            .borderRadius(41)
            .backgroundColor('#6F98BF')
            .justifyContent(FlexAlign.Center);

            Row() {
              Text('古诗')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.white);
            }
            .width(60)
            .height(60)
            .borderRadius(20)
            .backgroundColor(Palette.green)
            .justifyContent(FlexAlign.Center);
          }
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .padding(20)
        .borderRadius(32)
        .backgroundColor('#B9D1EA');

        SectionHeader({ title: '今日推荐', subtitle: '学会一首诗，也读懂一份想念。' });

        Column({ space: 14 }) {
          Row({ space: 14 }) {
            Row() {
              Text('春')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.white);
            }
            .width(82)
            .height(82)
            .borderRadius(24)
            .backgroundColor(Palette.green)
            .justifyContent(FlexAlign.Center);

            Column({ space: 8 }) {
              Text('春晓')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);

              Text('[唐] 孟浩然')
                .fontSize(12)
                .fontColor(Palette.muted);

              Text('春眠不觉晓，处处闻啼鸟。')
                .fontSize(14)
                .fontColor(Palette.ink);

              Text('夜来风雨声，花落知多少。')
                .fontSize(14)
                .fontColor(Palette.ink);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%');

          Row() {
            Text('继续学习')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.green);
          }
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(18)
          .backgroundColor(Palette.greenSoft)
          .alignSelf(ItemAlign.End);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        SectionHeader({ title: '热门古诗', subtitle: '孩子最喜欢的四首启蒙古诗。' });

        Row({ space: 10 }) {
          ForEach(POPULAR_POEMS, (item: PoemCardModel) => {
            PoemMiniCard({ item: item });
          }, (item: PoemCardModel) => item.id);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(14)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        SectionHeader({ title: '学习进度', subtitle: '今天学习15分钟，连续学习7天。' });

        Column({ space: 14 }) {
          Row() {
            Column({ space: 6 }) {
              Text('本周目标')
                .fontSize(12)
                .fontColor(Palette.muted);

              Text('已完成 70%')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);
            }
            .alignItems(HorizontalAlign.Start);

            Blank();

            Column({ space: 8 }) {
              Text('7天')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.green);

              Text('30天')
                .fontSize(12)
                .fontColor(Palette.muted);
            }
            .alignItems(HorizontalAlign.End);
          }

          ProgressTrack({ percent: 70, color: Palette.green });

          Row({ space: 10 }) {
            Row() {
              Text('累计学习 7 天')
                .fontSize(12)
                .fontColor(Palette.green);
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(Palette.greenSoft);

            Row() {
              Text('已掌握 15 首')
                .fontSize(12)
                .fontColor(Palette.orange);
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(Palette.orangeSoft);
          }
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row({ space: 12 }) {
          ActionCard({
            title: '跟读练习',
            subtitle: '开口读诗，AI即时评分',
            symbol: '读',
            accent: Palette.green,
            stack: this.stack,
            routeName: 'reading'
          });

          ActionCard({
            title: '背诵闯关',
            subtitle: '补全诗句，解锁奖励',
            symbol: '关',
            accent: Palette.orange,
            stack: this.stack,
            routeName: 'challenge'
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor(Palette.paper);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.paper);
  }
}

@Component
struct CollectionPage {
  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 4 }) {
            Text('诗单')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('收藏好诗，随时学习。')
              .fontSize(12)
              .fontColor(Palette.muted);
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          Row({ space: 8 }) {
            MonogramBadge({ symbol: '搜', accent: Palette.green, badgeSize: 36, fontSize: 14 });
            MonogramBadge({ symbol: '列', accent: Palette.cardAlt, badgeSize: 36, fontSize: 14 });
          }
        }
        .width('100%');

        Row({ space: 12 }) {
          Column({ space: 10 }) {
            Text('我的收藏')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('把喜欢的诗词都装进自己的小书架。')
              .fontSize(12)
              .fontColor(Palette.muted);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          MonogramBadge({ symbol: '卷', accent: Palette.gold, badgeSize: 54, fontSize: 22 });
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row({ space: 8 }) {
          ForEach(FAVORITE_POEMS, (item: PoemCardModel) => {
            FavoritePoemCard({ item: item });
          }, (item: PoemCardModel) => item.id);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(12)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        SectionHeader({ title: '诗单分类', subtitle: '按主题慢慢收集，一首一首读熟。' });

        Row({ space: 12 }) {
          CategoryCard({ item: CATEGORIES[0] });
          CategoryCard({ item: CATEGORIES[1] });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Row({ space: 12 }) {
          CategoryCard({ item: CATEGORIES[2] });
          CategoryCard({ item: CATEGORIES[3] });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        SectionHeader({ title: '最近学习', subtitle: '继续你还没背熟的那些诗。' });

        Column({ space: 12 }) {
          ForEach(RECENT_STUDIES, (item: RecentStudyModel) => {
            RecentStudyRow({ item: item });
          }, (item: RecentStudyModel) => item.title);
        }
        .width('100%');
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor(Palette.paper);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.paper);
  }
}

@Component
struct StudyPage {
  stack: NavPathStack = new NavPathStack();

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('学诗')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          Blank();

          Row({ space: 8 }) {
            Row() {
              Text('收藏')
                .fontSize(12)
                .fontColor(Palette.orange);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(18)
            .backgroundColor(Palette.orangeSoft);

            Row() {
              Text('更多')
                .fontSize(12)
                .fontColor(Palette.green);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(18)
            .backgroundColor(Palette.greenSoft);
          }
        }
        .width('100%');

        Column({ space: 18 }) {
          Column({ space: 8 }) {
            Text(FEATURED_POEM.title)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(`唐 · ${FEATURED_POEM.author}`)
              .fontSize(14)
              .fontColor(Palette.muted);
          }

          Column({ space: 14 }) {
            Text('chuáng qián míng yuè guāng')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('床前明月光，')
              .fontSize(32)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Text('yí shì dì shàng shuāng')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('疑是地上霜。')
              .fontSize(32)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Text('jǔ tóu wàng míng yuè')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('举头望明月，')
              .fontSize(32)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Text('dī tóu sī gù xiāng')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('低头思故乡。')
              .fontSize(32)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);
          }
          .width('100%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.card);

          Row({ space: 12 }) {
            Row({ space: 8 }) {
              MonogramBadge({ symbol: '拼', accent: Palette.green, badgeSize: 36, fontSize: 14 });
              Text('拼音')
                .fontSize(15)
                .fontColor(Palette.ink);
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .borderRadius(22)
            .backgroundColor(Palette.greenSoft);

            Blank();

            Row({ space: 8 }) {
              Text('▶')
                .fontSize(14)
                .fontColor(Palette.white)
                .fontWeight(FontWeight.Bold);
              Text('朗读')
                .fontSize(15)
                .fontColor(Palette.white);
            }
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .borderRadius(22)
            .backgroundColor(Palette.green)
            .onClick(() => {
              this.stack.pushPathByName('reading', undefined);
            });
          }
          .width('100%');
        }
        .width('100%')
        .padding(20)
        .borderRadius(32)
        .backgroundColor(Palette.blueSoft)
        .border({ width: 1, color: Palette.border });

        SectionHeader({ title: '逐句讲解', subtitle: '一句一句听懂诗意，也更容易记住。' });

        Column({ space: 12 }) {
          ForEach(EXPLAINS, (item: PoemLineExplainModel) => {
            ExplainCard({ item: item });
          }, (item: PoemLineExplainModel) => item.title);
        }
        .width('100%');

        Row({ space: 10 }) {
          ActionCard({
            title: '背一背',
            subtitle: '补全诗句，完成闯关',
            symbol: '背',
            accent: Palette.orange,
            stack: this.stack,
            routeName: 'challenge'
          });
          ActionCard({
            title: '跟读练习',
            subtitle: '字词清晰度即时反馈',
            symbol: '读',
            accent: Palette.green,
            stack: this.stack,
            routeName: 'reading'
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor(Palette.paper);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.paper);
  }
}

@Component
struct GrowthPage {
  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('成长')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          Blank();

          MonogramBadge({ symbol: '↗', accent: Palette.greenSoft, badgeSize: 38, fontSize: 16 });
        }
        .width('100%');

        Row({ space: 16 }) {
          MonogramBadge({ symbol: '诗', accent: Palette.green, badgeSize: 64, fontSize: 26 });

          Column({ space: 8 }) {
            Text('太棒了！')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('你在本周又有新进步，继续加油，未来可期！')
              .fontSize(13)
              .fontColor(Palette.muted);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        SectionHeader({ title: '本周学习情况', subtitle: '5月12日 - 5月18日' });

        Row() {
          ForEach(WEEKLY_METRICS, (item: GrowthMetricModel) => {
            GrowthMetricCard({ item: item });
          }, (item: GrowthMetricModel) => item.label);
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border })
        .justifyContent(FlexAlign.SpaceAround);

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('已掌握古诗')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('36首')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.orange);

            Text('超过了90%的小朋友')
              .fontSize(12)
              .fontColor(Palette.muted);

            Row() {
              Text('查看我的诗单')
                .fontSize(12)
                .fontColor(Palette.green);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(16)
            .backgroundColor(Palette.greenSoft);
          }
          .width('48%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);

          Column({ space: 8 }) {
            Text('连续学习')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('12天')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.orange);

            Text('继续保持哦！')
              .fontSize(12)
              .fontColor(Palette.muted);

            Row({ space: 8 }) {
              Text('一 二 三 四 五 六 日')
                .fontSize(11)
                .fontColor(Palette.muted);
            }

            ProgressDots({ active: 6, total: 7, color: Palette.green });
          }
          .width('48%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Column({ space: 16 }) {
          Text('学习成长曲线')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          Row({ space: 10 }) {
            ForEach(GROWTH_VALUES, (item: number, index: number) => {
              Column({ space: 8 }) {
                Text(`${item}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(index === GROWTH_VALUES.length - 1 ? Palette.orange : Palette.green);

                Row()
                  .width(42)
                  .height(item * 2)
                  .borderRadius(20)
                  .backgroundColor(index === GROWTH_VALUES.length - 1 ? Palette.orangeSoft : Palette.greenSoft);

                Text(index === 0 ? '4周前' : index === 1 ? '3周前' : index === 2 ? '2周前' : index === 3 ? '1周前' : '本周')
                  .fontSize(10)
                  .fontColor(Palette.muted);
              }
              .justifyContent(FlexAlign.End);
              }, (item: number, index: number) => `${item}-${index}`);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Column({ space: 14 }) {
          Row() {
            Text('荣誉勋章')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Blank();

            Text('已获得 6 枚')
              .fontSize(14)
              .fontColor(Palette.muted);
          }
          .width('100%');

          Row({ space: 8 }) {
            ForEach(BADGES, (item: BadgeModel) => {
              BadgeToken({ item: item });
            }, (item: BadgeModel) => item.title);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row({ space: 16 }) {
          MonogramBadge({ symbol: '杯', accent: Palette.gold, badgeSize: 64, fontSize: 24 });

          Column({ space: 10 }) {
            Text('继续加油，向着更高的目标前进！')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('下一目标：掌握 50 首古诗')
              .fontSize(13)
              .fontColor(Palette.muted);

            ProgressTrack({ percent: 72, color: Palette.orange });

            Text('36 / 50')
              .fontSize(12)
              .fontColor(Palette.orange);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor(Palette.paper);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.paper);
  }
}

@Component
struct ProfilePage {
  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('我的')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          Blank();

          Row({ space: 8 }) {
            MonogramBadge({ symbol: '铃', accent: Palette.cardAlt, badgeSize: 36, fontSize: 14 });
            MonogramBadge({ symbol: '设', accent: Palette.cardAlt, badgeSize: 36, fontSize: 14 });
          }
        }
        .width('100%');

        Row({ space: 16 }) {
          MonogramBadge({ symbol: '芽', accent: Palette.green, badgeSize: 72, fontSize: 28 });

          Column({ space: 8 }) {
            Text('小诗童')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('ID: 20240520')
              .fontSize(12)
              .fontColor(Palette.muted);

            Row({ space: 8 }) {
              Row() {
                Text('Lv.28')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Palette.white);
              }
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(14)
              .backgroundColor(Palette.green);

              Text('诗词小达人')
                .fontSize(12)
                .fontColor(Palette.green);
            }

            ProgressTrack({ percent: 68, color: Palette.green });
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Column({ space: 6 }) {
            Text('今日学习')
              .fontSize(12)
              .fontColor(Palette.muted);

            Text('15分钟')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.orange);
          }
          .padding(14)
          .borderRadius(20)
          .backgroundColor(Palette.orangeSoft)
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row() {
          Column({ space: 6 }) {
            Text('已学古诗')
              .fontSize(12)
              .fontColor(Palette.muted);
            Text('128首')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);
          }
          .width('33%')
          .alignItems(HorizontalAlign.Center);

          Column({ space: 6 }) {
            Text('累计星星')
              .fontSize(12)
              .fontColor(Palette.muted);
            Text('560颗')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);
          }
          .width('33%')
          .alignItems(HorizontalAlign.Center);

          Column({ space: 6 }) {
            Text('累计天数')
              .fontSize(12)
              .fontColor(Palette.muted);
            Text('42天')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);
          }
          .width('33%')
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .padding({ top: 18, bottom: 18 })
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Column({ space: 14 }) {
          Row() {
            Text('我的勋章')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Blank();

            Text('全部勋章')
              .fontSize(12)
              .fontColor(Palette.muted);
          }
          .width('100%');

          Row({ space: 8 }) {
            ForEach(PROFILE_BADGES, (item: BadgeModel) => {
              BadgeToken({ item: item });
            }, (item: BadgeModel) => item.title);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Column({ space: 14 }) {
          Text('我的诗单')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          Row({ space: 8 }) {
            ForEach(FAVORITE_POEMS, (item: PoemCardModel) => {
              FavoritePoemCard({ item: item });
            }, (item: PoemCardModel) => item.id);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row({ space: 12 }) {
          Column({ space: 4 }) {
            ServiceRow({ title: '学习报告', subtitle: '查看本周进步', symbol: '报' });
            ServiceRow({ title: '成就墙', subtitle: '看看获得了什么', symbol: '星' });
            ServiceRow({ title: '跟读记录', subtitle: '找到最近朗读的诗', symbol: '读' });
            ServiceRow({ title: '收藏管理', subtitle: '整理自己的诗单', symbol: '藏' });
            ServiceRow({ title: '设置', subtitle: '通知与字体大小', symbol: '设' });
          }
          .width('58%')
          .padding(16)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });

          Column({ space: 12 }) {
            Column({ space: 8 }) {
              Text('家长中心')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);
              Text('查看孩子学习情况')
                .fontSize(12)
                .fontColor(Palette.muted);
            }
            .width('100%')
            .padding(16)
            .borderRadius(24)
            .backgroundColor(Palette.orangeSoft)
            .alignItems(HorizontalAlign.Start);

            Column({ space: 8 }) {
              Text('帮助与反馈')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);
              Text('有问题就来找我们')
                .fontSize(12)
                .fontColor(Palette.muted);
            }
            .width('100%')
            .padding(16)
            .borderRadius(24)
            .backgroundColor(Palette.blueSoft)
            .alignItems(HorizontalAlign.Start);
          }
          .width('38%');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Column({ space: 12 }) {
          Text('最近成就')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.ink);

          ForEach(ACHIEVEMENTS, (item: string, index: number) => {
            Row({ space: 12 }) {
              MonogramBadge({
                symbol: index === 0 ? '卷' : index === 1 ? '日' : '藏',
                accent: index === 0 ? Palette.orange : index === 1 ? Palette.green : Palette.blue,
                badgeSize: 36,
                fontSize: 14
              });

              Text(item)
                .fontSize(13)
                .fontColor(Palette.ink)
                .layoutWeight(1);
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 });
          }, (item: string) => item);
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor(Palette.paper);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Palette.paper);
  }
}

@Component
struct ReadingPracticePage {
  stack: NavPathStack = new NavPathStack();
  @State hasResult: boolean = false;
  @State isReading: boolean = false;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          DetailTopBar({ title: '跟读', trailing: '诗文', stack: this.stack });

          Column({ space: 12 }) {
            Text('当前诗句')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('jǔ tóu wàng míng yuè')
              .fontSize(14)
              .fontColor(Palette.green);

            Text('举头望明月，')
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('出自《静夜思》 · 唐 · 李白')
              .fontSize(13)
              .fontColor(Palette.muted);
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);

          Row({ space: 16 }) {
            MonogramBadge({ symbol: '芽', accent: Palette.green, badgeSize: 96, fontSize: 34 });

            Column({ space: 10 }) {
              Text(this.hasResult ? '读得真棒！' : '准备好了吗？')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);

              Text(this.hasResult ? '声音洪亮，吐字清晰。' : '点击下方按钮，AI会听你朗读。')
                .fontSize(13)
                .fontColor(Palette.muted);

              Row({ space: 8 }) {
                Text(this.hasResult ? '⭐ ⭐ ⭐ ⭐' : '跟读前先深呼吸一下')
                  .fontSize(14)
                  .fontColor(this.hasResult ? Palette.gold : Palette.green);
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.blueSoft)
          .border({ width: 1, color: Palette.border });

          Column({ space: 18 }) {
            Text(this.isReading ? 'AI 正在听你朗读…' : '朗读声纹')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Row({ space: 6 }) {
              ForEach(WAVE_BARS, (value: number, index: number) => {
                Row()
                  .width(8)
                  .height(this.isReading ? value : value / 2)
                  .borderRadius(8)
                  .backgroundColor(index % 2 === 0 ? Palette.green : '#8AD7C0');
              }, (value: number, index: number) => `${value}-${index}`);
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Bottom)
            .height(80);
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });

          Column({ space: 10 }) {
            Row() {
              Text(this.isReading ? '停' : '读')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.white);
            }
            .width(92)
            .height(92)
            .borderRadius(46)
            .backgroundColor(Palette.green)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.isReading = !this.isReading;
              this.hasResult = true;
            });

            Text(this.isReading ? '停止朗读' : '开始朗读')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center);

          Row({ space: 12 }) {
            Column({ space: 8 }) {
              Text('发音评分')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Text(this.hasResult ? '92分' : '--')
                .fontSize(38)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.orange);

              Text('太棒了！')
                .fontSize(12)
                .fontColor(Palette.orange);
            }
            .width('34%')
            .padding(18)
            .borderRadius(26)
            .backgroundColor(Palette.orangeSoft)
            .alignItems(HorizontalAlign.Start);

            Column({ space: 12 }) {
              Text('字词发音准确度')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Row({ space: 10 }) {
                ForEach(['举', '头', '望', '明', '月'], (item: string, index: number) => {
                  Column({ space: 6 }) {
                    Row() {
                      Text(item)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(index === 2 ? Palette.orange : Palette.green);
                    }
                    .width(34)
                    .height(34)
                    .borderRadius(17)
                    .backgroundColor(index === 2 ? Palette.orangeSoft : Palette.greenSoft)
                    .justifyContent(FlexAlign.Center);

                    Text(index === 2 ? '良好' : '优秀')
                      .fontSize(10)
                      .fontColor(index === 2 ? Palette.orange : Palette.green);
                  }
                }, (item: string) => item);
              }
            }
            .width('62%')
            .padding(18)
            .borderRadius(26)
            .backgroundColor(Palette.card)
            .border({ width: 1, color: Palette.border })
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          Column({ space: 12 }) {
            Text('星级奖励')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(this.hasResult ? '⭐ ⭐ ⭐ ⭐ ☆' : '完成一次朗读即可点亮星星')
              .fontSize(22)
              .fontColor(Palette.gold);

            Text('再得 1 颗星，解锁新的诗句卡片！')
              .fontSize(13)
              .fontColor(Palette.muted);
          }
          .width('100%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.goldSoft)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
        .backgroundColor(Palette.paper);
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true);
  }
}

@Component
struct ChallengePage {
  stack: NavPathStack = new NavPathStack();
  @State firstBlank: string = '';
  @State secondBlank: string = '';

  private isSuccess(): boolean {
    return this.firstBlank === '明' && this.secondBlank === '月';
  }

  private isFailed(): boolean {
    return this.firstBlank.length > 0 && this.secondBlank.length > 0 && !this.isSuccess();
  }

  private useWord(word: string): void {
    if (this.firstBlank === '' && !this.isWordUsed(word)) {
      this.firstBlank = word;
      return;
    }

    if (this.secondBlank === '' && !this.isWordUsed(word)) {
      this.secondBlank = word;
    }
  }

  private isWordUsed(word: string): boolean {
    return this.firstBlank === word || this.secondBlank === word;
  }

  private resetChallenge(): void {
    this.firstBlank = '';
    this.secondBlank = '';
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          DetailTopBar({ title: '闯关', trailing: '诗库', stack: this.stack });

          Row({ space: 10 }) {
            Row() {
              Text('第3关')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .borderRadius(20)
            .backgroundColor(Palette.card);

            Blank();

            ForEach([1, 2, 3, 4, 5], (item: number) => {
              Row() {
                Text(`${item}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(item <= 3 ? Palette.white : Palette.muted);
              }
              .width(34)
              .height(34)
              .borderRadius(17)
              .backgroundColor(item < 3 ? Palette.green : item === 3 ? Palette.orange : '#D9D5CE')
              .justifyContent(FlexAlign.Center);
            }, (item: number) => `${item}`);
          }
          .width('100%')
          .padding(16)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });

          Column({ space: 14 }) {
            Text('补全诗句')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text('把正确的字放回诗句里。')
              .fontSize(13)
              .fontColor(Palette.muted);

            Text('静夜思  ·  李白')
              .fontSize(16)
              .fontColor(Palette.green);

            Row({ space: 8 }) {
              Text('床前')
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Row() {
                Text(this.firstBlank.length > 0 ? this.firstBlank : ' ')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Palette.green);
              }
              .width(72)
              .height(46)
              .borderRadius(16)
              .backgroundColor(Palette.cardAlt)
              .border({ width: 1, color: Palette.green })
              .justifyContent(FlexAlign.Center);

              Text('光，')
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);
            }

            Text('疑是地上霜。')
              .fontSize(26)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Row({ space: 8 }) {
              Text('举头望')
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Row() {
                Text(this.secondBlank.length > 0 ? this.secondBlank : ' ')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Palette.green);
              }
              .width(72)
              .height(46)
              .borderRadius(16)
              .backgroundColor(Palette.cardAlt)
              .border({ width: 1, color: Palette.green })
              .justifyContent(FlexAlign.Center);

              Text('月，')
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);
            }

            Text('低头思故乡。')
              .fontSize(26)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);

          Row({ space: 12 }) {
            ForEach(CHALLENGE_CHOICES, (item: string) => {
              Row() {
                Text(item)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isWordUsed(item) ? Palette.muted : Palette.ink);
              }
              .width(72)
              .height(72)
              .borderRadius(22)
              .backgroundColor(this.isWordUsed(item) ? '#ECE6DC' : Palette.card)
              .border({ width: 1, color: this.isWordUsed(item) ? '#D1CABC' : Palette.border })
              .justifyContent(FlexAlign.Center)
              .opacity(this.isWordUsed(item) ? 0.6 : 1)
              .onClick(() => {
                this.useWord(item);
              });
            }, (item: string) => item);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          if (this.isSuccess()) {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                MonogramBadge({ symbol: '奖', accent: Palette.gold, badgeSize: 58, fontSize: 22 });

                Column({ space: 6 }) {
                  Text('挑战成功')
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.orange);

                  Text('真棒！你太厉害啦，获得一份闯关奖励。')
                    .fontSize(13)
                    .fontColor(Palette.muted);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }

              Row({ space: 12 }) {
                Row() {
                  Text('下一关')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.white);
                }
                .padding({ left: 18, right: 18, top: 12, bottom: 12 })
                .borderRadius(20)
                .backgroundColor(Palette.green);

                Row() {
                  Text('查看诗文')
                    .fontSize(16)
                    .fontColor(Palette.green);
                }
                .padding({ left: 18, right: 18, top: 12, bottom: 12 })
                .borderRadius(20)
                .backgroundColor(Palette.greenSoft);
              }
            }
            .width('100%')
            .padding(18)
            .borderRadius(28)
            .backgroundColor(Palette.orangeSoft)
            .border({ width: 1, color: Palette.border })
            .alignItems(HorizontalAlign.Start);
          }

          if (this.isFailed()) {
            Column({ space: 12 }) {
              Text('再想想看')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.red);

              Text('顺序有一点点不对，点击下面按钮重新试一次。')
                .fontSize(13)
                .fontColor(Palette.muted);

              Row() {
                Text('重来一次')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Palette.white);
              }
              .padding({ left: 18, right: 18, top: 12, bottom: 12 })
              .borderRadius(20)
              .backgroundColor(Palette.red)
              .onClick(() => {
                this.resetChallenge();
              });
            }
            .width('100%')
            .padding(18)
            .borderRadius(28)
            .backgroundColor(Palette.peachSoft)
            .border({ width: 1, color: Palette.border })
            .alignItems(HorizontalAlign.Start);
          }

          if (!this.isSuccess() && !this.isFailed()) {
            Row() {
              Text('选择两个字，补全诗句。')
                .fontSize(14)
                .fontColor(Palette.muted);
            }
            .width('100%')
            .padding(16)
            .borderRadius(20)
            .backgroundColor(Palette.card);
          }

          Row({ space: 12 }) {
            Row({ space: 8 }) {
              MonogramBadge({ symbol: '讲', accent: Palette.greenSoft, badgeSize: 36, fontSize: 14 });
              Text('诗意小讲堂')
                .fontSize(14)
                .fontColor(Palette.ink);
            }
            .width('48%')
            .padding(14)
            .borderRadius(22)
            .backgroundColor(Palette.card)
            .border({ width: 1, color: Palette.border });

            Row({ space: 8 }) {
              MonogramBadge({ symbol: '诗', accent: Palette.orangeSoft, badgeSize: 36, fontSize: 14 });
              Text('查看诗文')
                .fontSize(14)
                .fontColor(Palette.ink);
            }
            .width('48%')
            .padding(14)
            .borderRadius(22)
            .backgroundColor(Palette.card)
            .border({ width: 1, color: Palette.border });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
        .backgroundColor(Palette.paper);
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true);
  }
}
