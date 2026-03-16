import { Telegraf, Markup } from 'telegraf';
import type { Context } from 'telegraf';
import https from 'https';
import { authMiddleware } from './utils/auth.js';
import { formatPostPreview, formatPostSummary } from './utils/format.js';
import * as db from './db.js';
import { createPostizDraft, isPostizConfigured } from './postiz.js';
import type { AwaitingInput, PostRecord } from './types.js';

// Custom HTTPS agent with hardcoded IP for api.telegram.org
// autoSelectFamily is disabled globally in index.ts
import dns from 'dns';
const telegramAgent = new https.Agent({
  keepAlive: true,
  keepAliveMsecs: 10000,
  family: 4,
  lookup: (hostname: string, optionsOrCb: any, maybeCb?: any) => {
    const cb = typeof optionsOrCb === 'function' ? optionsOrCb : maybeCb;
    if (hostname === 'api.telegram.org' && typeof cb === 'function') {
      cb(null, '149.154.166.110', 4);
      return;
    }
    if (maybeCb) {
      dns.lookup(hostname, optionsOrCb, maybeCb);
    } else {
      dns.lookup(hostname, optionsOrCb);
    }
  },
} as any);

const bot = new Telegraf(process.env.TELEGRAM_BOT_TOKEN!, {
  telegram: { agent: telegramAgent },
});

// Track conversation state for edits/rejections
const awaitingInput = new Map<number, AwaitingInput>();

// Prevent double-processing of approve actions
const approvalInProgress = new Set<number>();

