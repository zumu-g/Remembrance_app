import type { PostRecord } from '../types.js';

export function formatPostPreview(post: PostRecord): string {
  const statusEmoji: Record<string, string> = {
    pending: '🟡',
    approved: '🟢',
    rejected: '🔴',
    published: '🚀',
    failed: '❌',
  };

  const emoji = statusEmoji[post.status] || '⚪';
  const images = post.image_urls ? JSON.parse(post.image_urls) as string[] : [];
  const imageCount = images.length;

  let text = `${emoji} <b>Post #${post.id}</b>\n\n`;
  text += `<b>Hook:</b>\n${escapeHtml(post.hook)}\n\n`;
  text += `<b>Caption:</b>\n${escapeHtml(post.caption)}\n\n`;

  if (post.audio_direction) {
    text += `🎵 <b>Audio:</b> ${escapeHtml(post.audio_direction)}\n`;
  }

  if (imageCount > 0) {
    text += `📸 <b>Images:</b> ${imageCount} slides\n`;
  }

  if (post.platform) {
    text += `📱 <b>Platform:</b> ${post.platform}\n`;
  }

  if (post.notes) {
    text += `\n📝 <b>Notes:</b> ${escapeHtml(post.notes)}\n`;
  }

  if (post.reviewer_note) {
    text += `\n💬 <b>Review note:</b> ${escapeHtml(post.reviewer_note)}\n`;
  }

  return text;
}

export function formatPostSummary(post: PostRecord): string {
  const statusEmoji: Record<string, string> = {
    pending: '🟡',
    approved: '🟢',
    rejected: '🔴',
    published: '🚀',
    failed: '❌',
  };

  const emoji = statusEmoji[post.status] || '⚪';
  const hookPreview = post.hook.length > 50 ? post.hook.slice(0, 50) + '...' : post.hook;
  return `${emoji} <b>#${post.id}</b> — ${escapeHtml(hookPreview)}`;
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
