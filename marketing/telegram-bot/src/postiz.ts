// Blotato API client (replaces Postiz)
// Docs: https://help.blotato.com/api

import fs from 'fs';
import path from 'path';

const BLOTATO_API_URL = 'https://backend.blotato.com/v2';
const BLOTATO_API_KEY = process.env.BLOTATO_API_KEY || '';
const FAL_API_KEY = process.env.FAL_API_KEY || '';

// Upload a local file to catbox.moe and get a public URL
async function uploadToPublicUrl(filepath: string): Promise<string> {
  const fileData = fs.readFileSync(filepath);
  const filename = path.basename(filepath);

  const boundary = `----FormBoundary${Date.now()}`;
  const parts: Buffer[] = [];

  // reqtype field
  parts.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="reqtype"\r\n\r\nfileupload\r\n`));

  // file field
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
    if (url.startsWith('https://')) return url;
  }

  throw new Error(`Failed to upload image to public URL: ${filepath}`);
}

// Convert local file paths to public URLs
async function resolveImageUrls(paths: string[]): Promise<string[]> {
  const urls: string[] = [];
  for (const p of paths) {
    if (p.startsWith('http://') || p.startsWith('https://')) {
      urls.push(p);
    } else if (fs.existsSync(p)) {
      console.log(`Uploading ${path.basename(p)} for public URL...`);
      const url = await uploadToPublicUrl(p);
      console.log(`  → ${url}`);
      urls.push(url);
    } else {
      console.error(`Image not found, skipping: ${p}`);
    }
  }
  return urls;
}

// BLOCKED accounts — personal/business, NOT Remembrance. Never post to these.
const BLOCKED_ACCOUNT_IDS = new Set(['20433', '27973', '24997', '13433', '10585']);

function validateAccountId(accountId: string): void {
  if (BLOCKED_ACCOUNT_IDS.has(accountId)) {
    throw new Error(`BLOCKED: Account ${accountId} is a personal/business account, not Remembrance. Aborting.`);
  }
}

interface BlotatoPostOptions {
  caption: string;
  imageUrls: string[];
  tiktokAccountId?: string;
  instagramAccountId?: string;
  isDraft?: boolean;
}

interface BlotatoResponse {
  postSubmissionId: string;
}

async function blotatoFetch(endpoint: string, options: RequestInit = {}): Promise<Response> {
  const url = `${BLOTATO_API_URL}${endpoint}`;
  return fetch(url, {
    ...options,
    headers: {
      'blotato-api-key': BLOTATO_API_KEY,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
}

async function publishToTikTok(options: BlotatoPostOptions): Promise<BlotatoResponse | null> {
  const accountId = options.tiktokAccountId || process.env.BLOTATO_TIKTOK_ACCOUNT_ID;
  if (!accountId) return null;
  validateAccountId(accountId);

  const body = {
    post: {
      accountId,
      content: {
        text: options.caption,
        mediaUrls: options.imageUrls,
        platform: 'tiktok',
      },
      target: {
        targetType: 'tiktok',
        privacyLevel: 'PUBLIC_TO_EVERYONE',
        disabledComments: false,
        disabledDuet: false,
        disabledStitch: false,
        isBrandedContent: false,
        isYourBrand: false,
        isAiGenerated: true,
        isDraft: options.isDraft ?? true,
      },
    },
  };

  const res = await blotatoFetch('/posts', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Blotato TikTok error (${res.status}): ${errorText}`);
  }

  return res.json() as Promise<BlotatoResponse>;
}

async function publishToInstagram(options: BlotatoPostOptions): Promise<BlotatoResponse | null> {
  const accountId = options.instagramAccountId || process.env.BLOTATO_INSTAGRAM_ACCOUNT_ID;
  if (!accountId) return null;
  validateAccountId(accountId);

  const body = {
    post: {
      accountId,
      content: {
        text: options.caption,
        mediaUrls: options.imageUrls,
        platform: 'instagram',
      },
      target: {
        targetType: 'instagram',
      },
    },
  };

  const res = await blotatoFetch('/posts', {
    method: 'POST',
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Blotato Instagram error (${res.status}): ${errorText}`);
  }

  return res.json() as Promise<BlotatoResponse>;
}

export async function createPostizDraft(options: {
  caption: string;
  imageUrls: string[];
  integrationIds: string[];
}): Promise<{ id: string }> {
  const results: string[] = [];

  // Resolve local file paths to public URLs for Blotato
  const publicUrls = await resolveImageUrls(options.imageUrls);

  // Post to TikTok as draft (requires at least 1 image/video)
  if (publicUrls.length > 0) {
    try {
      const tikTokResult = await publishToTikTok({
        caption: options.caption,
        imageUrls: publicUrls,
        isDraft: true,
      });
      if (tikTokResult) results.push(`tiktok:${tikTokResult.postSubmissionId}`);
    } catch (err) {
      console.error('TikTok post failed:', err);
      throw err;
    }
  } else {
    console.log('Skipping TikTok — no images attached');
  }

  // Post to Instagram (requires at least 1 image)
  if (publicUrls.length > 0) {
    try {
      const igResult = await publishToInstagram({
        caption: options.caption,
        imageUrls: publicUrls,
      });
      if (igResult) results.push(`instagram:${igResult.postSubmissionId}`);
    } catch (err) {
      console.error('Instagram post failed:', err);
      // Don't throw — TikTok might have succeeded
      if (results.length === 0) throw err;
    }
  } else {
    console.log('Skipping Instagram — no images attached');
  }

  if (results.length === 0 && publicUrls.length === 0) {
    throw new Error('Cannot publish — TikTok and Instagram both require images. Add images and try again.');
  }

  return { id: results.join(',') };
}

export function isPostizConfigured(): boolean {
  return Boolean(BLOTATO_API_KEY);
}

// Fetch connected account IDs from Blotato
export async function listAccounts(): Promise<Array<{ id: string; platform: string; name: string }>> {
  const res = await blotatoFetch('/users/me/accounts');
  if (!res.ok) {
    throw new Error(`Failed to list accounts: ${res.status}`);
  }
  return res.json() as Promise<Array<{ id: string; platform: string; name: string }>>;
}
