import { Telegraf, Markup } from 'telegraf';
import type { Context } from 'telegraf';
import https from 'https';
import { authMiddleware } from './utils/auth.js';
import { formatPostPreview, formatPostSummary } from './utils/format.js';
import * as db from './db.js';
import { createPostizDraft, isPostizConfigured } from './postiz.js';
import { generateSlideImages, isFalConfigured, fallbackImagePrompt } from './image-gen.js';
import type { AwaitingInput, PostRecord } from './types.js';

// TikTok/Instagram require images. Older posts (hook-bank) were created without
// any — generate them on demand at publish time so /post_ID retries recover.
async function ensureImages(post: PostRecord): Promise<string[]> {
  const existing = post.image_urls ? JSON.parse(post.image_urls) as string[] : [];
  if (existing.length > 0 || !isFalConfigured()) return existing;
  const prompts = post.image_prompts
    ? JSON.parse(post.image_prompts) as string[]
    : [fallbackImagePrompt(post.hook)];
  const urls = await generateSlideImages(prompts, post.id);
  if (urls.length > 0) db.updateImageUrls(post.id, urls);
  return urls;
}

// IPv4-safe Telegram API helper — bypasses node-fetch entirely
export function telegramPost(method: string, body: Record<string, unknown>): Promise<any> {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(body);
    const req = https.request(
      {
        hostname: 'api.telegram.org',
        path: `/bot${process.env.TELEGRAM_BOT_TOKEN}/${method}`,
        method: 'POST',
        family: 4,
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
        },
        timeout: 15000,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            if (!json.ok) reject(new Error(json.description || 'API error'));
            else resolve(json.result);
          } catch {
            reject(new Error(`Invalid JSON: ${data.slice(0, 100)}`));
          }
        });
      }
    );
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Request timeout')); });
    req.write(postData);
    req.end();
  });
}

// Helper: send a text message via IPv4
async function sendMsg(chatId: number, text: string, opts: Record<string, unknown> = {}): Promise<any> {
  return telegramPost('sendMessage', { chat_id: chatId, text, ...opts });
}

// Helper: send message with approval buttons
async function sendPostWithButtons(chatId: number, post: PostRecord): Promise<any> {
  const text = formatPostPreview(post);
  return sendMsg(chatId, text, {
    parse_mode: 'HTML',
    reply_markup: {
      inline_keyboard: [
        [
          { text: '✅ Approve', callback_data: `approve_${post.id}` },
          { text: '❌ Reject', callback_data: `reject_${post.id}` },
        ],
        [
          { text: '✏️ Edit Hook', callback_data: `edit_hook_${post.id}` },
          { text: '✏️ Edit Caption', callback_data: `edit_caption_${post.id}` },
        ],
        [
          { text: '🚀 Direct Publish', callback_data: `direct_${post.id}` },
        ],
      ],
    },
  });
}

const bot = new Telegraf(process.env.TELEGRAM_BOT_TOKEN!);

// Track conversation state for edits/rejections
const awaitingInput = new Map<number, AwaitingInput>();

// Auth middleware — only respond to authorized user
bot.use(authMiddleware);

// /start command
bot.start(async (ctx) => {
  await sendMsg(ctx.chat.id,
    '🟢 <b>Remembrance Marketing Bot</b>\n\n' +
    'I help you review and approve social media posts.\n\n' +
    '<b>Commands:</b>\n' +
    '/newpost — Generate a new post for approval\n' +
    '/pending — View pending posts\n' +
    '/stats — Post counts by status\n' +
    '/history — Recent posts\n' +
    '/report — Log post metrics\n' +
    '/insights — See what\'s working\n' +
    '/learnings — Auto-analyze what\'s working\n' +
    '/analytics — Live performance data\n' +
    '/help — Show this message\n\n' +
    'Posts arrive for your approval. Tap ✅ Approve for Blotato drafts or 🚀 Direct Publish to go live instantly with auto-trending music.',
    { parse_mode: 'HTML' }
  );
});

