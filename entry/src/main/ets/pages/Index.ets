import { common } from '@kit.AbilityKit';
import {
  getOfflineCategoryById,
  getOfflinePoemById,
  getOfflinePoemsByCategory,
  getRecommendedPoems,
  OFFLINE_POEM_CATEGORIES,
  OFFLINE_POEMS,
  OfflinePoem,
  searchOfflinePoems
} from '../data/OfflinePoemLibrary';
import {
  advanceChallengeLevel,
  completeChallenge,
  createDefaultPoemBudData,
  DailyStudyRecord,
  openPoemLearning,
  PoemBudData,
  PoemBudStore,
  recordPoemListening,
  recordReadingResult,
  resetLocalStudyData,
  signInLocalProfile,
  toggleFavoritePoem,
  updateSettings
} from '../model/PoemBudStore';
import { PoemAudioPlayer } from '../utils/PoemAudioPlayer';
import { PoemRecorder } from '../utils/PoemRecorder';

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

interface PoemContentModel {
  id: string;
  title: string;
  author: string;
  dynasty: string;
  lead: string;
  lines: string[];
  pinyin: string[];
  explains: PoemLineExplainModel[];
}

interface CategoryModel {
  id: string;
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

interface StudyMilestoneModel {
  label: string;
  value: string;
  days: number;
  outerColor: string;
  innerColor: string;
  ribbonColor: string;
}

class PoemRouteParam {
  poemId: string = 'jingyesi';

  constructor(poemId: string) {
    this.poemId = poemId;
  }
}

class InfoRouteParam {
  title: string = '';
  subtitle: string = '';
  content: string = '';

  constructor(title: string, subtitle: string, content: string) {
    this.title = title;
    this.subtitle = subtitle;
    this.content = content;
  }
}

class PoemListRouteParam {
  title: string = '';
  categoryId: string = '';
  query: string = '';

  constructor(title: string, categoryId: string, query: string = '') {
    this.title = title;
    this.categoryId = categoryId;
    this.query = query;
  }
}

function openNavDestination(stack: NavPathStack, name: string, param: Object): void {
  stack.pushPath({ name, param });
}

AppStorage.setOrCreate<PoemBudData>('poemBudData', createDefaultPoemBudData());
AppStorage.setOrCreate<string>('poemAudioPlaybackStatus', 'idle');
AppStorage.setOrCreate<string>('poemAudioPlaybackRawPath', '');

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
  id: 'chunxiao',
  title: '春晓',
  author: '孟浩然',
  symbol: '春',
  accent: Palette.green
};

function makePoemSymbol(title: string): string {
  return title.length > 0 ? title.substring(0, 1) : '诗';
}

function getPoemAccent(poem: OfflinePoem): string {
  if (poem.categories.includes('spring')) {
    return Palette.green;
  }
  if (poem.categories.includes('moon')) {
    return Palette.blue;
  }
  if (poem.categories.includes('summer')) {
    return Palette.peach;
  }
  if (poem.categories.includes('landscape')) {
    return Palette.orange;
  }
  return Palette.gold;
}

function getPoemLead(poem: OfflinePoem): string {
  if (poem.categories.includes('starter')) {
    return '启蒙必背短诗，适合每天听一听、读一读。';
  }
  if (poem.categories.includes('spring')) {
    return '春景清新明亮，适合孩子感受四时变化。';
  }
  if (poem.categories.includes('moon')) {
    return '明月意象鲜明，适合练习想象和情感表达。';
  }
  if (poem.categories.includes('landscape')) {
    return '山水画面开阔，适合训练朗读的节奏。';
  }
  return '读熟诗句，再试着说出诗里的画面。';
}

function buildExplainCards(poem: OfflinePoem): PoemLineExplainModel[] {
  return poem.lines.map((line: string, index: number): PoemLineExplainModel => {
    return {
      title: line,
      meaning: `先读熟这一句，再找一找诗里的关键词：${line.replace(/[，。！？；：、]/g, ' ')}`,
      symbol: `${index + 1}`
    };
  });
}

function offlinePoemToCard(poem: OfflinePoem): PoemCardModel {
  return {
    id: poem.id,
    title: poem.title,
    author: poem.author,
    symbol: makePoemSymbol(poem.title),
    accent: getPoemAccent(poem),
    note: poem.gradeBand
  };
}

function offlinePoemToContent(poem: OfflinePoem): PoemContentModel {
  return {
    id: poem.id,
    title: poem.title,
    author: poem.author,
    dynasty: poem.dynasty,
    lead: getPoemLead(poem),
    lines: poem.lines,
    pinyin: poem.pinyin,
    explains: buildExplainCards(poem)
  };
}

function categoryToModel(categoryId: string, symbol: string, accent: string): CategoryModel {
  const category = getOfflineCategoryById(categoryId) ?? OFFLINE_POEM_CATEGORIES[0];
  return {
    id: category.id,
    title: category.name,
    count: `${category.poemCount}首诗`,
    symbol,
    accent
  };
}

const POEM_CONTENTS: PoemContentModel[] = OFFLINE_POEMS.map((poem: OfflinePoem) => offlinePoemToContent(poem));
const POEM_SEQUENCE: string[] = OFFLINE_POEMS.map((poem: OfflinePoem) => poem.id);
const HOME_BANNER_POEM_IDS: string[] = ['chunxiao', 'jingyesi', 'dengguanquelou'];
const POPULAR_POEMS: PoemCardModel[] = getRecommendedPoems().slice(0, 4).map((poem: OfflinePoem) => offlinePoemToCard(poem));
const FAVORITE_POEMS: PoemCardModel[] = POPULAR_POEMS;
const CATEGORIES: CategoryModel[] = [
  categoryToModel('tang', '唐', Palette.green),
  categoryToModel('moon', '月', Palette.blue),
  categoryToModel('spring', '春', Palette.peach),
  categoryToModel('landscape', '山', Palette.gold)
];

const RECENT_STUDIES: RecentStudyModel[] = [
  { title: '小池', author: '杨万里', daysAgo: '今天学习', progress: 4, accent: Palette.green, symbol: '池' },
  { title: '清明', author: '杜牧', daysAgo: '昨天学习', progress: 3, accent: Palette.blue, symbol: '清' },
  { title: '山行', author: '杜牧', daysAgo: '2天前学习', progress: 3, accent: Palette.orange, symbol: '山' },
  { title: '枫桥夜泊', author: '张继', daysAgo: '3天前学习', progress: 2, accent: Palette.peach, symbol: '枫' }
];

const STUDY_MILESTONES: StudyMilestoneModel[] = [
  { label: '7天', value: '7', days: 7, outerColor: '#CA8851', innerColor: '#F3D7B0', ribbonColor: '#B86B3D' },
  { label: '14天', value: '14', days: 14, outerColor: '#B9C2CC', innerColor: '#EEF2F5', ribbonColor: '#98A2AD' },
  { label: '30天', value: '30', days: 30, outerColor: '#D7B24F', innerColor: '#F4E3A8', ribbonColor: '#C89128' }
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
function formatMonthDay(date: Date): string {
  return `${date.getMonth() + 1}月${date.getDate()}日`;
}

function getCurrentWeekRangeText(): string {
  const now = new Date();
  const day = now.getDay() === 0 ? 7 : now.getDay();
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day + 1);
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate() - day + 7);
  return `${formatMonthDay(start)} - ${formatMonthDay(end)}`;
}

function getGrowthValues(data: PoemBudData): number[] {
  const records = data.dailyRecords.slice(-28);
  if (records.length === 0) {
    return GROWTH_VALUES;
  }
  const values: number[] = [];
  for (let index = 0; index < 4; index += 1) {
    const group = records.slice(index * 7, index * 7 + 7);
    values.push(group.reduce((sum: number, item: DailyStudyRecord) => sum + item.openedPoemIds.length + item.readingCount + item.challengeCount, 0));
  }
  values.push(data.progress.learnedPoems);
  return values.map((item: number) => Math.max(1, item));
}

function buildWeeklyMetricModels(data: PoemBudData): GrowthMetricModel[] {
  return [
    { label: '学习天数', value: `${data.progress.weeklyStudyDays}天`, symbol: '学' },
    { label: '学习古诗', value: `${data.progress.weeklyPoems}首`, symbol: '诗' },
    { label: '跟读练习', value: `${data.progress.weeklyReadingCount}次`, symbol: '读' },
    { label: '闯关练习', value: `${data.progress.weeklyChallengeCount}次`, symbol: '关' },
    { label: '获得星星', value: `${data.progress.weeklyStars}颗`, symbol: '星' }
  ];
}

function getPoemContent(poemId: string): PoemContentModel {
  const poem = POEM_CONTENTS.find((item: PoemContentModel) => item.id === poemId);
  return poem ?? POEM_CONTENTS[0];
}

function getCurrentPoemId(data: PoemBudData): string {
  return data.study.currentPoemId.length > 0 ? data.study.currentPoemId : FEATURED_POEM.id;
}

