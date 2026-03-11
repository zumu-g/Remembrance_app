import Database from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';
import type { DraftPost, PostRecord, PostStatus, PostMetrics, HookCategory } from './types.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_PATH = path.join(__dirname, '..', 'posts.db');

const db = new Database(DB_PATH);

// Enable WAL mode for better concurrent access
db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS posts (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    hook                TEXT NOT NULL,
    caption             TEXT NOT NULL,
    image_prompts       TEXT,
    image_urls          TEXT,
    audio_direction     TEXT,
    notes               TEXT,
    platform            TEXT DEFAULT 'both',
    status              TEXT DEFAULT 'pending',
    reviewer_note       TEXT,
    telegram_message_id INTEGER,
    telegram_chat_id    INTEGER,
    postiz_post_id      TEXT,
    postiz_response     TEXT,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at         DATETIME,
    published_at        DATETIME
  )
`);

db.exec(`
  CREATE TABLE IF NOT EXISTS metrics (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id         INTEGER NOT NULL,
    platform        TEXT NOT NULL,
    views           INTEGER DEFAULT 0,
    likes           INTEGER DEFAULT 0,
    comments        INTEGER DEFAULT 0,
    shares          INTEGER DEFAULT 0,
    saves           INTEGER DEFAULT 0,
    profile_visits  INTEGER DEFAULT 0,
    downloads_est   INTEGER DEFAULT 0,
    recorded_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id)
  )
`);

// Add hook_category column to posts if it doesn't exist
try {
  db.exec(`ALTER TABLE posts ADD COLUMN hook_category TEXT DEFAULT 'other'`);
} catch {
  // Column already exists
}

const insertStmt = db.prepare(`
  INSERT INTO posts (hook, caption, image_prompts, image_urls, audio_direction, notes, platform)
  VALUES (@hook, @caption, @image_prompts, @image_urls, @audio_direction, @notes, @platform)
`);

const updateStatusStmt = db.prepare(`
  UPDATE posts SET status = @status, reviewed_at = datetime('now') WHERE id = @id
`);

const updateFieldStmt = db.prepare(`
  UPDATE posts SET hook = COALESCE(@hook, hook), caption = COALESCE(@caption, caption) WHERE id = @id
`);

const setTelegramIdsStmt = db.prepare(`
  UPDATE posts SET telegram_message_id = @message_id, telegram_chat_id = @chat_id WHERE id = @id
`);

const setReviewerNoteStmt = db.prepare(`
  UPDATE posts SET reviewer_note = @note, status = 'rejected', reviewed_at = datetime('now') WHERE id = @id
`);

const setPostizStmt = db.prepare(`
  UPDATE posts SET postiz_post_id = @postiz_id, postiz_response = @response, status = 'published', published_at = datetime('now') WHERE id = @id
