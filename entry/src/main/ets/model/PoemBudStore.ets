import { PreferencesManager } from '../utils/PreferencesManager';

const STORE_NAME = 'poem_bud_preferences';
const DATA_KEY = 'poem_bud_data';
const SCHEMA_VERSION = 6;
const MAX_CHALLENGE_LEVEL = 5;

export interface ProfileData {
  loggedIn: boolean;
  name: string;
  userId: string;
  title: string;
  level: number;
  expPercent: number;
}

export interface ProgressData {
  todayMinutes: number;
  streakDays: number;
  totalStudyDays: number;
  learnedPoems: number;
  masteredPoems: number;
  totalStars: number;
  weeklyGoalPercent: number;
  weeklyStudyDays: number;
  weeklyPoems: number;
  weeklyReadingCount: number;
  weeklyChallengeCount: number;
  weeklyStars: number;
}

export interface ReadingAttemptData {
  poemId: string;
  lineIndex: number;
  lineText: string;
  recordPath: string;
  durationSeconds: number;
  rewardStars: number;
  createdAt: number;
}

export interface ReadingData {
  attempts: number;
  bestScore: number;
  lastScore: number;
  lastRecordPath: string;
  lastRecordTime: number;
  attemptHistory: ReadingAttemptData[];
}

export interface ChallengeData {
  currentLevel: number;
  passedLevels: number;
  stars: number;
  lastCompletedTime: number;
}

export interface StudyData {
  currentPoemId: string;
  learnedPoemIds: string[];
  challengePassedPoemIds: string[];
  listenedPoemIds: string[];
}

export interface CollectionData {
  favoritePoemIds: string[];
  recentPoemIds: string[];
}

export interface DailyStudyRecord {
  date: string;
  studyMinutes: number;
  openedPoemIds: string[];
  listenedPoemIds: string[];
  readingCount: number;
  challengeCount: number;
  stars: number;
}

export interface PoemLearningProgress {
  poemId: string;
  openedCount: number;
  listenedCount: number;
  readExplanation: boolean;
  readingCount: number;
  challengePassedCount: number;
  mastered: boolean;
  lastStudyTime: number;
}

export interface SettingsData {
  showPinyin: boolean;
  soundEnabled: boolean;
  fontScale: number;
}

export interface PoemBudData {
  schemaVersion: number;
  profile: ProfileData;
  progress: ProgressData;
  reading: ReadingData;
  challenge: ChallengeData;
  study: StudyData;
  collection: CollectionData;
  dailyRecords: DailyStudyRecord[];
  poemProgressRecords: PoemLearningProgress[];
  settings: SettingsData;
  achievements: string[];
}

function updateWeeklyGoalPercent(data: PoemBudData): void {
  const score = data.progress.weeklyStudyDays * 20 + data.progress.weeklyPoems * 18 +
    data.progress.weeklyReadingCount * 5 + data.progress.weeklyChallengeCount * 6;
  data.progress.weeklyGoalPercent = Math.min(100, score);
}