function getPoemThumbnail(poemId: string): Resource {
  if (poemId === 'dengguanquelou') {
    return $r('app.media.thumb_dengguanquelou');
  }
  if (poemId === 'wanglushanpubu') {
    return $r('app.media.thumb_wanglushanpubu');
  }
  if (poemId === 'yonge') {
    return $r('app.media.thumb_yonge');
  }
  const poem = getOfflinePoemById(poemId);
  if (poem.categories.includes('spring') || poem.categories.includes('summer')) {
    return $r('app.media.thumb_yonge');
  }
  if (poem.categories.includes('landscape')) {
    return $r('app.media.thumb_wanglushanpubu');
  }
  if (poem.categories.includes('moon')) {
    return $r('app.media.thumb_jingyesi');
  }
  return $r('app.media.thumb_jingyesi');
}

function getPoemBanner(poemId: string): Resource {
  if (poemId === 'dengguanquelou') {
    return $r('app.media.banner_dengguanquelou');
  }
  if (poemId === 'wanglushanpubu') {
    return $r('app.media.banner_wanglushanpubu');
  }
  if (poemId === 'yonge') {
    return $r('app.media.banner_yonge');
  }
  const poem = getOfflinePoemById(poemId);
  if (poem.categories.includes('spring') || poem.categories.includes('summer')) {
    return $r('app.media.banner_yonge');
  }
  if (poem.categories.includes('landscape')) {
    return $r('app.media.banner_wanglushanpubu');
  }
  if (poem.categories.includes('moon')) {
    return $r('app.media.banner_jingyesi');
  }
  return $r('app.media.banner_jingyesi');
}

function getPoemMiniCardIcon(poemId: string): Resource {
  return getPoemThumbnail(poemId);
}

function getPoemIdByTitle(title: string): string {
  const found = OFFLINE_POEMS.find((item: OfflinePoem) => item.title === title);
  return found?.id ?? FEATURED_POEM.id;
}

function getPoemCard(poemId: string): PoemCardModel {
  return offlinePoemToCard(getOfflinePoemById(poemId));
}

function getNextPoemId(poemId: string): string {
  const currentIndex = POEM_SEQUENCE.indexOf(poemId);
  if (currentIndex < 0 || currentIndex === POEM_SEQUENCE.length - 1) {
    return POEM_SEQUENCE[0];
  }
  return POEM_SEQUENCE[currentIndex + 1];
}

function getFavoriteCards(data: PoemBudData): PoemCardModel[] {
  if (data.collection.favoritePoemIds.length === 0) {
    return [];
  }
  return data.collection.favoritePoemIds.map((item: string) => getPoemCard(item));
}

function isFavoritePoem(data: PoemBudData, poemId: string): boolean {
  return data.collection.favoritePoemIds.includes(poemId);
}

function getRecentStudyRows(data: PoemBudData): RecentStudyModel[] {
  if (data.collection.recentPoemIds.length === 0) {
    return RECENT_STUDIES;
  }

  return data.collection.recentPoemIds.map((item: string, index: number) => {
    const poem = getPoemCard(item);
    const row: RecentStudyModel = {
      title: poem.title,
      author: poem.author,
      daysAgo: index === 0 ? '刚刚学习' : index === 1 ? '上次学习' : `${index + 1} 次前学习`,
      progress: Math.min(5, index + 2),
      accent: poem.accent,
      symbol: poem.symbol
    };
    return row;
  });
}

function getActionIcon(routeName: string): Resource {
  if (routeName === 'reading') {
    return $r('app.media.icon_follow_read');
  }
  if (routeName === 'poem') {
    return $r('app.media.icon_reading');
  }
  if (routeName === 'challenge') {
    return $r('app.media.icon_challenge');
  }
  return $r('app.media.icon_today');
}

function getPoemAudioRawFile(poemId: string): string {
  return getOfflinePoemById(poemId).audioRawFile;
}

function hasPoemAudio(poemId: string): boolean {
  const poem = getOfflinePoemById(poemId);
  return poem.audioAvailable && poem.audioRawFile.length > 0;
}

function getActivePoemAudioStatus(rawPath: string, playbackRawPath: string, playbackStatus: string): string {
  if (rawPath !== playbackRawPath) {
    return 'idle';
  }
  return playbackStatus;
}

function getPoemAudioButtonLabel(status: string, idleLabel: string): string {
  if (status === 'playing') {
    return '暂停';
  }
  if (status === 'paused') {
    return '继续';
  }
  if (status === 'loading') {
    return '加载中';
  }
  return idleLabel;
}

function getPoemAudioButtonIcon(status: string): string {
  if (status === 'playing') {
    return 'Ⅱ';
  }
  return '▶';
}

function getPoemAudioButtonColor(status: string): string {
  if (status === 'playing') {
    return Palette.orange;
  }
  if (status === 'paused') {
    return Palette.gold;
  }
  if (status === 'loading') {
    return '#9AA79E';
  }
  return Palette.green;
}

function getPoemAudioButtonBorderColor(status: string): string {
  if (status === 'playing') {
    return '#D77F4A';
  }
  if (status === 'paused') {
    return '#BE9348';
  }
  if (status === 'loading') {
    return '#85918A';
  }
  return '#7D9776';
}

function getStudyProgressDays(data: PoemBudData): number {
  return Math.max(data.progress.totalStudyDays, data.progress.streakDays);
}

function getStudyProgressPercent(studyDays: number): number {
  const days = Math.max(0, studyDays);
  if (days <= 0) {
    return 0;
  }
  if (days < 7) {
    return days / 7 * 33;
  }
  if (days < 14) {
    return 33 + (days - 7) / 7 * 33;
  }
  if (days < 30) {
    return 66 + (days - 14) / 16 * 34;
  }
  return 100;
}

function getStudyProgressHint(studyDays: number): string {
  const days = Math.max(0, studyDays);
  if (days === 0) {
    return '开始今日学习';
  }
  for (let index = 0; index < STUDY_MILESTONES.length; index += 1) {
    const milestone = STUDY_MILESTONES[index];
    if (days < milestone.days) {
      return `距${milestone.label}还差${milestone.days - days}天`;
    }
  }
  return '已点亮全部勋章';
}

interface ChallengeQuestionModel {
  poemId: string;
  title: string;
  author: string;
  prompt: string;
  prefixA: string;
  suffixA: string;
  answerA: string;
  middleLine: string;
  prefixB: string;
  suffixB: string;
  answerB: string;
  choices: string[];
}

interface BlankLineModel {
  prefix: string;
  answer: string;
  suffix: string;
}

function getChineseCharIndexes(line: string): number[] {
  const indexes: number[] = [];
  const chars = line.split('');
  chars.forEach((char: string, index: number) => {
    if (/[\u4e00-\u9fa5]/.test(char)) {
      indexes.push(index);
    }
  });
  return indexes;
}

function makeBlankLine(line: string, rank: number): BlankLineModel {
  const indexes = getChineseCharIndexes(line);
  if (indexes.length === 0) {
    return { prefix: line, answer: '', suffix: '' };
  }
  const target = indexes[Math.min(Math.max(rank, 0), indexes.length - 1)];
  return {
    prefix: line.substring(0, target),
    answer: line.substring(target, target + 1),
    suffix: line.substring(target + 1)
  };
}

function buildChallengeChoices(poem: OfflinePoem, answerA: string, answerB: string): string[] {
  const choices: string[] = [answerA, answerB];
  poem.lines.join('').split('').forEach((char: string) => {
    if (/[\u4e00-\u9fa5]/.test(char) && !choices.includes(char) && choices.length < 4) {
      choices.push(char);
    }
  });
  ['诗', '山', '月', '春'].forEach((char: string) => {
    if (!choices.includes(char) && choices.length < 4) {
      choices.push(char);
    }
  });
  return choices;
}

function getChallengeQuestion(poemId: string): ChallengeQuestionModel {
  const poem = getOfflinePoemById(poemId);
  const lineA = poem.lines[0];
  const lineB = poem.lines.length > 1 ? poem.lines[poem.lines.length - 1] : poem.lines[0];
  const blankA = makeBlankLine(lineA, 2);
  const blankB = makeBlankLine(lineB, Math.max(0, getChineseCharIndexes(lineB).length - 2));
  return {
    poemId: poem.id,
    title: poem.title,
    author: poem.author,
    prompt: '把正确的字放回诗句里。',
    prefixA: blankA.prefix,
    suffixA: blankA.suffix,
    answerA: blankA.answer,
    middleLine: poem.lines.length > 2 ? poem.lines[1] : getPoemLead(poem),
    prefixB: blankB.prefix,
    suffixB: blankB.suffix,
    answerB: blankB.answer,
    choices: buildChallengeChoices(poem, blankA.answer, blankB.answer)
  };
}

@Entry
@Component
struct Index {
  private navStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();

  aboutToAppear(): void {
    this.loadPersistedData();
  }