bot.help(async (ctx) => {
  await sendMsg(ctx.chat.id,
    '<b>Commands:</b>\n' +
    '/newpost — Generate a new post for approval\n' +
    '/pending — View all posts waiting for approval\n' +
    '/stats — See counts by status\n' +
    '/history — Last 10 posts\n' +
    '/post_ID — View a specific post (e.g. /post_3)\n' +
    '/report — Log metrics (e.g. /report 3 tiktok 50000 2300 145 890)\n' +
    '/insights — Performance analysis and recommendations\n' +
    '/learnings — Auto-analyze what\'s working\n' +
    '/analytics — Live performance data from Upload-Post\n\n' +
    'When a post arrives, tap:\n' +
    '✅ <b>Approve</b> — sends to Blotato as DRAFT (you publish manually + add audio)\n' +
    '🚀 <b>Direct Publish</b> — posts LIVE instantly with auto-trending music\n' +
    '❌ <b>Reject</b> — asks for a reason\n' +
    '✏️ <b>Edit</b> — modify hook or caption',
    { parse_mode: 'HTML' }
  );
});

// /newpost — generate and submit a new post from the content bank
bot.command('newpost', async (ctx) => {
  const chatId = ctx.chat.id;

  // Show typing indicator so user knows it's working
  await telegramPost('sendChatAction', { chat_id: chatId, action: 'typing' });

  try {
    const { generateAndSubmitPost } = await import('./generate-daily-post.js');
    await generateAndSubmitPost(true);
  } catch (err: any) {
    await sendMsg(chatId, `❌ Failed to generate post: ${err.message?.slice(0, 200) || 'Unknown error'}`);
  }
});

// /pending — list pending posts
bot.command('pending', async (ctx) => {
  const posts = db.getPendingPosts();
  if (posts.length === 0) {
    return sendMsg(ctx.chat.id, 'No pending posts. 🎉');
  }

  const lines = posts.map((p) => formatPostSummary(p));
  await sendMsg(ctx.chat.id,
    `<b>${posts.length} pending post${posts.length > 1 ? 's' : ''}:</b>\n\n${lines.join('\n')}`,
    { parse_mode: 'HTML' }
  );
});

// /stats — counts by status
bot.command('stats', async (ctx) => {
  const counts = db.getStatusCounts();
  await sendMsg(ctx.chat.id,
    `📊 <b>Post Stats</b>\n\n` +
    `🟡 Pending: ${counts.pending}\n` +
    `🟢 Approved: ${counts.approved}\n` +
    `🔴 Rejected: ${counts.rejected}\n` +
    `🚀 Published: ${counts.published}\n` +
    `❌ Failed: ${counts.failed}`,
    { parse_mode: 'HTML' }
  );
});

// /history — recent posts
bot.command('history', async (ctx) => {
  const posts = db.getRecentPosts(10);
  if (posts.length === 0) {
    return sendMsg(ctx.chat.id, 'No posts yet.');
  }

  const lines = posts.map((p) => formatPostSummary(p));
  await sendMsg(ctx.chat.id,
    `<b>Recent posts:</b>\n\n${lines.join('\n')}`,
    { parse_mode: 'HTML' }
  );
});

// /post_ID — view specific post
bot.hears(/^\/post_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match[1], 10);
  const post = db.getPost(id);
  if (!post) {
    return sendMsg(ctx.chat.id, `Post #${id} not found.`);
  }

  if (post.status === 'pending') {
    await sendPostWithButtons(ctx.chat.id, post);
  } else {
    await sendMsg(ctx.chat.id, formatPostPreview(post), { parse_mode: 'HTML' });
  }
});