function pad2(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

function getDateKey(date: Date = new Date()): string {
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;
}

function getOrCreateTodayRecord(data: PoemBudData): DailyStudyRecord {
  const today = getDateKey();
  const found = data.dailyRecords.find((item: DailyStudyRecord) => item.date === today);
  if (found) {
    return found;
  }

  const record: DailyStudyRecord = {
    date: today,
    studyMinutes: 0,
    openedPoemIds: [],
    listenedPoemIds: [],
    readingCount: 0,
    challengeCount: 0,
    stars: 0
  };
  data.dailyRecords.push(record);
  data.dailyRecords = data.dailyRecords.slice(-120);
  return record;
}

function addUnique(items: string[], value: string): string[] {
  if (items.includes(value)) {
    return items;
  }
  const next = items.slice();
  next.push(value);
  return next;
}

function getOrCreatePoemProgress(data: PoemBudData, poemId: string): PoemLearningProgress {
  const found = data.poemProgressRecords.find((item: PoemLearningProgress) => item.poemId === poemId);
  if (found) {
    return found;
  }

  const record: PoemLearningProgress = {
    poemId,
    openedCount: 0,
    listenedCount: 0,
    readExplanation: false,
    readingCount: 0,
    challengePassedCount: 0,
    mastered: false,
    lastStudyTime: 0
  };
  data.poemProgressRecords.push(record);
  return record;
}

function updateProfileLevel(data: PoemBudData): void {
  const exp = data.progress.totalStars * 10 + data.progress.learnedPoems * 15 + data.progress.masteredPoems * 25;
  data.profile.level = data.profile.loggedIn ? Math.max(1, Math.floor(exp / 120) + 1) : data.profile.level;
  data.profile.expPercent = Math.min(100, exp % 120 / 120 * 100);
  if (data.profile.loggedIn) {
    data.profile.title = data.progress.masteredPoems >= 10 ? '诗词小达人' : '诗词初学者';
  }
}

function refreshProgressFromRecords(data: PoemBudData): void {
  data.progress.learnedPoems = data.study.learnedPoemIds.length;
  data.progress.masteredPoems = data.poemProgressRecords.filter((item: PoemLearningProgress) => item.mastered).length;
  data.progress.totalStudyDays = data.dailyRecords.filter((item: DailyStudyRecord) => item.studyMinutes > 0 ||
    item.openedPoemIds.length > 0 || item.readingCount > 0 || item.challengeCount > 0).length;
  data.progress.weeklyStudyDays = Math.min(7, data.dailyRecords.slice(-7).filter((item: DailyStudyRecord) => item.studyMinutes > 0 ||
    item.openedPoemIds.length > 0 || item.readingCount > 0 || item.challengeCount > 0).length);
  data.progress.weeklyPoems = data.dailyRecords.slice(-7)
    .reduce((acc: string[], item: DailyStudyRecord) => {
      item.openedPoemIds.forEach((poemId: string) => {
        if (!acc.includes(poemId)) {
          acc.push(poemId);
        }
      });
      return acc;
    }, []).length;
  data.progress.weeklyReadingCount = data.dailyRecords.slice(-7)
    .reduce((sum: number, item: DailyStudyRecord) => sum + item.readingCount, 0);
  data.progress.weeklyChallengeCount = data.dailyRecords.slice(-7)
    .reduce((sum: number, item: DailyStudyRecord) => sum + item.challengeCount, 0);
  data.progress.weeklyStars = data.dailyRecords.slice(-7)
    .reduce((sum: number, item: DailyStudyRecord) => sum + item.stars, 0);
  data.progress.streakDays = Math.max(data.progress.streakDays, data.progress.weeklyStudyDays);
  updateWeeklyGoalPercent(data);
  updateProfileLevel(data);
}

function prependAchievement(data: PoemBudData, message: string): void {
  const nextAchievements = data.achievements.slice();
  nextAchievements.unshift(message);
  data.achievements = nextAchievements.slice(0, 3);
}

export function createDefaultPoemBudData(): PoemBudData {
  return {
    schemaVersion: SCHEMA_VERSION,
    profile: {
      loggedIn: false,
      name: '未登录',
      userId: '--',
      title: '创建学习档案',
      level: 0,
      expPercent: 0
    },
    progress: {
      todayMinutes: 0,
      streakDays: 0,
      totalStudyDays: 0,
      learnedPoems: 0,
      masteredPoems: 0,
      totalStars: 0,
      weeklyGoalPercent: 0,
      weeklyStudyDays: 0,
      weeklyPoems: 0,
      weeklyReadingCount: 0,
      weeklyChallengeCount: 0,
      weeklyStars: 0
    },
    reading: {
      attempts: 0,
      bestScore: 0,
      lastScore: 0,
      lastRecordPath: '',
      lastRecordTime: 0,
      attemptHistory: []
    },
    challenge: {
      currentLevel: 1,
      passedLevels: 0,
      stars: 0,
      lastCompletedTime: 0
    },
    study: {
      currentPoemId: 'jingyesi',
      learnedPoemIds: [],
      challengePassedPoemIds: [],
      listenedPoemIds: []
    },
    collection: {
      favoritePoemIds: [],
      recentPoemIds: []
    },
    dailyRecords: [],
    poemProgressRecords: [],
    settings: {
      showPinyin: true,
      soundEnabled: true,
      fontScale: 1
    },
    achievements: []
  };
}

export function clonePoemBudData(data: PoemBudData): PoemBudData {
  return JSON.parse(JSON.stringify(data)) as PoemBudData;
}

function normalizePoemBudData(data: PoemBudData): PoemBudData {
  const defaults = createDefaultPoemBudData();
  const normalized = clonePoemBudData(defaults);
  normalized.schemaVersion = defaults.schemaVersion;
  normalized.profile.loggedIn = data.profile?.loggedIn ?? defaults.profile.loggedIn;
  normalized.profile.name = data.profile?.name ?? defaults.profile.name;
  normalized.profile.userId = data.profile?.userId ?? defaults.profile.userId;
  normalized.profile.title = data.profile?.title ?? defaults.profile.title;
  normalized.profile.level = data.profile?.level ?? defaults.profile.level;
  normalized.profile.expPercent = data.profile?.expPercent ?? defaults.profile.expPercent;

  normalized.progress.todayMinutes = data.progress?.todayMinutes ?? defaults.progress.todayMinutes;
  normalized.progress.streakDays = data.progress?.streakDays ?? defaults.progress.streakDays;
  normalized.progress.totalStudyDays = data.progress?.totalStudyDays ?? defaults.progress.totalStudyDays;
  normalized.progress.learnedPoems = data.progress?.learnedPoems ?? defaults.progress.learnedPoems;
  normalized.progress.masteredPoems = data.progress?.masteredPoems ?? defaults.progress.masteredPoems;
  normalized.progress.totalStars = data.progress?.totalStars ?? defaults.progress.totalStars;
  normalized.progress.weeklyGoalPercent = data.progress?.weeklyGoalPercent ?? defaults.progress.weeklyGoalPercent;
  normalized.progress.weeklyStudyDays = data.progress?.weeklyStudyDays ?? defaults.progress.weeklyStudyDays;
  normalized.progress.weeklyPoems = data.progress?.weeklyPoems ?? defaults.progress.weeklyPoems;
  normalized.progress.weeklyReadingCount = data.progress?.weeklyReadingCount ?? defaults.progress.weeklyReadingCount;
  normalized.progress.weeklyChallengeCount = data.progress?.weeklyChallengeCount ?? defaults.progress.weeklyChallengeCount;
  normalized.progress.weeklyStars = data.progress?.weeklyStars ?? defaults.progress.weeklyStars;

  normalized.reading.attempts = data.reading?.attempts ?? defaults.reading.attempts;
  normalized.reading.bestScore = data.reading?.bestScore ?? defaults.reading.bestScore;
  normalized.reading.lastScore = data.reading?.lastScore ?? defaults.reading.lastScore;
  normalized.reading.lastRecordPath = data.reading?.lastRecordPath ?? defaults.reading.lastRecordPath;
  normalized.reading.lastRecordTime = data.reading?.lastRecordTime ?? defaults.reading.lastRecordTime;
  normalized.reading.attemptHistory = Array.isArray(data.reading?.attemptHistory) ? data.reading.attemptHistory.slice(0, 80) : defaults.reading.attemptHistory;

  normalized.challenge.currentLevel = data.challenge?.currentLevel ?? defaults.challenge.currentLevel;
  normalized.challenge.passedLevels = data.challenge?.passedLevels ?? defaults.challenge.passedLevels;
  normalized.challenge.stars = data.challenge?.stars ?? defaults.challenge.stars;
  normalized.challenge.lastCompletedTime = data.challenge?.lastCompletedTime ?? defaults.challenge.lastCompletedTime;

  normalized.study.currentPoemId = data.study?.currentPoemId ?? defaults.study.currentPoemId;
  normalized.study.learnedPoemIds = Array.isArray(data.study?.learnedPoemIds) ? data.study.learnedPoemIds : defaults.study.learnedPoemIds;
  normalized.study.challengePassedPoemIds = Array.isArray(data.study?.challengePassedPoemIds) ? data.study.challengePassedPoemIds : defaults.study.challengePassedPoemIds;
  normalized.study.listenedPoemIds = Array.isArray(data.study?.listenedPoemIds) ? data.study.listenedPoemIds : defaults.study.listenedPoemIds;

  normalized.collection.favoritePoemIds = Array.isArray(data.collection?.favoritePoemIds) ? data.collection.favoritePoemIds : defaults.collection.favoritePoemIds;
  normalized.collection.recentPoemIds = Array.isArray(data.collection?.recentPoemIds) ? data.collection.recentPoemIds : defaults.collection.recentPoemIds;
  normalized.dailyRecords = Array.isArray(data.dailyRecords) ? data.dailyRecords.slice(-120) : defaults.dailyRecords;
  normalized.poemProgressRecords = Array.isArray(data.poemProgressRecords) ? data.poemProgressRecords : defaults.poemProgressRecords;
  normalized.settings.showPinyin = data.settings?.showPinyin ?? defaults.settings.showPinyin;
  normalized.settings.soundEnabled = data.settings?.soundEnabled ?? defaults.settings.soundEnabled;
  normalized.settings.fontScale = data.settings?.fontScale ?? defaults.settings.fontScale;
  normalized.achievements = Array.isArray(data.achievements) ? data.achievements.slice(0, 3) : [];
  refreshProgressFromRecords(normalized);
  return normalized;
}

export function buildWeeklyMetrics(data: PoemBudData): GrowthMetricModel[] {
  return [
    { label: '学习天数', value: `${data.progress.weeklyStudyDays}天`, symbol: '学' },
    { label: '学习古诗', value: `${data.progress.weeklyPoems}首`, symbol: '诗' },
    { label: '跟读练习', value: `${data.progress.weeklyReadingCount}次`, symbol: '读' },
    { label: '闯关练习', value: `${data.progress.weeklyChallengeCount}次`, symbol: '关' },
    { label: '获得星星', value: `${data.progress.weeklyStars}颗`, symbol: '星' }
  ];
}

export interface GrowthMetricModel {
  label: string;
  value: string;
  symbol: string;
}

function markRecentPoem(data: PoemBudData, poemId: string): void {
  const filtered = data.collection.recentPoemIds.filter((item: string) => item !== poemId);
  filtered.unshift(poemId);
  data.collection.recentPoemIds = filtered.slice(0, 6);
  data.study.currentPoemId = poemId;
  const today = getOrCreateTodayRecord(data);
  today.openedPoemIds = addUnique(today.openedPoemIds, poemId);
  const progress = getOrCreatePoemProgress(data, poemId);
  progress.openedCount += 1;
  progress.lastStudyTime = new Date().getTime();
}

function markLearnedPoem(data: PoemBudData, poemId: string): void {
  if (!data.study.learnedPoemIds.includes(poemId)) {
    const nextIds = data.study.learnedPoemIds.slice();
    nextIds.push(poemId);
    data.study.learnedPoemIds = nextIds;
  }
  data.progress.learnedPoems = data.study.learnedPoemIds.length;
}

export function recordPoemListening(data: PoemBudData, poemId: string): PoemBudData {
  const next = clonePoemBudData(data);
  markRecentPoem(next, poemId);
  markLearnedPoem(next, poemId);
  if (!next.study.listenedPoemIds.includes(poemId)) {
    const listenedIds = next.study.listenedPoemIds.slice();
    listenedIds.push(poemId);
    next.study.listenedPoemIds = listenedIds;
  }
  next.progress.todayMinutes += 1;
  const today = getOrCreateTodayRecord(next);
  today.studyMinutes += 1;
  today.listenedPoemIds = addUnique(today.listenedPoemIds, poemId);
  const progress = getOrCreatePoemProgress(next, poemId);
  progress.listenedCount += 1;
  progress.lastStudyTime = new Date().getTime();
  refreshProgressFromRecords(next);
  return next;
}

export function recordReadingResult(
  data: PoemBudData,
  poemId: string,
  score: number,
  recordPath: string,
  lineIndex: number = 0,
  lineText: string = '',
  durationSeconds: number = 0
): PoemBudData {
  const next = clonePoemBudData(data);
  const now = new Date().getTime();
  const rewardStars = Math.max(2, Math.min(5, durationSeconds >= 8 ? 5 : durationSeconds >= 4 ? 4 : 3));
  markRecentPoem(next, poemId);
  markLearnedPoem(next, poemId);
  next.reading.attempts += 1;
  next.reading.lastScore = score;
  next.reading.bestScore = Math.max(next.reading.bestScore, score);
  next.reading.lastRecordPath = recordPath;
  next.reading.lastRecordTime = now;
  const attempt: ReadingAttemptData = {
    poemId,
    lineIndex,
    lineText,
    recordPath,
    durationSeconds,
    rewardStars,
    createdAt: now
  };
  const history = next.reading.attemptHistory.slice();
  history.unshift(attempt);
  next.reading.attemptHistory = history.slice(0, 80);
  const today = getOrCreateTodayRecord(next);
  today.readingCount += 1;
  today.studyMinutes += 2;
  today.stars += rewardStars;
  const progress = getOrCreatePoemProgress(next, poemId);
  progress.readingCount += 1;
  progress.lastStudyTime = now;
  next.progress.totalStars += rewardStars;
  next.progress.todayMinutes += 2;
  next.progress.learnedPoems = Math.max(next.progress.learnedPoems, 1);
  refreshProgressFromRecords(next);
  prependAchievement(next, `完成一次跟读练习，获得${rewardStars}颗星星`);
  return next;
}

export function completeChallenge(data: PoemBudData, poemId: string): PoemBudData {
  const next = clonePoemBudData(data);
  const now = new Date().getTime();
  markRecentPoem(next, poemId);
  markLearnedPoem(next, poemId);
  const progress = getOrCreatePoemProgress(next, poemId);
  if (progress.challengePassedCount < next.challenge.currentLevel) {
    next.challenge.passedLevels = Math.max(next.challenge.passedLevels, next.challenge.currentLevel);
    next.challenge.stars += 3;
    next.challenge.lastCompletedTime = now;
    if (!next.study.challengePassedPoemIds.includes(poemId)) {
      const passedIds = next.study.challengePassedPoemIds.slice();
      passedIds.push(poemId);
      next.study.challengePassedPoemIds = passedIds;
    }
    const today = getOrCreateTodayRecord(next);
    today.challengeCount += 1;
    today.studyMinutes += 2;
    today.stars += 3;
    progress.challengePassedCount = Math.max(progress.challengePassedCount, next.challenge.currentLevel);
    progress.mastered = progress.challengePassedCount >= 3;
    progress.lastStudyTime = now;
    next.progress.totalStars += 3;
    next.progress.masteredPoems = next.study.challengePassedPoemIds.length;
    next.progress.learnedPoems = Math.max(next.progress.learnedPoems, next.challenge.currentLevel);
    refreshProgressFromRecords(next);
    prependAchievement(next, `通过第${next.challenge.currentLevel}关，获得3颗星星`);
  }
  return next;
}

export function signInLocalProfile(data: PoemBudData): PoemBudData {
  const next = clonePoemBudData(data);
  next.profile.loggedIn = true;
  next.profile.name = '小诗童';
  next.profile.userId = 'LOCAL-POEM';
  next.profile.title = '诗词初学者';
  next.profile.level = Math.max(next.profile.level, 1);
  return next;
}

export function advanceChallengeLevel(data: PoemBudData): PoemBudData {
  const next = clonePoemBudData(data);
  next.challenge.currentLevel = Math.min(MAX_CHALLENGE_LEVEL, next.challenge.currentLevel + 1);
  next.challenge.lastCompletedTime = 0;
  return next;
}

export function openPoemLearning(data: PoemBudData, poemId: string): PoemBudData {
  const next = clonePoemBudData(data);
  markRecentPoem(next, poemId);
  refreshProgressFromRecords(next);
  return next;
}

export function toggleFavoritePoem(data: PoemBudData, poemId: string): PoemBudData {
  const next = clonePoemBudData(data);
  const currentIds = next.collection.favoritePoemIds.slice();
  const targetIndex = currentIds.indexOf(poemId);
  if (targetIndex >= 0) {
    currentIds.splice(targetIndex, 1);
  } else {
    currentIds.push(poemId);
  }
  next.collection.favoritePoemIds = currentIds;
  return next;
}

export function updateSettings(data: PoemBudData, settings: SettingsData): PoemBudData {
  const next = clonePoemBudData(data);
  next.settings = settings;
  return next;
}

export function resetLocalStudyData(data: PoemBudData): PoemBudData {
  const next = createDefaultPoemBudData();
  next.profile = data.profile;
  next.settings = data.settings;
  return next;
}

export class PoemBudStore {
  static async load(): Promise<PoemBudData> {
    const prefs = await PreferencesManager.getPreferences(STORE_NAME);
    const stored = await prefs.get(DATA_KEY, '');
    if (typeof stored === 'string' && stored.length > 0) {
      try {
        const parsed = JSON.parse(stored) as PoemBudData;
        if (parsed.schemaVersion !== SCHEMA_VERSION) {
          const defaults = createDefaultPoemBudData();
          console.info(`[PoemBud] reset old preferences schema=${parsed.schemaVersion}`);
          await PoemBudStore.save(defaults);
          return defaults;
        }
        console.info(`[PoemBud] load prefs loggedIn=${parsed.profile.loggedIn} level=${parsed.profile.level} todayMinutes=${parsed.progress.todayMinutes}`);
        return normalizePoemBudData(parsed);
      } catch (_err) {
        const defaults = createDefaultPoemBudData();
        console.info('[PoemBud] reset invalid preferences payload');
        await PoemBudStore.save(defaults);
        return defaults;
      }
    }

    const defaults = createDefaultPoemBudData();
    console.info('[PoemBud] create default preferences');
    await PoemBudStore.save(defaults);
    return defaults;
  }

  static async save(data: PoemBudData): Promise<void> {
    const prefs = await PreferencesManager.getPreferences(STORE_NAME);
    console.info(`[PoemBud] save prefs loggedIn=${data.profile.loggedIn} level=${data.profile.level} todayMinutes=${data.progress.todayMinutes} weeklyGoal=${data.progress.weeklyGoalPercent}`);
    await prefs.put(DATA_KEY, JSON.stringify(data));
    await prefs.flush();
  }
}
