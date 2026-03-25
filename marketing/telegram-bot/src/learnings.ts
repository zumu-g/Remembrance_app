import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { getTopPosts, getCategoryPerformance, getPostsWithMetrics, getAllPublishedPostsWithMetrics } from './db.js';
import type { TopPost, CategoryPerformance } from './db.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LEARNINGS_PATH = path.join(__dirname, '..', 'learnings.json');

// --- Types ---

export interface BestPerformingHook {
  id: number;
  hook: string;
  views: number;
  category: string;
  engagement: number;
}

export interface Learnings {
  lastUpdated: string;
  totalPostsAnalyzed: number;
  topCategories: string[];
  weakCategories: string[];
  topWords: string[];
  topEmojis: string[];
  avgEngagementRate: number;
  bestPerformingHooks: BestPerformingHook[];
  recommendations: string[];
  hookTemplates: string[];
  bestPostingHours: number[];
}

// --- Word / Emoji extraction helpers ---

const STOP_WORDS = new Set([
  'the', 'a', 'an', 'i', 'me', 'my', 'you', 'your', 'we', 'our', 'it', 'its',
  'is', 'was', 'are', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
  'do', 'does', 'did', 'will', 'would', 'could', 'should', 'can', 'may',
  'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as', 'into',
  'and', 'but', 'or', 'so', 'if', 'not', 'no', 'this', 'that', 'these',
  'those', 'what', 'which', 'who', 'when', 'where', 'how', 'all', 'each',
  'just', 'about', 'up', 'out', 'than', 'then', 'them', 'they', 'their',
  'there', 'here', 'some', 'any', 'only', 'very', 'too', 'also', 'more',
  'after', 'before', 'she', 'he', 'her', 'him', 'his', 'get', 'got',
  'make', 'made', 'one', 'two', 'don', 'didn', 'doesn', 'won', 'isn',
  'like', 'know', 'think', 'see', 'say', 'said', 'tell', 'told',
]);

function extractWords(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[^a-z\s'-]/g, '')
    .split(/\s+/)
    .filter((w) => w.length > 2 && !STOP_WORDS.has(w));
}

function extractEmojis(text: string): string[] {
  const emojiRegex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{200D}\u{20E3}]/gu;
  return text.match(emojiRegex) || [];
}

function countFrequency(items: string[]): Map<string, number> {
  const freq = new Map<string, number>();
  for (const item of items) {
    freq.set(item, (freq.get(item) || 0) + 1);
  }
  return freq;
}

function topN(freq: Map<string, number>, n: number): string[] {
  return [...freq.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, n)
    .map(([key]) => key);
}

function extractHour(dateStr: string | null): number | null {
  if (!dateStr) return null;
  const match = dateStr.match(/(\d{2}):\d{2}:\d{2}/);
  return match ? parseInt(match[1], 10) : null;
}

// --- Core analysis ---