// /report — log metrics for a post
bot.command('report', async (ctx) => {
  const text = ctx.message.text;
  const parts = text.split(/\s+/).slice(1);

  if (parts.length < 4) {
    return sendMsg(ctx.chat.id,
      '<b>Usage:</b>\n' +
      '<code>/report POST_ID PLATFORM VIEWS LIKES COMMENTS SHARES</code>\n\n' +
      '<b>Example:</b>\n' +
      '<code>/report 3 tiktok 50000 2300 145 890</code>\n\n' +
      'Platform: tiktok, instagram, facebook, twitter, youtube',
      { parse_mode: 'HTML' }
    );
  }

  const postId = parseInt(parts[0], 10);
  const platform = parts[1].toLowerCase();
  const views = parseInt(parts[2], 10) || 0;
  const likes = parseInt(parts[3], 10) || 0;
  const comments = parseInt(parts[4], 10) || 0;
  const shares = parseInt(parts[5], 10) || 0;

  const post = db.getPost(postId);
  if (!post) {
    return sendMsg(ctx.chat.id, `Post #${postId} not found.`);
  }

  db.recordMetrics(postId, platform, { views, likes, comments, shares });

  if (!(post as any).hook_category || (post as any).hook_category === 'other') {
    const category = autoDetectCategory(post.hook);
    db.setHookCategory(postId, category);
  }

  await sendMsg(ctx.chat.id,
    `📊 Metrics recorded for Post #${postId} on ${platform}:\n` +
    `👁 ${views.toLocaleString()} views\n` +
    `❤️ ${likes.toLocaleString()} likes\n` +
    `💬 ${comments.toLocaleString()} comments\n` +
    `🔄 ${shares.toLocaleString()} shares`
  );
});

// /insights — show what's working
bot.command('insights', async (ctx) => {
  const topPosts = db.getTopPosts(5);
  const catPerf = db.getCategoryPerformance();

  if (topPosts.length === 0) {
    return sendMsg(ctx.chat.id, 'No metrics recorded yet. Use /report to log post performance.');
  }

  let text = '📈 <b>Performance Insights</b>\n\n';
  text += '<b>Top Posts:</b>\n';
  topPosts.forEach((p, i) => {
    const hookShort = p.hook.length > 45 ? p.hook.slice(0, 45) + '...' : p.hook;
    text += `${i + 1}. #${p.id} — ${p.total_views.toLocaleString()} views\n`;
    text += `   "${hookShort}"\n`;
  });

  if (catPerf.length > 0) {
    text += '\n<b>Hook Category Performance:</b>\n';
    catPerf.forEach(c => {
      const bar = '█'.repeat(Math.min(Math.round(c.avg_views / (catPerf[0].avg_views || 1) * 10), 10));
      text += `${c.hook_category}: ${bar} ${c.avg_views.toLocaleString()} avg views (${c.post_count} posts)\n`;
    });
  }

  if (catPerf.length >= 2) {
    const best = catPerf[0];
    const worst = catPerf[catPerf.length - 1];
    text += `\n<b>Recommendation:</b>\n`;
    text += `Double down on <b>${best.hook_category}</b> hooks (${best.avg_views.toLocaleString()} avg views).\n`;
    if (worst.avg_views < best.avg_views * 0.3) {
      text += `Consider retiring <b>${worst.hook_category}</b> hooks (${worst.avg_views.toLocaleString()} avg views).\n`;
    }
  }

  const viralPosts = topPosts.filter(p => p.total_views >= 50000);
  if (viralPosts.length > 0) {
    text += `\n🔥 <b>${viralPosts.length} post(s) over 50K views!</b> Create variations of:\n`;
    viralPosts.forEach(p => {
      text += `• #${p.id}: "${p.hook.slice(0, 50)}..."\n`;
    });
  }

  await sendMsg(ctx.chat.id, text, { parse_mode: 'HTML' });
});

// /learnings — generate and show auto-learnings
bot.command('learnings', async (ctx) => {
  const chatId = ctx.chat.id;
  await telegramPost('sendChatAction', { chat_id: chatId, action: 'typing' });

  try {
    const { generateLearnings, getLearningsSummary } = await import('./learnings.js');
    await generateLearnings();
    const summary = getLearningsSummary();
    await sendMsg(chatId, summary, { parse_mode: 'HTML' });
  } catch (err: any) {
    await sendMsg(chatId, `❌ Failed to generate learnings: ${err.message?.slice(0, 200)}`);
  }
});