  private async loadPersistedData(): Promise<void> {
    try {
      this.data = await PoemBudStore.load();
      console.info(`[PoemBud] load profile loggedIn=${this.data.profile.loggedIn} name=${this.data.profile.name} level=${this.data.profile.level} progress=${this.data.progress.weeklyGoalPercent}`);
    } catch (err) {
      console.error(`Failed to load poem data: ${JSON.stringify(err)}`);
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
            HomePage({ stack: this.navStack, data: $data });
          }
          .tabBar(this.tabBuilder('首页', '首', 0, Palette.green));

          TabContent() {
            CollectionPage({ stack: this.navStack, data: $data });
          }
          .tabBar(this.tabBuilder('诗库', '诗', 1, Palette.orange));

          TabContent() {
            StudyPage({ stack: this.navStack, data: $data, poemId: getCurrentPoemId(this.data), showTopBar: false });
          }
          .tabBar(this.tabBuilder('学习', '学', 2, Palette.blue));

          TabContent() {
            ProfilePage({ stack: this.navStack, data: $data });
          }
          .tabBar(this.tabBuilder('我的', '我', 3, Palette.peach));
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
    .mode(NavigationMode.Stack);
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
struct PlaqueTitleHeader {
  title: string = '';
  image: Resource = $r('app.media.title_today_recommend_v2');
  textColor: string = '#F8F4EA';
  titleWidth: number = 92;
  rightInset: number = 25;

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.image)
          .width(160)
          .height(40)
          .objectFit(ImageFit.Fill);

        Row() {
          Text(this.title)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor)
            .textAlign(TextAlign.Center);
        }
        .width(this.titleWidth)
        .height(24)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({ right: this.rightInset });
      }
      .width(160)
      .height(40);
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
struct StudyMilestoneBadge {
  milestone: StudyMilestoneModel = STUDY_MILESTONES[0];
  reached: boolean = false;

  build() {
    Column({ space: 3 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Row({ space: 4 }) {
          Column()
            .width(7)
            .height(10)
            .borderRadius(3)
            .backgroundColor(this.reached ? this.milestone.ribbonColor : '#DED2C1');

          Column()
            .width(7)
            .height(10)
            .borderRadius(3)
            .backgroundColor(this.reached ? this.milestone.ribbonColor : '#DED2C1');
        }
        .margin({ top: 20 });

        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(30)
            .height(30)
            .borderRadius(15)
            .backgroundColor(this.reached ? this.milestone.outerColor : '#E5DAC7');

          Row()
            .width(22)
            .height(22)
            .borderRadius(11)
            .backgroundColor(this.reached ? this.milestone.innerColor : '#F6EFE3');

          Text(this.milestone.value)
            .fontSize(this.milestone.value.length > 1 ? 9 : 11)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.reached ? '#6A4724' : '#9C907F');
        }
      }
      .width(34)
      .height(36);

      Text(this.milestone.label)
        .fontSize(9)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.reached ? Palette.ink : Palette.muted);
    }
    .width(36)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.reached ? 1 : 0.72);
  }
}

@Component
struct PoemMiniCard {
  item: PoemCardModel = POPULAR_POEMS[0];
  stack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 8 }) {
      Image(getPoemMiniCardIcon(this.item.id))
        .width(72)
        .height(72)
        .borderRadius(18)
        .objectFit(ImageFit.Cover);

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
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      openNavDestination(this.stack, 'poem', new PoemRouteParam(this.item.id));
    });
  }
}

@Component
struct FavoritePoemCard {
  item: PoemCardModel = FAVORITE_POEMS[0];
  stack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 10 }) {
      Image(getPoemMiniCardIcon(this.item.id))
        .width(76)
        .height(76)
        .borderRadius(20)
        .objectFit(ImageFit.Cover);

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
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      openNavDestination(this.stack, 'poem', new PoemRouteParam(this.item.id));
    });
  }
}

@Component
struct CategoryCard {
  item: CategoryModel = CATEGORIES[0];
  stack: NavPathStack = new NavPathStack();

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
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      openNavDestination(this.stack, 'poemList', new PoemListRouteParam(this.item.title, this.item.id));
    });
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
  stack: NavPathStack = new NavPathStack();

  build() {
    Row({ space: 14 }) {
      Image(getPoemMiniCardIcon(getPoemIdByTitle(this.item.title)))
        .width(68)
        .height(68)
        .borderRadius(20)
        .objectFit(ImageFit.Cover);

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
    .border({ width: 1, color: Palette.border })
    .onClick(() => {
      openNavDestination(this.stack, 'poem', new PoemRouteParam(getPoemIdByTitle(this.item.title)));
    });
  }
}

@Component
struct PoemListRow {
  poem: OfflinePoem = OFFLINE_POEMS[0];
  stack: NavPathStack = new NavPathStack();

  build() {
    Row({ space: 14 }) {
      Image(getPoemMiniCardIcon(this.poem.id))
        .width(66)
        .height(66)
        .borderRadius(18)
        .objectFit(ImageFit.Cover);

      Column({ space: 6 }) {
        Text(this.poem.title)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.ink);

        Text(`[${this.poem.dynasty}] ${this.poem.author} · ${this.poem.gradeBand}`)
          .fontSize(12)
          .fontColor(Palette.muted)
          .maxLines(1);

        Text(this.poem.lines[0])
          .fontSize(12)
          .fontColor(Palette.muted)
          .maxLines(1);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Column({ space: 6 }) {
        Text(hasPoemAudio(this.poem.id) ? '有范读' : '仅诗文')
          .fontSize(11)
          .fontColor(hasPoemAudio(this.poem.id) ? Palette.green : Palette.muted);

        Row() {
          Text('学')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Palette.white);
        }
        .width(38)
        .height(38)
        .borderRadius(19)
        .backgroundColor(Palette.green)
        .justifyContent(FlexAlign.Center);
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding(14)
    .borderRadius(22)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border })
    .onClick(() => {
      openNavDestination(this.stack, 'poem', new PoemRouteParam(this.poem.id));
    });
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
  routeParam: PoemRouteParam = new PoemRouteParam('jingyesi');

  build() {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Palette.ink);