// Safely parse image_urls JSON, returning empty array on failure
function safeParseImageUrls(raw: string | null | undefined): string[] {
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

// Auth middleware — only respond to authorized user
bot.use(authMiddleware);

// /start command
bot.start((ctx) => {
  ctx.reply(
    '🟢 <b>Remembrance Marketing Bot</b>\n\n' +
    'I help you review and approve social media posts.\n\n' +
    '<b>Commands:</b>\n' +
    '/next — Submit next post from bank now\n' +
    '/pending — View pending posts\n' +
    '/stats — Post counts by status\n' +
    '/history — Recent posts\n' +
    '/report — Log post metrics\n' +
    '/insights — See what\'s working\n' +
    '/help — Show this message\n\n' +
    'Posts auto-submit daily at 9:00 AM. Nothing publishes without your approval.',
    { parse_mode: 'HTML' }
  );
});

bot.help((ctx) => {
  ctx.reply(
    '<b>Commands:</b>\n' +
    '/next — Submit next post from bank now\n' +
    '/pending — View all posts waiting for approval\n' +
    '/stats — See counts by status\n' +
    '/history — Last 10 posts\n' +
    '/post_ID — View a specific post (e.g. /post_3)\n' +
    '/report — Log metrics (e.g. /report 3 tiktok 50000 2300 145 890)\n' +
    '/insights — Performance analysis and recommendations\n\n' +
    'Posts auto-submit daily at 9:00 AM.\n' +
    'When a post arrives, tap:\n' +
    '✅ <b>Approve</b> — sends to Blotato as DRAFT (you publish manually)\n' +
    '❌ <b>Reject</b> — asks for a reason\n' +
    '✏️ <b>Edit</b> — modify hook or caption',
    { parse_mode: 'HTML' }
  );
});

// /next — manually submit the next post from the bank
bot.command('next', async (ctx) => {
  const { submitNextPost } = await import('./scheduler.js');
  await ctx.reply('Submitting next post from the bank...');
  try {
    const result = await submitNextPost();
    if (!result.submitted) {
      await ctx.reply(result.message);
    }
    // If submitted, notifyNewPost already sent the approval message
  } catch (err) {
    await ctx.reply(`Failed: ${err instanceof Error ? err.message : 'Unknown error'}`);
  }
});

// /pending — list pending posts
bot.command('pending', (ctx) => {
  const posts = db.getPendingPosts();
  if (posts.length === 0) {
    return ctx.reply('No pending posts. 🎉');
  }

  const lines = posts.map((p) => formatPostSummary(p));
  ctx.reply(
    `<b>${posts.length} pending post${posts.length > 1 ? 's' : ''}:</b>\n\n${lines.join('\n')}`,
    { parse_mode: 'HTML' }
  );
});

// /stats — counts by status
bot.command('stats', (ctx) => {
  const counts = db.getStatusCounts();
  ctx.reply(
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
bot.command('history', (ctx) => {
  const posts = db.getRecentPosts(10);
  if (posts.length === 0) {
    return ctx.reply('No posts yet.');
  }

  const lines = posts.map((p) => formatPostSummary(p));
  ctx.reply(
    `<b>Recent posts:</b>\n\n${lines.join('\n')}`,
    { parse_mode: 'HTML' }
  );
});

// /post_ID — view specific post
bot.hears(/^\/post_(\d+)$/, (ctx) => {
  const id = parseInt(ctx.match[1], 10);
  const post = db.getPost(id);
  if (!post) {
    return ctx.reply(`Post #${id} not found.`);
  }

  const text = formatPostPreview(post);
  if (post.status === 'pending') {
    ctx.reply(text, {
      parse_mode: 'HTML',
      ...Markup.inlineKeyboard([
        [
          Markup.button.callback('✅ Approve', `approve_${post.id}`),
          Markup.button.callback('❌ Reject', `reject_${post.id}`),
        ],
        [
          Markup.button.callback('✏️ Edit Hook', `edit_hook_${post.id}`),
          Markup.button.callback('✏️ Edit Caption', `edit_caption_${post.id}`),
        ],
      ]),
    });
  } else {
    ctx.reply(text, { parse_mode: 'HTML' });
  }
});

// /report — log metrics for a post
// Usage: /report 3 tiktok 50000 2300 145 890
// Format: /report <post_id> <platform> <views> <likes> <comments> <shares>
bot.command('report', (ctx) => {
  const text = ctx.message.text;
  const parts = text.split(/\s+/).slice(1); // remove /report

  if (parts.length < 4) {
    return ctx.reply(
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
  const views = parseInt(parts[2], 10);
  const likes = parseInt(parts[3], 10);
  const comments = parseInt(parts[4], 10);
  const shares = parseInt(parts[5], 10);

  if (isNaN(postId) || isNaN(views) || isNaN(likes)) {
    return ctx.reply('Invalid numbers. Post ID, views, and likes must be valid numbers.');
  }

  if (views < 0 || likes < 0 || (comments < 0 && !isNaN(comments)) || (shares < 0 && !isNaN(shares))) {
    return ctx.reply('Metric values must be non-negative.');
  }

  const validPlatforms = ['tiktok', 'instagram', 'facebook', 'twitter', 'youtube'];
  if (!validPlatforms.includes(platform)) {
    return ctx.reply(
      `Invalid platform: "${platform}".\nValid platforms: ${validPlatforms.join(', ')}`
    );
  }

  const post = db.getPost(postId);
  if (!post) {
    return ctx.reply(`Post #${postId} not found.`);
  }

  if (post.status !== 'published' && post.status !== 'approved') {
    return ctx.reply(`Post #${postId} is "${post.status}" — metrics can only be logged for published or approved posts.`);
  }

  db.recordMetrics(postId, platform, { views, likes, comments: comments || 0, shares: shares || 0 });

  // Auto-categorize hook if not already done
  if (!(post as any).hook_category || (post as any).hook_category === 'other') {
    const category = autoDetectCategory(post.hook);
    db.setHookCategory(postId, category);
  }

  ctx.reply(
    `📊 Metrics recorded for Post #${postId} on ${platform}:\n` +
    `👁 ${views.toLocaleString()} views\n` +
    `❤️ ${likes.toLocaleString()} likes\n` +
    `💬 ${comments.toLocaleString()} comments\n` +
    `🔄 ${shares.toLocaleString()} shares`
  );
});

// /insights — show what's working
bot.command('insights', (ctx) => {
  const topPosts = db.getTopPosts(5);
  const catPerf = db.getCategoryPerformance();

  if (topPosts.length === 0) {
    return ctx.reply('No metrics recorded yet. Use /report to log post performance.');
  }

  let text = '📈 <b>Performance Insights</b>\n\n';

  // Top posts
  text += '<b>Top Posts:</b>\n';
  topPosts.forEach((p, i) => {
    const hookShort = p.hook.length > 45 ? p.hook.slice(0, 45) + '...' : p.hook;
    text += `${i + 1}. #${p.id} — ${p.total_views.toLocaleString()} views\n`;
    text += `   "${hookShort}"\n`;
  });

  // Category performance
  if (catPerf.length > 0) {
    text += '\n<b>Hook Category Performance:</b>\n';
    catPerf.forEach(c => {
      const bar = '█'.repeat(Math.min(Math.round(c.avg_views / (catPerf[0].avg_views || 1) * 10), 10));
      text += `${c.hook_category}: ${bar} ${c.avg_views.toLocaleString()} avg views (${c.post_count} posts)\n`;
    });
  }

  // Recommendations
  if (catPerf.length >= 2) {
    const best = catPerf[0];
    const worst = catPerf[catPerf.length - 1];
    text += `\n<b>Recommendation:</b>\n`;
    text += `Double down on <b>${best.hook_category}</b> hooks (${best.avg_views.toLocaleString()} avg views).\n`;
    if (worst.avg_views < best.avg_views * 0.3) {
      text += `Consider retiring <b>${worst.hook_category}</b> hooks (${worst.avg_views.toLocaleString()} avg views).\n`;
    }
  }

  // Viral threshold check
  const viralPosts = topPosts.filter(p => p.total_views >= 50000);
  if (viralPosts.length > 0) {
    text += `\n🔥 <b>${viralPosts.length} post(s) over 50K views!</b> Create variations of:\n`;
    viralPosts.forEach(p => {
      text += `• #${p.id}: "${p.hook.slice(0, 50)}..."\n`;
    });
  }

  ctx.reply(text, { parse_mode: 'HTML' });
});

// --- Inline keyboard callbacks ---

// Approve
bot.action(/^approve_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const post = db.getPost(id);
  if (!post) {
    return ctx.answerCbQuery('Post not found.');
  }

  if (post.status !== 'pending' && post.status !== 'failed') {
    return ctx.answerCbQuery(`Post already ${post.status}.`);
  }

  if (approvalInProgress.has(id)) {
    return ctx.answerCbQuery('Approval already in progress...');
  }
  approvalInProgress.add(id);

  try {
  db.updateStatus(id, 'approved');
  await ctx.answerCbQuery('Approved! ✅');
  await ctx.editMessageText(
    formatPostPreview({ ...post, status: 'approved' }),
    { parse_mode: 'HTML' }
  );

  // Try to send to Postiz
  if (isPostizConfigured()) {
    try {
      const imageUrls = safeParseImageUrls(post.image_urls);
      const integrationIds = getIntegrationIds(post.platform);

      const result = await createPostizDraft({
        caption: `${post.hook}\n\n${post.caption}`,
        imageUrls,
        integrationIds,
      });

      db.setPostizResult(id, result.id, JSON.stringify(result));
      await ctx.reply(
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
      await ctx.reply(
        `❌ Failed to send Post #${id} to Blotato: ${errorMsg}\n\nTap Retry to try again.`,
        Markup.inlineKeyboard([
          Markup.button.callback('🔄 Retry', `approve_${id}`),
        ])
      );
    }
  } else {
    await ctx.reply(`✅ Post #${id} approved. Blotato not configured — publish manually.`, { parse_mode: 'HTML' });
  }
  } finally {
    approvalInProgress.delete(id);
  }
});

// Reject — ask for reason
bot.action(/^reject_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'reject_reason' });
  await ctx.answerCbQuery('Send me the reason for rejection.');
  await ctx.reply(`Why are you rejecting Post #${id}? Reply with your reason:`, { reply_markup: { force_reply: true } });
});

// Edit hook
bot.action(/^edit_hook_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'hook' });
  await ctx.answerCbQuery('Send me the new hook.');
  await ctx.reply(`Send the new hook for Post #${id}:`, { reply_markup: { force_reply: true } });
});