export async function generateLearnings(): Promise<Learnings> {
  const allPosts = getAllPublishedPostsWithMetrics();
  const catPerf = getCategoryPerformance();

  if (allPosts.length === 0) {
    const empty: Learnings = {
      lastUpdated: new Date().toISOString(),
      totalPostsAnalyzed: 0,
      topCategories: [],
      weakCategories: [],
      topWords: [],
      topEmojis: [],
      avgEngagementRate: 0,
      bestPerformingHooks: [],
      recommendations: ['No published posts with metrics yet. Use /report to log post performance.'],
      hookTemplates: [],
      bestPostingHours: [],
    };
    fs.writeFileSync(LEARNINGS_PATH, JSON.stringify(empty, null, 2));
    return empty;
  }

  // --- Percentile thresholds ---
  const sortedByViews = [...allPosts].sort((a, b) => b.total_views - a.total_views);
  const top20Index = Math.max(1, Math.ceil(allPosts.length * 0.2));
  const bottom50Index = Math.ceil(allPosts.length * 0.5);

  const topPosts = sortedByViews.slice(0, top20Index);
  const bottomPosts = sortedByViews.slice(bottom50Index);

  // --- Category analysis ---
  const overallAvgViews = allPosts.reduce((sum, p) => sum + p.total_views, 0) / allPosts.length;

  const topCategories = catPerf
    .filter((c) => c.avg_views >= overallAvgViews)
    .map((c) => c.hook_category);

  const weakCategories = catPerf
    .filter((c) => c.avg_views < overallAvgViews * 0.5)
    .map((c) => c.hook_category);

  // --- Word analysis on top vs bottom ---
  const topWords = extractWords(topPosts.map((p) => p.hook).join(' '));
  const bottomWords = new Set(extractWords(bottomPosts.map((p) => p.hook).join(' ')));

  // Words that appear in top posts but are rare in bottom posts
  const topWordFreq = countFrequency(topWords);
  // Remove words that are equally common in bottom posts
  for (const word of bottomWords) {
    const topCount = topWordFreq.get(word) || 0;
    if (topCount <= 1) {
      topWordFreq.delete(word);
    }
  }

  const bestWords = topN(topWordFreq, 10);

  // --- Emoji analysis ---
  const topEmojis = extractEmojis(topPosts.map((p) => `${p.hook} ${p.caption}`).join(' '));
  const emojiFreq = countFrequency(topEmojis);
  const bestEmojis = topN(emojiFreq, 5);

  // --- Engagement rate ---
  const totalEngagement = allPosts.reduce((sum, p) => sum + p.avg_engagement, 0);
  const avgEngagementRate = parseFloat((totalEngagement / allPosts.length).toFixed(4));

  // --- Best performing hooks ---
  const bestPerformingHooks: BestPerformingHook[] = topPosts.slice(0, 5).map((p) => ({
    id: p.id,
    hook: p.hook,
    views: p.total_views,
    category: (p as any).hook_category || 'other',
    engagement: p.avg_engagement,
  }));

  // --- Best posting hours ---
  const hourCounts = new Map<number, { totalViews: number; count: number }>();
  for (const post of allPosts) {
    const hour = extractHour((post as any).published_at);
    if (hour === null) continue;
    const existing = hourCounts.get(hour) || { totalViews: 0, count: 0 };
    existing.totalViews += post.total_views;
    existing.count += 1;
    hourCounts.set(hour, existing);
  }
  const bestPostingHours = [...hourCounts.entries()]
    .sort((a, b) => (b[1].totalViews / b[1].count) - (a[1].totalViews / a[1].count))
    .slice(0, 3)
    .map(([hour]) => hour);

  // --- Generate recommendations ---
  const recommendations: string[] = [];

  if (topCategories.length > 0) {
    const bestCat = catPerf[0];
    if (bestCat && overallAvgViews > 0) {
      const multiplier = (bestCat.avg_views / overallAvgViews).toFixed(1);
      recommendations.push(
        `Double down on '${bestCat.hook_category}' hooks — ${multiplier}x higher avg views`
      );
    }
  }

  if (weakCategories.length > 0) {
    for (const cat of weakCategories) {
      const perf = catPerf.find((c) => c.hook_category === cat);
      if (perf && overallAvgViews > 0) {
        const pctBelow = Math.round((1 - perf.avg_views / overallAvgViews) * 100);
        recommendations.push(
          `Avoid '${cat}' hooks — ${pctBelow}% below average`
        );
      }
    }
  }

  if (bestWords.length > 0) {
    const wordAppearances = bestWords.slice(0, 3);
    recommendations.push(
      `Include '${wordAppearances.join("', '")}' in hooks — appears frequently in top posts`
    );
  }

  if (bestPostingHours.length > 0) {
    const hourLabels = bestPostingHours.map((h) => `${h}:00`).join(', ');
    recommendations.push(
      `Best posting hours: ${hourLabels} (highest avg views)`
    );
  }

  if (avgEngagementRate > 0) {
    const highEngagement = allPosts.filter((p) => p.avg_engagement > avgEngagementRate * 1.5);
    if (highEngagement.length > 0) {
      recommendations.push(
        `${highEngagement.length} post(s) have 1.5x+ engagement — study their comment hooks`
      );
    }
  }

  // --- Generate hook templates ---
  const hookTemplates: string[] = [];
  for (const post of bestPerformingHooks.slice(0, 3)) {
    const hookShort = post.hook.length > 60 ? post.hook.slice(0, 60) + '...' : post.hook;
    if (post.category === 'conflict' || post.category === 'discovery') {
      hookTemplates.push(
        `Based on top post #${post.id}: Try variations of ${post.category} hooks like "${hookShort}"`
      );
    } else if (post.category === 'forgetting' || post.category === 'ritual') {
      hookTemplates.push(
        `Based on top post #${post.id}: Emotional ${post.category} hooks resonate — create similar angle`
      );
    } else {
      hookTemplates.push(
        `Based on top post #${post.id}: Riff on "${hookShort}"`
      );
    }
  }

  const learnings: Learnings = {
    lastUpdated: new Date().toISOString(),
    totalPostsAnalyzed: allPosts.length,
    topCategories,
    weakCategories,
    topWords: bestWords,
    topEmojis: bestEmojis,
    avgEngagementRate,
    bestPerformingHooks,
    recommendations,
    hookTemplates,
    bestPostingHours,
  };

  fs.writeFileSync(LEARNINGS_PATH, JSON.stringify(learnings, null, 2));
  console.log(`[learnings] Saved learnings.json — ${allPosts.length} posts analyzed`);

  return learnings;
}

