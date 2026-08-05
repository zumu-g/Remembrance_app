// Daily post scheduler — submits one post per day from the post bank for approval
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { createPost, getPost, getRecentPosts, updateImageUrls } from './db.js';
import { notifyNewPost } from './bot.js';
import { generateSlideImages, isFalConfigured, fallbackImagePrompt } from './image-gen.js';
import type { DraftPost } from './types.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const POSTS_DIR = path.join(__dirname, '..', '..', 'posts');
const STATE_FILE = path.join(__dirname, '..', 'scheduler-state.json');

interface SchedulerState {
  lastPostedIndex: number;
  lastPostedDate: string;
  postedIds: number[]; // post bank indices already used
}

interface ParsedPost {
  index: number;
  title: string;
  hook: string;
  caption: string;
  imagePrompts: string[];
  audioDirection: string;
  hashtags: string;
}

function loadState(): SchedulerState {
  try {
    const data = fs.readFileSync(STATE_FILE, 'utf-8');
    return JSON.parse(data);
  } catch {
    return { lastPostedIndex: -1, lastPostedDate: '', postedIds: [] };
  }
}

function saveState(state: SchedulerState): void {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

// Parse a full post file (post-01.md through post-05.md)
function parseFullPost(content: string, index: number): ParsedPost {
  const titleMatch = content.match(/^# (.+)/m);
  const hookMatch = content.match(/## Hook.*\n+"?([^"]+)"?/m) || content.match(/\*\*Hook:\*\* "?([^"]+)"?/m);
  const captionMatch = content.match(/## Caption\n+([\s\S]*?)(?=\n##|\n---|\n*$)/);
  const audioMatch = content.match(/## Audio Direction\n+([\s\S]*?)(?=\n##|\n---|\n*$)/);

  // Extract image prompts (slides 1-3 and 6 only — slides 4-5 are app screenshots)
  const imagePrompts: string[] = [];
  const slideMatches = content.matchAll(/### Slide \d+ — .+\n+([\s\S]*?)(?=\n###|\n##|\n*$)/g);
  for (const match of slideMatches) {
    const prompt = match[1].trim();
    if (!prompt.startsWith('USE ACTUAL APP SCREENSHOT')) {
      imagePrompts.push(prompt);
    }
  }

  const caption = captionMatch ? captionMatch[1].trim() : '';
  // Split hashtags from caption
  const hashtagLine = caption.match(/(#\w+[\s#]*)+$/);

  return {
    index,
    title: titleMatch ? titleMatch[1] : `Post ${index + 1}`,
    hook: hookMatch ? hookMatch[1].trim().replace(/^"|"$/g, '') : '',
    caption: hashtagLine ? caption.replace(hashtagLine[0], '').trim() : caption,
    imagePrompts,
    audioDirection: audioMatch ? audioMatch[1].trim() : '',
    hashtags: hashtagLine ? hashtagLine[0].trim() : '',
  };
}

// Parse a hook from the hook bank file (posts 06-20)
function parseHookBankEntry(block: string, index: number): ParsedPost {
  const hookMatch = block.match(/\*\*Hook:\*\* "?([^"]+)"?/);
  const captionMatch = block.match(/\*\*Caption:\*\* ([\s\S]*?)(?=\n\*\*|\n---|\n##|$)/);
  const hashtagMatch = block.match(/\*\*Hashtags:\*\* (.+)/);
  const titleMatch = block.match(/## Post \d+ — "(.+)"/);

  return {
    index,
    title: titleMatch ? titleMatch[1] : `Hook Bank Post ${index + 1}`,
    hook: hookMatch ? hookMatch[1].trim().replace(/^"|"$/g, '') : '',
    caption: captionMatch ? captionMatch[1].trim() : '',
    imagePrompts: [], // Hook bank posts don't have image prompts
    audioDirection: '',
    hashtags: hashtagMatch ? hashtagMatch[1].trim() : '',
  };
}

// Load all posts from the post bank
function loadPostBank(): ParsedPost[] {
  const posts: ParsedPost[] = [];

  // Load full posts (01-05)
  for (let i = 1; i <= 5; i++) {
    const filename = `post-${String(i).padStart(2, '0')}.md`;
    const filepath = path.join(POSTS_DIR, filename);
    try {
      const content = fs.readFileSync(filepath, 'utf-8');
      posts.push(parseFullPost(content, posts.length));
    } catch {
      console.log(`[Scheduler] Skipping ${filename} — not found`);
    }
  }

  // Load hook bank (06-20)
  const hookBankPath = path.join(POSTS_DIR, 'post-06-to-20-hooks.md');
  try {
    const content = fs.readFileSync(hookBankPath, 'utf-8');
    const blocks = content.split(/\n(?=## Post \d+)/);
    for (const block of blocks) {
      if (block.match(/## Post \d+/)) {
        posts.push(parseHookBankEntry(block, posts.length));
      }
    }
  } catch {
    console.log('[Scheduler] Hook bank file not found');
  }

  return posts;
}

// Get today's date as YYYY-MM-DD
function todayStr(): string {
  return new Date().toISOString().split('T')[0];
}

// Submit the next post from the bank
export async function submitNextPost(): Promise<{ submitted: boolean; message: string }> {
  const state = loadState();
  const today = todayStr();

  // Already posted today
  if (state.lastPostedDate === today) {
    return { submitted: false, message: 'Already submitted a post today.' };
  }

  const bank = loadPostBank();
  if (bank.length === 0) {
    return { submitted: false, message: 'Post bank is empty.' };
  }

  // Find next unposted entry
  const nextIndex = state.postedIds.length;
  if (nextIndex >= bank.length) {
    return { submitted: false, message: 'All posts in the bank have been used. Add more content to marketing/posts/.' };
  }

  const post = bank[nextIndex];

  // Build caption with hashtags
  const fullCaption = post.hashtags
    ? `${post.caption}\n\n${post.hashtags}`
    : post.caption;

  const draft: DraftPost = {
    hook: post.hook,
    caption: fullCaption,
    imagePrompts: post.imagePrompts.length > 0 ? post.imagePrompts : [fallbackImagePrompt(post.hook)],
    audioDirection: post.audioDirection || undefined,
    notes: `Auto-submitted from post bank: ${post.title}`,
    platform: 'both',
  };

  // Create post in DB
  const id = createPost(draft);

  // Generate images if prompts provided and fal.ai configured
  if (isFalConfigured() && draft.imagePrompts && draft.imagePrompts.length > 0) {
    console.log(`[Scheduler] Generating ${draft.imagePrompts.length} images for post #${id}...`);
    try {
      const urls = await generateSlideImages(draft.imagePrompts);
      if (urls.length > 0) {
        updateImageUrls(id, urls);
      }
    } catch (err) {
      console.error('[Scheduler] Image generation failed:', err);
    }
  }

  const record = getPost(id);
  if (!record) {
    return { submitted: false, message: 'Failed to create post record.' };
  }

  // Send to Telegram for approval
  await notifyNewPost(record);

  // Update state
  state.lastPostedIndex = nextIndex;
  state.lastPostedDate = today;
  state.postedIds.push(nextIndex);
  saveState(state);

  console.log(`[Scheduler] Post #${id} submitted: "${post.hook.slice(0, 50)}..."`);
  return {
    submitted: true,
    message: `Post #${id} submitted for approval: "${post.hook}"`,
  };
}

// Calculate ms until next target time
function msUntilNext(hour: number, minute: number): number {
  const now = new Date();
  const target = new Date(now);
  target.setHours(hour, minute, 0, 0);

  // If target time already passed today, schedule for tomorrow
  if (target.getTime() <= now.getTime()) {
    target.setDate(target.getDate() + 1);
  }

  return target.getTime() - now.getTime();
}

// Start the daily scheduler
export function startScheduler(hour = 9, minute = 0): void {
  const scheduleNext = () => {
    const ms = msUntilNext(hour, minute);
    const nextRun = new Date(Date.now() + ms);
    console.log(`[Scheduler] Next post at ${nextRun.toLocaleString()} (in ${Math.round(ms / 60000)} minutes)`);

    setTimeout(async () => {
      try {
        const result = await submitNextPost();
        console.log(`[Scheduler] ${result.message}`);
      } catch (err) {
        console.error('[Scheduler] Error:', err);
      }
      // Schedule next day
      scheduleNext();
    }, ms);
  };

  console.log(`📅 Daily scheduler active — posts at ${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')} each day`);
  scheduleNext();
}