// /analytics — fetch live analytics from Upload-Post
bot.command('analytics', async (ctx) => {
  const chatId = ctx.chat.id;
  await telegramPost('sendChatAction', { chat_id: chatId, action: 'typing' });

  try {
    const { isUploadPostConfigured, fetchAnalytics } = await import('./upload-post.js');

    if (!isUploadPostConfigured()) {
      await sendMsg(chatId, 'Upload-Post not configured. Set UPLOADPOST_TOKEN and UPLOADPOST_USER env vars.');
      return;
    }

    const username = process.env.UPLOADPOST_PROFILE_USERNAME || 'remembranceapp';
    const data = await fetchAnalytics(username, 7);

    let text = `📊 <b>Analytics — @${username} (7 days)</b>\n\n`;
    text += `👥 Followers: ${data.followers?.toLocaleString() || 'N/A'}\n`;
    text += `👁 Total Impressions: ${data.totalImpressions?.toLocaleString() || 'N/A'}\n\n`;

    if (data.posts && data.posts.length > 0) {
      text += `<b>Recent Posts:</b>\n`;
      data.posts.slice(0, 5).forEach((p, i) => {
        text += `${i + 1}. ${p.views?.toLocaleString() || 0} views, ${p.likes?.toLocaleString() || 0} likes\n`;
      });
    }

    if (data.dailyBreakdown && data.dailyBreakdown.length > 0) {
      text += `\n<b>Daily Views:</b>\n`;
      data.dailyBreakdown.forEach(d => {
        const bar = '█'.repeat(Math.min(Math.round((d.views || d.impressions || 0) / 1000), 20));
        text += `${d.date}: ${bar} ${(d.views || d.impressions || 0).toLocaleString()}\n`;
      });
    }

    await sendMsg(chatId, text, { parse_mode: 'HTML' });
  } catch (err: any) {
    await sendMsg(chatId, `❌ Analytics fetch failed: ${err.message?.slice(0, 200)}`);
  }
});

// --- Inline keyboard callbacks ---

// Approve
bot.action(/^approve_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  const post = db.getPost(id);
  if (!post) {
    await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Post not found.' });
    return;
  }

  db.updateStatus(id, 'approved');
  await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Approved! ✅' });

  // Update the original message
  if (ctx.callbackQuery.message) {
    await telegramPost('editMessageText', {
      chat_id: chatId,
      message_id: ctx.callbackQuery.message.message_id,
      text: formatPostPreview({ ...post, status: 'approved' }),
      parse_mode: 'HTML',
    }).catch(() => {}); // ignore if message hasn't changed
  }

  // Try to send to Postiz
  if (isPostizConfigured()) {
    try {
      const imageUrls = await ensureImages(post);
      const integrationIds = getIntegrationIds(post.platform);

      const result = await createPostizDraft({
        caption: `${post.hook}\n\n${post.caption}`,
        imageUrls,
        integrationIds,
      });

      db.setPostizResult(id, result.id, JSON.stringify(result));
      await sendMsg(chatId,
        `🚀 Post #${id} sent to Blotato as <b>draft</b>.\n\n` +
        `<b>Next steps:</b>\n` +
        `1. Open TikTok — check notifications for draft\n` +
        `2. Add trending audio\n` +
        `3. Publish manually\n\n` +
        `After publishing, log metrics with:\n` +
        `<code>/report ${id} tiktok VIEWS LIKES COMMENTS SHARES</code>`,
        { parse_mode: 'HTML' }
      );
    } catch (err) {
      db.setFailed(id);
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      await sendMsg(chatId,
        `❌ Failed to send Post #${id} to Blotato: ${errorMsg}\n\nUse /post_${id} to retry.`
      );
    }
  } else {
    await sendMsg(chatId, `✅ Post #${id} approved. Blotato not configured — publish manually.`);
  }
});