// --- Load existing learnings ---

export function loadLearnings(): Learnings | null {
  try {
    if (!fs.existsSync(LEARNINGS_PATH)) return null;
    const raw = fs.readFileSync(LEARNINGS_PATH, 'utf-8');
    return JSON.parse(raw) as Learnings;
  } catch {
    return null;
  }
}

// --- Human-readable Telegram summary ---

export function getLearningsSummary(): string {
  const learnings = loadLearnings();
  if (!learnings || learnings.totalPostsAnalyzed === 0) {
    return '📊 <b>No learnings yet.</b>\n\nUse /report to log post metrics first.';
  }

  let text = '🧠 <b>Auto-Learnings Report</b>\n';
  text += `<i>Updated: ${new Date(learnings.lastUpdated).toLocaleDateString()}</i>\n`;
  text += `<i>${learnings.totalPostsAnalyzed} posts analyzed</i>\n\n`;

  // Top categories
  if (learnings.topCategories.length > 0) {
    text += `✅ <b>Winning categories:</b> ${learnings.topCategories.join(', ')}\n`;
  }
  if (learnings.weakCategories.length > 0) {
    text += `⚠️ <b>Weak categories:</b> ${learnings.weakCategories.join(', ')}\n`;
  }
  text += '\n';

  // Top performing hooks
  if (learnings.bestPerformingHooks.length > 0) {
    text += '🏆 <b>Top Hooks:</b>\n';
    for (const hook of learnings.bestPerformingHooks) {
      const hookShort = hook.hook.length > 50 ? hook.hook.slice(0, 50) + '...' : hook.hook;
      text += `  #${hook.id} — ${hook.views.toLocaleString()} views (${hook.category})\n`;
      text += `  "${hookShort}"\n`;
    }
    text += '\n';
  }

  // Key words and emojis
  if (learnings.topWords.length > 0) {
    text += `🔤 <b>Power words:</b> ${learnings.topWords.slice(0, 6).join(', ')}\n`;
  }
  if (learnings.topEmojis.length > 0) {
    text += `🎯 <b>Top emojis:</b> ${learnings.topEmojis.join(' ')}\n`;
  }
  text += `📈 <b>Avg engagement rate:</b> ${(learnings.avgEngagementRate * 100).toFixed(2)}%\n`;

  if (learnings.bestPostingHours.length > 0) {
    text += `⏰ <b>Best hours:</b> ${learnings.bestPostingHours.map((h) => `${h}:00`).join(', ')}\n`;
  }
  text += '\n';

  // Recommendations
  if (learnings.recommendations.length > 0) {
    text += '💡 <b>Recommendations:</b>\n';
    for (const rec of learnings.recommendations) {
      text += `• ${rec}\n`;
    }
    text += '\n';
  }

  // Hook templates
  if (learnings.hookTemplates.length > 0) {
    text += '📝 <b>Hook Ideas:</b>\n';
    for (const tmpl of learnings.hookTemplates) {
      text += `• ${tmpl}\n`;
    }
  }

  return text;
}
