// Upload-Post API client
// Docs: https://api.upload-post.com
// Enables direct publishing (not drafts) with auto-trending music
//
// Required env vars:
//   UPLOADPOST_TOKEN          — Upload-Post API key
//   UPLOADPOST_USER           — Upload-Post user ID
//   UPLOADPOST_PROFILE_USERNAME — TikTok/Instagram username (default: remembranceapp)

import fs from 'fs';
import path from 'path';

const UPLOADPOST_API_URL = 'https://api.upload-post.com';
const UPLOADPOST_TOKEN = process.env.UPLOADPOST_TOKEN || '';
const UPLOADPOST_USER = process.env.UPLOADPOST_USER || '';

interface UploadPostOptions {
  caption: string;
  imageUrls: string[];  // Must be public HTTPS URLs
  platform: 'tiktok' | 'instagram' | 'both';
  profileUsername: string;
  autoAddMusic?: boolean;  // TikTok only — adds trending music automatically
}

interface UploadPostResponse {
  requestId: string;
  status: string;
  platforms: string[];
}

interface AnalyticsResponse {
  profileUsername: string;
  followers: number;
  totalImpressions: number;
  posts: Array<{
    postId: string;
    views: number;
    likes: number;
    comments: number;
    shares: number;
    postUrl: string;
    createdAt: string;
  }>;
  dailyBreakdown: Array<{
    date: string;
    impressions: number;
    views: number;
  }>;
}

async function uploadPostFetch(endpoint: string, options: RequestInit = {}): Promise<Response> {
  const url = `${UPLOADPOST_API_URL}${endpoint}`;
  return fetch(url, {
    ...options,
    headers: {
      'Authorization': `Bearer ${UPLOADPOST_TOKEN}`,
      'X-User': UPLOADPOST_USER,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
}

// Upload local images to catbox.moe for public URLs
async function ensurePublicUrls(imagePaths: string[]): Promise<string[]> {
  const urls: string[] = [];
  for (const p of imagePaths) {
    if (p.startsWith('http://') || p.startsWith('https://')) {
      urls.push(p);
      continue;
    }
    if (!fs.existsSync(p)) {
      console.error(`Image not found, skipping: ${p}`);
      continue;
    }

    // Upload to catbox.moe
    const fileData = fs.readFileSync(p);
    const filename = path.basename(p);
    const boundary = `----FormBoundary${Date.now()}`;
    const parts: Buffer[] = [];
    parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="reqtype"\r\n\r\nfileupload\r\n`));
    parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="fileToUpload"; filename="${filename}"\r\nContent-Type: image/jpeg\r\n\r\n`));
    parts.push(fileData);
    parts.push(Buffer.from(`\r\n--${boundary}--\r\n`));
    const body = Buffer.concat(parts);

    const res = await fetch('https://catbox.moe/user/api.php', {
      method: 'POST',
      headers: { 'Content-Type': `multipart/form-data; boundary=${boundary}` },
      body,
    });

    if (res.ok) {
      const url = (await res.text()).trim();
      if (url.startsWith('https://')) {
        console.log(`  📤 Uploaded: ${filename} → ${url}`);
        urls.push(url);
        continue;
      }
    }
    console.error(`Failed to upload: ${filename}`);
  }
  return urls;
}

/**
 * Publish carousel directly to TikTok and/or Instagram live feed.
 * Unlike Blotato which creates drafts, this posts directly.
 */
export async function publishDirect(options: UploadPostOptions): Promise<UploadPostResponse> {
  const publicUrls = await ensurePublicUrls(options.imageUrls);

  if (publicUrls.length === 0) {
    throw new Error('No valid images to publish. At least one image is required.');
  }

  // TikTok title: max 90 chars with hashtags
  const tiktokTitle = options.caption.length > 90
    ? options.caption.slice(0, 87) + '...'
    : options.caption;

  // Instagram caption: max 2000 chars (platform limit 2200, leave buffer)
  const instagramCaption = options.caption.length > 2000
    ? options.caption.slice(0, 1997) + '...'
    : options.caption;

  const body: Record<string, unknown> = {
    profileUsername: options.profileUsername,
    media: publicUrls.map(url => ({ type: 'image', url })),
    platforms: options.platform === 'both' ? ['tiktok', 'instagram'] : [options.platform],
    tiktok: {
      title: tiktokTitle,
      auto_add_music: options.autoAddMusic ?? true,  // Auto-trending music by default
      privacy_level: 'PUBLIC_TO_EVERYONE',
      disable_comments: false,
      disable_duet: false,
      disable_stitch: false,
      is_ai_generated: true,
    },
    instagram: {
      caption: instagramCaption,
    },
  };

  console.log(`🚀 Publishing directly to ${options.platform === 'both' ? 'TikTok + Instagram' : options.platform}...`);

  const res = await uploadPostFetch('/api/uploadposts', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Upload-Post error (${res.status}): ${errorText}`);
  }

  const result = await res.json() as UploadPostResponse;
  console.log(`✅ Published! Request ID: ${result.requestId}`);
  return result;
}

/**
 * Fetch analytics for a profile.
 */
export async function fetchAnalytics(profileUsername: string, days: number = 7): Promise<AnalyticsResponse> {
  const endDate = new Date().toISOString().split('T')[0];
  const startDate = new Date(Date.now() - days * 86400000).toISOString().split('T')[0];

  const res = await uploadPostFetch(
    `/api/analytics/${profileUsername}?start_date=${startDate}&end_date=${endDate}`
  );

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Analytics error (${res.status}): ${errorText}`);
  }

  return res.json() as Promise<AnalyticsResponse>;
}

/**
 * Fetch total impressions for a profile over a time window.
 */
export async function fetchImpressions(profileUsername: string, days: number = 7): Promise<{ totalImpressions: number; dailyBreakdown: Array<{ date: string; views: number }> }> {
  const endDate = new Date().toISOString().split('T')[0];
  const startDate = new Date(Date.now() - days * 86400000).toISOString().split('T')[0];

  const res = await uploadPostFetch(
    `/api/uploadposts/total-impressions/${profileUsername}?start_date=${startDate}&end_date=${endDate}`
  );

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Impressions error (${res.status}): ${errorText}`);
  }

  return res.json() as Promise<{ totalImpressions: number; dailyBreakdown: Array<{ date: string; views: number }> }>;
}

export function isUploadPostConfigured(): boolean {
  return Boolean(UPLOADPOST_TOKEN && UPLOADPOST_USER);
}