// Direct publish via Upload-Post API
bot.action(/^direct_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  const post = db.getPost(id);
  if (!post) {
    await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Post not found.' });
    return;
  }

  const { isUploadPostConfigured, publishDirect } = await import('./upload-post.js');

  if (!isUploadPostConfigured()) {
    await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Upload-Post not configured. Set UPLOADPOST_TOKEN and UPLOADPOST_USER.' });
    return;
  }

  db.updateStatus(id, 'approved');
  await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Publishing directly... 🚀' });

  // Update the original message
  if (ctx.callbackQuery.message) {
    await telegramPost('editMessageText', {
      chat_id: chatId,
      message_id: ctx.callbackQuery.message.message_id,
      text: formatPostPreview({ ...post, status: 'approved' }),
      parse_mode: 'HTML',
    }).catch(() => {});
  }

  try {
    const imageUrls = await ensureImages(post);
    const profileUsername = process.env.UPLOADPOST_PROFILE_USERNAME || 'remembranceapp';

    const result = await publishDirect({
      caption: `${post.hook}\n\n${post.caption}`,
      imageUrls,
      platform: (post.platform as 'tiktok' | 'instagram' | 'both') || 'both',
      profileUsername,
      autoAddMusic: true,
    });

    db.setPostizResult(id, result.requestId, JSON.stringify(result));
    await sendMsg(chatId,
      `🚀 Post #${id} published DIRECTLY to live feed!\n\n` +
      `✅ Auto-trending music added on TikTok\n` +
      `✅ Posted to ${result.platforms?.join(' + ') || post.platform}\n` +
      `📊 Request ID: ${result.requestId}\n\n` +
      `No manual steps needed! Track with:\n` +
      `<code>/report ${id} tiktok VIEWS LIKES COMMENTS SHARES</code>`,
      { parse_mode: 'HTML' }
    );
  } catch (err) {
    db.setFailed(id);
    const errorMsg = err instanceof Error ? err.message : 'Unknown error';
    await sendMsg(chatId,
      `❌ Direct publish failed for Post #${id}: ${errorMsg}\n\nFalling back to Blotato draft with /post_${id}`
    );
  }
});

// Reject — ask for reason
bot.action(/^reject_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'reject_reason' });
  await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Send me the reason for rejection.' });
  await sendMsg(chatId, `Why are you rejecting Post #${id}? Reply with your reason:`, {
    reply_markup: { force_reply: true },
  });
});

// Edit hook
bot.action(/^edit_hook_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'hook' });
  await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Send me the new hook.' });
  await sendMsg(chatId, `Send the new hook for Post #${id}:`, {
    reply_markup: { force_reply: true },
  });
});

// Edit caption
bot.action(/^edit_caption_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'caption' });
  await telegramPost('answerCallbackQuery', { callback_query_id: ctx.callbackQuery.id, text: 'Send me the new caption.' });
  await sendMsg(chatId, `Send the new caption for Post #${id}:`, {
    reply_markup: { force_reply: true },
  });
});

// Handle text input for edits and rejections
bot.on('text', async (ctx) => {
  const chatId = ctx.chat.id;
  const msgText = ctx.message.text;
  const pending = awaitingInput.get(chatId);

  if (!pending) {
    // Natural language triggers for creating a new post
    const lower = msgText.toLowerCase().trim();
    if (lower.includes('new post') || lower.includes('newpost') || lower.includes('create post') || lower.includes('generate post') || lower.includes('make a post') || lower.includes('next post')) {
      await telegramPost('sendChatAction', { chat_id: chatId, action: 'typing' });
      try {
        const { generateAndSubmitPost } = await import('./generate-daily-post.js');
        await generateAndSubmitPost(true);
      } catch (err: any) {
        await sendMsg(chatId, `❌ Failed to generate post: ${err.message?.slice(0, 200) || 'Unknown error'}`);
      }
    }
    return;
  }

  const { postId, field } = pending;
  const text = msgText;
  awaitingInput.delete(chatId);

  const post = db.getPost(postId);
  if (!post) {
    return sendMsg(chatId, `Post #${postId} not found.`);
  }

  if (field === 'reject_reason') {
    db.setReviewerNote(postId, text);
    await sendMsg(chatId, `🔴 Post #${postId} rejected.\nReason: ${text}`);
    return;
  }

  if (field === 'metrics') return;

  // Edit hook or caption
  db.updateField(postId, field as 'hook' | 'caption', text);
  const updated = db.getPost(postId)!;
  await sendPostWithButtons(chatId, updated);
});