        Text(this.subtitle)
          .fontSize(12)
          .fontColor(Palette.muted)
          .maxLines(2);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Image(getActionIcon(this.routeName))
        .width(58)
        .height(58)
        .borderRadius(18)
        .objectFit(ImageFit.Cover);
    }
    .width('48%')
    .height(112)
    .padding(16)
    .borderRadius(24)
    .backgroundColor(Palette.card)
    .border({ width: 1, color: Palette.border })
    .onClick(() => {
      if (this.routeName.length > 0) {
        openNavDestination(this.stack, this.routeName, this.routeParam);
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
    .width('19%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct ServiceRow {
  title: string = '';
  subtitle: string = '';
  symbol: string = '';
  stack: NavPathStack = new NavPathStack();
  routeName: string = '';
  routeParam: Object = new InfoRouteParam('', '', '');

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
    .padding({ top: 10, bottom: 10 })
    .onClick(() => {
      if (this.routeName.length > 0) {
        openNavDestination(this.stack, this.routeName, this.routeParam);
      }
    });
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
  @Link data: PoemBudData;
  @StorageLink('poemAudioPlaybackStatus') audioPlaybackStatus: string = 'idle';
  @StorageLink('poemAudioPlaybackRawPath') audioPlaybackRawPath: string = '';
  private bannerController: SwiperController = new SwiperController();

  private async openPoem(poemId: string): Promise<void> {
    console.info(`[PoemBud] request open poem detail poemId=${poemId}`);
    const next = openPoemLearning(this.data, poemId);
    this.data = next;
    await PoemBudStore.save(next);
    openNavDestination(this.stack, 'poem', new PoemRouteParam(poemId));
  }

  private async openGrowth(): Promise<void> {
    console.info('[PoemBud] request open growth detail');
    openNavDestination(this.stack, 'growth', new InfoRouteParam('', '', ''));
  }

  private async playFeaturedPoem(): Promise<void> {
    const poemId = getCurrentPoemId(this.data);
    if (!hasPoemAudio(poemId) || !this.data.settings.soundEnabled) {
      return;
    }
    const rawPath = this.featuredPoemAudioRawPath();
    const playbackStatus = this.featuredPoemPlaybackStatus();
    console.info(`[PoemBud] toggle featured poem from home poemId=${poemId} status=${playbackStatus}`);
    if (playbackStatus === 'loading') {
      return;
    }

    if (playbackStatus === 'idle') {
      const next = recordPoemListening(this.data, poemId);
      this.data = next;
      await PoemBudStore.save(next);
    }

    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await PoemAudioPlayer.toggleRawFile(context, rawPath);
    } catch (err) {
      console.error(`Failed to play featured poem audio: ${JSON.stringify(err)}`);
    }
  }

  private currentPoem(): PoemContentModel {
    return getPoemContent(getCurrentPoemId(this.data));
  }

  private currentPoemBanner(): Resource {
    return getPoemBanner(getCurrentPoemId(this.data));
  }

  private currentPoemLines(): string[] {
    return this.currentPoem().lines;
  }

  private featuredPoemAudioRawPath(): string {
    return getPoemAudioRawFile(getCurrentPoemId(this.data));
  }

  private featuredPoemPlaybackStatus(): string {
    return getActivePoemAudioStatus(
      this.featuredPoemAudioRawPath(),
      this.audioPlaybackRawPath,
      this.audioPlaybackStatus
    );
  }

  private isGuest(): boolean {
    return !this.data.profile.loggedIn;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 18 }) {
          Row() {
            Column({ space: 4 }) {
              Text('首页')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);

              Text(this.isGuest() ? '先创建本地学习档案，再开始积累诗词进度。' : `${this.data.profile.name}，继续今天的古诗学习。`)
                .fontSize(12)
                .fontColor(Palette.muted);
            }
            .alignItems(HorizontalAlign.Start);

            Blank();

            Row({ space: 8 }) {
              Image($r('app.media.icon_today_header'))
                .width(44)
                .height(44)
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                  this.openPoem('jingyesi');
                });
              Image($r('app.media.icon_profile_header_v2'))
                .width(44)
                .height(44)
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                  if (this.isGuest()) {
                    openNavDestination(this.stack, 'info', new InfoRouteParam('游客模式', '当前还没有本地学习档案。', '进入“我的”页面，点击未登录卡片即可创建本地档案。'));
                    return;
                  }
                  this.openGrowth();
                });
            }
          }
          .width('100%');
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20 });

        Column() {
          Swiper(this.bannerController) {
            ForEach(HOME_BANNER_POEM_IDS, (poemId: string) => {
              Image(getPoemBanner(poemId))
                .width('100%')
                .height(204)
                .borderRadius(30)
                .objectFit(ImageFit.Cover)
                .onClick(() => {
                  this.openPoem(poemId);
                });
            }, (poemId: string) => poemId);
          }
          .width('100%')
          .height(204)
          .autoPlay(true)
          .interval(3200)
          .loop(true)
          .duration(500)
          .indicator(
            new DotIndicator()
              .itemWidth(8)
              .itemHeight(8)
              .selectedItemWidth(18)
              .selectedItemHeight(8)
              .color('#D5D9CF')
              .selectedColor(Palette.green)
          );
        }
        .width('100%')
        .padding({ left: 16, right: 16 });

        Column({ space: 4 }) {
          PlaqueTitleHeader({
            title: '今日推荐',
            image: $r('app.media.title_today_recommend_v2'),
            textColor: '#F8F4EA',
            titleWidth: 92,
            rightInset: 25
          });

          Column({ space: 14 }) {
            Row({ space: 12 }) {
              Row({ space: 12 }) {
                Image(this.currentPoemBanner())
                  .width(110)
                  .height(96)
                  .borderRadius(16)
                  .objectFit(ImageFit.Cover);

                Column({ space: 4 }) {
                  Text(this.currentPoem().title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.ink);

                  Text(`[${this.currentPoem().dynasty}] ${this.currentPoem().author}`)
                    .fontSize(11)
                    .fontColor(Palette.muted);

                  Column({ space: 2 }) {
                    ForEach(this.currentPoemLines(), (line: string) => {
                      Text(line)
                        .fontSize(11)
                        .lineHeight(15)
                        .fontColor(Palette.ink);
                    }, (line: string) => line);
                  }
                  .alignItems(HorizontalAlign.Start);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }
              .layoutWeight(1)
              .alignItems(VerticalAlign.Top)
              .onClick(() => {
                this.openPoem(getCurrentPoemId(this.data));
              });

              Row({ space: 6 }) {
                Row() {
                  Text(getPoemAudioButtonIcon(this.featuredPoemPlaybackStatus()))
                    .fontSize(10)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.white);
                }
                .width(20)
                .height(20)
                .borderRadius(10)
                .backgroundColor(getPoemAudioButtonBorderColor(this.featuredPoemPlaybackStatus()))
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center);

                Text(getPoemAudioButtonLabel(this.featuredPoemPlaybackStatus(), '听赏'))
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F8F4EA');
              }
              .padding({ left: 7, right: 12, top: 5, bottom: 5 })
              .borderRadius(15)
              .backgroundColor(getPoemAudioButtonColor(this.featuredPoemPlaybackStatus()))
              .border({ width: 1, color: getPoemAudioButtonBorderColor(this.featuredPoemPlaybackStatus()) })
              .onClick(() => {
                this.playFeaturedPoem();
              });
            }
            .alignItems(VerticalAlign.Bottom)
            .width('100%');
          }
          .width('100%')
          .padding(16)
          .borderRadius(26)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: '#C7D8C7' });

          PlaqueTitleHeader({
            title: '热门古诗',
            image: $r('app.media.title_hot_poems'),
            textColor: '#FFF3E6',
            titleWidth: 96,
            rightInset: 18
          });

          Row({ space: 10 }) {
            ForEach(POPULAR_POEMS, (item: PoemCardModel) => {
              PoemMiniCard({ item: item, stack: this.stack });
            }, (item: PoemCardModel) => item.id);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(14)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });

          Stack() {
            Image($r('app.media.bg_study_progress_card'))
              .width('100%')
              .height('100%')
              .borderRadius(30)
              .objectFit(ImageFit.Fill);

            Column({ space: 8 }) {
              Row() {
                Row({ space: 8 }) {
                  Text('学习进度')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.ink);
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(16)
                .backgroundColor('#FFF8EC')
                .border({ width: 1, color: '#D8CBB3' });

                Blank();

                Row({ space: 4 }) {
                  Text('查看报告')
                    .fontSize(11)
                    .fontColor('#8A7B66');

                  Text('>')
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#8A7B66');
                }
              }
              .width('100%')
              .alignItems(VerticalAlign.Center);

              Row({ space: 8 }) {
                Row({ space: 8 }) {
                  Stack({ alignContent: Alignment.Center }) {
                    Row()
                      .width(62)
                      .height(62)
                      .borderRadius(31)
                      .backgroundColor('#F6EAD5');

                    Image($r('app.media.icon_study_progress_emblem'))
                      .width(54)
                      .height(54)
                      .borderRadius(27)
                      .objectFit(ImageFit.Cover);
                  }

                  Column({ space: 5 }) {
                    Text('今日学习')
                      .fontSize(11)
                      .fontColor(Palette.muted)
                      .maxLines(1);

                    Row({ space: 3 }) {
                      Text(`${this.data.progress.todayMinutes}`)
                        .fontSize(25)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#355645')
                        .maxLines(1);

                      Text('分钟')
                        .fontSize(11)
                        .fontColor('#7F6D59')
                        .maxLines(1);
                    }
                    .alignItems(VerticalAlign.Bottom);

                    Row({ space: 3 }) {
                      Text('累计学习')
                        .fontSize(10)
                        .fontColor('#8A7B66')
                        .maxLines(1);

                      Text(`${getStudyProgressDays(this.data)}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#C27A49')
                        .maxLines(1);

                      Text('天')
                        .fontSize(10)
                        .fontColor('#8A7B66')
                        .maxLines(1);
                    }
                    .alignItems(VerticalAlign.Bottom);
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width(136)
                .alignItems(VerticalAlign.Center);

                Column({ space: 4 }) {
                  Row() {
                    ForEach(STUDY_MILESTONES, (milestone: StudyMilestoneModel) => {
                      StudyMilestoneBadge({
                        milestone: milestone,
                        reached: getStudyProgressDays(this.data) >= milestone.days
                      });
                    }, (milestone: StudyMilestoneModel) => milestone.label);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween);

                  Stack({ alignContent: Alignment.Start }) {
                    Row()
                      .width('100%')
                      .height(8)
                      .borderRadius(8)
                      .backgroundColor('#E9DDC9');

                    Row()
                      .width(`${getStudyProgressPercent(getStudyProgressDays(this.data))}%`)
                      .height(8)
                      .borderRadius(8)
                      .backgroundColor('#6C9A78');

                    Row() {
                      Blank();

                      Row()
                        .width(14)
                        .height(14)
                        .borderRadius(7)
                        .backgroundColor('#FFF8EA')
                        .border({ width: 3, color: '#C78950' });
                    }
                    .width(`${Math.max(getStudyProgressPercent(getStudyProgressDays(this.data)), 8)}%`)
                    .height(14)
                    .alignItems(VerticalAlign.Center);
                  }
                  .width('100%')
                  .height(14);

                  Row({ space: 4 }) {
                    Text(getStudyProgressHint(getStudyProgressDays(this.data)))
                      .fontSize(9)
                      .fontColor('#7F6D59')
                      .maxLines(1);

                    Blank();

                    Text(`本周 ${this.data.progress.weeklyGoalPercent}%`)
                      .fontSize(9)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#567760')
                      .maxLines(1);
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .alignItems(VerticalAlign.Center);
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 });
          }
          .width('100%')
          .height(166)
          .borderRadius(30)
          .onClick(() => {
            this.openGrowth();
          });

          Row({ space: 12 }) {
            ActionCard({
              title: '跟读练习',
              subtitle: '开口读诗，记录朗读表现',
              symbol: '读',
              accent: Palette.green,
              stack: this.stack,
              routeName: 'reading',
              routeParam: new PoemRouteParam(getCurrentPoemId(this.data))
            });

            ActionCard({
              title: '阅读练习',
              subtitle: '理解诗意，巩固记忆',
              symbol: '阅',
              accent: Palette.orange,
              stack: this.stack,
              routeName: 'poem',
              routeParam: new PoemRouteParam(getCurrentPoemId(this.data))
            });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 });
      }
      .width('100%')
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
  stack: NavPathStack = new NavPathStack();
  @Link data: PoemBudData;
  @State searchKeyword: string = '';

  private searchResults(): OfflinePoem[] {
    return searchOfflinePoems(this.searchKeyword).slice(0, 12);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 4 }) {
            Text('诗库')
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
            Image($r('app.media.icon_library'))
              .width(40)
              .height(40)
              .borderRadius(20)
              .objectFit(ImageFit.Cover);
            Image($r('app.media.icon_hot'))
              .width(40)
              .height(40)
              .borderRadius(20)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                openNavDestination(this.stack, 'poemList', new PoemListRouteParam('全部诗词', '', ''));
              });
          }
        }
        .width('100%');

        TextInput({ placeholder: '搜索诗名、作者或诗句', text: this.searchKeyword })
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .borderRadius(24)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .fontSize(15)
          .fontColor(Palette.ink)
          .placeholderColor(Palette.muted)
          .onChange((value: string) => {
            this.searchKeyword = value;
          });

        if (this.searchKeyword.trim().length > 0) {
          Column({ space: 12 }) {
            Row() {
              Text(`搜索结果 ${this.searchResults().length}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);

              Blank();

              Text('清空')
                .fontSize(13)
                .fontColor(Palette.green)
                .onClick(() => {
                  this.searchKeyword = '';
                });
            }
            .width('100%');

            ForEach(this.searchResults(), (poem: OfflinePoem) => {
              PoemListRow({ poem: poem, stack: this.stack });
            }, (poem: OfflinePoem) => poem.id);
          }
          .width('100%');
        }

        Row({ space: 12 }) {
          Column({ space: 10 }) {
            Text('我的收藏')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(`已收藏 ${this.data.collection.favoritePoemIds.length} 首，把喜欢的诗词都装进小书架。`)
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

        if (getFavoriteCards(this.data).length > 0) {
          Row({ space: 8 }) {
            ForEach(getFavoriteCards(this.data), (item: PoemCardModel) => {
              FavoritePoemCard({ item: item, stack: this.stack });
            }, (item: PoemCardModel) => item.id);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(12)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border });
        }

        if (getFavoriteCards(this.data).length === 0) {
          Column({ space: 10 }) {
            Text('还没有收藏')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);
            Text('先从首页或学习页点进一首诗，后续再扩展收藏管理。')
              .fontSize(12)
              .fontColor(Palette.muted);
          }
          .width('100%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);
        }

        SectionHeader({ title: '诗单分类', subtitle: '按主题慢慢收集，一首一首读熟。' });

        Row({ space: 12 }) {
          CategoryCard({ item: CATEGORIES[0], stack: this.stack });
          CategoryCard({ item: CATEGORIES[1], stack: this.stack });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        Row({ space: 12 }) {
          CategoryCard({ item: CATEGORIES[2], stack: this.stack });
          CategoryCard({ item: CATEGORIES[3], stack: this.stack });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        SectionHeader({ title: '最近学习', subtitle: '继续你还没背熟的那些诗。' });

        Column({ space: 12 }) {
          ForEach(getRecentStudyRows(this.data), (item: RecentStudyModel) => {
            RecentStudyRow({ item: item, stack: this.stack });
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
  @Link data: PoemBudData;
  poemId: string = FEATURED_POEM.id;
  showTopBar: boolean = true;
  @StorageLink('poemAudioPlaybackStatus') audioPlaybackStatus: string = 'idle';
  @StorageLink('poemAudioPlaybackRawPath') audioPlaybackRawPath: string = '';

  private currentPoem(): PoemContentModel {
    return getPoemContent(this.poemId);
  }

  private poemAudioRawPath(): string {
    return getPoemAudioRawFile(this.poemId);
  }

  private poemPlaybackStatus(): string {
    return getActivePoemAudioStatus(this.poemAudioRawPath(), this.audioPlaybackRawPath, this.audioPlaybackStatus);
  }

  private async playPoemAudio(): Promise<void> {
    if (!hasPoemAudio(this.poemId) || !this.data.settings.soundEnabled) {
      return;
    }

    const playbackStatus = this.poemPlaybackStatus();
    if (playbackStatus === 'loading') {
      return;
    }

    try {
      if (playbackStatus === 'idle') {
        const next = recordPoemListening(this.data, this.poemId);
        this.data = next;
        await PoemBudStore.save(next);
      }
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await PoemAudioPlayer.toggleRawFile(context, this.poemAudioRawPath());
    } catch (err) {
      console.error(`Failed to play poem audio: ${JSON.stringify(err)}`);
    }
  }

  private async toggleFavorite(): Promise<void> {
    const next = toggleFavoritePoem(this.data, this.poemId);
    this.data = next;
    await PoemBudStore.save(next);
  }

  private async togglePinyin(): Promise<void> {
    const next = updateSettings(this.data, {
      showPinyin: !this.data.settings.showPinyin,
      soundEnabled: this.data.settings.soundEnabled,
      fontScale: this.data.settings.fontScale
    });
    this.data = next;
    await PoemBudStore.save(next);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (this.showTopBar) {
          DetailTopBar({ title: this.currentPoem().title, trailing: '诗文', stack: this.stack });
        }

        if (!this.showTopBar) {
          Row() {
            Text('学习')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Blank();

            Image($r('app.media.icon_reading'))
              .width(44)
              .height(44)
              .borderRadius(16)
              .objectFit(ImageFit.Cover);
          }
          .width('100%');
        }

        Column({ space: 18 }) {
          Column({ space: 8 }) {
            Text(this.currentPoem().title)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(`${this.currentPoem().dynasty} · ${this.currentPoem().author}`)
              .fontSize(14)
              .fontColor(Palette.muted);
          }

          Row({ space: 8 }) {
            Row() {
              Text(isFavoritePoem(this.data, this.poemId) ? '已收藏' : '收藏')
                .fontSize(12)
                .fontColor(Palette.orange);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(18)
            .backgroundColor(Palette.orangeSoft)
            .onClick(() => {
              this.toggleFavorite();
            });

            Row() {
              Text('赏析')
                .fontSize(12)
                .fontColor(Palette.green);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(18)
            .backgroundColor(Palette.greenSoft)
            .onClick(() => {
              openNavDestination(this.stack, 'info', new InfoRouteParam('诗词赏析', this.currentPoem().title, this.currentPoem().lead));
            });
          }

          Image(getPoemThumbnail(this.poemId))
            .width('100%')
            .height(132)
            .borderRadius(26)
            .objectFit(ImageFit.Cover);

          Column({ space: 14 }) {
            ForEach(this.currentPoem().lines, (line: string, index: number) => {
              Column({ space: 6 }) {
                if (this.data.settings.showPinyin) {
                  Text(this.currentPoem().pinyin[index] ?? '')
                    .fontSize(14 * this.data.settings.fontScale)
                    .fontColor(Palette.green);
                }

                Text(line)
                  .fontSize(29 * this.data.settings.fontScale)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Palette.ink)
                  .lineHeight(40 * this.data.settings.fontScale);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center);
            }, (line: string, index: number) => `${line}-${index}`);
          }
          .width('100%')
          .padding(18)
          .borderRadius(28)
          .backgroundColor(Palette.card);

          Row({ space: 12 }) {
            Row({ space: 8 }) {
              MonogramBadge({ symbol: '拼', accent: Palette.green, badgeSize: 36, fontSize: 14 });
              Text(this.data.settings.showPinyin ? '隐藏拼音' : '显示拼音')
                .fontSize(15)
                .fontColor(Palette.ink);
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .borderRadius(22)
            .backgroundColor(Palette.greenSoft)
            .onClick(() => {
              this.togglePinyin();
            });

            Blank();

            Row({ space: 8 }) {
              Text(getPoemAudioButtonIcon(this.poemPlaybackStatus()))
                .fontSize(14)
                .fontColor(Palette.white)
                .fontWeight(FontWeight.Bold);
              Text(hasPoemAudio(this.poemId) ? getPoemAudioButtonLabel(this.poemPlaybackStatus(), '范读') : '暂无音频')
                .fontSize(15)
                .fontColor(Palette.white);
            }
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .borderRadius(22)
            .backgroundColor(hasPoemAudio(this.poemId) ? getPoemAudioButtonColor(this.poemPlaybackStatus()) : '#9AA79E')
            .onClick(() => {
              this.playPoemAudio();
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
          ForEach(this.currentPoem().explains, (item: PoemLineExplainModel) => {
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
            routeName: 'challenge',
            routeParam: new PoemRouteParam(this.poemId)
          });
          ActionCard({
            title: '跟读练习',
            subtitle: '录下朗读，保存练习记录',
            symbol: '读',
            accent: Palette.green,
            stack: this.stack,
            routeName: 'reading',
            routeParam: new PoemRouteParam(this.poemId)
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
  data: PoemBudData = createDefaultPoemBudData();
  stack: NavPathStack = new NavPathStack();
  showTopBar: boolean = false;

  aboutToAppear(): void {
    console.info(`[PoemBud] growth page appear loggedIn=${this.data.profile.loggedIn} level=${this.data.profile.level} weeklyGoal=${this.data.progress.weeklyGoalPercent}`);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (this.showTopBar) {
          DetailTopBar({ title: '学习报告', trailing: '成长', stack: this.stack });
        }

        if (!this.showTopBar) {
          Row() {
            Text('成长')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Blank();

            MonogramBadge({ symbol: '↗', accent: Palette.greenSoft, badgeSize: 38, fontSize: 16 });
          }
          .width('100%');
        }

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

        SectionHeader({ title: '本周学习情况', subtitle: getCurrentWeekRangeText() });

        Row() {
          ForEach(buildWeeklyMetricModels(this.data), (item: GrowthMetricModel) => {
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

            Text(`${this.data.progress.masteredPoems}首`)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.orange);

            Text('完成闯关即可计入掌握')
              .fontSize(12)
              .fontColor(Palette.muted);

            Row() {
              Text('查看我的诗单')
                .fontSize(12)
                .fontColor(Palette.green);
            }
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(16)
            .backgroundColor(Palette.greenSoft)
            .onClick(() => {
              openNavDestination(this.stack, 'poemList', new PoemListRouteParam('我的收藏', '', ''));
            });
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

            Text(`${this.data.progress.streakDays}天`)
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

            ProgressDots({ active: this.data.progress.weeklyStudyDays, total: 7, color: Palette.green });
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
            ForEach(getGrowthValues(this.data), (item: number, index: number) => {
              Column({ space: 8 }) {
                Text(`${item}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(index === getGrowthValues(this.data).length - 1 ? Palette.orange : Palette.green);

                Row()
                  .width(42)
                  .height(Math.min(90, item * 2))
                  .borderRadius(20)
                  .backgroundColor(index === getGrowthValues(this.data).length - 1 ? Palette.orangeSoft : Palette.greenSoft);

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

            Text(`已获得 ${this.data.challenge.stars} 颗闯关星`)
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

            ProgressTrack({ percent: Math.min(100, this.data.progress.masteredPoems * 2), color: Palette.orange });

            Text(`${this.data.progress.masteredPoems} / 50`)
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
  stack: NavPathStack = new NavPathStack();
  @Link data: PoemBudData;

  private async handleProfileCardClick(): Promise<void> {
    if (!this.data.profile.loggedIn) {
      const next = signInLocalProfile(this.data);
      this.data = next;
      await PoemBudStore.save(next);
      console.info('[PoemBud] local profile created from mine card');
      return;
    }
    console.info('[PoemBud] mine card open growth detail');
    openNavDestination(this.stack, 'growth', new InfoRouteParam('', '', ''));
  }

  aboutToAppear(): void {
    console.info(`[PoemBud] mine page appear loggedIn=${this.data.profile.loggedIn} name=${this.data.profile.name} level=${this.data.profile.level}`);
  }

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
            Image($r('app.media.icon_today'))
              .width(40)
              .height(40)
              .borderRadius(20)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                openNavDestination(this.stack, 'info', new InfoRouteParam('通知提醒', '单机版暂不接系统推送。', '后续可以扩展本地学习提醒。'));
              });
            Image($r('app.media.icon_library'))
              .width(40)
              .height(40)
              .borderRadius(20)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                openNavDestination(this.stack, 'info', new InfoRouteParam('页面设置', '当前提供基础显示信息。', '后续可以继续扩展字体大小和护眼模式。'));
              });
          }
        }
        .width('100%');

        Row({ space: 16 }) {
          Image($r('app.media.poem_profile_hero'))
            .width(78)
            .height(78)
            .borderRadius(24)
            .objectFit(ImageFit.Cover);

          Column({ space: 8 }) {
            Text(this.data.profile.name)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(`ID: ${this.data.profile.userId}`)
              .fontSize(12)
              .fontColor(Palette.muted);

            Row({ space: 8 }) {
              if (this.data.profile.loggedIn) {
                Row() {
                  Text(`Lv.${this.data.profile.level}`)
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.white);
                }
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .borderRadius(14)
                .backgroundColor(Palette.green);
              }

              Text(this.data.profile.title)
                .fontSize(12)
                .fontColor(Palette.green);
            }

            ProgressTrack({ percent: this.data.profile.expPercent, color: Palette.green });
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Column({ space: 6 }) {
            Text('今日学习')
              .fontSize(12)
              .fontColor(Palette.muted);

            Text(`${this.data.progress.todayMinutes}分钟`)
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
        .border({ width: 1, color: Palette.border })
        .onClick(() => {
          this.handleProfileCardClick();
        });

        Row() {
          Column({ space: 6 }) {
            Text('已学古诗')
              .fontSize(12)
              .fontColor(Palette.muted);
            Text(`${this.data.progress.learnedPoems}首`)
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
            Text(`${this.data.progress.totalStars}颗`)
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
            Text(`${this.data.progress.totalStudyDays}天`)
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

          if (getFavoriteCards(this.data).length > 0) {
            Row({ space: 8 }) {
              ForEach(getFavoriteCards(this.data), (item: PoemCardModel) => {
                FavoritePoemCard({ item: item, stack: this.stack });
              }, (item: PoemCardModel) => item.id);
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween);
          }

          if (getFavoriteCards(this.data).length === 0) {
            Text('还没有加入诗单，先去首页开始学习。')
              .fontSize(13)
              .fontColor(Palette.muted);
          }
        }
        .width('100%')
        .padding(18)
        .borderRadius(28)
        .backgroundColor(Palette.card)
        .border({ width: 1, color: Palette.border });

        Row({ space: 12 }) {
          Column({ space: 4 }) {
            ServiceRow({
              title: '学习报告',
              subtitle: '查看本周进步',
              symbol: '报',
              stack: this.stack,
              routeName: 'growth',
              routeParam: new InfoRouteParam('', '', '')
            });
            ServiceRow({
              title: '成就墙',
              subtitle: '看看获得了什么',
              symbol: '星',
              stack: this.stack,
              routeName: 'growth',
              routeParam: new InfoRouteParam('', '', '')
            });
            ServiceRow({
              title: '跟读记录',
              subtitle: '找到最近朗读的诗',
              symbol: '读',
              stack: this.stack,
              routeName: 'info',
              routeParam: new InfoRouteParam('跟读记录', `累计练习 ${this.data.reading.attempts} 次`, this.data.reading.lastRecordPath.length > 0 ? this.data.reading.lastRecordPath : '还没有录音记录，先去完成一次跟读练习。')
            });
            ServiceRow({
              title: '收藏管理',
              subtitle: '整理自己的诗单',
              symbol: '藏',
              stack: this.stack,
              routeName: 'poemList',
              routeParam: new PoemListRouteParam('我的收藏', '', '')
            });
            ServiceRow({
              title: '设置',
              subtitle: '通知与字体大小',
              symbol: '设',
              stack: this.stack,
              routeName: 'settings',
              routeParam: new InfoRouteParam('', '', '')
            });
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
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              openNavDestination(this.stack, 'info', new InfoRouteParam('家长中心', '当前是单机版说明页。', '可以在“学习报告”和“跟读记录”里查看本地学习数据。'));
            });

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
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              openNavDestination(this.stack, 'info', new InfoRouteParam('帮助与反馈', '当前为本地帮助页。', '如需继续补充更多功能，可以继续让我直接改工程。'));
            });
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

          ForEach(this.data.achievements, (item: string, index: number) => {
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
struct InfoPage {
  stack: NavPathStack = new NavPathStack();
  title: string = '';
  subtitle: string = '';
  content: string = '';

  aboutToAppear(): void {
    console.info(`[PoemBud] info page appear title=${this.title}`);
  }

  build() {
    Column({ space: 18 }) {
      DetailTopBar({ title: this.title, trailing: '', stack: this.stack });

      Text(this.subtitle)
        .fontSize(16)
        .fontColor(Palette.green)
        .width('100%');

      Text(this.content)
        .fontSize(15)
        .fontColor(Palette.ink)
        .lineHeight(26)
        .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor(Palette.paper)
    .alignItems(HorizontalAlign.Start);
  }
}

@Component
struct PoemListPage {
  stack: NavPathStack = new NavPathStack();
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  title: string = '全部诗词';
  categoryId: string = '';
  query: string = '';

  private poems(): OfflinePoem[] {
    if (this.title === '我的收藏') {
      return this.data.collection.favoritePoemIds.map((poemId: string) => getOfflinePoemById(poemId));
    }
    if (this.query.trim().length > 0) {
      return searchOfflinePoems(this.query);
    }
    if (this.categoryId.length > 0) {
      return getOfflinePoemsByCategory(this.categoryId);
    }
    return OFFLINE_POEMS;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        DetailTopBar({ title: this.title.length > 0 ? this.title : '全部诗词', trailing: `${this.poems().length}首`, stack: this.stack });

        ForEach(this.poems(), (poem: OfflinePoem) => {
          PoemListRow({ poem: poem, stack: this.stack });
        }, (poem: OfflinePoem) => poem.id);
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
struct SettingsPage {
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  stack: NavPathStack = new NavPathStack();

  private async togglePinyin(): Promise<void> {
    const next = updateSettings(this.data, {
      showPinyin: !this.data.settings.showPinyin,
      soundEnabled: this.data.settings.soundEnabled,
      fontScale: this.data.settings.fontScale
    });
    this.data = next;
    await PoemBudStore.save(next);
  }

  private async toggleSound(): Promise<void> {
    const next = updateSettings(this.data, {
      showPinyin: this.data.settings.showPinyin,
      soundEnabled: !this.data.settings.soundEnabled,
      fontScale: this.data.settings.fontScale
    });
    this.data = next;
    await PoemBudStore.save(next);
  }

  private async setFontScale(value: number): Promise<void> {
    const next = updateSettings(this.data, {
      showPinyin: this.data.settings.showPinyin,
      soundEnabled: this.data.settings.soundEnabled,
      fontScale: value
    });
    this.data = next;
    await PoemBudStore.save(next);
  }

  private async resetData(): Promise<void> {
    const next = resetLocalStudyData(this.data);
    this.data = next;
    await PoemBudStore.save(next);
  }

  build() {
    Column({ space: 18 }) {
      DetailTopBar({ title: '设置', trailing: '本地', stack: this.stack });

      Column({ space: 14 }) {
        Row({ space: 12 }) {
          MonogramBadge({ symbol: '拼', accent: Palette.greenSoft, badgeSize: 36, fontSize: 14 });
          Column({ space: 4 }) {
            Text('默认显示拼音')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);
            Text(this.data.settings.showPinyin ? '已开启' : '已关闭')
              .fontSize(11)
              .fontColor(Palette.muted);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
          Text(this.data.settings.showPinyin ? '开' : '关')
            .fontSize(13)
            .fontColor(Palette.green);
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
            this.togglePinyin();
        });

        Row({ space: 12 }) {
          MonogramBadge({ symbol: '声', accent: Palette.greenSoft, badgeSize: 36, fontSize: 14 });
          Column({ space: 4 }) {
            Text('声音播放')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);
            Text(this.data.settings.soundEnabled ? '已开启' : '已关闭')
              .fontSize(11)
              .fontColor(Palette.muted);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
          Text(this.data.settings.soundEnabled ? '开' : '关')
            .fontSize(13)
            .fontColor(Palette.green);
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
            this.toggleSound();
        });

        Row({ space: 10 }) {
          Text('字号')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.ink);
          Blank();
          ForEach([0.9, 1, 1.12], (item: number) => {
            Row() {
              Text(item === 0.9 ? '小' : item === 1 ? '中' : '大')
                .fontSize(13)
                .fontColor(this.data.settings.fontScale === item ? Palette.white : Palette.green);
            }
            .width(42)
            .height(34)
            .borderRadius(17)
            .backgroundColor(this.data.settings.fontScale === item ? Palette.green : Palette.greenSoft)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.setFontScale(item);
            });
          }, (item: number) => `${item}`);
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 });

        Row() {
          Text('清空本地学习数据')
            .fontSize(16)
            .fontColor(Palette.red);
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          this.resetData();
        });
      }
      .width('100%')
      .padding(18)
      .borderRadius(28)
      .backgroundColor(Palette.card)
      .border({ width: 1, color: Palette.border });
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor(Palette.paper)
    .alignItems(HorizontalAlign.Start);
  }
}

@Component
struct ReadingPracticePage {
  stack: NavPathStack = new NavPathStack();
  @Link data: PoemBudData;
  poemId: string = FEATURED_POEM.id;
  @State hasResult: boolean = false;
  @State isReading: boolean = false;
  @State currentLineIndex: number = 0;
  @State recordingStartedAt: number = 0;
  @StorageLink('poemAudioPlaybackStatus') audioPlaybackStatus: string = 'idle';
  @StorageLink('poemAudioPlaybackRawPath') audioPlaybackRawPath: string = '';
  private recorder: PoemRecorder = new PoemRecorder();

  private currentPoem(): PoemContentModel {
    return getPoemContent(this.poemId);
  }

  aboutToAppear(): void {
    this.hasResult = this.data.reading.attemptHistory.length > 0;
    console.info(`[PoemBud] reading page appear poemId=${this.poemId} hasResult=${this.hasResult}`);
  }

  private currentLineText(): string {
    return this.currentPoem().lines[this.currentLineIndex] ?? this.currentPoem().lines[0];
  }

  private currentLinePinyin(): string {
    return this.currentPoem().pinyin[this.currentLineIndex] ?? '';
  }

  private lastAttemptText(): string {
    const last = this.data.reading.attemptHistory[0];
    if (!last) {
      return '完成一次录音即可保存练习记录。';
    }
    return `最近练习：${last.durationSeconds}秒，获得${last.rewardStars}颗星星`;
  }

  private poemAudioRawPath(): string {
    return getPoemAudioRawFile(this.poemId);
  }

  private poemPlaybackStatus(): string {
    return getActivePoemAudioStatus(this.poemAudioRawPath(), this.audioPlaybackRawPath, this.audioPlaybackStatus);
  }

  private async playPoemAudio(): Promise<void> {
    if (!hasPoemAudio(this.poemId) || !this.data.settings.soundEnabled) {
      return;
    }

    const playbackStatus = this.poemPlaybackStatus();
    if (playbackStatus === 'loading') {
      return;
    }

    try {
      if (playbackStatus === 'idle') {
        const next = recordPoemListening(this.data, this.poemId);
        this.data = next;
        await PoemBudStore.save(next);
      }
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await PoemAudioPlayer.toggleRawFile(context, this.poemAudioRawPath());
    } catch (err) {
      console.error(`Failed to play poem audio: ${JSON.stringify(err)}`);
    }
  }

  private async playLastRecord(): Promise<void> {
    if (this.data.reading.lastRecordPath.length === 0) {
      return;
    }

    try {
      await PoemAudioPlayer.playUri(`file://${this.data.reading.lastRecordPath}`);
    } catch (err) {
      console.error(`Failed to replay reading record: ${JSON.stringify(err)}`);
    }
  }

  private async toggleRecording(): Promise<void> {
    try {
      if (this.isReading) {
        const recordPath = await this.recorder.stop();
        this.isReading = false;
        const durationSeconds = Math.max(1, Math.round((new Date().getTime() - this.recordingStartedAt) / 1000));
        const next = recordReadingResult(this.data, this.poemId, 0, recordPath, this.currentLineIndex, this.currentLineText(), durationSeconds);
        this.data = next;
        this.hasResult = true;
        await PoemBudStore.save(next);
        return;
      }

      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await this.recorder.start(context);
      this.recordingStartedAt = new Date().getTime();
      this.isReading = true;
    } catch (err) {
      this.isReading = false;
      console.error(`Failed to toggle recording: ${JSON.stringify(err)}`);
    }
  }

  private switchLine(delta: number): void {
    const nextIndex = this.currentLineIndex + delta;
    if (nextIndex < 0) {
      this.currentLineIndex = this.currentPoem().lines.length - 1;
      return;
    }
    if (nextIndex >= this.currentPoem().lines.length) {
      this.currentLineIndex = 0;
      return;
    }
    this.currentLineIndex = nextIndex;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
          DetailTopBar({ title: '跟读练习', trailing: this.currentPoem().title, stack: this.stack });

          Column({ space: 12 }) {
            Text('当前诗句')
              .fontSize(14)
              .fontColor(Palette.green);

            Text(this.currentLinePinyin())
              .fontSize(14)
              .fontColor(Palette.green);

            Text(this.currentLineText())
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.ink);

            Text(`出自《${this.currentPoem().title}》 · ${this.currentPoem().dynasty} · ${this.currentPoem().author}`)
              .fontSize(13)
              .fontColor(Palette.muted);

            Row({ space: 8 }) {
              Text(getPoemAudioButtonIcon(this.poemPlaybackStatus()))
                .fontSize(13)
                .fontColor(Palette.white)
                .fontWeight(FontWeight.Bold);
              Text(hasPoemAudio(this.poemId) ? getPoemAudioButtonLabel(this.poemPlaybackStatus(), '播放范读') : '暂无范读')
                .fontSize(13)
                .fontColor(Palette.white);
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(18)
            .backgroundColor(hasPoemAudio(this.poemId) ? getPoemAudioButtonColor(this.poemPlaybackStatus()) : '#9AA79E')
            .onClick(() => {
              this.playPoemAudio();
            });

            Row({ space: 10 }) {
              Text('上一句')
                .fontSize(13)
                .fontColor(Palette.green)
                .onClick(() => {
                  this.switchLine(-1);
                });
              Text(`${this.currentLineIndex + 1}/${this.currentPoem().lines.length}`)
                .fontSize(12)
                .fontColor(Palette.muted);
              Text('下一句')
                .fontSize(13)
                .fontColor(Palette.green)
                .onClick(() => {
                  this.switchLine(1);
                });
            }
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);

          Row({ space: 16 }) {
            Image($r('app.media.icon_follow_read'))
              .width(96)
              .height(96)
              .borderRadius(30)
              .objectFit(ImageFit.Cover);

            Column({ space: 10 }) {
              Text(this.hasResult ? '读得真棒！' : '准备好了吗？')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);

              Text(this.hasResult ? this.lastAttemptText() : '点击下方按钮，系统会录下你的朗读。')
                .fontSize(13)
                .fontColor(Palette.muted);

              Row({ space: 8 }) {
                Text(this.hasResult ? '⭐ 已保存本地练习记录' : '跟读前先深呼吸一下')
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
            Text(this.isReading ? '正在录音，请朗读诗句…' : '本地录音波形')
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
              this.toggleRecording();
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
              Text('练习完成')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Text(this.hasResult ? `${this.data.reading.attempts}次` : '--')
                .fontSize(36)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.orange);

              Text('本地保存')
                .fontSize(12)
                .fontColor(Palette.orange);
            }
            .width('34%')
            .padding(18)
            .borderRadius(26)
            .backgroundColor(Palette.orangeSoft)
            .alignItems(HorizontalAlign.Start);

            Column({ space: 12 }) {
              Text('本句练习记录')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);

              Text(this.hasResult ? this.lastAttemptText() : '先完成一次录音，系统会记录练习次数和星星奖励。')
                .fontSize(13)
                .lineHeight(22)
                .fontColor(Palette.muted);

              Row() {
                Text('播放最近录音')
                  .fontSize(13)
                  .fontColor(this.data.reading.lastRecordPath.length > 0 ? Palette.green : Palette.muted);
              }
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .borderRadius(18)
              .backgroundColor(Palette.greenSoft)
              .onClick(() => {
                this.playLastRecord();
              });
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

            Text('星星由录音完成度和练习时长计算，全部保存在本机。')
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
}

@Component
struct ChallengePage {
  stack: NavPathStack = new NavPathStack();
  @Link data: PoemBudData;
  poemId: string = FEATURED_POEM.id;
  @State firstBlank: string = '';
  @State secondBlank: string = '';

  aboutToAppear(): void {
    console.info(`[PoemBud] challenge page appear poemId=${this.poemId} level=${this.data.challenge.currentLevel}`);
  }

  private question(): ChallengeQuestionModel {
    return getChallengeQuestion(this.poemId);
  }

  private isSuccess(): boolean {
    return this.firstBlank === this.question().answerA && this.secondBlank === this.question().answerB;
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
      this.persistChallengeSuccess();
    }
  }

  private isWordUsed(word: string): boolean {
    return this.firstBlank === word || this.secondBlank === word;
  }

  private resetChallenge(): void {
    this.firstBlank = '';
    this.secondBlank = '';
  }

  private async persistChallengeSuccess(): Promise<void> {
    if (this.isSuccess()) {
      const next = completeChallenge(this.data, this.poemId);
      this.data = next;
      await PoemBudStore.save(next);
    }
  }

  private async goNextLevel(): Promise<void> {
    const next = advanceChallengeLevel(this.data);
    this.data = next;
    this.resetChallenge();
    await PoemBudStore.save(next);
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
          DetailTopBar({ title: '背诵闯关', trailing: this.question().title, stack: this.stack });

          Image($r('app.media.poem_challenge_hero'))
            .width('100%')
            .height(176)
            .borderRadius(30)
            .objectFit(ImageFit.Cover);

          Row({ space: 10 }) {
            Row() {
              Text(`第${this.data.challenge.currentLevel}关`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Palette.ink);
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .borderRadius(20)
            .backgroundColor(Palette.card);

            Blank();

            Text(`⭐ ${this.data.progress.totalStars}`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Palette.orange);

            ForEach([1, 2, 3, 4, 5], (item: number) => {
              Row() {
                Text(`${item}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(item <= this.data.challenge.currentLevel ? Palette.white : Palette.muted);
              }
              .width(34)
              .height(34)
              .borderRadius(17)
              .backgroundColor(item < this.data.challenge.currentLevel ? Palette.green : item === this.data.challenge.currentLevel ? Palette.orange : '#D9D5CE')
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

            Text(this.question().prompt)
              .fontSize(13)
              .fontColor(Palette.muted);

            Text(`${this.question().title}  ·  ${this.question().author}`)
              .fontSize(16)
              .fontColor(Palette.green);

            Row({ space: 8 }) {
              Text(this.question().prefixA)
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

              Text(this.question().suffixA)
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);
            }

            Text(this.question().middleLine)
              .fontSize(26)
              .fontWeight(FontWeight.Medium)
              .fontColor(Palette.ink);

            Row({ space: 8 }) {
              Text(this.question().prefixB)
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

              Text(this.question().suffixB)
                .fontSize(26)
                .fontWeight(FontWeight.Medium)
                .fontColor(Palette.ink);
            }
          }
          .width('100%')
          .padding(20)
          .borderRadius(30)
          .backgroundColor(Palette.card)
          .border({ width: 1, color: Palette.border })
          .alignItems(HorizontalAlign.Start);

          Row({ space: 12 }) {
            ForEach(this.question().choices, (item: string) => {
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
                  Text(this.data.challenge.currentLevel >= 5 ? '已完成' : '下一关')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Palette.white);
                }
                .padding({ left: 18, right: 18, top: 12, bottom: 12 })
                .borderRadius(20)
                .backgroundColor(Palette.green)
                .onClick(() => {
                  if (this.data.challenge.currentLevel < 5) {
                    this.goNextLevel();
                  }
                });

                Row() {
                  Text('查看诗文')
                    .fontSize(16)
                    .fontColor(Palette.green);
                }
                .padding({ left: 18, right: 18, top: 12, bottom: 12 })
                .borderRadius(20)
                .backgroundColor(Palette.greenSoft)
                .onClick(() => {
                  openNavDestination(this.stack, 'poem', new PoemRouteParam(this.poemId));
                });
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
            .border({ width: 1, color: Palette.border })
            .onClick(() => {
              openNavDestination(this.stack, 'info', new InfoRouteParam('诗意小讲堂', this.question().title, getPoemContent(this.poemId).lead));
            });

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
            .border({ width: 1, color: Palette.border })
            .onClick(() => {
              openNavDestination(this.stack, 'poem', new PoemRouteParam(this.poemId));
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
    .height('100%');
  }
}

@Component
struct PoemRouteEntry {
  poemId: string = FEATURED_POEM.id;
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      StudyPage({ stack: this.stack, data: $data, poemId: this.poemId, showTopBar: true });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct ReadingRouteEntry {
  poemId: string = FEATURED_POEM.id;
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      ReadingPracticePage({ stack: this.stack, data: $data, poemId: this.poemId });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct ChallengeRouteEntry {
  poemId: string = FEATURED_POEM.id;
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      ChallengePage({ stack: this.stack, data: $data, poemId: this.poemId });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct GrowthRouteEntry {
  @StorageLink('poemBudData') data: PoemBudData = createDefaultPoemBudData();
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      GrowthPage({ data: this.data, stack: this.stack, showTopBar: true });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct InfoRouteEntry {
  title: string = '';
  subtitle: string = '';
  content: string = '';
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      InfoPage({ stack: this.stack, title: this.title, subtitle: this.subtitle, content: this.content });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct PoemListRouteEntry {
  title: string = '全部诗词';
  categoryId: string = '';
  query: string = '';
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      PoemListPage({ stack: this.stack, title: this.title, categoryId: this.categoryId, query: this.query });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Component
struct SettingsRouteEntry {
  @State stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      SettingsPage({ stack: this.stack });
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.stack = context.pathStack;
    });
  }
}

@Builder
function PoemRouteBuilder(_name?: string, param?: Object) {
  PoemRouteEntry({ poemId: (param as PoemRouteParam)?.poemId ?? FEATURED_POEM.id });
}

@Builder
function ReadingRouteBuilder(_name?: string, param?: Object) {
  ReadingRouteEntry({ poemId: (param as PoemRouteParam)?.poemId ?? FEATURED_POEM.id });
}

@Builder
function ChallengeRouteBuilder(_name?: string, param?: Object) {
  ChallengeRouteEntry({ poemId: (param as PoemRouteParam)?.poemId ?? FEATURED_POEM.id });
}

@Builder
function GrowthRouteBuilder(_name?: string, _param?: Object) {
  GrowthRouteEntry();
}

@Builder
function InfoRouteBuilder(_name?: string, param?: Object) {
  InfoRouteEntry({
    title: (param as InfoRouteParam)?.title ?? '',
    subtitle: (param as InfoRouteParam)?.subtitle ?? '',
    content: (param as InfoRouteParam)?.content ?? ''
  });
}

@Builder
function PoemListRouteBuilder(_name?: string, param?: Object) {
  PoemListRouteEntry({
    title: (param as PoemListRouteParam)?.title ?? '全部诗词',
    categoryId: (param as PoemListRouteParam)?.categoryId ?? '',
    query: (param as PoemListRouteParam)?.query ?? ''
  });
}

@Builder
function SettingsRouteBuilder(_name?: string, _param?: Object) {
  SettingsRouteEntry();
}