`);

export function createPost(draft: DraftPost): number {
  const result = insertStmt.run({
    hook: draft.hook,
    caption: draft.caption,
    image_prompts: draft.imagePrompts ? JSON.stringify(draft.imagePrompts) : null,
    image_urls: draft.imageUrls ? JSON.stringify(draft.imageUrls) : null,
    audio_direction: draft.audioDirection ?? null,
    notes: draft.notes ?? null,
    platform: draft.platform ?? 'both',
  });
  return result.lastInsertRowid as number;
}

export function getPost(id: number): PostRecord | undefined {
  return db.prepare('SELECT * FROM posts WHERE id = ?').get(id) as PostRecord | undefined;
}

export function getPendingPosts(): PostRecord[] {
  return db.prepare("SELECT * FROM posts WHERE status = 'pending' ORDER BY created_at DESC").all() as PostRecord[];
}

export function getPostsByStatus(status: PostStatus): PostRecord[] {
  return db.prepare('SELECT * FROM posts WHERE status = ? ORDER BY created_at DESC').all(status) as PostRecord[];
}

export function getRecentPosts(limit = 10): PostRecord[] {
  return db.prepare('SELECT * FROM posts ORDER BY created_at DESC LIMIT ?').all(limit) as PostRecord[];
}

export function getStatusCounts(): Record<string, number> {
  const rows = db.prepare('SELECT status, COUNT(*) as count FROM posts GROUP BY status').all() as Array<{ status: string; count: number }>;
  const counts: Record<string, number> = { pending: 0, approved: 0, rejected: 0, published: 0, failed: 0 };
  for (const row of rows) {
    counts[row.status] = row.count;
  }
  return counts;
}

export function updateStatus(id: number, status: PostStatus): void {
  updateStatusStmt.run({ id, status });
}

export function updateField(id: number, field: 'hook' | 'caption', value: string): void {
  updateFieldStmt.run({
    id,
    hook: field === 'hook' ? value : null,
    caption: field === 'caption' ? value : null,
  });
}

export function setTelegramIds(id: number, messageId: number, chatId: number): void {
  setTelegramIdsStmt.run({ id, message_id: messageId, chat_id: chatId });
}

export function setReviewerNote(id: number, note: string): void {
  setReviewerNoteStmt.run({ id, note });
}

export function setPostizResult(id: number, postizId: string, response: string): void {
  setPostizStmt.run({ id, postiz_id: postizId, response });
}

export function updateImageUrls(id: number, urls: string[]): void {
  db.prepare('UPDATE posts SET image_urls = ? WHERE id = ?').run(JSON.stringify(urls), id);
}

export function setFailed(id: number): void {
  db.prepare("UPDATE posts SET status = 'failed' WHERE id = ?").run(id);
}

// --- Analytics ---

export function recordMetrics(postId: number, platform: string, metrics: {
  views?: number; likes?: number; comments?: number; shares?: number;
  saves?: number; profile_visits?: number; downloads_est?: number;
}): void {
  db.prepare(`
    INSERT INTO metrics (post_id, platform, views, likes, comments, shares, saves, profile_visits, downloads_est)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    postId, platform,
    metrics.views ?? 0, metrics.likes ?? 0, metrics.comments ?? 0,
    metrics.shares ?? 0, metrics.saves ?? 0, metrics.profile_visits ?? 0,
    metrics.downloads_est ?? 0
  );
}

export function getLatestMetrics(postId: number): PostMetrics[] {
  return db.prepare(`
    SELECT * FROM metrics WHERE post_id = ?
    ORDER BY recorded_at DESC
  `).all(postId) as PostMetrics[];
}

export function setHookCategory(postId: number, category: HookCategory): void {
  db.prepare('UPDATE posts SET hook_category = ? WHERE id = ?').run(category, postId);
}

export interface TopPost {
  id: number;
  hook: string;
  hook_category: string;
  total_views: number;
  total_likes: number;
  total_shares: number;
  total_comments: number;
}

export function getTopPosts(limit = 5): TopPost[] {
  return db.prepare(`
    SELECT p.id, p.hook, p.hook_category,
      COALESCE(SUM(m.views), 0) as total_views,
      COALESCE(SUM(m.likes), 0) as total_likes,
      COALESCE(SUM(m.shares), 0) as total_shares,
      COALESCE(SUM(m.comments), 0) as total_comments
    FROM posts p
    LEFT JOIN metrics m ON p.id = m.post_id
    WHERE p.status IN ('published', 'approved')
    GROUP BY p.id
    ORDER BY total_views DESC
    LIMIT ?
  `).all(limit) as TopPost[];
}

export interface CategoryPerformance {
  hook_category: string;
  post_count: number;
  avg_views: number;
  avg_likes: number;
  avg_shares: number;
  total_views: number;
}

export function getCategoryPerformance(): CategoryPerformance[] {
  return db.prepare(`
    SELECT p.hook_category,
      COUNT(DISTINCT p.id) as post_count,
      COALESCE(ROUND(AVG(m.views), 0), 0) as avg_views,
      COALESCE(ROUND(AVG(m.likes), 0), 0) as avg_likes,
      COALESCE(ROUND(AVG(m.shares), 0), 0) as avg_shares,
      COALESCE(SUM(m.views), 0) as total_views
    FROM posts p
    LEFT JOIN metrics m ON p.id = m.post_id
    WHERE p.status IN ('published', 'approved')
    GROUP BY p.hook_category
    ORDER BY avg_views DESC
  `).all() as CategoryPerformance[];
}

export function getPostsWithMetrics(): Array<PostRecord & { total_views: number }> {
  return db.prepare(`
    SELECT p.*, COALESCE(SUM(m.views), 0) as total_views
    FROM posts p
    LEFT JOIN metrics m ON p.id = m.post_id
    WHERE p.status IN ('published', 'approved')
    GROUP BY p.id
    ORDER BY p.created_at DESC
  `).all() as Array<PostRecord & { total_views: number }>;
}

export { db };