function autoDetectCategory(hook: string): import('./types.js').HookCategory {
  const h = hook.toLowerCase();
  if (h.includes('therapist') || h.includes('ritual') || h.includes('every morning') || h.includes('every day') || h.includes('routine'))
    return 'ritual';
  if (h.includes('forget') || h.includes('fading') || h.includes('remember her') || h.includes('remember his') || h.includes('remember him'))
    return 'forgetting';
  if (h.includes('sister') || h.includes('family') || h.includes('landlord') || h.includes('said i') || h.includes('told me') || h.includes('asked'))
    return 'conflict';
  if (h.includes('found') || h.includes('discovered') || h.includes('reddit') || h.includes('stranger') || h.includes('downloaded'))
    return 'discovery';
  if (h.includes('year') || h.includes('birthday') || h.includes('anniversary') || h.includes('mother') || h.includes('father') || h.includes('365'))
    return 'milestone';
  if (h.includes('quotes') || h.includes('photos') || h.includes('notification') || h.includes('features'))
    return 'feature';
  return 'other';
}

function getIntegrationIds(platform: string): string[] {
  const ids: string[] = [];
  const tiktokId = process.env.POSTIZ_INTEGRATION_ID_TIKTOK;
  const igId = process.env.POSTIZ_INTEGRATION_ID_INSTAGRAM;

  if (platform === 'tiktok' || platform === 'both') {
    if (tiktokId) ids.push(tiktokId);
  }
  if (platform === 'instagram' || platform === 'both') {
    if (igId) ids.push(igId);
  }
  return ids;
}

// Send a local image file to Telegram via multipart upload
async function sendLocalPhoto(chatId: number, filepath: string, caption?: string): Promise<void> {
  const fs = await import('fs');
  const path = await import('path');

  const filename = path.default.basename(filepath);
  const fileData = fs.default.readFileSync(filepath);
  const boundary = `----FormBoundary${Date.now()}`;

  const parts: Buffer[] = [];

  // chat_id field
  parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="chat_id"\r\n\r\n${chatId}\r\n`));

  // caption field
  if (caption) {
    parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="caption"\r\n\r\n${caption}\r\n`));
  }

  // photo file
  parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="photo"; filename="${filename}"\r\nContent-Type: image/jpeg\r\n\r\n`));
  parts.push(fileData);
  parts.push(Buffer.from(`\r\n--${boundary}--\r\n`));

  const body = Buffer.concat(parts);

  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'api.telegram.org',
      path: `/bot${process.env.TELEGRAM_BOT_TOKEN}/sendPhoto`,
      method: 'POST',
      family: 4,
      headers: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': body.length,
      },
      timeout: 30000,
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (!json.ok) reject(new Error(json.description || 'sendPhoto failed'));
          else resolve();
        } catch {
          reject(new Error(`Invalid response: ${data.slice(0, 100)}`));
        }
      });
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Upload timeout')); });
    req.write(body);
    req.end();
  });
}

// Export for use in server.ts to send notifications
export async function notifyNewPost(post: PostRecord): Promise<void> {
  const chatId = parseInt(process.env.TELEGRAM_AUTHORIZED_USER_ID || '0', 10);
  if (!chatId) return;

  const imagePaths = post.image_urls ? JSON.parse(post.image_urls) as string[] : [];

  // Send images first if available (local file paths)
  if (imagePaths.length > 0) {
    const fs = await import('fs');
    for (let i = 0; i < imagePaths.length; i++) {
      const filepath = imagePaths[i];
      try {
        if (fs.default.existsSync(filepath)) {
          const caption = i === 0 ? `📸 Slide ${i + 1}/${imagePaths.length} for Post #${post.id}` : `📸 Slide ${i + 1}/${imagePaths.length}`;
          await sendLocalPhoto(chatId, filepath, caption);
        } else {
          console.error(`Image file not found: ${filepath}`);
        }
      } catch (err) {
        console.error(`Failed to send image ${i + 1}:`, err);
      }
    }
  }

  // Send post details with action buttons
  await sendPostWithButtons(chatId, post);
}

export default bot;