// Edit caption
bot.action(/^edit_caption_(\d+)$/, async (ctx) => {
  const id = parseInt(ctx.match![1], 10);
  const chatId = ctx.chat?.id;
  if (!chatId) return;

  awaitingInput.set(chatId, { postId: id, field: 'caption' });
  await ctx.answerCbQuery('Send me the new caption.');
  await ctx.reply(`Send the new caption for Post #${id}:`, { reply_markup: { force_reply: true } });
});

// Handle text input for edits and rejections
bot.on('text', (ctx) => {
  const chatId = ctx.chat.id;
  const pending = awaitingInput.get(chatId);

  if (!pending) return;

  const { postId, field } = pending;
  const text = ctx.message.text;
  awaitingInput.delete(chatId);

  const post = db.getPost(postId);
  if (!post) {
    return ctx.reply(`Post #${postId} not found.`);
  }

  if (field === 'reject_reason') {
    db.setReviewerNote(postId, text);
    ctx.reply(`🔴 Post #${postId} rejected.\nReason: ${text}`);
    return;
  }

  if (field === 'metrics') return; // handled separately

  // Edit hook or caption
  db.updateField(postId, field as 'hook' | 'caption', text);
  const updated = db.getPost(postId)!;
  ctx.reply(formatPostPreview(updated), {
    parse_mode: 'HTML',
    ...Markup.inlineKeyboard([
      [
        Markup.button.callback('✅ Approve', `approve_${postId}`),
        Markup.button.callback('❌ Reject', `reject_${postId}`),
      ],
      [
        Markup.button.callback('✏️ Edit Hook', `edit_hook_${postId}`),
        Markup.button.callback('✏️ Edit Caption', `edit_caption_${postId}`),
      ],
    ]),
  });
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

// Export for use in server.ts to send notifications
export async function notifyNewPost(post: PostRecord): Promise<void> {
  const chatId = parseInt(process.env.TELEGRAM_AUTHORIZED_USER_ID || '0', 10);
  if (!chatId) return;

  const imageUrls = safeParseImageUrls(post.image_urls);

  // Send images first if available
  if (imageUrls.length > 0) {
    try {
      if (imageUrls.length === 1) {
        await bot.telegram.sendPhoto(chatId, imageUrls[0]);
      } else {
        // Send as media group (album) — max 10 per group
        const mediaGroup = imageUrls.slice(0, 10).map((url, i) => ({
          type: 'photo' as const,
          media: url,
          ...(i === 0 ? { caption: `📸 ${imageUrls.length} slides for Post #${post.id}` } : {}),
        }));
        await bot.telegram.sendMediaGroup(chatId, mediaGroup);
      }
    } catch (err) {
      console.error('Failed to send images:', err);
    }
  }

  // Send post details with action buttons
  const text = formatPostPreview(post);
  try {
    const msg = await bot.telegram.sendMessage(chatId, text, {
      parse_mode: 'HTML',
      ...Markup.inlineKeyboard([
        [
          Markup.button.callback('✅ Approve', `approve_${post.id}`),
          Markup.button.callback('❌ Reject', `reject_${post.id}`),
        ],
        [
          Markup.button.callback('✏️ Edit Hook', `edit_hook_${post.id}`),
          Markup.button.callback('✏️ Edit Caption', `edit_caption_${post.id}`),
        ],
      ]),
    });

    db.setTelegramIds(post.id, msg.message_id, chatId);
  } catch (err) {
    console.error(`Failed to send notification for post #${post.id}:`, err);
  }
}

export default bot;
